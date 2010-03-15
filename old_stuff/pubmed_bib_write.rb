#!/usr/bin/ruby -w

$LOAD_PATH.push File.join( File.dirname(__FILE__), "lib" )

###############################################################################
# John Prince
# pubmed_bib_write.rb
# Takes a list of pubmed id's, queries pubmed to get the citation,
# and outputs a rich text format (rtf) document based on the below $TEMPLATE
###############################################################################

###########################################################################
###########################################################################
# Choose the style of bibliography here:
##### Four Formatting tags:
# n = normal text
# b = bold
# i = italics
# u = underline

##### Helper tags (shouldn't go inside other tags)
# s = space (normal text)
# dot = '.'
# ds = '. '
# sd = ' .'

##### Lightweight tags (must be format still)
# para = parenthesized eg ()

# NOTE: Author list is guaranteed to end in a period!
$styles = {
  'article' => 'n(author_list) + s + para(@year) + ds + b(@title) + ds + i(@journal) + ds + n(@vol + para(@issue) + ":" + @pages) + dot',
  'article_to_be_submitted' => 'n(author_list) + s + b(@title) + ds + i(@journal) + ds + i("to be submitted") + dot',
  'book' => 'n(author_list) + s + para(@pub_year) + ds + b(@title) + ds + i(@publisher) + dot',
  'webpage' => 'b(@title) + ds + u(@href)'
}

# CITATION VARIABLES:
# the font size of the in-text citation marker
# 7 is default
CIT_FONTSIZE = 7
# the height of the in-text citation marker (range at least -7 to 7)
# 5 is probably a good height
CIT_HEIGHT = 6
# Replaces the brackets in the paper with numbered footnotes
REPLACE_CITATIONS = true  

$FILE_TRAILER = "_PRETTY.rtf"

###########################################################################
###########################################################################

def usage
  string =<<HERE
***************************************************************
* usage: #{File.basename($0)} file.rtf ref_file.txt                          *
*     - change templates in the program for different formats *
***************************************************************
HERE
end


## This is a hack to fix author names with strange characters:
def correct_author_lists(citation_hash)
  citation_hash[:authors].each do |auth|
    auth.last.gsub!(/Pasa-Toli.*/, 'Pasa-Tolic')
    auth.last.gsub!(/G.rg/, 'Gorg') # can't get this one working...
  end
end


require 'bib_writer'

# citations will look like this:
# [pmid 123456] or [ref 23]

unless ARGV.length == 2
  puts usage()
  exit
end

file = ARGV[0]
ref_file = ARGV[1]

bib = BibWriter.new(file, ref_file)
bib.read_citations(REPLACE_CITATIONS, CIT_FONTSIZE, CIT_HEIGHT)
string = bib.create_bib($styles)
out = file.gsub(/\.\w+$/, $FILE_TRAILER)
File.open(out, "w") do |file|
  file.print string
end

