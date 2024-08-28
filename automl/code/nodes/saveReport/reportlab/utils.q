// code/nodes/saveReport/reportlab/utils.q - Utilities reportlab
// Copyright (c) 2021 Kx Systems Inc
//
// Utilities used for the generation of a reportlab PDF

\d .automl

// Python imports
saveReport.i.canvas:.p.import`reportlab.pdfgen.canvas
saveReport.i.table:.p.import[`reportlab.platypus]`:Table
saveReport.i.np:.p.import`numpy

// @kind function
// @category saveReportUtility
// @desc Convert kdb description table to printable format
// @param tab {table} kdb table to be converted
// @return {dictionary} Table and corresponding height
saveReport.i.printDescripTab:{[tab]
  dti:10&count tab;
  h:dti*27-dti%2;
  tab:value d:dti#tab;
  tab:.ml.df2tab .ml.tab2df[tab][`:round]3;
  t:enlist[enlist[`col],cols tab],key[d],'flip value flip tab;
  `h`t!(h;t)
  }

// @kind function
// @category saveReportUtility
// @desc Convert kdb table to printable format
// @param pdf {<} PDF gen module used
// @param f {int} The placement height from the bottom of the page
// @param tab {table} kdb table to be converted
// @return {int} The placement height from the bottom of the page
saveReport.i.printKDBTable:{[pdf;f;tab]
  dd:{(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}tab;
  cntf:first[count dd]{[m;h;s]ff:saveReport.i.text[m;h 0;15;s h 1;
    "Helvetica";11];
    (ff;1+h 1)}[pdf;;dd]/(f-5;0);
  first cntf
  }

// @kind function
// @category saveReportUtility
// @desc Add text to report
// @param m {<} Pdf gen module used
// @param h {int} The placement height from the bottom of the page
// @param i {int} How far below is the text
// @param txt {string} Text to include
// @param f {int} Font size
// @param s {int} Font size
// @return {int} The placement height from the bottom of the page
saveReport.i.text:{[m;h;i;txt;f;s]
  if[(h-i)<100;h:795;m[`:showPage][];];
  m[`:setFont][pydstr f;s];
  m[`:drawString][30;h-:i;pydstr txt];
  h
  }

// @kind function
// @category saveReportUtility
// @desc Add title to report
// @param m {<} Pdf gen module used
// @param h {int} The placement height from the bottom of the page
// @param i {int} How far below is the text
// @param txt {string} Text to include
// @param f {int} Font size
// @param s {int} Font size
// @return {int} The placement height from the bottom of the page
saveReport.i.title:{[m;h;i;txt;f;s]
  if[(h-i)<100;h:795;m[`:showPage][]];
  m[`:setFont][pydstr f;s];
  m[`:drawString][150;h-:i;pydstr txt];
  h
  }

// @kind function
// @category saveReportUtility
// @desc Add image to report
// @param m {<} Pdf gen module used
// @param fp {string} Filepath
// @param h {int} The placement height from the bottom of the page
// @param i {int} How far below is the text
// @param wi {int} Image width
// @param hi {int} Image height
// @return {int} The placement height from the bottom of the page
saveReport.i.image:{[m;fp;h;i;wi;hi]
  if[(h-i)<100;h:795;m[`:showPage][]];
  m[`:drawImage][pydstr fp;40;h-:i;wi;hi];
  h
  }

// @kind function
// @category saveReportUtility
// @desc Add table to report
// @param m {<} Pdf gen module used
// @param t {<} Pandas table
// @param h {int} The placement height from the bottom of the page
// @param i {int} How far below is the text
// @param wi {int} Image width
// @param hi {int} Image height
// @return {int} The placement height from the bottom of the page
saveReport.i.makeTable:{[m;t;h;i;wi;hi]
  if[(h-i)<100;h:795;m[`:showPage][]]t:saveReport.i.table 
    saveReport.i.np[`:array][t][`:tolist][];
  t[`:wrapOn][m;wi;hi];
  t[`:drawOn][m;30;h-:i];
  h
  }
