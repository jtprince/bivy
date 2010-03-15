

require 'test/unit'
require File.join( File.dirname(__FILE__), '..', 'lib', 'pubmed' )


class TestBasic < Test::Unit::TestCase
  @@klass = PubMed

  def test_nothing
    x = @@klass.new
    assert_equal(@@klass, x.class, "equal class")
  end

  def test_one
    begin
      pm = PubMed.new(17323448)
      hash = {:title=>"Separation media for microchips.", :journal_medline =>"Anal Chem", :journal_iso=> 'Anal. Chem.', :journal_full => 'Analytical chemistry', :year=>"2007", :month=>"Feb", :vol=>"79", :issue=>"3", :pages=>"800-8", :ident=>"Wirth2007", :pmid=>17323448, :quotes => []}
      hash.each do |k,v|
        assert_equal(v, pm.send(k), "#{k}: attributes on pubmed retrieval")
      end
      assert_equal('Wirth', pm.authors.first.last)
      assert_equal('MJ', pm.authors.first.initials)

    rescue SocketError
      assert_nil( puts("No Internet Connection, skipping test") )
    end
  end

end
