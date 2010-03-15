#!/usr/bin/ruby -w

require 'optparse'

require 'formatter'
require 'bibliography'
require 'format'
require 'media'

$format_type = :jtp
$citation = nil
$yaml = nil
$cit_order = nil
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <bibliography>.yaml <file>.odt"
  op.separator "outputs: <file>.cit.odt <file>.bib.html"
  op.on("-f", "--format <type>", "type = jtp|acs|mla|bioinformatics|bmc") {|v| $format_type = v.to_sym }
  op.on("--cit-pos <position>", "position = before|after the punctuation") {|v| $citation = v }
  op.on("--yaml <file>", "outputs bib used to file") {|v| $yaml = v }
  op.on("--cit-order <file>", "outputs initial appearance of citations IDs") {|v| $cit_order = v }
end

opts.parse!

if ARGV.size != 2
  puts opts
  exit
end

format_obj = Format.new(Media.new(:html), $format_type)

bib = ARGV.shift
odt = ARGV.shift

options = {}
if $format_type == :mla or $format_type == :bioinformatics
  options[:bib] = :mla
elsif $format_type == :bmc
  options[:bracket] = true
end
if $citation
  options[:cit_pos] = $citation.to_sym
end

outfile = odt.sub(/\.odt$/, '.bib.html')
bib_object = Formatter.new.create_bibliography(odt, bib, options)
if $cit_order
  File.open($cit_order, 'w') {|out| out.print( bib_object.citations.map {|c| c.ident }.join("\n") ) }
end

string = bib_object.write(format_obj)
File.open(outfile, 'w') {|fh| fh.print string }
if $yaml
  bib_object.to_yaml($yaml)
end

