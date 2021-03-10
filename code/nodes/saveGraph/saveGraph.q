// code/nodes/saveGraph/saveGraph.q - Save graph node
// Copyright (c) 2021 Kx Systems Inc
//
// Save all the graphs required for report generation

\d .automl

// @kind function
// @category node
// @desc Save all graphs needed for reports 
// @param params {dictionary} All data generated during the preprocessing and
//   prediction stages
// @return {::} All graphs needed for reports are saved to appropriate 
//   location
saveGraph.node.function:{[params]
  if[params[`config;`saveOption]in 0 1;:params];
  savePath:params[`config;`imagesSavePath];
  logFunc:params[`config;`logFunc];
  savePrint:utils.printDict[`graph],savePath;
  logFunc savePrint;
  saveGraph.targetPlot[params;savePath];
  saveGraph.resultPlot[params;savePath]
  saveGraph.impactPlot[params;savePath];
  saveGraph.dataSplitPlot[params;savePath];
  params
  }

// Input information
saveGraph.node.inputs:"!"

// Output information
saveGraph.node.outputs:"!"
