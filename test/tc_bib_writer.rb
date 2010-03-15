
require 'test/unit'
require 'bib_writer'

class TestReplaceCitations < Test::Unit::TestCase
  def test_basic
    string = "This is the#[billy211], document#[mark2006, john2007, simon2010].  Why do you think it is like it is? #[mark2006, billy211].  How are you doing? [#[sally32, mark2006]]. And you #[billy211, mark2006, simon2010, markus32]."
    (new_string, ordered_cits) = BibWriter.new.replace_citations_numerically(string, '#[', ']', ', ')
    assert_equal(%w(billy211 mark2006 john2007 simon2010 sally32 markus32), ordered_cits, "ordered_cits")
    assert_equal("This is the1, document2-4.  Why do you think it is like it is? 1-2.  How are you doing? [2,5]. And you 1-2,4,6.", new_string, "replaces string contents")

  end
end
