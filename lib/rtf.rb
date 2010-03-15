module RTF

  def rtf_num_list(items, num_spacer_lines=0)
    with_number = items.collect do |item|
      '\par \pard\plain {\listtext\pard\plain \li283\ri0\lin283\rin0\fi-283\f2\f2\f4 2.}\ilvl0 \ltrpar\s1\ls0\li283\ri0\lin283\rin0\fi-283\rtlch\af4\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f2\fs24\lang1033{\loch\f2\fs24\lang1033\i0\b0\*\cs8\cf0\rtlch\ltrch\dbch\loch\f1\fs24\lang1033 ' + item.to_s + '}'
    end

    ## Add spacers
    spacing = ""
    rtf_list_spacer = '\par \pard\plain \ltrpar\s1\li283\ri0\lin283\rin0\fi0\rtlch\af4\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f2\fs24\lang1033'
    spacer_lines = []
    num_spacer_lines.times do
      spacer_lines.push(rtf_list_spacer)
    end
    if spacer_lines.size > 0
      spacing = spacer_lines.join("\n")
    else
      spacing = ""
    end
    with_number.join(spacing)
  end

  def in_text_citation(string, font_size=7, citation_height=5)
    rtf_fontsize = font_size * 2
    return '{\fs' + rtf_fontsize.to_s + '{\*\updnprop10000}\up'+ citation_height.to_s + ' ' + string.to_s + '}'
  end


  def rtf_stylesheet_insert_for_list
    '{\*\cs7\cf0\rtlch\af3\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033 Numbering Symbols;}'
  end

  def rtf_list_header
    # NOTE THE triple quotes are necessary to end up with: \'
    string = '
{\*\listtable{\list\listtemplateid1
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'00.;}{\levelnumbers\\\'01;}\fi-283\li283}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'01.;}{\levelnumbers\\\'01;}\fi-283\li567}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'02.;}{\levelnumbers\\\'01;}\fi-283\li850}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'03.;}{\levelnumbers\\\'01;}\fi-283\li1134}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'04.;}{\levelnumbers\\\'01;}\fi-283\li1417}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'05.;}{\levelnumbers\\\'01;}\fi-283\li1701}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'06.;}{\levelnumbers\\\'01;}\fi-283\li1984}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'07.;}{\levelnumbers\\\'01;}\fi-283\li2268}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'08.;}{\levelnumbers\\\'01;}\fi-283\li2551}
{\*\soutlvl{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \\\'02\\\'09.;}{\levelnumbers\\\'01;}\fi-283\li2835}}\listid1}
}{\listoverridetable{\listoverride\listid1\listoverridecount0\ls0}}

'
  end

  # returns an rtf header string
  def footer
    '}'
  end
  # italicized text
  def i(string)
    if string 
      return '{\i\insrsid6900457 ' + string + '}'
    else
      return ""
    end
  end
  # underlined text
  def u(string)
    if string 
    '{\ul\insrsid6900457\charrsid6900457 '+string+'}'
    else
      return ""
    end
  end
  # bold text
  def b(string)
    if string 
    '{\b\insrsid6900457\charrsid6900457 '+string+'}'
    else
      return ""
    end
  end
  # Normal text
  def n(string)
    if string 
    '{\insrsid6900457 '+string+'}'
    else
      return ""
    end
  end
  # returns a normal '.'
  def dot
    '{\insrsid6900457 '+ '.' +'}'
  end

  # returns a normal '. '
  def ds
    '{\insrsid6900457 '+ '. ' +'}'
  end
  # returns a normal ' .'
  def sd 
    '{\insrsid6900457 '+ ' .' +'}'
  end
  # parenthesized: adds () around the non nil strings
  # NOTE: will not parenthesize nil or empty ("") string!
  def para(string)
    if string && string != "" 
      return '(' + string + ')'
    else
      return ""
    end
  end
  # space of normal text
  def s
    '{\insrsid6900457 '+ ' ' +'}'
  end
  def newline(number)
    string = '{\insrsid13852479' + "\n"
    pars = []
    number.times {pars << '\par'}
    string << pars.join("\n")
    string << '}'
    string
  end

  # returns a new string with the list info embedded
  def insert_list_to_header(rtf_string)
    search_string = '{\stylesheet'
    #puts "RTF_string: " + rtf_string + "**********"
    not_interested, header = rtf_string.split(search_string)
    return rtf_string unless header
    new_string = ""
    brack_cnt = 0
    #   {stuff}{stuff}{insert my stuff}}insert list stuff
    nothing_left_to_do = false
    header.scan(/.|\n/) do |letter|
      if nothing_left_to_do
        new_string << letter
        next
      end
      if letter == "{"
        brack_cnt += 1
      elsif letter == '}'
        brack_cnt -= 1
      end
      if brack_cnt < 0
        new_string << rtf_stylesheet_insert_for_list
        new_string << '}'
        new_string << rtf_list_header
        nothing_left_to_do = true
      else
        new_string << letter
      end
    end
    new_rtf = [not_interested,new_string].join(search_string)
    return new_rtf
  end
end

 

=begin

# this is the microsoft rtf header

    return '{\rtf1\ansi\ansicpg1252\uc1\deff0\stshfdbch0\stshfloch0\stshfhich0\stshfbi0\deflang1033\deflangfe1033{\fonttbl{\f0\froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;}{\f119\froman\fcharset238\fprq2 Times New Roman CE;}
{\f120\froman\fcharset204\fprq2 Times New Roman Cyr;}{\f122\froman\fcharset161\fprq2 Times New Roman Greek;}{\f123\froman\fcharset162\fprq2 Times New Roman Tur;}{\f124\froman\fcharset177\fprq2 Times New Roman (Hebrew);}
{\f125\froman\fcharset178\fprq2 Times New Roman (Arabic);}{\f126\froman\fcharset186\fprq2 Times New Roman Baltic;}{\f127\froman\fcharset163\fprq2 Times New Roman (Vietnamese);}}{\colortbl;\red0\green0\blue0;\red0\green0\blue255;\red0\green255\blue255;
\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;
\red128\green128\blue128;\red192\green192\blue192;}{\stylesheet{\ql \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1033\langfe1033\cgrid\langnp1033\langfenp1033 \snext0 Normal;}{\*\cs10 \additive \ssemihidden
Default Paragraph Font;}{\*\ts11\tsrowd\trftsWidthB3\trpaddl108\trpaddr108\trpaddfl3\trpaddft3\trpaddfb3\trpaddfr3\tscellwidthfts0\tsvertalt\tsbrdrt\tsbrdrl\tsbrdrb\tsbrdrr\tsbrdrdgl\tsbrdrdgr\tsbrdrh\tsbrdrv
\ql \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs20\lang1024\langfe1024\cgrid\langnp1024\langfenp1024 \snext11 \ssemihidden Normal Table;}}{\*\rsidtbl \rsid6900457}{\*\generator Microsoft Word 10.0.2627;}{\info
{\title This part normal}{\author john}{\operator john}{\creatim\yr2003\mo3\dy19\hr17\min13}{\revtim\yr2003\mo3\dy19\hr17\min14}{\version1}{\edmins1}{\nofpages1}{\nofwords14}{\nofchars83}{\*\company UT Austin}{\nofcharsws96}{\vern16437}}
\widowctrl\ftnbj\aenddoc\noxlattoyen\expshrtn\noultrlspc\dntblnsbdb\nospaceforul\formshade\horzdoc\dgmargin\dghspace180\dgvspace180\dghorigin1800\dgvorigin1440\dghshow1\dgvshow1
\jexpand\viewkind1\viewscale100\pgbrdrhead\pgbrdrfoot\splytwnine\ftnlytwnine\htmautsp\nolnhtadjtbl\useltbaln\alntblind\lytcalctblwd\lyttblrtgr\lnbrkrule\nobrkwrptbl\snaptogridincell\allowfieldendsel\wrppunct\asianbrkrule\rsidroot6900457 \fet0\sectd
\linex0\endnhere\sectlinegrid360\sectdefaultcl\sftnbj {\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang {\pntxta .}}{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang {\pntxta .}}{\*\pnseclvl3\pndec\pnstart1\pnindent720\pnhang {\pntxta .}}{\*\pnseclvl4
\pnlcltr\pnstart1\pnindent720\pnhang {\pntxta )}}{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang {\pntxtb (}
{\pntxta )}}{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}\pard\plain \ql \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0
\fs24\lang1033\langfe1033\cgrid\langnp1033\langfenp1033'


# the oofice header
# includes formatting for lists!
  def header
    return '{\rtf1\ansi\deff0\adeflang1025
{\fonttbl{\f0\froman\fprq2\fcharset0 Nimbus Roman No9 L;}{\f1\froman\fprq2\fcharset0 Nimbus Roman No9 L;}{\f2\fnil\fprq2\fcharset0 Bitstream Vera Sans;}{\f3\fnil\fprq2\fcharset0 Lucidasans;}{\f4\fnil\fprq0\fcharset0 Lucidasans;}}
{\colortbl;\red0\green0\blue0;\red128\green128\blue128;}
{\stylesheet{\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af3\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033\snext1 Default;}
{\s2\sa120\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af3\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033\sbasedon1\snext2 Text body;}
{\s3\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033\sbasedon2\snext3 List;}
{\s4\sb120\sa120\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs20\lang255\ai\ltrch\dbch\af2\afs20\langfe255\ai\loch\f0\fs20\lang1033\i\sbasedon1\snext4 Caption;}
{\s5\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033\sbasedon1\snext5 Index;}
{\*\cs7\cf0\rtlch\af3\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033 Numbering Symbols;}
}{\*\listtable{\list\listtemplateid1
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'00.;}{\levelnumbers\'01;}\fi-283\li283}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'01.;}{\levelnumbers\'01;}\fi-283\li567}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'02.;}{\levelnumbers\'01;}\fi-283\li850}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'03.;}{\levelnumbers\'01;}\fi-283\li1134}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'04.;}{\levelnumbers\'01;}\fi-283\li1417}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'05.;}{\levelnumbers\'01;}\fi-283\li1701}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'06.;}{\levelnumbers\'01;}\fi-283\li1984}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'07.;}{\levelnumbers\'01;}\fi-283\li2268}
{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'08.;}{\levelnumbers\'01;}\fi-283\li2551}
{\*\soutlvl{\listlevel\levelnfc0\leveljc0\levelstartat1\levelfollow2{\leveltext \'02\'09.;}{\levelnumbers\'01;}\fi-283\li2835}}\listid1}
}{\listoverridetable{\listoverride\listid1\listoverridecount0\ls0}}

{\info{\creatim\yr2005\mo10\dy28\hr8\min49}{\revtim\yr2005\mo10\dy28\hr8\min49}{\printim\yr1601\mo1\dy1\hr0\min0}{\comment StarWriter}{\vern6450}}\deftab709
{\*\pgdsctbl
{\pgdsc0\pgdscuse195\pgwsxn12240\pghsxn15840\marglsxn1800\margrsxn1800\margtsxn1440\margbsxn1440\pgdscnxt0 Default;}}
\paperh15840\paperw12240\margl1800\margr1800\margt1440\margb1440\sectd\sbknone\pgwsxn12240\pghsxn15840\marglsxn1800\margrsxn1800\margtsxn1440\margbsxn1440\ftnbj\ftnstart1\ftnrstcont\ftnnar\aenddoc\aftnrstcont\aftnstart1\aftnnrlc
\pard\plain {\listtext\pard\plain \li283\ri0\lin283\rin0\fi-283 1.}\ilvl0 \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\ls0\li283\ri0\lin283\rin0\fi-283\rtlch\af3\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033 {\loch\f0\fs24\lang1033\i0\b0 First item}
\par \pard\plain {\listtext\pard\plain \li283\ri0\lin283\rin0\fi-283 2.}\ilvl0 \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\ls0\li283\ri0\lin283\rin0\fi-283\rtlch\af3\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033 {\loch\f0\fs24\lang1033\i0\b0 Second}
\par \pard\plain {\listtext\pard\plain \li283\ri0\lin283\rin0\fi-283 3.}\ilvl0 \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\ls0\li283\ri0\lin283\rin0\fi-283\rtlch\af3\afs24\lang255\ltrch\dbch\af2\afs24\langfe255\loch\f0\fs24\lang1033 {\loch\f0\fs24\lang1033\i0\b0 Third}
\par }'

  end

=end


