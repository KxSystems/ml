\d .automl

canvas:.p.import[`reportlab.pdfgen.canvas]
table:.p.import[`reportlab.platypus]`:Table
np:.p.import`numpy

// Generate a report using FPDF outlining the results from a run of the automl pipeline
/* dict  = dictionary with needed with values for the pdf
/* dt    = dictionary denoting the start and end time of an automl run
/* fname = This is a file path which denotes a save location for the generated report.
/. r     > returns a null with an associated pdf report saved to disk
post.report:{[dict;dt;fname;ptype]
 bst_mdl:first[key[dict`model_scores]];
 pdf:canvas[`:Canvas][fname,"q_automl_report_",ssr[sv["_";string(bst_mdl;dt`sttime)],".pdf";":";"."]];

 font[pdf;"Helvetica-BoldOblique";15];  
 f:title[pdf;775;0;"kdb+/q AutoML model generated report"];

 font[pdf;"Helvetica";11];
 f:cell[pdf;f;40;"This report outlines the results for a ",ssr[string ptype;"_";" "]," problem achieved through the running "];

 f:cell[pdf;f;15;"of kdb+/q autoML. This run started at ",string[dt`stdate]," at ",string[dt`sttime],"."];

 font[pdf;"Helvetica-Bold";13];
 f:cell[pdf;f;30;"Description of Input Data"];

 font[pdf;"Helvetica";11];
 f:cell[pdf;f;30;"The following is a breakdown of information for each of the relevant columns in the dataset"];

 vd:.ml.df2tab .ml.tab2df[value d:(dti:10&count dict`describe)#dict`describe][`:round][3];
 t:enlist[enlist[`col],cols vd],key[d],'flip value flip vd;
 f:mktab[pdf;t;f;(27-(dti%2))*dti;10;10];

 font[pdf;"Helvetica-Bold";13];
 f:cell[pdf;f;30;"Breakdown of Pre-Processing"];

 font[pdf;"Helvetica";11];
 f:cell[pdf;f;30;string[dict[`typ]]," feature extraction was performed with a total of ",string[dict`cnt_feats]," features produced."];

 f:cell[pdf;f;30;"Feature extraction took ",string[dict`feat_time]," time in total."];

 font[pdf;"Helvetica-Bold";13];
 f:cell[pdf;f;30;"Initial Scores"];

 font[pdf;"Helvetica";11];
 xval:$[(dict[`xv]0)in `mcsplit`pcsplit;
         "A percentage based cross validation .ml.",string[dict[`xv]0],
           " was performed with a set of size ",string[dict[`xv]1],
           " of training data used as holdout.";
         string[dict[`xv]1],"-fold cross validation was performed on the training ",
           "set to find the best model using, ",string[dict[`xv]0],"."];
 f:cell[pdf;f;30;xval];
 
 f:image[pdf;path,"/code/postproc/images/train_test_validate.png";f;90;500;70];
 font[pdf;"Helvetica";10];
 f:cell[pdf;f;25;"Figure 1: This is representative image showing the data split into training, validation and testing sets."];

 font[pdf;"Helvetica";11];
 f:cell[pdf;f;30;"The total time to complete the running of cross validation for each of the models on the training set was: "];
 f:cell[pdf;f;15;string[dict`xval_time],"."];

 f:cell[pdf;f;30;"The metric that is being used for scoring and optimizing the models was: ",string[dict`metric],"."];

 // Take in a kdb dictionary for printing line by line to the pdf file.
 dd:{(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}dict`model_scores;
 cntf:first [count dd]{[m;h;s]ff:cell[m;h[0];15;s[h[1]]];(ff;1+h[1])}[pdf;;dd]/(f-5;0);
 f:first cntf;

 f:image[pdf;dict`impact_plot;f;350;400;300];
 font[pdf;"Helvetica";10];
 f:cell[pdf;f;25;"Figure 2: This is the feature impact for a number of the most significant features as determined on the training set"];

 font[pdf;"Helvetica-Bold";13];
 f:cell[pdf;f;30;"Model selection summary"];

 font[pdf;"Helvetica";11];
 f:cell[pdf;f;30;"Best scoring model = ",string bst_mdl];

 f:cell[pdf;f;30;"The score on the validation set for this model was = ",string[dict`holdout],"."];

 f:cell[pdf;f;30;"The total time to complete the running of this model on the validation set was: ",string[dict`val_time],"."];

 hptyp:@[;0;upper]string srch:dict`hp;
 hptyp:enlist[hptyp],$[srch=`grid;`gs;srch in`random`sobol;`rs];

 if[not bst_mdl in i.excludelist;
   font[pdf;"Helvetica-Bold";13];
   hptitle:hptyp[0]," search for a ",string[bst_mdl]," model.";
   f:cell[pdf;f;30;hptyp[0]," search for a ",string[bst_mdl]," model."];
   
   font[pdf;"Helvetica";11];
   f:cell[pdf;f;30;]$[(dict[hptyp 1]0)in `mcsplit`pcsplit;
           "The hyperparameter search was completed using .ml.",string[hptyp 1],".",string[dict[hptyp 1]0],
             " with a percentage of ",string[dict[hptyp 1]1],"% of training data used for validation";
           "A ",string[dict[hptyp 1]1],"-fold ",lower[hptyp 0],"-search was performed on the training + validation set",
             " to find the best model using, ",string[dict[hptyp 1]0],"."];
   
   font[pdf;"Helvetica";11];
   f:cell[pdf;f;30;"The following are the hyperparameters which have been deemed optimal for the model"];
   
   dhp:{(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}dict`hyper_params;
   cntf:first [count dhp]{[m;h;s]ff:cell[m;h[0];15;s[h[1]]];(ff;1+h[1])}[pdf;;dhp]/(f-5;0);
   f:first cntf];
  
  f:cell[pdf;f;30;"The score for the best model fit on the entire training set and scored on the test set was = ",string[dict`test_score]];

 if[string[ptype]like"*class*";
    f:image[pdf;dict`conf_plot;f;350;350;350];
    font[pdf;"Helvetica";10];
    cell[pdf;f;25;"Figure 3: This is the confusion matrix produced for predictions made on the testing set"]];

  pdf[`:save][];
 }


// Utilities for the report generation functionality
/* m =   pdf gen module used
/* i =   how far below is the text
/* h =   the placement height from the bottom of the page 
/* f =   font size
/* s =   font size
/* txt = text to include
/* fp =  filepath
/* wi =  image width
/* hi =  image height
/* t  =  pandas table
font:{[m;f;s]m[`:setFont][f;s]}
cell:{[m;h;i;txt]if[(h-i)<100;h:795;m[`:showPage][]];
     m[`:drawString][30;h-:i;txt];h}
title:{[m;h;i;txt]if[(h-i)<100;h:795;m[`:showPage][]];
    m[`:drawString][150;h-:i;txt];h}
image:{[m;fp;h;i;wi;hi]if[(h-i)<100;h:795;m[`:showPage][]];
    m[`:drawImage][fp;40;h-:i;wi;hi];h}
mktab:{[m;t;h;i;wi;hi]if[(h-i)<100;h:795;m[`:showPage][]]
 t:table np[`:array][t][`:tolist][];
 t[`:wrapOn][m;wi;hi];
 t[`:drawOn][m;30;h-:i];h};