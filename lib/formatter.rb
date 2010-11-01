require 'citation'
require 'pubmed'
require 'set'
require 'ooffice'

class Formatter

  FindStartCitation = '#['
  FindEndCitation = ']'
  SplitCitations = ','
  StartNumbering = 1
  ReplaceWith = 'X'


  # later we can figure out the little trick to do this on the fly
  # the letter for the entry being added
  ArSizeToLetter = {
    1 => 'b',
    2 => 'c',
    3 => 'd',
    4 => 'e',
    5 => 'f',
    6 => 'g',
    7 => 'h',
    8 => 'i',
    9 => 'j',
    10 => 'k',
  }

  # outputs an html string and modifies the document (only .odt files
  # currently)
  # biblio is a yaml file
  # creates .cit.odt file with citations replaced
  def create_bibliography(document, biblio, options={})
    bib = Bibliography.from_yaml(biblio)
    new_document = document.sub(/\.odt$/, '.cit.odt')

    ordered_cit_ids = nil
    if options[:bib] == :mla
      OpenOffice.new.modify_content(document, new_document) do |xml| 
        if cp = options[:cit_pos]
          xml = reposition_citations(xml, cp)
        end
        # this may actually change the year on some bibs
        (new_xml, ordered_cit_ids) = replace_citations_mla(xml, bib)
        new_xml
      end
      unless ordered_cit_ids ; abort "Couldn't get citations" end
      bib.select_by_id!(ordered_cit_ids)
    else
      OpenOffice.new.modify_content(document, new_document) do |xml| 
        if cp = options[:cit_pos]
          xml = reposition_citations(xml, cp)
        end
        if options[:bracket]
          (new_xml, ordered_cit_ids) = replace_citations_numerically(xml, FindStartCitation, FindEndCitation, SplitCitations, StartNumbering, ' [X]')
          # (string, find_start_citation='#[', find_end_citation=']', split_citations=',', start_numbering=1, replace_with='X')
        else
          (new_xml, ordered_cit_ids) = replace_citations_numerically(xml)
        end
        new_xml
      end
      unless ordered_cit_ids ; abort "Couldn't get citations" end
      bib.select_by_id!(ordered_cit_ids)
    end
    bib
  end

  # moves all citations following '.' or ',' to desired position
  # position = :before or :after
  #
  def reposition_citations(xml, position)
    # search<text:span text:style-name="T29">#[Keller2002]</text:span>,
    # --> search,<text:span text:style-name="T29">#[Keller2002]</text:span>
    #  human samples<text:span text:style-name="T29">#[Qian2005]</text:span>.
    # -->  human samples.<text:span text:style-name="T29">#[Qian2005]</text:span>
    #  OR human samples#[Qian2005].
    # -->  human samples.#[Qian2005]
    case position
    when :after
      xml = xml.gsub(/(#\[.*?\])([\.\,])/) do |md|
        $2 + $1
      end
      xml.gsub(/(<[^\/][^<]+>)(#\[.*?\])(<\/.*?>)([\.\,])/) do |md|
        $4 + $1 + $2 + $3
      end
    when :before
      xml = xml.gsub(/([\.\,])(#\[.*?\])/) do |md|
        $2 + $1
      end
      xml.gsub(/([\.\,])(<[^\/][^<]+>)(#\[.*?\])(<\/.*?>)/) do |md|
        $2 + $3 + $4 + $1
      end

    end
  end

  def to_mla_ref(citation)
    if citation.bibtype == :webpage
      citation.title
    else
      author_bit = 
        if citation.authors.is_a? String  # just use first listed thing for now
          citation.authors.split(/\s+/).first
        else # assuming array
          aa = citation.authors
          case aa.size
          when 1 
            aa[0].last
          when 2 
            aa[0].last + ' and ' + aa[1].last
            #aa[0].last + ' &amp; ' + aa[1].last   ## using an ampersand
          else
            aa[0].last + ' et al.'
          end
        end
      author_bit + ', ' + "#{citation.year}"
    end
  end

  # order can be :alphabetical or :as_is
  # warning: may change the year on some bib citations!
  def replace_citations_mla(string, bib, start_citation='#[', end_citation=']', split_citations=',', order=:alphabetical)
    regex_string = Regexp.escape(start_citation) + '(.*?)' + Regexp.escape(end_citation)
    id_to_cit = {}
    bib.citations.each do |cit|
      id_to_cit[cit.ident] = cit
    end

    # This is a hash that helps to distinguish between citations with the same
    # mla_ref.
    mla_ref_to_cits = Hash.new {|h,k| h[k] = [] }
    id_to_mla_ref = {}  # from the citation id to the mla_ref
    # First pass to determine if some author/year combos are duplicated
    # in which case they will be yeara and yearb and so on (2004a).
    string.scan(/#{regex_string}/) do
      refs = $1.split(split_citations)
      refs.each do |ref|
        unless id_to_cit.key?(ref)
          puts "*************************************"
          puts "* No citation for: #{ref}"
          puts "*************************************"
          exit
        end
        citation = id_to_cit[ref]
        mla_ref = to_mla_ref(citation)
        ## alter mla_ref if necessary
        if mla_ref_to_cits.key?(mla_ref)
          if id_to_mla_ref.key?(citation.ident)
            # this reference already has already been seen, do nothing
          else  # conflict
            ar = mla_ref_to_cits[mla_ref]
            if ar.size == 1
              # change mla_ref
              id_to_mla_ref[ar[0].ident] = mla_ref + 'a' # new mla_ref
              # change the citation year for bibliography
              id_to_cit[ar[0].ident].year << 'a'
            end
            letter = ArSizeToLetter[ar.size]
            new_mla_ref = mla_ref + letter
            # put in a modified mla_ref
            id_to_mla_ref[citation.ident] = new_mla_ref
            # change the year in bib
            id_to_cit[citation.ident].year << letter
            mla_ref_to_cits[mla_ref].push(citation)
          end
        else # first mla_ref of its kind
          mla_ref_to_cits[mla_ref].push(citation)
          id_to_mla_ref[ref] = mla_ref
        end
      end
    end

    # second pass to create actual citation with updated mla_refs
    new_string = string.gsub(/#{regex_string}/) do
      refs = $1.split(split_citations)
      mla_refs = refs.map do |ref|
        id_to_mla_ref[id_to_cit[ref].ident]
      end
      to_mla_citation_string(mla_refs)
    end

    # final list of citations will be ordered by ordering the mla_ref_to_cits
    # keys (the years are already ordered a,b,c... if necessary)
    
    ordered_cit_ids = []
    sorted_mla_refs = mla_ref_to_cits.keys.sort_by {|k| k.downcase }

    sorted_mla_refs.each do |mla_ref|
      cits = mla_ref_to_cits[mla_ref]
      ordered_cit_ids.push( *(cits.map {|cit| cit.ident }) )
    end
    [new_string, ordered_cit_ids]
  end

  # takes a string of mla_refs and spits out the final guy
  def to_mla_citation_string(mla_refs)
    " (#{mla_refs.join('; ')})"
  end


  # replace citations will take any string and replace any references
  # according to find_start_citation, find_end_citation and split_citations
  # returns [string, citation_hash]
  # string is the substituted string, hash is hashed by reference and gives
  # replace_with uses the formatting of the string given to format the
  # citation.  The 'X' is the numeric citation.  So, X is just the number and
  # '[X]' would be a bracketed number.
  # the citation number
  # (see tests for examples) 
  def replace_citations_numerically(string, find_start_citation=FindStartCitation, find_end_citation=FindEndCitation, split_citations=SplitCitations, start_numbering=StartNumbering, replace_with=ReplaceWith)
    (before_X, after_X) = replace_with.split('X').map(&:to_s)
    before_X ||= ''
    after_X ||= ''
    cits = {}
    regex_string = Regexp.escape(find_start_citation) + '(.*?)' + Regexp.escape(find_end_citation)

    ref_cnt = start_numbering
    new_string = string.gsub(/#{regex_string}/) do
      refs = $1.split(split_citations)
      cit_list = refs.map do |ref|
        unless cits.key? ref 
          cits[ref] = ref_cnt
          ref_cnt += 1
        end
        cits[ref]  # <- no formatting at this point
      end
      before_X + cit_string(cit_list) + after_X
    end
    ordered_cits = cits.map {|k,v| [v,k]}.sort.map {|ar| ar[1] }
    [new_string, ordered_cits]
  end

  # given an array of citations, generate the string for their citation
  # 
  # e.g. if [10, 11, 12], string should be '10-12'
  # e.g. if [4, 13, 12, 17] string should be '4,12-13,17' 
  def cit_string(cit_num_array)
    # Single citation:
    if cit_num_array.size == 0
      return ''
    elsif cit_num_array.size == 1
      return cit_num_array.first.to_s
    end
    # Multiple citations:
    cit_num_array.sort!
    #memo = [previous, running, size_cnt, string]
    tracker = nil
    cit_num_array.inject([nil,false,1,'']) do |memo,num|
      ## not in a run:
      if (num - 1) != memo[0] # not in a run:
        if memo[1]            # finish a run
          memo[3] << "-#{memo[0]},#{num}"
        else                  # wasn't running before:
          if memo[0]          # if there is a previous
            memo[3] << ",#{num}"
          else                # the start
            memo[3] << "#{num}"
          end
        end
        memo[1] = false       # state that we are not in a run
      else                    # in a run 
        if memo[2] == cit_num_array.size  # the last item (in a run)
          memo[3] << "-#{num}"
        end
        memo[1] = true        # state that we are running
      end
      memo[2] += 1            # keep track of the size
      memo[0] = num           # set previous number
      tracker = memo
      memo
    end
    tracker[3]
  end

end
