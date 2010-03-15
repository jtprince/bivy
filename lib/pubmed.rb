require 'open-uri'
require 'rexml/document'
require 'iconv'
require 'citation'

# given the html page where the display is specified as xml
# extracts out the requested pieces
class PubMed < Citation::Article

  attr_accessor :pmid

  # also takes pmid=hash of values to set
  def initialize(pmid=nil, identifier=nil)
    @quotes = []
    if pmid.is_a? Hash
      ########## THIS WHOLE MESS SHOULD BE ENCAPSULATED/INHERITED! but can't get
      #inheritance with authors= working for some reason
      @authors = []
      pmid.each do |k,v|
        if k == 'authors'
          v.each do |auth|
          if auth.is_a? String
            authors.push( Citation::Author.from_s(auth) )
          else
            authors.push( auth )
          end
          end
        else
          send("#{k}=".to_sym, v)
        end
      end
      ############ <-- END MESS
    else
      @authors = []
      @pmid = pmid
      @bibtype = :article
      if pmid
        begin
          url = query_builder(pmid)
          xml_string = get_xml(url)
          extract_attrs_from_xml(xml_string)
        end
      end
      if identifier
        @ident = identifier
      else
        if pmid
          @ident = create_id
        end
      end
    end
  end


  # returns xml from online (parses html output).  No internet connection gives nil
  def get_xml(query)
    handle = open(query)
    xml = handle.read
    handle.close
    xml
  end

  # first author's last name + year collapsing any spaces
  def create_id
    (@authors[0].last.to_s + @year.to_s).sub(/\s+/,'')
  end

  def inspect
    st = "<#{self.class}:##{self.__id__} "
    st << ( %w(authors ident quotes abstract journal_medline title year month vol issue pages).reject{|v| (v == :authors || v == :url)}.push(:bibtype).map {|v| ":#{v}=>#{send(v).inspect}"}.join(", ") )
    st << " @authors=[#{authors.map{|g| g.inspect }.join(", ")}]"
    st << ">"
    st
  end


  # Builds the query to ask for a citation given a pubmed id
  # valid types are xml, medline, (...need to figure out others)
  private

  # returns pubmed query based on pubmed id with xml as the output type.  Note that the xml is embedded in the page's html.
  #   Example: http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=xml&list_uids=14654843&query_hl=6
  #

  # http://www.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=Pubmed&id=11283582&rettype=xml
  def query_builder(pmid)
    type = 'xml'
    #base_url = 'http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?' 
    base_url = 'http://www.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?'
    cgi_params = ['db=Pubmed', "rettype=#{type}", 'retmode=text', "id=#{pmid}"].join('&')
    base_url + cgi_params
  end

  # get an xml element's text according to its path (assumes single element)
  def get_e_text(element, path)
    #element = @xml if element == nil
    els = element.elements.to_a(path)
    if els.size > 1
      raise "More than one #{path}!"
    elsif els.size == 0
      return nil
    else
      begin
        text = els[0].get_text.value
        return text
      rescue NoMethodError
        return nil
      end
    end
  end

  def get_author_list(xml)
    auths = xml.elements.to_a("//PubmedArticle/MedlineCitation/Article/AuthorList/Author")
    authors = auths.collect do |auth|
      last_name = get_e_text(auth, "LastName")
      initials = get_e_text(auth, "Initials")
      ## I think we are getting author names out in UTF-8 which is not being interpreted properly.  
      ## Transform characters into something more standard, eh
      begin
        last_name = Iconv.new('iso-8859-15', 'utf-8').iconv(last_name)
      rescue Iconv::IllegalSequence
        last_name = "**BADCHARS**"
      end
      begin
        initials = Iconv.new('iso-8859-15', 'utf-8').iconv(initials)
      rescue Iconv::IllegalSequence
        initials = "**BADINITS**"
      end
      Citation::Author.new(last_name, initials)
    end
  end

  # if they are not set from the xml, tries to set from hashes or raises a
  # RuntimeError
  def set_journals_or_die(journal_medline)
    error_messages = []
    unless @journal_iso
      if Journal::Medline_to_ISO.key?(journal_medline)
        @journal_iso = Journal::Medline_to_ISO[journal_medline]
      else
        error_messages << "Expect key for '#{journal_medline}' in Journal::Medline_to_ISO"
        error_messages << "(alter file journal/medline_to_iso.yaml)"
      end
    end

    unless @journal_full
      if Journal::Medline_to_Full.key?(journal_medline)
        @journal_full = Journal::Medline_to_Full[journal_medline]
      else
        error_messages << "Expect key for '#{journal_medline}' in Journal::Medline_to_Full"
        error_messages << "(alter file journal/medline_to_full.yaml)"
      end

    end
    if error_messages.size > 0
      label = "******************************************************************"
      error_messages.unshift label
      error_messages.unshift ''
      error_messages << "Aborting!"
      error_messages << label
      error_messages << ''
      raise(error_messages.join("\n"))
    end

  end

  def extract_attrs_from_xml(xml_string)
    xml = REXML::Document.new xml_string
    art = "//PubmedArticle/MedlineCitation/Article/"
    @title = get_e_text(xml, art + "ArticleTitle")
    #puts "TITLE: "
    #puts @title
    @journal_medline = get_e_text(xml, "//PubmedArticle/MedlineCitation/MedlineJournalInfo/MedlineTA")
    @journal_full = get_e_text(xml, art + 'Journal/Title')
    @journal_iso = get_e_text(xml, art + 'Journal/ISOAbbreviation')
    set_journals_or_die(@journal_medline)

    #puts "THREE JOURNALS"
    #puts @journal_medline 
    #puts @journal_full 
    #puts @journal_iso 
    @authors = get_author_list(xml)
    iss = art + "Journal/JournalIssue/"
    pdate = iss + "PubDate/"
    @vol = get_e_text(xml, iss + "Volume")
    @issue = get_e_text(xml, iss + "Issue")
    @year = get_e_text(xml, pdate + "Year")
    @month = get_e_text(xml, pdate + "Month")
    @pages = get_e_text(xml, art + "Pagination/MedlinePgn") || '[Epub]'
    @abstract = get_e_text(xml, art + "Abstract/AbstractText") || ''
  end

  # unnecessary now..
  def pubmed_extract_xml_from_html(string)
    html = ""
    if string =~ /<dd><pre>(.*)<\/pre><\/dd>/m
      html = $1
      html.gsub!(/<\/?font.*?>/, '')
      html.gsub!(/<\/?b.*?>/, '')
      html.gsub!(/\&lt;/, '<')
      html.gsub!(/\&gt;/, '>')
      html.gsub!(/\&quot;/, '"')
    end 
    html 
  end


end

