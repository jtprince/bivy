require 'fileutils'
FU = FileUtils

class OpenOffice

  # unzips the file, gives a string of the content xml and will replace it
  # whatever you pass back (preferably a string;)
  # requires write access to the directory where the file is located 
  # The next time you open the file, it will act like you've corrupted the
  # file (the character count is probably off, etc) just let it clean it up
  # for you!
  # new_basename = base name of the new file (preferably <name>.odt)
  def modify_content(filename, new_basename, &blk)
    content_file = 'content.xml'
    basename = File.basename(filename)
    tmpdir = basename + ".unzip.tmp"
    Dir.chdir(File.dirname(filename)) do
      if File.exist?(tmpdir)
        warn "#{tmpdir} already exists!"
        warn "deleting contents of #{tmpdir}"
        FU.rm_rf(tmpdir)
      end
      FU.mkpath(tmpdir)
      FU.cp(basename, tmpdir)
      Dir.chdir(tmpdir) do
        print `unzip -q #{basename}`
        string = IO.read(content_file)
        replace_with = blk.call(string)
        File.open(content_file,'w') {|fh| fh.print(replace_with) }
        FU.rm(basename, :force => true)
        to_include = Dir["*"]
        print `zip -r -q #{new_basename} #{to_include.map {|v| "'" + v + "'" }.join(' ')}`
        FU.mv new_basename, '..'
      end
      FU.rm_rf tmpdir
    end
  end

end
