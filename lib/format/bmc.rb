
class Format::BMC
  include Format
  Format::Symbol_to_class_string[:bmc] = 'BMC'

 def article
    issue_string =
      if issue.nil?
        ''
      else
        "(#{issue})"
      end
    vol_string = 
      if vol.nil?
        ''
      else
        vol
      end

    # This is the original:
    "#{author_list('')}: #{b(periodize(title))} #{i(journal_medline)} #{year}, #{b(vol_string)}#{issue_string}:#{pages_full}."
    #  ThIS IS NOT the BMC format:
    # "#{author_list('.', ' ', ', ', '&', true)} (#{year}) #{title.gsub(/\.$/,'')}, #{periodize(i(journal_iso))} #{i(vol_string)}, #{pages}."
  end

# Webpage (2 examples):
# b(Webpage Name) [http://chemfinder.cambridgesoft.com]

  def webpage
    [b(title), br(url)].compact.join(' ')
  end

  # TODO: book

end



