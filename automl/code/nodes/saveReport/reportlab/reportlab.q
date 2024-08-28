// code/nodes/saveReport/reportlab/reportlab.q - Report generation
// Copyright (c) 2021 Kx Systems Inc
//
// Python report generation using reportlab

\d .automl

// @kind function
// @category saveReport
// @desc Generate a report using the Python package 'reportlab'.
//   This report outlines the results from a timed + dated run of automl.
// @param params {dictionary} All data generated during the process
// @param filePath {string} Location to save report
// @return {::} Associated pdf report saved to disk
saveReport.reportlabGenerate:{[params;filePath]
  // Main variables
  bestModel:params`modelName;
  modelMeta:params`modelMetaData;
  config:params`config;
  pdf:saveReport.i.canvas[`:Canvas]pydstr filePath,".pdf";
  ptype:$[`class~config`problemType;"classification";"regression"];
  plots:params`savedPlots;
  // Report generation
  // Title
  f:saveReport.i.title[pdf;775;0;"kdb+/q AutoML Procedure Report";
    "Helvetica-BoldOblique";15];
  // Summary
  f:saveReport.i.text[pdf;f;40;"This report outlines the results for a ",ptype,
    " problem achieved through running kdb+/q AutoML.";"Helvetica";11];
  f:saveReport.i.text[pdf;f;30;"This run started on ",string[config`startDate],
    " at ",string[config`startTime],".";"Helvetica";11];
  // Input data
  f:saveReport.i.text[pdf;f;30;"Description of Input Data";"Helvetica-Bold";
    13];
  f:saveReport.i.text[pdf;f;30;"The following is a breakdown of information",
    " for each of the relevant columns in the dataset:";"Helvetica";11];
  ht:saveReport.i.printDescripTab params`dataDescription;
  f:saveReport.i.makeTable[pdf;ht`t;f;ht`h;10;10];
  f:saveReport.i.image[pdf;plots`target;f;250;280;210];
  f:saveReport.i.text[pdf;f;25;"Figure 1: Distribution of input target data";
    "Helvetica";10];
  // Feature extraction and selection
  f:saveReport.i.text[pdf;f;30;"Breakdown of Pre-Processing";"Helvetica-Bold";
    13];
  numSig:count params`sigFeats;
  f:saveReport.i.text[pdf;f;30;@[string config`featureExtractionType;0;upper],
    " feature extraction and selection was performed with a total of ",
    string[numSig],
    " feature",$[1~numSig;;"s",]" produced.";"Helvetica";11];
  f:saveReport.i.text[pdf;f;30;"Feature extraction took ",
  string[params`creationTime], " time in total.";"Helvetica";11];
  // Cross validation
  f:saveReport.i.text[pdf;f;30;"Initial Scores";"Helvetica-Bold";13];
  xvalFunc:string config[`crossValidationFunction];
  xvalSize:config[`crossValidationArgument];
  xvalType:`$last"."vs xvalFunc;
  xval:$[xvalType in`mcsplit`pcsplit;
    "Percentage based cross validation, ",xvalFunc,
    ", was performed with a testing set created from ",
    string[100*xvalSize],"% of the training data.";
    string[xvalSize],"-fold cross validation was performed on the training",
    " set to find the best model using ",xvalFunc,"."
    ];
  f:saveReport.i.text[pdf;f;30;xval;"Helvetica";11];
  f:saveReport.i.image[pdf;plots`data;f;90;500;100];
  f:saveReport.i.text[pdf;f;25;"Figure 2: The data split used within this",
  " run of AutoML, with data split into training, holdout and testing sets";
  "Helvetica";10];
  f:saveReport.i.text[pdf;f;30;"The total time taken to carry out cross", 
  " validation for each model on the training set was ",
  string[modelMeta`xValTime];"Helvetica";11];
  f:saveReport.i.text[pdf;f;15;"where models were scored and optimized using ",
    string[modelMeta`metric],".";"Helvetica";11];
  f:saveReport.i.text[pdf;f;30;"Model scores:";"Helvetica";11];
  // Feature impact
  f:saveReport.i.printKDBTable[pdf;f;modelMeta`modelScores];
  f:saveReport.i.image[pdf;plots`impact;f;250;280;210];
  f:saveReport.i.text[pdf;f;25;"Figure 3: Feature impact of each significant",
  " feature as determined by the training set";"Helvetica";10];
  // Run models
  f:saveReport.i.text[pdf;f;30;"Model selection summary";"Helvetica-Bold";13];
  f:saveReport.i.text[pdf;f;30;"Best scoring model = ",string bestModel;
    "Helvetica";11];
  f:saveReport.i.text[pdf;f;30;"The score on the holdout set for this model", 
  " was = ", string[ modelMeta`holdoutScore],".";"Helvetica";11];
  f:saveReport.i.text[pdf;f;30;"The total time taken to complete the running",
  " of this model on the holdout set was: ",
  string[modelMeta`holdoutTime],".";"Helvetica";11];
  // Hyperparameter search
  srch:config`hyperparameterSearchType;
  hptyp:$[srch=`grid;
    "grid";
    srch in`random`sobol;
    "random";
    '"inappropriate type"
    ];
  hpFunc:string config`$hptyp,"SearchFunction";
  hpSize:string config`$hptyp,"SearchArgument";
  hpMethod:`$last"."vs hpFunc;
  f:saveReport.i.text[pdf;f;30;"Best Model";"Helvetica-Bold";13];
  if[not bestModel in utils.excludeList;
    f:saveReport.i.text[pdf;f;30;;"Helvetica";11]$[hpMethod in`mcsplit`pcsplit;
      "The hyperparameter search was completed using ",hpFunc,
      " with a percentage of ",hpSize,"% of training data used for validation";
      "A ",hpSize,"-fold ",lower[hptyp]," search was performed on the",
      " training set to find the best model using, ",hpFunc,"."];
    f:saveReport.i.text[pdf;f;30;"The following are the hyperparameters",
      " which have been deemed optimal for the model:";"Helvetica";11];
    f:saveReport.i.printKDBTable[pdf;f;params`hyperParams];
    ];
  // Final results
  f:saveReport.i.text[pdf;f;30;"The score for the best model fit on the",
  " entire training set and scored on the testing set was = ",
    string params`testScore;"Helvetica";11];
  $[ptype like"*class*";
    [f:saveReport.i.image[pdf;plots`conf;f;300;250;250];
     saveReport.i.text[pdf;f;25;"Figure 4: This is the confusion matrix",
     " produced for predictions made on the testing set";"Helvetica";10]
     ];
    [f:saveReport.i.image[pdf;plots`reg;f;300;250;250];
     saveReport.i.text[pdf;f;25;"Figure 4: Regression analysis plot produced",
       " for predictions made on the testing set";"Helvetica";10]
     ];
    ];
  pdf[`:save][];
  }
