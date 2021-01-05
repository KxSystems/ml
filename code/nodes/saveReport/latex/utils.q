\d .automl

// Utilities used for the generation of a Latex PDF

// @kind function
// @category saveReportUtility
// @fileoverview Load in python latex function
// @return {<} Python latex function
saveReport.i.latexReportGen:.p.get`python_latex

// @kind function
// @category saveReportUtility
// @fileoverview Convert table to a pandas dataframe
// @param tab {tab} To be converted to a pandas dataframe
// @return {<} Pandas dataframe object
saveReport.i.tab2dfFunc:{[tab]
  .ml.tab2df[tab][`:round][3]
  }

// @kind function
// @category saveReportUtility
// @fileoverview Convert table to a pandas dataframe
// @param describe {dict} Description of input data
// @return {<} Pandas dataframe object
saveReport.i.descriptionTab:{[describe]
  describeDict:enlist[`column]!enlist key describe;
  describeTab:flip[describeDict],'value describe;
  saveReport.i.tab2dfFunc describeTab
  }

// @kind function
// @category saveReportUtility
// @fileoverview Convert table to a pandas dataframe
// @param scoreDict {dict} Scores of each model
// @return {<} Pandas dataframe object
saveReport.i.scoringTab:{[scoreDict]
  scoreTab:flip `model`score!(key scoreDict;value scoreDict);
  saveReport.i.tab2dfFunc scoreTab
  }

// @kind function
// @category saveReportUtility
// @fileoverview Convert table to a pandas dataframe
// @param hyperParam {dict} Hyperparameters used on the best model
// @return {<} Pandas dataframe object
saveReport.i.gridSearch:{[hyperParams]
  if[99h=type hyperParams;
    grid:flip`param`val!(key hyperParams;value hyperParams);
    hyperParams:saveReport.i.tab2dfFunc grid
    ];
  hyperParams
  }

