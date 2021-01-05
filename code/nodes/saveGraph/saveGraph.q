\d .automl

// Save all the graphs required for report generation

// @kind function
// @category node
// @fileoverview Save all graphs needed for reports 
// @param params {dict} All data generated during the preprocessing and
//   prediction stages
// @return {null} All graphs needed for reports are saved to appropriate location
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
saveGraph.node.inputs  :"!"

// Output information
saveGraph.node.outputs :"!"
