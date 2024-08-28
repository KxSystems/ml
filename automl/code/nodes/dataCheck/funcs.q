// code/nodes/dataCheck/funcs.q - Functions called in dataCheck node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of
// .automl.dataCheck

\d .automl

// Configuration update

// @kind function
// @category dataCheck
// @desc Update configuration based on feature dataset and default 
//   parameters
// @param features {table} Feature data as a table
// @param config {dictionary|char[]} Path to JSON file containing configuration 
//   dictionary or a dictionary containing relevant information for the update
//   of augmented with start date/time
// @return {dictionary} Full configuration info needed, augmenting config with
//   any default information
dataCheck.updateConfig:{[features;config]
  typ:config`featureExtractionType;
  // Retrieve boiler plate additions at run start - ignored in custom additions
  standardCfg:`startDate`startTime`featureExtractionType`problemType#config;
  // Retrieve custom configuration information used to update default params
  customCfg:$[`configPath in key config;
    config`configPath;
    `startDate`startTime`featureExtractionType`problemType _ config
    ];
  // Retrieve default params and replace defaults with custom configuration
  updateCfg:$[typ in`normal`nlp`fresh;
    dataCheck.i.getCustomConfig[features;customCfg;config;typ];
    '`$"Inappropriate feature extraction type"
    ];
  config:standardCfg,updateCfg;
  // If applicable add save path information to configuration dictionary
  config,:$[0<config`saveOption;dataCheck.i.pathConstruct config;()!()];
  if[utils.logging;config:dataCheck.i.logging config];
  config[`logFunc]:utils.printFunction[config`printFile;;1;1];
  checks:all not utils[`printing`logging],config`saveOption;
  if[(2=utils.ignoreWarnings)&checks;
    updatePrinting[];
    config[`logFunc]utils.printWarnings`printDefault
    ];
  // Check that no log/save path created already exists
  dataCheck.i.fileNameCheck config;
  warnType:$[config`pythonWarning;`module;`ignore];
  .p.import[`warnings][`:filterwarnings]warnType;
  if[0~checkimport 4;.p.get[`tfWarnings]$[config`pythonWarning;`0;`2]];
  savedWord2Vec:enlist[`savedWord2Vec]!enlist 0b;
  if[0W~config`seed;config[`seed]:"j"$.z.t];
  config,savedWord2Vec
  }

// Data and configuration checking 

// @kind function
// @category dataCheck
// @desc Ensure that any non-default functions a user wishes to use 
//   exist within the current process such that they are callable
// @param config {dictionary} Information relating to the current run of AutoML
// @return {::|err} Null on success, error if function invalid
dataCheck.functions:{[config]
  // List of possible objects where user may input a custom function
  funcs2Search:`predictionFunction`trainTestSplit`significantFeatures,
    `scoringFunctionClassification`scoringFunctionRegression,
    `gridSearchFunction`randomSearchFunction`crossValidationFunction;
  funcs:raze config funcs2Search;
  // Ensure the custom inputs are suitably typed
  typeCheck:{$[not type[utils.qpyFuncSearch x]in(99h;100h;104h;105h);'err;0b]};
  locs:@[typeCheck;;{[err]err;1b}]each funcs;
  if[0<cnt:sum locs;
    strFunc:{$[2>x;" ",raze[y]," is";"s ",sv[", ";y]," are"]};
    functionList:strFunc[cnt]string funcs where locs;
    '`$"The function",/functionList," not defined in your process\n"
    ];
  }

// @kind function
// @category dataCheck
// @desc Ensure that NLP functionality is available
// @param config {dictionary} Information relating to the current run of AutoML
// @return {::|err} Null on success, error if requirements insufficient
dataCheck.NLPLoad:{[config]
  if[not`nlp~config`featureExtractionType;:()];
  if[not(0~checkimport 3)&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
    '"User attempting to run NLP models with insufficient requirements,",
     " see documentation"
    ];
  if[(""~getenv`PYTHONHASHSEED)&utils.ignoreWarnings>0;
    config[`logFunc]utils.printWarnings`pythonHashSeed
    ];
  }

// @kind function
// @category dataCheck
// @desc Ensure data contains appropriate types for application of NLP
// @param config {dictionary} Information relating to the current run of AutoML
// @param features {table} Feature data as a table
// @return {::|err} Null on success, error for inappropriate data
dataCheck.NLPSchema:{[config;features]
  if[not`nlp~config`featureExtractionType;:()];
  if[0~count .ml.i.findCols[features;"C"];
    '`$"User wishing to apply nlp functionality must pass a table containing ",
     "a character column."
    ];
  }

// @kind function
// @category dataCheck
// @desc Remove feature columns which do not conform to allowed schema
// @param features {table} Feature data as a table
// @param config {dictionary} Information relating to the current run of AutoML
// @return {table} Feature dataset with inappropriate columns removed
dataCheck.featureTypes:{[features;config]
  typ:config`featureExtractionType;
  $[typ in`tseries`normal;
    [fCols:.ml.i.findCols[features;"sfihjbepmdznuvt"];
     tab:flip fCols!features fCols
    ];
    typ=`fresh;
    // Ignore aggregating columns for FRESH as these can be of any type
    [apprCols:flip(aggCols:config[`aggregationColumns])_ flip features;
     cls:.ml.i.findCols[apprCols;"sfiehjb"];
     // Restore aggregating columns
     tab:flip(aggCols!features aggCols,:()),cls!features cls;
     fCols:cols tab
     ];
    typ=`nlp;
    [fCols:.ml.i.findCols[features;"sfihjbepmdznuvtC"];
     tab:flip fCols!features fCols
     ];
    '`$"This form of feature extraction is not currently supported"
    ];
  dataCheck.i.errColumns[cols features;fCols;typ;config];
  tab
  }

// @kind function
// @category dataCheck
// @desc Ensure target data and final feature dataset are same length
// @param features {table} Feature data as a table
// @param target {number[]|symbol[]} Target data as a numeric/symbol vector 
// @param config {dictionary} Information relating to the current run of AutoML
// @return {::|err} Null on success, error if mismatch in length
dataCheck.length:{[features;target;config]
  typ:config`featureExtractionType;
  $[-11h=type typ;
    $[`fresh=typ;
     // Check that the number of unique aggregate equals the number of targets
      [aggcols:config`aggregationColumns;
       featAggCols:$[1=count aggcols;features aggcols;(,'/)features aggcols];
       if[count[target]<>count distinct featAggCols;
         '`$"Target count must equal count of unique agg values for FRESH"
         ];
       ];
      typ in`normal`nlp;
        if[count[target]<>count features;
          '"Must have the same number of targets as values in table"
          ];
      '"Input for typ must be a supported type"
      ];
    '"Input for typ must be a supported symbol"
    ];
  }

// @kind function
// @category dataCheck
// @desc Ensure target data contains more than one unique value
// @param target {(number[]|symbol[])} Target data as a numeric/symbol vector
// @return {::|err} Null on success, error on unsuitable target
dataCheck.target:{[target]
  if[1=count distinct target;'"Target must have more than one unique value"]
  }

// @kind function
// @category dataCheck
// @desc Checks that the trainTestSplit size provided in config is a 
//   floating value between 0 and 1
// @param config {dictionary} Information relating to the current run of AutoML
// @return {::|err} Null on success, error on unsuitable target
dataCheck.ttsSize:{[config]
  if[(sz<0.)|(sz>1.)|-9h<>type sz:config`testingSize;
    '"Testing size must be in range 0-1"
    ]
  }
