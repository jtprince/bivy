#!/usr/bin/ruby -w


# outputs a string that ruby will read in as a hash
def to_hash_string(hash)
  string = []
  string << "Medline_to_Full = {"
  hash.sort.each do |k,v|
    string << "'#{k}' => '#{v}',"
  end
  string << "}"
  string.join("\n")
end


a_to_j = {}  ## should be uniq mapping here


Dir["*.html"].each do |file|
  puts "FILE: #{file}"
  num_matches = 0
  IO.read(file).scan(/<TR><TD>(.*?)<\/TD><TD>(.*?)<\/TD>/m) do |match|
    pair = match.map do |m|
    
      # The last sub is because of some bad html they have in their journal
      # ...<TR><TD>Annu Rev Plant Physiol Plant Mol Biol
      m.gsub(/<\/?i>/,'').gsub(/<\/?A.*?>/,'').strip.sub(/ \(.*\)$/,'').sub(/<TR><TD>.*$/, '')
    end
    num_matches += 1
    #if a_to_j.key? pair[0] ; puts "ALREADY HAVE KEY! " end
    a_to_j[pair[0]] = pair[1]
  end
  IO.read(file).scan(/<TR>\n<TD>(.*?)<\/TD>\n<TD>(.*?)<\/TD>/) do |match|
    pair = match.map do |m|

      # The last sub is because of some bad html they have in their journal
      # ...<TR><TD>Annu Rev Plant Physiol Plant Mol Biol
      m.gsub(/<\/?i>/,'').gsub(/<\/?A.*?>/,'').strip.sub(/ \(.*\)$/,'').sub(/<TR><TD>.*$/, '')
    end
    num_matches += 1
    #if a_to_j.key? pair[0] ; puts "ALREADY HAVE KEY! " end
    a_to_j[pair[0]] = pair[1]
  end

  puts "#{num_matches} MATHCEES"
end

File.open("for_ruby_class.rb", 'w') do |fh| 
  fh.print( to_hash_string(a_to_j)) 
end
