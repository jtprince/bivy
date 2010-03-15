
class Media::HTML
  include Media
  Media::Symbol_to_class_string[:html] = 'HTML'

  def header
    "<html><body>"
  end

  def footer
    "</body></html>"
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

  def list(citations_as_strings) 
    cts = citations_as_strings.map do |cit|
      "\t<li>#{cit}</li>"
    end
    "<ol>\n" + cts.join("\n") + "\n</ol>\n"
  end

  # expects opening and closing tags.  Operates on last one.
  # trailing text (outside a tag) is operated on if existing
  # <tag>text</tag> => <tag>text.</tag>
  # <tag>text</tag>more_text => '...more_text.'
  # if the text already has a period, then no change
  # method periodize (TODO: should alias, really)
  def periodize(array_or_string)
    if array_or_string.is_a?(Array)
      array_or_string.map do |st|
        periodize(st)
      end
    else
      st = array_or_string
      if st[-1,1] == '>'
        st.sub(/(.*)(<\/.*?>)/) do |v|
          if $1[-1,1] =~ /[\.\?\!]/
            $1 + $2
          else
            $1 + '.' + $2
          end
        end
      else
        if st[-1,1] =~ /[\.\?\!]/
          st
        else
          st << '.'
        end
      end
    end
  end

end

