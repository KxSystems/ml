// code/nodes/dataPreprocessing/funcs.q - Functions called by dataPreprocessing
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of
// .automl.dataPreprocessing

\d .automl

// @kind function
// @category dataPreprocessing
// @desc Symbol encoding applied to feature data
// @param features {table} Feature data as a table
// @param config {dictionary} Information relating to the current run of AutoML
// @return {table} Feature table encoded appropriately for the task
dataPreprocessing.symEncoding:{[features;config;symEncode]
  typ:config`featureExtractionType;
  // If no symbol columns, return table or empty encoding schema
  if[all{not` in x}each value symEncode;
    if[count symEncode`freq;
      features:$[`fresh~typ;
        [aggColData:0!config[`aggregationColumns]xgroup features;
         raze .ml.freqEncode[;symEncode`freq]each flip each aggColData
        ];
        .ml.freqEncode[features;symEncode`freq]
        ]; 
      ];
    features:.ml.oneHot.fitTransform[0!features;symEncode`ohe];
    // Extract symbol columns from dictionary
    symbolCols:distinct raze symEncode;
    :flip symbolCols _ flip features
    ];
  features
  }

// @kind function
// @category dataPreprocessing
// @desc  Apply preprocessing depending on feature extraction type
// @param features {table} Feature data as a table
// @param config {dictionary} Information relating to the current run of AutoML
// @return {table} Feature table with appropriate feature preprocessing applied
dataPreprocessing.featPreprocess:{[features;config]
  typ:config`featureExtractionType;
  // For FRESH the aggregate columns need to be excluded from the preprocessing
  // steps. This ensures that encoding is not performed on the aggregate 
  // columns if this is a symbol and/or this column is constant.
  if[`fresh=typ;
    aggData:(config[`aggregationColumns],())#flip features;
    features:flip(cols[features]except config`aggregationColumns)#flip features
    ];
  featTable:$[not typ in`nlp;
    dataPreprocessing.nonTextPreprocess features;
    dataPreprocessing.textPreprocess features
    ];
  // Rejoin separated aggregate columns for FRESH
  config[`logFunc]utils.printDict`preproc;
  $[`fresh=typ;flip[aggData],';]featTable
  }

// @kind function
// @category dataPreprocessing
// @desc Apply preprocessing for non NLP feature extraction type
// @param features {table} Feature data as a table
// @return {table} Feature table with appropriate feature preprocessing applied
dataPreprocessing.nonTextPreprocess:{[features]
  features:dataPreprocessing.nullEncode[features;med];
  features:.ml.dropConstant features;
  .ml.infReplace features
  }

// @kind function
// @category dataPreprocessing
// @desc  Apply preprocessing for NLP feature extraction type
// @param features {table} Feature data as a table
// @return {table} Feature table with appropriate feature preprocessing applied
dataPreprocessing.textPreprocess:{[features]
  if[count[cols features]>count charCol:.ml.i.findCols[features;"C"];
    nonTextPreproc:dataPreprocessing.nonTextPreprocess charCol _features;
    :?[features;();0b;charCol!charCol],'nonTextPreproc
    ];
  features
  }

// @kind function
// @category dataPreprocessingUtility
// @desc Null encoding of feature data 
// @param features {table} Feature data as a table
// @param func {fn} Function to be applied to column from which the value 
//   to fill nulls is derived (med/min/max)
// @return {table} Feature table with null values filled if required
dataPreprocessing.nullEncode:{[features;func]
  nullCheck:flip null features;
  nullFeat:where 0<sum each nullCheck;
  nullValues:nullCheck nullFeat;
  names:`$string[nullFeat],\:"_null";
  // 0 filling needed if return value also null
  // Encoding maintained through added columns
  $[0=count nullFeat;
   features;
   flip 0^(func each flip features)^flip[features],names!nullValues
   ]
  }
