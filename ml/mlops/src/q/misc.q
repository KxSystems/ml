\d .ml

// .ml.registry.util.percentile - Functionality from the ml-toolkit. Percentile
//   calculation for an array
// @param array {number[]} A numerical array
// @param perc {float} Percentile of interest
// @returns {float} The value below which `perc` percent of the observations
//   within the array are found
mlops.percentile:{[array;perc]
  array:array where not null array;
  percent:perc*-1+count array;
  i:0 1+\:floor percent;
  iDiff:0^deltas asc[array]i;
  iDiff[0]+(percent-i 0)*last iDiff
  }

// Apply function to data of various types
// @param func {fn} Function to apply to data
// @param data {any} Data of various types
// @return {fn} function to apply to data
mlops.ap:{[func;data] 
  $[0=type data;
      func each data;
    98=type data;
      flip func each flip data;
    99<>type data;
      func data;
    98=type key data;
      key[data]!.z.s[func] value data;
    func each data
    ]
  }

// Replace +/- infinities with data min/max
// @param data {table|dictionary|number[]} Numerical data
// @return {table|dictionary|number[]} Data with positive/negative 
//   infinities are replaced by max/min values
mlops.infReplace:mlops.ap{[data;inf;func]
  t:.Q.t abs type first first data;
  if[not t in "hijefpnuv";:data];
  i:$[t;]@/:(inf;0n);
  @[data;i;:;func@[data;i:where data=i 0;:;i 1]]
  }/[;-0w 0w;min,max]

// Load code with the file extension '*.py'
//
// @param codePath {string} The absolute path to the 'code'
//   folder containing any source code
// @param files {symbol|symbol[]} Python files which should be loadable
// return {::}
mlops.load.py:{[codePath;files]
  sys:.p.import`sys;
  sys[`:path.append][codePath];
  pyfiles:string files;
  {.p.e "import ",x}each -3_/:$[10h=type pyfiles;enlist;]pyfiles
  }

// Wrap models such that they all have a predict key regardless of where
// they originate
//
// @param mdlType {symbol} Form of model being used `q`sklearn`xgboost`keras`torch`theano,
//   this defines how the model gets interpreted in the case it is Python code
//   in particular.
// @param model {dictionary|fn|proj|<|foreign} Model retrieved from registry
// @return {fn|proj|<|foreign} The predict function
mlops.format:{[mdlType;model]
  $[99h=type model;
    model[`predict];
    type[model]in 105 112h;
    $[mdlType in `sklearn`xgboost;
      {[model;data]
        model[`:predict;<]$[98h=type data;tab2df;]data
        }[model];
      mdlType~`keras;
      raze model[`:predict;<] .p.import[`numpy][`:array]::;
      mdlType~`torch;
      (raze/){[model;data]
        data:$[type data<0;enlist;]data;
        prediction:model .p.import[`torch][`:Tensor][data];
        prediction[`:cpu][][`:detach][][`:numpy][]`
        }[model]each::;
      mdlType~`theano;
      {x`}model .p.import[`numpy][`:array]::;
      mdlType~`pyspark;
      {[model;data]
      $[.pykx.loaded;
        {.pykx.eval["lambda x: x.asDict()"][x]`} each model[`:transform][data][`:select][`prediction][`:collect][]`;
        first flip model[`:transform][data][`:select]["prediction"][`:collect][]`
       ]
      }[model];
      model
      ];
    model
    ]
  }

// Transform data incoming into an appropriate format
// this is important because data that is being passed to the Python
// models and data that is being passed to the KX models relies on a
// different 'formats' for the data (Custom models in q would expect data)
// in 'long' format rather than 'wide' in current implementation
//
// @param data {any} Input data being passed to the model
// @param axis {boolean} Whether the data is to be in a 'long' or 'wide' format
// @param mdlType {symbol} Form of model being used `q`sklearn`xgboost`keras`torch`theano,
//   this defines how the model gets interpreted in the case it is Python code
//   in particular.
// @return {any} The data in the appropriate format
.ml.mlops.transform:{[data;axis;mdlType]
  dataType:type data;
  if[mdlType=`pyspark;
    :.ml.mlops.pysparkInput data];
  if[dataType<=20;:data];
  if[mdlType in `xgboost`sklearn;
    $[(98h=type data);
        :tab2df data;
        :data]];
  data:$[98h=dataType;
      value flip data;
    99h=dataType;
      value data;
    dataType in 105 112h;
      @[{value flip .ml.df2tab x};data;{'"This input type is not supported"}];
    '"This input type is not supported"
    ];
  if[98h<>type data;
    data:$[axis;;flip]data
    ];
  data
  }

// Utility function to transform data suitable for a pyspark model
//
// @param data {table|any[][]} Input data
// @param {<} An embedPy object representing a Spark dataframe
mlops.pysparkInput:{[data]
  if[not type[data] in 0 98h;
    '"This input type is not supported"
    ];
  $[98h=type data;
    [df:.p.import[`pyspark.sql][`:SparkSession.builder.getOrCreate][]
      [`:createDataFrame] .ml.tab2df data;
    :df:.p.import[`pyspark.ml.feature][`:VectorAssembler]
      [`inputCols pykw df[`:columns];`outputCol pykw `features]
      [`:transform][df]
    ];
    [data:flip (`$string each til count data[0])!flip data;
    .z.s data]
  ]
  }

// Wrap models retrieved such that they all have the same format regardless of
// from where they originate, the data passed to the model will also be transformed
// to the appropriate format
//
// @param mdlType {symbol} Form of model being used `q`sklearn`xgboost`keras`torch`theano,
//   this defines how the model gets interpreted in the case it is Python code
//   in particular.
// @param model {dictionary|fn|proj|<|foreign} Model retrieved from registry
// @param axis {boolean} Whether the data should be in a 'long' (0b ) or 
//   'wide' (1b) format
// @return {fn|proj|<|foreign} The predict function wrapped with a transformation
//   function
mlops.wrap:{[mdlType;model;axis]
  model:mlops.format[mdlType;model];
  transform:mlops.transform[;axis;mdlType];
  model transform::
  }

