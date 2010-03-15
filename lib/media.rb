
module Media
  # note that you need to add the shortcut to module Format::MediaForwarding
  # hash if you want to be able to access it!

  # add to this class the conversion from the filename (as a symbol) to the
  # properly capitalized classname.  If the class name is just capitalized and
  # all lower case, not necessary.
  Symbol_to_class_string = { }
  #:html => 'HTML'

  def self.new(tp=:jtp)
    require "media/#{tp}"
    #puts( $".grep(/html/) )
    klass_st = ((x = Symbol_to_class_string[tp]) ? x : tp.to_s.capitalize)
    klass = Media.const_get(klass_st)
    klass.new
  end

  def header
  end

  def footer
  end

  def call_it(method, string)
    if var = string
      send(method, var.to_s)
    else
      nil
    end
  end

  def parenthesize(string)
    '(' + string + ')' 
  end

  def bracket(string)
    '[' + string + ']'
  end

  def br(string)
    call_it(:bracket, string)
  end

  def par(string)
    call_it(:parenthesize, string)
  end

  # italicize
  def i(string)
    call_it(:italics, string)
  end

  # bold
  def b(string)
    call_it(:bold, string)
  end

  # underline
  def u(string)
    call_it(:underline, string)
  end

  def italics(string)
    "<span style=\"font-style:italic;\">" + string + "</span>"
  end

  def bold(string)
    "<span style=\"font-weight:bold;\">" + string + "</span>"
  end

  def underline(string)
    "<span style=\"text-decoration:underline;\">" + string + "</span>"
  end

  # create the final bibliography string in whatever media you desire
  # the example here is html
  def format(format_object, citations)
    cts = citations.map do |cit|
      "  <li>" + format_object.format(cit) + "</li>"
    end
    "<ol>\n" + cts.join("\n") + "\n</ol>\n"
  end

end


