\d .automl

// For simplicity of implementation this code is written largely in python
// this is necessary as a result of the excessive use of structures such as with clauses
// which are more difficult to handle via embedPy

// @kind function
// @category saveReport
// @fileoverview Generate automl report in latex report generation if available
// @params   {dict} All data generated during the process
// @filePath {str} Location to save the report
// @return {null} Latex report is saved down locally 
saveReport.latexGenerate:{[params;filePath]
  dataDescribe:params`dataDescription;
  hyperParams :params`hyperParams;
  scoreDict   :params[`modelMetaData]`modelScores;
  describeTab :saveReport.i.descriptionTab dataDescribe;
  scoreTab    :saveReport.i.scoringTab scoreDict;
  gridTab     :saveReport.i.gridSearch hyperParams;
  pathDict:params[`savedPlots],`fpath`path!(filePath;.automl.path);
  params:string each params;
  saveReport.i.latexReportGen[params;pathDict;describeTab;scoreTab;gridTab;utils.excludeList];
  }

