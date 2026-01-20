# .latexmkrc
$lualatex = 'lualatex -halt-on-error -synctex=1 %O %S';
$pdf_mode = 4; 
$postscript_mode = $dvi_mode = 0;
$makeindex = 'upmendex %O -o %D %S';

# auxiliary files
$clean_ext .= ' %R.listing %R.synctex.gz %R.synctex.gz(busy) %R.run.xml %R.loe %R.ltjruby';