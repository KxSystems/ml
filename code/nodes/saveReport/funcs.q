\d .automl

// Definitions of the main callable functions used in the application of
//  .automl.saveReport

// @kind function
// @category saveReport
// @fileoverview Create a dictionary with image filenames for report generation
// @param params {dict} All data generated during the process
// @return {dict} Image filenames for report generation
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
// @fileoverview  Generate and save down procedure report
// @param params {dict} All data generated during the process
// @return {null} Report saved to appropriate location 
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
