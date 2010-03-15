
module Format
  Symbol_to_class_string = { }

  MediaForwarding = {
    :i => true,
    :b => true,
    :u => true,
    :header => true,
    :footer => true,
    :periodize => true,
    :par => true,
    :br => true,
  }

  def self.new(media_obj, tp=:jtp)
    require "format/#{tp}"
    klass_st = ((x = Symbol_to_class_string[tp]) ? x : tp.to_s.capitalize)
    klass = Format.const_get(klass_st)
    include_super = true
    obj = klass.new(media_obj)
  end

  def method_missing(*args)
    meth = args.first
    if MediaForwarding.key?(meth)
      @media_obj.send(*args)
    elsif @cit and @cit.respond_to?(meth)  
      @cit.send(*args)
    else
      raise NoMethodError, "method '#{meth}' called with args (#{args[1..-1].join(',')})"
    end
  end

  def initialize(media_obj)
    @media_obj = media_obj
    @cit = nil
  end

  # The method should take an array of strings, each formatted in whatever
  # method, and ensure that each string ends in a period.  This is annoying to
  # define, but it simplifies the writing of citation formats dramatically
  #def periodize(array)
  #  array.map do |st|
  #    if st[-1,1] == '.'
  #      st 
  #    else
  #      st << '.'
  #    end
  #  end
  #end

  def punctuate_initials(initials, punc='.')
    initials.split('').map { |i|  i + punc }.join('')
  end

  def format(cits)
    as_strings = cits.map do |cit|
      @cit = cit
      finish(send(@cit.bibtype))
    end
    @media_obj.list(as_strings)
  end

  # if given an array, will finish it with compaction and periodizing
  # otherwise, won't touch it
  def finish(arg)
    if arg.is_a? Array
      periodize(arg.compact).join(' ')
    else
      arg
    end
  end

  # probably only the first argument would you ever change
  # if delim is nil, then et al. format is used (1 author, fine, 2 authors
  # connect with 'and', 3 authors = et al
  def author_list(after_initials='.', separate_last_and_initials=' ', delim=", ", and_word="and", join_with_ands=false)
    if authors.is_a? String
      authors
    else 
      names = []
      names = authors.map do |auth|
        auth.last + separate_last_and_initials + punctuate_initials(auth.initials, after_initials)
      end
      if delim.nil?
        case authors.size
        when 1
          names.first
        when 2
          names.join(" #{and_word} ")
        else
          names.first + ' ' + i('et al.')
        end
      else
        if join_with_ands   
          names[0...-1].join(delim) + " #{and_word} " + names[-1]
        else
          names.join(delim)
        end
      end
    end
  end

  #############################
  # universal format methods
  #############################
  
  # parenthesizes any 'true' object that has to_s method, otherwise ''
  def par(st)
    if st
      "(#{st})"
    else
      ''
    end
  end
 
end


