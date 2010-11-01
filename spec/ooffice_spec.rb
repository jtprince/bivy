require 'spec_helper'

require 'fileutils'
require 'ooffice'

describe 'basic test' do
  before do
    @doc_permanent = TESTFILES + '/doc1.odt' 
    @doc = TESTFILES + '/doc1.tmp.odt'
    @newdoc = 'doc1.tmp.new.odt'
    @newdoc_with_path = TESTFILES + '/doc1.tmp.new.odt'
    FileUtils.cp @doc_permanent, @doc 
  end

  after do
    FileUtils.rm @doc
  end

  it 'can change the document' do
    start_read = 300
    OpenOffice.new.modify_content(@doc, @newdoc) {|string| string.sub(/john/,'peter')} 
    ok File.exist?(@newdoc_with_path)
    # can mess up the file end
    IO.read(@newdoc_with_path, 3000, start_read).isnt IO.read(@doc, 3000, start_read)
    File.unlink @newdoc_with_path
  end
end
