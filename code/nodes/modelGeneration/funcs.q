\d .automl

// Definitions of the main callable functions used in the application of
//   modelGeneration

// @kind function
// @category modelGeneration
// @fileoverview Extraction of an appropriately valued dictionary from a JSON
//   file
// @param config {dict} Information relating to the current run of AutoML
// @return {table} Models extracted from JSON file
modelGeneration.jsonParse:{[config]
  typ:$[`class~config`problemType;`classification;`regression];
  modelPath:path,"/code/customization/models/modelConfig/models.json";
  jsonPath:hsym`$modelPath;
  // Read in JSON file and select models based on problem type
  modelTab:.j.k[raze read0 jsonPath]typ;
  // Convert to desired structure and convert all values to symbols
  modelCols:`model`lib`fnc`seed`typ`apply;
  modelTab:modelCols xcol([]model:key modelTab),'value modelTab;
  // Convert to seed to either `seed or (::)
  seed:modelTab`seed;
  toSeed:{@[x;y;:;z]}/[count[seed]#();(where;where not::)@\:seed;(`seed;::)];
  modelTab:update seed:toSeed from modelTab;
  // Convert rest of table to symbol values
  modelTab:{![x;();0b;enlist[y]!enlist($;enlist`;y)]}/[modelTab;`lib`fnc`typ];
  select from modelTab where apply
  }

// @kind function
// @category modelGeneration
// @fileoverview Extract appropriate models based on the problem type
// @param config {dict} Information relating to the current run of AutoML
// @param modelTab {tab} Information on applicable models based on problem type
// @param target {(num[];sym[])} Numerical or symbol target vector
// @return {tab} Appropriate models based on target and problem type
modelGeneration.modelPrep:{[config;modelTab;target]
  if[`class=config`problemType;
    // For classification tasks remove inappropriate classification models
    modelTab:$[2<count distinct target;
      delete from modelTab where typ=`binary;
      delete from modelTab where lib=`keras,typ=`multi
      ]
    ];
  // Add a column with appropriate initialized models for each row
  update minit:.automl.modelGeneration.modelFunc .'flip(lib;fnc;model)from modelTab
  }

// @kind function
// @category modelGeneration
// @fileoverview Build up the model to be applied based on naming convention
// @param library {sym} Library which forms the basis for the definition
// @param func {sym} Function name if keras or module from which model is 
//   derived for non-keras models  
// @param model {sym} Model being applied within the library
// @return {<} Appropriate function or projection in the case of sklearn
modelGeneration.modelFunc:{[library;func;model]
  $[library in key models;
    get".automl.models.",string[library],".fitScore";
    // Projection used for sklearn models eg '.p.import[`sklearn.svm][`:SVC]'
    {[x;y;z].p.import[x]y}[` sv library,func;hsym model]
    ]
  }
