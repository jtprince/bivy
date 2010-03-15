require 'hash_by'
require 'citation'
require 'pubmed'

class Bibliography

  attr_accessor :citations

  def initialize(citations=nil)
    if citations
      @citations = citations
    end
  end

  # returns an array of citations from other that are not uniq compared self
  def not_uniq(other)
    scit = self.citations
    ocit = other.citations
    pass_id = not_uniq_by(scit, ocit, :ident)
    passed = [scit, ocit].map do |ar|
      ar.select {|v| v.respond_to? :pmid}
    end
    passed.push( *(not_uniq_by(passed[0], passed[1], :ident)) )
    passed.uniq!
    passed
  end

  def not_uniq_by(cits1, cits2, att)
    self_by_att = cits1.hash_by(att)
    other_by_att = cits2.hash_by(att)
    not_un = [] 
    other_by_att.each do |k,v| 
      if self_by_att.key? k
        not_un.push( *v )
      end
    end
    not_un 
  end

  # adds a list of citations.  It will ONLY add citations whose identifiers
  # do not already exist.  Citations which already have a duplicate identifier
  # will be returned.  nil is returned if no citation objects have clashing
  # id's
  def add(*citations)
    clashing = []
    hsh = to_hash
    citations.each do |cit|
      if hsh.key? cit.ident
        clashing << cit
      else
        @citations.push(cit)
      end
    end
    if clashing.size > 0
      clashing
    else
      nil
    end
  end

  # if file, loads it
  def self.from_yaml(file_or_string)
    hash = 
      if File.exist? file_or_string
        YAML.load_file(file_or_string)
      else
        YAML.load(file_or_string)
      end
    # we were given a nonexistent file and the yaml is not a hash
    # in this case we need to create an empty bib object
    unless hash.is_a? Hash
      hash = {}
    end
    citations = hash.map do |id,vals|
      vals['ident'] = id 
      bibtype = vals['bibtype']
      klass = 
        if vals.key? 'pmid'
          PubMed
        else
          Citation.const_get(bibtype.capitalize)
        end
        #when 'article'
        #  else
        #    Citation::Article
        #  end
        #when 'book'
        #  Citation::Book
        #else
        #  abort "Unrecognized bibtype!"
        #end
      vals['bibtype'] = bibtype.to_sym
      cit = klass.new(vals)
      #if cit.authors =~ /Paris/
      #  p cit.authors
      #  abort
      #end
      #if cit.authors.is_a? Array
      #  cit.authors = cit.author_strings_to_objects
      #end
      cit
    end
    bib = Bibliography.new(citations)
  end

  # selects as internal citations only those matching the array of idents
  # returns the citations
  def select_by_id!(ids)
    hash = @citations.hash_uniq_by(:ident)
    new_cits = ids.map do |id|
      unless hash.key? id ; abort "Cannot find '#{id}' in citations!" end
      hash[id]
    end
    @citations = new_cits
  end

  # hashes by ident
  def to_hash
    hsh = {}
    @citations.each do |cit|
       cthash = cit.to_hash
       cthash.delete('ident')
       hsh[cit.ident] = cthash
    end
    hsh
  end

  # if given a file, writes to the file, otherwise returns the string
  def to_yaml(file=nil)
    hsh = to_hash
    string = hsh.to_yaml
    if file
      File.open(file, 'w') {|v| v.print string }
    end
    string
  end

  # a format_obj can respond to the call obj.format(citation, format_type)
  # and :header and :footer
  def write(format_obj)
    format_obj.header + format_obj.format(@citations) + format_obj.footer
  end

end
