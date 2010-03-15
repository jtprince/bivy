#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

require 'pubmed'
require 'citation'
require 'bibliography'

bib_re = /bib\.ya?ml$/i
attemped_bib = Dir["*"].select {|v| v =~ bib_re }.first

opt = OpenStruct.new
opt.bib =
  if attemped_bib.nil?  
    "bib.yml"
  else
    attemped_bib
  end


opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTIONS] pubmed_id ..."
  op.separator ""
  op.separator "  appends citations to #{opt.bib} and outputs lines of identifiers"
  op.on("-b", "--bib", "filename of the bibliography (using: #{opt.bib})",
    "if == STDOUT, then prints to STDOUT") {|v| opt.bib = v }
  op.on("-i", "--id Array", Array, "give a unique identifier") {|v| opt.identifier = v}
  op.on("-q", "--quotes Array", Array, "direct or parenthetical") {|v| opt.quotes = v}
  op.separator "   * Arrays are parallel to id's"
end

opts.parse!

if ARGV.size < 1
  puts opts
  exit
end

pmids = ARGV.to_a

opt.stdout = true if opt.bib == 'STDOUT'

cits = pmids.to_a.map do |pmid|
  pm = PubMed.new(pmid)
  if opt.identifier
    uniq_id = opt.identifier.shift
    pm.ident = uniq_id
  end
  pm
end

if opt.stdout
  puts Bibliography.new(cits).to_yaml
else
  bib = Bibliography.from_yaml(opt.bib)
  clashing = bib.add( *cits )
  if clashing == nil
    sub_clashing = []
  else
    sub_clashing = clashing
  end
  added = cits - sub_clashing
  added.each do |ad|
    puts "#[#{ad.ident}]"
  end
  if clashing
    puts "ID#{((clashing.size > 1) ? 's' : '')} already taken! (see '-i' flag):\n"
    clashing.each do |clash|
      if bib.citations.any? {|cit| ((cit.respond_to?(:pmid)) and (clash.pmid == cit.pmid)) }
        puts "#{clash.pmid}: '#{clash.ident}' (pmid already present!)"
      else
        puts "#{clash.pmid}: '#{clash.ident}'"
      end
    end
  end
  bib.to_yaml(opt.bib)
end
