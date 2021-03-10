// code/nodes/saveReport/latex/utils.q - Utilities to save latex report
// Copyright (c) 2021 Kx Systems Inc
//
// Utilities used for the generation of a Latex PDF

\d .automl

// @kind function
// @category saveReportUtility
// @desc Load in python latex function
// @return {<} Python latex function
saveReport.i.latexReportGen:.p.get`python_latex

// @kind function
// @category saveReportUtility
// @desc Convert table to a pandas dataframe
// @param tab {table} To be converted to a pandas dataframe
// @return {<} Pandas dataframe object
saveReport.i.tab2dfFunc:{[tab]
  .ml.tab2df[tab][`:round][3]
  }

// @kind function
// @category saveReportUtility
// @desc Convert table to a pandas dataframe
// @param describe {dictionary} Description of input data
// @return {<} Pandas dataframe object
saveReport.i.descriptionTab:{[describe]
  describeDict:enlist[`column]!enlist key describe;
  describeTab:flip[describeDict],'value describe;
  saveReport.i.tab2dfFunc describeTab
  }

// @kind function
// @category saveReportUtility
// @desc Convert table to a pandas dataframe
// @param scoreDict {dictionary} Scores of each model
// @return {<} Pandas dataframe object
saveReport.i.scoringTab:{[scoreDict]
  scoreTab:flip `model`score!(key scoreDict;value scoreDict);
  saveReport.i.tab2dfFunc scoreTab
  }

// @kind function
// @category saveReportUtility
// @desc Convert table to a pandas dataframe
// @param hyperParam {dictionary} Hyperparameters used on the best model
// @return {<} Pandas dataframe object
saveReport.i.gridSearch:{[hyperParams]
  if[99h=type hyperParams;
    grid:flip`param`val!(key hyperParams;value hyperParams);
    hyperParams:saveReport.i.tab2dfFunc grid
    ];
  hyperParams
  }

