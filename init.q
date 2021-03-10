// init.q - Load automl library
// Copyright (c) 2021 Kx Systems Inc
//
// The automated machine-learning framework is built 
// largely on the tools available within the Machine Learning Toolkit. 
// The purpose of this framework is to help automate the process of 
// applying machine-learning techniques to real-world problems. In the 
// absence of expert machine-learning engineers this handles the 
// processes within a traditional workflow.

\l ml/ml.q
.ml.loadfile`:init.q

\d .automl 

// Load all nodes required for graph based on init file within 
// associated folder
nodelist:`configuration`featureData`targetData`dataCheck`modelGeneration,
  `featureDescription`labelEncode`dataPreprocessing`featureCreation,
  `featureSignificance`trainTestSplit`runModels`selectModels`optimizeModels,
  `preprocParams`predictParams`pathConstruct`saveGraph`saveMeta`saveReport,
  `saveModels

loadfile`:code/commandLine/utils.q
loadfile`:code/commandLine/cli.q
{loadfile hsym`$"code/nodes/",string[x],"/init.q"}each nodelist;
loadfile`:code/customization/init.q
loadfile`:code/graph.q
loadfile`:code/aml.q
loadfile`:code/utils.q

\d .nlp
.automl.utils.loadNLP[]
\d .automl

-1"\nDocumentation can be found at https://code.kx.com/q/ml/automl/";
