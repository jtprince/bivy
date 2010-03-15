
# authors(initialed) *title* i(Journal_iso) *year*, i(vol(issue)), pages.
class Format::JTP
  include Format
  Format::Symbol_to_class_string[:jtp] = 'JTP'

  def article
    vol_issue = 
      if vol
        "#{vol}#{par(issue)}"
      else
        nil
      end
    [author_list('.'), b(title), i(journal_iso), [b(year), vol_issue, pages].compact.join(', ')]
  end

  def article_to_be_submitted
    [author_list('.'), i(journal_iso), i('Article to be submitted')]
  end

  def webpage
    [periodize(b(title)), u(url), periodize("#{b(year)}, #{month} #{day}")].compact.join(' ')
  end

  # TODO: book
  
  
end


