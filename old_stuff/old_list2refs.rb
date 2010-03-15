#!/usr/bin/ruby -w


require 'ostruct'
require 'pubmed2html'

if ARGV.size < 2
  puts "usage: #{File.basename($0)} cits.txt ref_list.txt"
  exit
end

cits = ARGV[0]
reflist = ARGV[1]

outf = cits.gsub(/\.txt$/, ".html")

def read_reflist(reflist)
  hashes = {}
  reading = false
  key = nil
  File.open(reflist).each do |line|
    if line !~ /[\w\d]/
      reading = false 
    elsif reading
      if line =~ /(.*) = (.*)/ 
        ikey = $1.dup; ival = $2.dup
        if ikey == "authors"
          auths = ival.split(", ")
          ival = []
          auths.each do |auth|
            last, first = auth.split(/\s+/)
            ival << Author.new(last, first)
          end
        end
        hashes[key][ikey] = ival
      end
    elsif line =~ /^\d+\.\s+(.*)/
      key = $1.chomp
      hashes[key] = {}
      reading = true
    end
  end
  hashes
end

def cithash2html(hash)
  #puts "HASH GIVIN: " + hash.to_s
  ob = OpenStruct.new(hash)
  #puts "OBJ: "; p ob
  ob2html(ob)
end

reflist_hash = read_reflist(reflist)

#reflist_hash.each do |k,v| 
#  puts "****************************************"
#  puts "KEY: #{k}"
#  puts "****************************************"
#  v.each do |kk,vv| 
#    puts "#{kk}: #{vv}" 
#  end
#end

def html_header
  "<html><body><ol>"
end

def html_tail
  "</ol></body></html>"
end


html_lines = []
File.open(cits).each do |line|
  if line =~ /[\w\d]/ && line !~ /^[#]/
    #puts "LINE: " + line
    arr = line.chomp.split
    # is this a pmid?
    if arr[1] =~ /[^\d]/ && arr[1] != "NULL"
      #puts "ARR[1]: " + arr[1]
      # not a pmid
      call_key = arr[1..-1].join(" ")
      #puts "CALLING KEY: " + call_key
      if !reflist_hash.key?(call_key)
        puts "NO RESPONSE FOR #{call_key}"
        exit
      end
      cit_hash = reflist_hash[call_key]
      #p cit_hash
      html_lines << cithash2html(cit_hash)
    else
      #pmid
      html_lines << `ruby pubmed2html.rb #{arr[1]}`
    end
  end
end

File.open(outf, "w") do |fh|
  fh.print html_header + "\n"
  fh.print html_lines.join("\n")
  fh.print html_tail + "\n"
end

