// code/nodes/saveReport/saveReport.q - Save report node
// Copyright (c) 2021 Kx Systems Inc
//
// Save report summarizing automl pipeline results

\d .automl

// @kind function
// @category node
// @desc Save a Python generated report summarizing the process of
//   reaching the users final model via pyLatex/reportlab
// @param params {dictionary} All data generated during the preprocessing and
//   prediction stages
// @return {::} Report saved to a location defined by run date and time
saveReport.node.function:{[params]
  if[2<>params[`config]`saveOption;:()];
  params:saveReport.reportDict params;
  saveReport.saveReport params
  }

// Input information
saveReport.node.inputs:"!"

// Output information
saveReport.node.outputs:"!"
