// code/nodes/pathConstruct/pathConstruct.q - Path construction for saving
// Copyright (c) 2021 Kx Systems Inc
//
// Construct path to where all graphs/reports are to be saved down. Also join 
// together all information collected during preprocessing, processing and 
// configuration creation in order to provide all information required for 
// the generation of report/meta/graph/model saving.

\d .automl

// @kind function
// @category node
// @desc Construct paths where all graphs/reports are to be saved. Also
//   consolidate all information together that was generated during the process
// @param preProcParams {dictionary} Data generated during the preprocess stage
// @param predictionStore {dictionary} Data generated during the prediction 
//   stage
// @return {dictionary} All data collected along the entire process along with
//   paths to where graphs/reports will be generated
pathConstruct.node.function:{[preProcParams;predictionStore]
  pathConstruct.constructPath preProcParams;
  preProcParams,predictionStore
  }

// Input information
pathConstruct.node.inputs:`preprocParams`predictionStore!"!!"

// Output information
pathConstruct.node.outputs:"!"
