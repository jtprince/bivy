require File.expand_path( File.dirname(__FILE__) + '/spec_helper' )
require 'formatter'


describe Formatter, "repositioning citations" do
  before(:all) do
    dirbase = File.dirname(__FILE__) + "/formatter_spec/"
    @cits_after = IO.read( dirbase + "/cits_after.xml" )
    @cits_before = IO.read( dirbase + "/cits_before.xml" )
    @content_xml = IO.read( dirbase + "/content.xml" )
  end
  
  it 'positions after' do
    newxml = Formatter.new.reposition_citations(@content_xml, :after)
    newxml.should == @cits_after
  end

  it 'positions before' do 
    newxml = Formatter.new.reposition_citations(@content_xml, :before)
    newxml.should == @cits_before
  end
end
