
# authors(initialed,comma'd,no spaces, using et al for 3 or more) (2007) *title* i(Journal_iso) *year*, i(vol(issue)), pages.
# authors(initialed) \(year\). "title" u(Journal_medline) *vol*(issue): pages.
class Format::Bioinformatics
  include Format

  def article
    [ [periodize(author_list('.', ',',nil)), par(year), periodize(title), i(journal_iso)].compact.join(' '), b(vol), pages].compact.join(', ') << '.'
  end

  #def article_to_be_submitted
  #  #[periodize(author_list('.')),  periodize(par(year)), "\"#{periodize(title)}\"", i(journal_medline), b(vol), par(issue), ": #{pages}"].compact.join(' ')
  #  [author_list('.'), "\"#{periodize(title)}\"", u(journal_medline), i('Article to be submitted')].compact.join(' ') << '.'
  #end

  def article_in_review
    [periodize(author_list('.', ',',nil)), par(year), periodize(title), i(journal_iso)].compact.join(' ') + ', ' + i('manuscript in review') << '.'
  end

  # shouldn't really be webpages in the references
  def webpage
    abort 'shouldnt be webpages in Bioinformatics journals!'
  end

  #def workshop
  #  [periodize(author_list('.')),  periodize(par(year)), "\"#{periodize(title)}\"", u(name), "#{pages}"].compact.join(' ') << '.'
  #end

  # TODO: book

end


