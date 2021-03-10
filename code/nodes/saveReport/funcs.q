// code/nodes/saveReport/funcs.q - Functions called in saveReport node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of
// .automl.saveReport

\d .automl

// @kind function
// @category saveReport
// @desc Create a dictionary with image filenames for report generation
// @param params {dictionary} All data generated during the process
// @return {dictionary} Image filenames for report generation
saveReport.reportDict:{[params]
  config:params`config;
  saveImage:config`imagesSavePath;
  savedPlots:saveImage,/:string key hsym`$saveImage;
  plotNames:$[`class~config`problemType;
    `conf`data`impact;
    `data`impact`reg
    ],`target;
  savedPlots:enlist[`savedPlots]!enlist plotNames!savedPlots;
  params,savedPlots
  }

// @kind function
// @category saveReport
// @desc  Generate and save down procedure report
// @param params {dictionary} All data generated during the process
// @return {::} Report saved to appropriate location 
saveReport.saveReport:{[params]
  savePath:params[`config;`reportSavePath];
  modelName:params`modelName;
  logFunc:params[`config;`logFunc];
  filePath:savePath,"Report_",string modelName;
  savePrint:utils.printDict[`report],savePath;
  logFunc savePrint;
  $[0~checkimport 2;
    @[{saveReport.latexGenerate . x};
      (params;filePath);
      {[params;logFunc;err]
       errorMessage:utils.printDict[`latexError],err,"\n";
       logFunc errorMessage;
       saveReport.reportlabGenerate . params;
       }[(params;filePath);logFunc]
      ];
    saveReport.reportlabGenerate[params;filePath]
    ]
  }
