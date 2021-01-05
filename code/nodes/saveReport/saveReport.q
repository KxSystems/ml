\d .automl

// @kind function
// @category node
// @fileoverview  Save a Python generated report summarizing the process of
//   reaching the users final model via pyLatex/reportlab
// @param params {dict} All data generated during the preprocessing and
//   prediction stages
// @return {null} Report saved to a location defined by run date and time
saveReport.node.function:{[params]
  if[2<>params[`config]`saveOption;:()];
  params:saveReport.reportDict params;
  saveReport.saveReport params
  }

// Input information
saveReport.node.inputs  :"!"

// Output information
saveReport.node.outputs :"!"
