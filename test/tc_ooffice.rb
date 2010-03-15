
require 'fileutils'
require 'test/unit'
require 'ooffice'

class TestBasic < Test::Unit::TestCase

  def setup
    @tfiles = File.dirname(__FILE__) + '/tfiles/'
    @doc_permanent = @tfiles + 'doc1.odt' 
    @doc = @tfiles + 'doc1.tmp.odt'
    @newdoc = 'doc1.tmp.new.odt'
    @newdoc_with_path = @tfiles + 'doc1.tmp.new.odt'
    FileUtils.cp @doc_permanent, @doc 
  end

  def teardown
    FileUtils.rm @doc
  end

  def test_change
    start_read = 300
    OpenOffice.new.modify_content(@doc, @newdoc) {|string| string.sub(/john/,'peter')} 
    assert(File.exist?(@newdoc_with_path), "#{@newdoc} exists")
    assert_not_equal(IO.read(@doc, 3000, start_read), IO.read(@newdoc_with_path, 3000, start_read), "can mess up the file end")
    File.unlink @newdoc_with_path
  end

end
