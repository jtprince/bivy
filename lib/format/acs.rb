
# see: http://www.lib.berkeley.edu/CHEM/acsstyle.html

# Article:
# Basic Format:
# Author, A. A; Author, B. B; Author, C. C. Title of Article. Journal Abbreviation (italics) [Online if online] Year (boldface), Volume (italics), Pagination.

# Borman, S. Protein Sequencing For The Masses. Chem. Eng. News [Online] 2004, 82, pp 22-23.
# Slunt, K. M.; Giancarlo, L. C. Student-Centered Learning: A Comparison of Two Different Methods of Instruction. J. Chem. Educ. 2004, 81, pp 985-988.
# Takahaski, T. The Fate of Industrial Carbon Dioxide. Science [Online] 2004, 305, 352-353.
#                                              {italics      }  {b}  {i}
# (1) Washburn, M.P.; Wolters, D.; Yates, J.R. Nat. Biotechnol. 2001, 19, 242-7.
#
#
# Book with Author(s)

#Basic Format:
#Author, A. A.; Author, B. B. Book Title (italics), Edition (if any); Publisher: Place of Publication, Year; Pagination.
#
#Dill, K. A.; Bromberg, S. Molecular Driving Forces: Statistical Thermodynamics in Chemistry and Biology; Garland Science: New York, 2003.
#Engel, R; Cohen, J. I. Synthesis of Carbon-Phosphorus Bonds: New Methods of Exploration; CRC Press: Boca Raton, FL, 2004; pp 54-56.
#Zumdahl, S. S. Chemical Principles, 4th ed.; Houghton Mifflin: Boston, MA, 2002; p 7.

class Format::ACS
  include Format
  Format::Symbol_to_class_string[:acs] = 'ACS'

=begin
  def article(cit)
    [author_list('.', ', ', '; '), i(journal_iso), b(year), [vol, pages].compact.join(', ')]
  end

  # needs to deal with journal or no journal
  def article_to_be_submitted(cit)
    [author_list('.'), i(journal_iso), i('Article to be submitted')]
  end

  def webpage(cit)
    [periodize(b(title)), u(url), periodize("#{b(year)}, #{month} #{day}")].compact.join(' ')
  end

  # TODO: book

=end

 def article
    vol_o_nil = 
      if vol
        "#{vol}"
      else
        nil
      end
    [author_list('.'), i(journal_iso), [b(year), i(vol), pages].compact.join(', ')]
  end

  def article_to_be_submitted
    [author_list('.'), i(journal_iso), i('Article to be submitted')]
  end

# Webpage (2 examples):
# ChemFinder.Com. http://chemfinder.cambridgesoft.com (accessed July 14, 2004).

  # (accessed July 14, 2004)
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

  # TODO: book

  def book
    [author_list('.'), i(title), press_location(), ': ', press(), year(), pages]
  end

end



