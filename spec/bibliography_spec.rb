require 'spec_helper'

require 'bibliography'
require 'citation'
#require 'format/html'


describe 'basic bibliography test' do
  before do
    authors = %w(HQ BY JT).zip(%w(Dork Man Prince)).map do |init, last|
      Citation::Author.new(last, init)
    end
    hash = {
      :authors => authors, :title => "Silly Title", :journal_medline => 'Jail Cell', :journal_full => 'Jail Cell', :journal_iso => 'Jail Cell', :year => '1996', :month => 'Aug', :vol => 32, :pages => '32-8', :ident => 'Prince1996', :quotes => []
    }
    @cit1 = Citation::Article.new(hash)
    authors2 = %w(BM).zip(%w(Smith)).map do |init, last|
      Citation::Author.new(last, init)
    end
    hash2 = {
      :authors => authors2, :title => "Wacky Backy", :publisher => 'Rocky Mountain Publishing', :year => '2003', :ident => 'Smelly2003'
    }
    @cit2 = Citation::Book.new(hash2)
    @cits = [@cit1, @cit2]
  end

  it 'makes a YAML round trip' do
    yaml = <<END
--- 
month: Aug
journal_full: Jail Cell
journal_iso: Jail Cell
journal_medline: Jail Cell
title: Silly Title
ident: Prince1996
year: "1996"
authors: 
- Dork, HQ
- Man, BY
- Prince, JT
pages: 32-8
quotes: []
bibtype: article
vol: 32
END

    YAML.load(@cit1.to_yaml).is YAML.load(yaml) # just frozen really

    bibyaml = <<END2
Prince1996:
  month: Aug
  journal_full: Jail Cell
  journal_iso: Jail Cell
  journal_medline: Jail Cell
  title: Silly Title
  year: "1996"
  authors: 
  - Dork, HQ
  - Man, BY
  - Prince, JT
  pages: 32-8
  quotes: []
  bibtype: article
  vol: 32
END2

    bib = Bibliography.new
    bib.citations = [@cit1]
    created_yaml = bib.to_yaml

    # frozen
    YAML.load(created_yaml).is YAML.load(bibyaml)

    bib_from_yaml = Bibliography.from_yaml(bibyaml)
    #assert_equal(bibbib_from_yaml, "bibs are the same from objects and from yaml")
    #assert_equal(bib.citations.first, bib_from_yaml.citations.first, "cits are the same from objects and from yaml")
    bc1 = bib.citations.first
    bc2 = bib_from_yaml.citations.first
    %w(bibtype ident journal_full journal_medline journal_iso month pages title vol year).map {|v| v.to_sym}.each do |x|
      bc2.send(x).is bc1.send(x)
    end
    bc2.send(:authors).is bc1.send(:authors)
  end

  xit 'writes a bibliography' do  # better description??
    frozen = <<END
<html>
<body>
<ol>
  <li>Dork H.Q., Man B.Y., Prince J.T. <span style="font-style:italic;">Jail Cell.</span> <span style="font-weight:bold;">1996</span>, <span style="font-style:italic;">32</span>, 32-8.</li>
  <li>Smith B.M. <span style="font-style:italic;">Wacky Backy.</span> <span style="font-weight:bold;">2003</span>.</li>
</ol>
</body>
</html>
END
    bib = Bibliography.new(@cits)
    bib.write(Format::HTML.new).is frozen
  end

  it 'adds citations to the bibliography' do
    authors = %w(JT).zip(%w(Prince)).map do |init, last|
      Citation::Author.new(last, init)
    end
    hash = {
      :authors => authors, :title => "Theory of Everything", :journal_medline => 'OmiOmics', :journal_full => 'OmiOmics', :journal_iso => 'OmiOmics', :year => '2010', :month => 'Jan', :vol => 1010, :pages => '35-9', :ident => 'Prince2010', :quotes => []
    }
    diff_cit = Citation::Article.new(hash)

    # single
    bib = Bibliography.new([@cit1, @cit2])
    cits_before = bib.citations.dup
    ans = bib.add(@cit1)
    ans.size.is 1
    # rejects identical id
    ans.first.is @cit1
    # cits unchanged
    bib.citations.is cits_before

    ans = bib.add(@cit1, diff_cit)
    ans.size.is 1
    # rejects identical id
    ans.first.is @cit1
    # added a guy
    bib.citations.is cits_before.push(diff_cit)  
  end

end
