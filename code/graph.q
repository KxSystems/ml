// code/graph.q - Generate graph for automl
// Copyright (c) 2021 Kx Systems Inc
//
// Generate the complete graph for AutoML following the configuration defined
// in `graph/Automl_graph.png`. Code is structured through the addition of all
// relevant nodes followed by the connection of input nodes for these nodes to
// the relevant source node.

\d .automl

// Generate an empty graph
graph:.ml.createGraph[]

// Populate all required Nodes for the graph
graph:.ml.addNode[graph;`configuration      ;configuration.node]
graph:.ml.addNode[graph;`featureData        ;featureData.node]
graph:.ml.addNode[graph;`targetData         ;targetData.node]
graph:.ml.addNode[graph;`dataCheck          ;dataCheck.node]
graph:.ml.addNode[graph;`modelGeneration    ;modelGeneration.node]
graph:.ml.addNode[graph;`featureDescription ;featureDescription.node]
graph:.ml.addNode[graph;`labelEncode        ;labelEncode.node]
graph:.ml.addNode[graph;`dataPreprocessing  ;dataPreprocessing.node]
graph:.ml.addNode[graph;`featureCreation    ;featureCreation.node]
graph:.ml.addNode[graph;`featureSignificance;featureSignificance.node]
graph:.ml.addNode[graph;`trainTestSplit     ;trainTestSplit.node]
graph:.ml.addNode[graph;`selectModels       ;selectModels.node]
graph:.ml.addNode[graph;`runModels          ;runModels.node]
graph:.ml.addNode[graph;`optimizeModels     ;optimizeModels.node]
graph:.ml.addNode[graph;`preprocParams      ;preprocParams.node]
graph:.ml.addNode[graph;`predictParams      ;predictParams.node]
graph:.ml.addNode[graph;`pathConstruct      ;pathConstruct.node]
graph:.ml.addNode[graph;`saveGraph          ;saveGraph.node]
graph:.ml.addNode[graph;`saveMeta           ;saveMeta.node]
graph:.ml.addNode[graph;`saveReport         ;saveReport.node]
graph:.ml.addNode[graph;`saveModels         ;saveModels.node]


// Connect all possible edges prior to the data/config ingestion

// dataCheck
graph:.ml.connectEdge[graph;`configuration;`output;`dataCheck;`config];
graph:.ml.connectEdge[graph;`featureData  ;`output;`dataCheck;`features];
graph:.ml.connectEdge[graph;`targetData   ;`output;`dataCheck;`target];

// modelGeneration
graph:.ml.connectEdge[graph;`dataCheck;`config;`modelGeneration;`config]
graph:.ml.connectEdge[graph;`dataCheck;`target;`modelGeneration;`target]

// featureDescription
graph:.ml.connectEdge[graph;`dataCheck;`config  ;`featureDescription;`config]
graph:.ml.connectEdge[graph;`dataCheck;`features;`featureDescription;`features]

// labelEncode
graph:.ml.connectEdge[graph;`dataCheck;`target;`labelEncode;`input]

// dataPreprocessing
graph:.ml.connectEdge[graph;`dataCheck         ;`config   ;`dataPreprocessing;
  `config]
graph:.ml.connectEdge[graph;`featureDescription;`features ;`dataPreprocessing;
  `features]
graph:.ml.connectEdge[graph;`featureDescription;`symEncode;`dataPreprocessing;
  `symEncode]

// featureCreation
graph:.ml.connectEdge[graph;`dataPreprocessing;`output;`featureCreation;
  `features]
graph:.ml.connectEdge[graph;`dataCheck        ;`config;`featureCreation;
  `config]

// featureSignificance
graph:.ml.connectEdge[graph;`featureCreation;`features;`featureSignificance;
  `features]
graph:.ml.connectEdge[graph;`labelEncode    ;`target  ;`featureSignificance;
  `target]
graph:.ml.connectEdge[graph;`dataCheck      ;`config  ;`featureSignificance;
  `config]

// trainTestSplit
graph:.ml.connectEdge[graph;`featureSignificance;`features;`trainTestSplit;
  `features]
graph:.ml.connectEdge[graph;`featureSignificance;`sigFeats;`trainTestSplit;
  `sigFeats]
graph:.ml.connectEdge[graph;`labelEncode        ;`target  ;`trainTestSplit;
  `target]
graph:.ml.connectEdge[graph;`dataCheck          ;`config  ;`trainTestSplit;
  `config]

// selectModels
graph:.ml.connectEdge[graph;`trainTestSplit ;`output;`selectModels;`ttsObject]
graph:.ml.connectEdge[graph;`labelEncode    ;`target;`selectModels;`target]
graph:.ml.connectEdge[graph;`dataCheck      ;`config;`selectModels;`config]
graph:.ml.connectEdge[graph;`modelGeneration;`output;`selectModels;`models]

// runModels
graph:.ml.connectEdge[graph;`trainTestSplit;`output;`runModels;`ttsObject]
graph:.ml.connectEdge[graph;`selectModels  ;`output;`runModels;`models]
graph:.ml.connectEdge[graph;`dataCheck     ;`config;`runModels;`config]

// optimizeModels
graph:.ml.connectEdge[graph;`runModels     ;`orderFunc      ;`optimizeModels;
  `orderFunc]
graph:.ml.connectEdge[graph;`runModels     ;`bestModel      ;`optimizeModels;
  `bestModel]
graph:.ml.connectEdge[graph;`runModels     ;`bestScoringName;`optimizeModels;
  `bestScoringName]
graph:.ml.connectEdge[graph;`selectModels  ;`output         ;`optimizeModels;
  `models]
graph:.ml.connectEdge[graph;`trainTestSplit;`output         ;`optimizeModels;
  `ttsObject]
graph:.ml.connectEdge[graph;`dataCheck     ;`config         ;`optimizeModels;
  `config]

// preprocParams
graph:.ml.connectEdge[graph;`dataCheck          ;`config         ;
  `preprocParams;`config]
graph:.ml.connectEdge[graph;`featureDescription ;`dataDescription;
  `preprocParams;`dataDescription]
graph:.ml.connectEdge[graph;`featureDescription ;`symEncode      ;
  `preprocParams;`symEncode]
graph:.ml.connectEdge[graph;`featureCreation    ;`creationTime   ;
  `preprocParams;`creationTime]
graph:.ml.connectEdge[graph;`featureSignificance;`sigFeats       ;
  `preprocParams;`sigFeats]
graph:.ml.connectEdge[graph;`labelEncode        ;`symMap         ;
  `preprocParams;`symMap]
graph:.ml.connectEdge[graph;`featureCreation    ;`featModel      ;
  `preprocParams;`featModel]
graph:.ml.connectEdge[graph;`trainTestSplit     ;`output         ;
  `preprocParams;`ttsObject]

// predictParams
graph:.ml.connectEdge[graph;`optimizeModels;`bestModel    ;`predictParams;
  `bestModel]
graph:.ml.connectEdge[graph;`optimizeModels;`modelName    ;`predictParams;
  `modelName]
graph:.ml.connectEdge[graph;`optimizeModels;`testScore    ;`predictParams;
  `testScore]
graph:.ml.connectEdge[graph;`optimizeModels;`hyperParams  ;`predictParams;
  `hyperParams]
graph:.ml.connectEdge[graph;`optimizeModels;`analyzeModel ;`predictParams;
  `analyzeModel]
graph:.ml.connectEdge[graph;`runModels     ;`modelMetaData;`predictParams;
  `modelMetaData]

// pathConstruct
graph:.ml.connectEdge[graph;`predictParams;`output;`pathConstruct;
  `predictionStore]
graph:.ml.connectEdge[graph;`preprocParams;`output;`pathConstruct;
  `preprocParams]

// saveGraph
graph:.ml.connectEdge[graph;`pathConstruct;`output;`saveGraph;`input]

// saveMeta
graph:.ml.connectEdge[graph;`pathConstruct;`output;`saveMeta;`input]

// saveReport
graph:.ml.connectEdge[graph;`saveGraph;`output;`saveReport;`input]

// saveModel
graph:.ml.connectEdge[graph;`pathConstruct;`output;`saveModels;`input]
