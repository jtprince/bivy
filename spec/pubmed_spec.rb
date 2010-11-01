
require 'spec_helper'
require 'pubmed'


describe 'basic pubmed testing' do
  before do
    @pmid = 17323448
  end
  it 'adds a journal given a pubmed id' do
    begin
      pm = PubMed.new(@pmid)
      hash = {:title=>"Separation media for microchips.", :journal_medline =>"Anal Chem", :journal_iso=> 'Anal. Chem.', :journal_full => 'Analytical chemistry', :year=>"2007", :month=>"Feb", :vol=>"79", :issue=>"3", :pages=>"800-8", :ident=>"Wirth2007", :pmid=>17323448, :quotes => []}
      hash.each do |k,v|
        # "#{k}: attributes on pubmed retrieval"
        pm.send(k).is v
      end
      pm.authors.first.last.is 'Wirth'
      pm.authors.first.initials.is 'MJ'

    rescue SocketError
      ok !puts("No Internet Connection, skipping test")
    end
  end
end

