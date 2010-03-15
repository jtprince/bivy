#!/usr/bin/ruby -w


$jrn = {
  "Anal. Chem." => "Anal. Chem.",
  "Anal Chem" => "Anal. Chem.",
  "Nature Methods" => "Nature Methods",
  "Analytica Chimica Acta" => "Anal. Chim. Acta",
  "Bioinformatics" => "Bioinformatics",
  "Biomed. Mass Spectrom." => "Biomed. Mass Spectrom.",
  "Biomed Mass Spectrom" => "Biomed. Mass Spectrom.",
  "Environ Sci Technol" => "Environ. Sci. Technol.",
  "Eur. Food Res. Technol." => "Eur. Food Res. Technol.",
  "Genome Res" => "Genome Res.",
  "IEEE ASSP" => "IEEE ASSP",
  "J. Chemom." => "J. Chemom.",
  "J Chemom" => "J. Chemom.",
  "J. Mol. Biol." => "J. Mol. Biol.",
  "J Mol Biol" => "J. Mol. Biol.",
  "J. Am. Soc. Mass Spectrom." => "J. Am. Soc. Mass Spectrom.",
  "J. Chromatogr., A" => "J. Chromatogr., A",
  "J Chromatogr B Analyt Technol Biomed Life Sci" => "J. Chromatogr., B",
  "J Proteome Res" => "J. Proteome Res.",
  "J. Proteome Res." => "J. Proteome Res.",
  "J Chromatogr A" => "J. Chromatogr., A",
  "KDD Workshop on Mining Temporal and Sequential Data" => "KDD Workshop MTSD",
  "Mol Cell Proteomics" => "Mol. Cell. Proteomics",
  "Nat Biotechnol" => "Nat. Biotechnol.",
  "Nature" => "Nature",
  "Nat Chem Biol" => "Nat. Chem. Biol.",
  "Nucleic Acids Res" => "Nucleic Acids Res.",
  "Proteomics" => "Proteomics",
  "SIAM J. Num. Anal." => "SIAM J. Num. Anal.",
  "Rapid Commun Mass Spectrom" => "Rapid Commun. Mass Spectrom.",
}

$LOAD_PATH << "lib"
require 'pub_med'
require 'citation'


# takes author objects
def authors_to_list(authors)
  auths = []
  authors.each do |auth|
    a_init = ""
    if auth.initials =~ /\./
      a_init = auth.initials
    else
      a_init = auth.initials.split("").join(".") + '.'
    end
    auths << auth.last + ', ' + a_init
  end
  auths.join("; ")
end

# ob needs to respond to authors, journal, etc
def ob2html(ob)
  string = ""
  if ob.respond_to?(:btype) && ob.btype != "article"
    ## Type specific
    #puts "NON ARTICLE!"
    if ob.btype == "workshop"
      string = "<li>#{authors_to_list(ob.authors)} <span style=\"font-style:italic;\">#{format_journal(ob.name)}</span>. <span style=\"font-weight:bold\">#{ob.year}</span>.</li>"

    else
      puts "don't recognize type: #{ob.btype}"
      exit
    end
# Ho, M.; Pemberton, J. E. Anal. Chem.1998, 70, 4915–4920.
# (2) Bard, A. J.; Faulker, L. R. Electrochemical Methods, 2nd ed.; Wiley:
# New York; 2001.
# (3) Francesconi, K. A.; Kuehnelt, D. In Environmental Chemistry of Arsenic;
# Frankenberger, W. T., Jr., Ed.; Marcel Dekker: New York, 2002;
# pp 51–94.

  else
    #p ob
  string = "<li>#{authors_to_list(ob.authors)} <span style=\"font-style:italic;\">#{format_journal(ob.journal)}</span>. <span style=\"font-weight:bold\">#{ob.year}</span>, <span style=\"font-style:italic;\">#{ob.vol}</span>, #{ob.pages}.</li>"
  end
  string
end


# journal from pubmed
def format_journal(journal)
  if $jrn.key?(journal)
   $jrn[journal].gsub(/(\.\.$)|(\.$)/, "")
  else
    puts "NO KEY FOR: #{journal}"
    nil
  end
end


if $0 == __FILE__
  if ARGV.size < 1
    puts "usage: #{File.basename($0)} pmid ..."
    puts "outputs <li> item of the citation based on internal formatting"
    exit
  end

  ids = ARGV.to_a
  ids.each do |id|
    ob = PubMed.new(id)
    ## FORMAT THE RESULT:

    #ob.attr_as_hash.each do |k,v| puts k.to_s + " : " + v.to_s end


    # Last, F.M.; Last, F.M. <i>Journ.</i> <b>YEAR</b>, <i>VOL</i>, pages-pages.

    # analytical chemistry
    puts ob2html(ob)
  end
end



