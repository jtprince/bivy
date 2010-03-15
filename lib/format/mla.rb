
# authors(initialed) *title* i(Journal_iso) *year*, i(vol(issue)), pages.
# authors(initialed) \(year\). "title" u(Journal_medline) *vol*(issue): pages.
class Format::MLA
  include Format
  Format::Symbol_to_class_string[:mla] = 'MLA'

  def article
    vol_issue = 
      if vol
        "#{b(vol)}#{par(issue)}"
      else
        nil
      end
    [periodize(author_list('.')),  periodize(par(year)), "\"#{periodize(title)}\"", u(journal_medline), "#{vol_issue}: #{pages}"].compact.join(' ') << '.'
  end

  def article_to_be_submitted
    #[periodize(author_list('.')),  periodize(par(year)), "\"#{periodize(title)}\"", i(journal_medline), b(vol), par(issue), ": #{pages}"].compact.join(' ')
    [author_list('.'), "\"#{periodize(title)}\"", u(journal_medline), i('Article to be submitted')].compact.join(' ') << '.'
  end

  def webpage
    accessed_string = nil
    if year
      accessed_string = '(accessed '
      if month
        accessed_string << month.to_s
        if day
          accessed_string << " #{day}, "
        else
          accessed_string << " "
        end
      end
      accessed_string << year.to_s << ')'
    end

    [periodize(title), url, accessed_string].compact.join(' ') << '.'
  end

  def workshop
    [periodize(author_list('.')),  periodize(par(year)), "\"#{periodize(title)}\"", u(name), "#{pages}"].compact.join(' ') << '.'

  end

  # TODO: book
  
end


