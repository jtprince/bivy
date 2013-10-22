
require 'journal'

class Citation
  # quotes are director or parenthetical
  attr_accessor :bibtype, :ident, :quotes, :abstract, :uri
  # authors should be an array of Author objects, or a string for an exact
  # line
  attr_reader :authors

  def initialize(hash=nil)
    @authors = nil
    @quotes = []
    # Citation::Article -> :article
    @bibtype = self.class.to_s.split('::')[-1].downcase.to_sym
    if hash
      hash.each do |x,v|
        send("#{x}=".to_sym, v)
      end
    end
  end

  def to_hash
    hash = {}
    others = instance_variables.select {|v| v != '@authors'}
    others.each do |var|
      hash[var[1..-1]] = instance_variable_get(var)
    end
    hash['bibtype'] = hash['bibtype'].to_s
    hash['authors'] = instance_variable_get('@authors').map {|v| v.to_s }
    hash
  end

  ## We shouldn't have to do this one, it should be handled in our setter!!
  #def author_strings_to_objects
  #  if @authors
  #    @authors.map do |st|
  #      if st.is_a? Citation::Author
  #        st
  #      else
  #        Citation::Author.from_s(st)
  #      end
  #    end
  #  else
  #    []
  #  end
  #end

  # given an array of strings or objects, ensures objects, given string it
  # will set as a string
  def authors=(array)
    if array.is_a? Array
      @authors = array.map do |auth|
        if auth.is_a? String
          Citation::Author.from_s(auth)
        elsif auth.is_a? Citation::Author
          auth
        else
          abort "Don't recognize: #{auth.class} for #{auth}"
        end
      end
    else
      # this is a string
      @authors = array
    end
  end

  # make the yaml look like a hash
  def to_yaml
    to_hash.to_yaml
  end

end

module JournalLike
  attr_accessor :journal_medline, :journal_full, :journal_iso

  # unless the @journal_full or @journal_iso attributes are filled in already
  # will attemtp:
  # This method will search Journal::Medline_to_ISO and
  # Journal::Medline_to_Full and fill in the other entries, otherwise, it will
  # given a medline format journal name, fills in the 3 journal attributes
  def set_journal_from_medline(jrnl)
    @journal_medline = jrnl
    if @journal_full == nil
      if Journal::Medline_to_Full.key?(jrnl)
        @journal_full = Journal::Medline_to_Full[jrnl]
      else
        @journal_full = jrnl
      end
    end
    if @journal_iso == nil 
      if Journal::Medline_to_ISO.key?(jrnl)
        @journal_iso = Journal::Medline_to_ISO[jrnl]
      else
        @journal_iso = jrnl
      end
    end
  end

  def has_journal?
    journal_medline != nil
  end


end

class Citation::Article < Citation
  include JournalLike
  # ident = unique identifier for placing in papers
  attr_accessor :title, :year, :month, :vol, :issue, :pages
  
  def ==(other)
    if self.respond_to? :pmid
      if other.respond_to?(:pmid) && (self.pmid == other.pmid)
        return true
      else
        return false
      end
    else
      %w(title year month vol issue pages journal_medline bibtype).each do |v|
        if self.send(v.to_sym) != other.send(v.to_sym)
          return false
        end
      end
    end
    return true
  end

  def pages_full
    st_p, end_p = @pages.split('-')
    if !@pages.include?('.') && end_p && end_p.to_i < st_p.to_i  # 123-29
      diff = st_p.size - end_p.size
      new_end_p = st_p[0,diff] + end_p
      [st_p, new_end_p].join('-')
    else
      @pages
    end
  end
end


class Citation::Article_to_be_submitted < Citation
  include JournalLike
  attr_accessor :title
end

class Citation::Workshop < Citation
  attr_accessor :title, :name, :year, :pages
end

class Citation::Book < Citation
  attr_accessor :title, :publisher, :location, :year
end

class Citation::Webpage < Citation
  attr_accessor :title, :year, :month, :day, :url
  # month, year, day are all for the creation of the media itself
  # date last accessed (String: 'yyyy-mm-dd')
  attr_accessor :accessed
end


class Citation::Author

  ## INITIALS should be with NO spaces, all caps
  attr_reader :last, :initials
  def initialize(last, initials)
    @last = last
    @initials = initials
  end
  def inspect
    "<#{@last}, #{initials}>"
  end

  def to_s
    "#{@last}, #{@initials}"    
  end

  # TODO: make this smarter for initials
  def self.from_s(string)
    pieces = string.split(', ')
    last = pieces.shift
    initials = pieces.join(', ')
    self.new(last, initials)
  end

  def ==(other)
    [self.last, self.initials] == [other.last, other.initials]
  end

end


