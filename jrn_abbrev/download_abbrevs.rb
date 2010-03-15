#!/usr/bin/ruby -w

require 'open-uri'

base_url_start = 'http://home.ncifcrf.gov/research/bja/journams_'
base_url_end = '.html'

# http://home.ncifcrf.gov/research/bja/journams_a.html
# http://home.ncifcrf.gov/research/bja/journams_b.html

ar = ('a'..'z').to_a

ar.each do |v|
  File.open("JRNL_ABBR_#{v}.html", 'w') do |out|
    open(base_url_start + v + base_url_end) do |fh|
      out.print( fh.read )
    end
  end
end

