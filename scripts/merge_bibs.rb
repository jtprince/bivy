#!/usr/bin/ruby -w

require 'yaml'

require 'optparse'

$force = false
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} bib.yml ..."
  op.separator "on matching key or pmid aborts with informative warning"
  op.separator "otherwise, outputs file 'merged.yml'"
  op.on("-f", "--force", "gives warnings but still prints merged.yml") { $force = true }
end

opts.parse!

if ARGV.size < 2
  puts opts.to_s
  exit
end

all_pmids = {}
all_refs = {}
overlapping_refs = Hash.new {|h,k| h[k] = [] }
overlapping_pmids = Hash.new {|h,k| h[k] = [] }
one_bad = false
ARGV.each do |file|
  yml = YAML.load_file(file)
  yml.each do |k,v|
    if all_refs.key?(k) 
      unless all_refs[k] == v
        overlapping_refs[k].push(v)
      end
    elsif all_pmids.key?(k)
      overlapping_pmids[k].push(v)
    end
    all_refs[k] = v
  end
end

bad_keys = overlapping_refs.size > 0 || overlapping_pmids.size > 0

if bad_keys
  if overlapping_refs.size > 0
    puts "Overlapping KEYS (but different entries): "
    overlapping_refs.each do |k,v|
      puts "#{k}:" 
      v.each do |val|
        puts "<<<<<<<<<<<<<"
        puts "#{val.to_yaml}"
        puts ">>>>>>>>>>>>>"
      end
    end
  end
  if overlapping_pmids.size > 0
    puts "Overlapping PMIDs: "
    overlapping_pmids.each do |k,v|
      puts "#{k}:" 
      v.each do |val|
        puts "<<<<<<<<<<<<<"
        puts "#{val.to_yaml}"
        puts ">>>>>>>>>>>>>"
      end
    end
  end
end
if !bad_keys || $force
  puts "printing to file: \"merged.yml\""
  File.open('merged.yml', 'w') {|out| out.print(all_refs.to_yaml) }
end
