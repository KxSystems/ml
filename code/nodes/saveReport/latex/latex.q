// code/nodes/saveReport/latex/latex.q - Save latex report
// Copyright (c) 2021 Kx Systems Inc
//
// Save report summarizing automl pipeline results

\d .automl

// For simplicity of implementation this code is written largely in python
// this is necessary as a result of the excessive use of structures such as
// with clauses which are more difficult to handle via embedPy

// @kind function
// @category saveReport
// @desc Generate automl report in latex report generation if available
// @params {dictionary} All data generated during the process
// @filePath {string} Location to save the report
// @return {::} Latex report is saved down locally 
saveReport.latexGenerate:{[params;filePath]
  dataDescribe:params`dataDescription;
  hyperParams:params`hyperParams;
  scoreDict:params[`modelMetaData]`modelScores;
  describeTab:saveReport.i.descriptionTab dataDescribe;
  scoreTab:saveReport.i.scoringTab scoreDict;
  gridTab:saveReport.i.gridSearch hyperParams;
  pathDict:params[`savedPlots],`fpath`path!(filePath;.automl.path);
  params:string each params;
  saveReport.i.latexReportGen[params;pathDict;describeTab;scoreTab;gridTab;
    utils.excludeList];
  }

