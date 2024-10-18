\d .ml

// Update the latency monitoring details of a saved model
// @param config {dictionary} Any additional configuration needed for
//   setting the model

// @param cli {dictionary} Command line arguments as passed to the system on
//   initialisation, this defines how the fundamental interactions of
//   the interface are expected to operate.
// @param model {function} Model to be applied
// @param data {table} The data which is to be used to calculate the model
//   latency
// @return {::}
mlops.update.latency:{[fpath;model;data]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  func:{{system"sleep 0.0005";t:.z.p;x y;(1e-9)*.z.p-t}[x]each 30#y}model;
  updateData:@[`avg`std!(avg;dev)@\:func::;
    data;
    {'"Unable to generate appropriate configuration for latency with error: ",x}
    ];
  config[`monitoring;`latency;`values]:updateData;
  config[`monitoring;`latency;`monitor]:1b;
  // need to add deps for .com_kx_json
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {}
    ];
  }

// Update configuration information related to null value replacement from
// within a q process
// @param fpath {string|symbol|hsym} Path to a JSON file to be used to
//   overwrite initially defined configuration
// @param data {table} Representative/training data suitable for providing
//   statistics about expected system behaviour
// @return {::}
mlops.update.nulls:{[fpath;data]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  if[98h<>type data;
    -1"Updating schema information only supported for tabular data";   
    :(::)
    ];
  func:{med each flip mlops.infReplace x};
  updateData:@[func;
    data;
    {'"Unable to generate appropriate configuration for nulls with error: ",x}
    ];
  config[`monitoring;`nulls;`values]:updateData;
  config[`monitoring;`nulls;`monitor]:1b;
  // need to add deps for .com_kx_json
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {'"Could not persist configuration to JSON file with error: ",x}
    ];

  }

// Update configuration information related to infinity replacement from
// within a q process
// @param fpath {string|symbol|hsym} Path to a JSON file to be used to
//   overwrite initially defined configuration
// @param data {table} Representative/training data suitable for providing
//   statistics about expected system behaviour
// @return {::}
mlops.update.infinity:{[fpath;data]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  if[98h<>type data;
    -1"Updating schema information only supported for tabular data";
    :(::)
    ];
  func:{(`negInfReplace`posInfReplace)!(min;max)@\:mlops.infReplace x};
  updateData:@[func;
    data;
    {'"Unable to generate appropriate configuration for infinities with error: ",x}
    ];
  config[`monitoring;`infinity;`values]:updateData;
  config[`monitoring;`infinity;`monitor]:1b;
  // need to add deps for .com_kx_json
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {'"Could not persist configuration to JSON file with error: ",x}
    ];
  }

// Update configuration information related to CSI from within a q process
// @param fpath {string|symbol|hsym} Path to a JSON file to be used to
//   overwrite initially defined configuration
// @param data {table} Representative/training data suitable for providing
//   statistics about expected system behaviour
// @return {::}
mlops.update.csi:{[fpath;data]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  if[98h<>type data;
    -1"Updating CSI information only supported for tabular data";
    :(::)
    ];
  bins:first 10^@["j"$;(count data)&@[{"J"$.ml.monitor.config.args x};`bins;{0N}];{0N}];
  updateData:@[{mlops.create.binExpected[;y]each flip x}[;bins];
    data;
    {'"Unable to generate appropriate configuration for CSI with error: ",x}
    ];
  config[`monitoring;`csi;`values]:updateData;
  config[`monitoring;`csi;`monitor]:1b;
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {}
    ];
  }

// Update configuration information related to PSI from within a q process
//
// @param fpath {string|symbol|hsym} Path to a JSON file to be used to
//   overwrite initially defined configuration
// @param model {function} Prediction function to be used to generate
//   representative predictions for population stability calculation
// @param data {table} Representative/training data suitable for providing
//   statistics about expected system behaviour
// @return {::}
mlops.update.psi:{[fpath;model;data]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  if[98h<>type data;
    -1"Updating PSI information only supported for tabular data";
    :(::)
    ];
  bins:first 10^@["j"$;(count data)&@[{"J"$.ml.monitor.config.args x};`bins;{0N}];{0N}];
  func:{mlops.create.binExpected[raze x y;z]}[model;;bins];
  updateData:@[func;
    data;
    {'"Unable to generate appropriate configuration for PSI with error: ",x}
    ];
  config[`monitoring;`psi;`values]:updateData;
  config[`monitoring;`psi;`monitor]:1b;
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {}
    ];
  .ml.monitor.config.model::config;
  }

// Update configuration information related to type information for models
// retrieved from disk
//
// @param fpath {string|symbol|hsym} Path to a JSON file to be used to
//   overwrite initially defined configuration
// @param format {string} Type/format of the model that is being retrieved from disk
// @return {::}
mlops.update.type:{[fpath;format]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  config[`model;`type]:format;
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {}
    ];
  .ml.monitor.config.model::config;
  }

// Update supervised monitoring information
//
// @param fpath {string|symbol|hsym} Path to a JSON file to be used to
//   overwrite initially defined configuration
// @param metrics {string[]} Type/format of the model that is being retrieved from disk
// @return {::}
mlops.update.supervise:{[fpath;metrics]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  config[`monitoring;`supervised;`values]:metrics;
  config[`monitoring;`supervised;`monitor]:1b;
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {}
    ];
  .ml.monitor.config.model::config;
  }


// Update configuration information related to expected from within a q process
//
// @param fpath {string|symbol|hsym} Path to a JSON file to be used to
//   overwrite initially defined configuration
// @param data {table} Representative/training data suitable for providing
//   statistics about expected system behaviour
// @return {::}
mlops.update.schema:{[fpath;data]
  fpath:hsym $[-11h=ty:type fpath;;10h=ty;`$;'"unsupported fpath"]fpath;
  config:@[.j.k raze read0::;
    fpath;
    {'"Could not load configuration file at ",x," with error: ",y}[1_string fpath]
    ];
  if[98h<>type data;
    -1"Updating schema information only supported for tabular data";
    :(::)
    ];
  config[`monitoring;`schema;`values]:(!) . (select c,t from meta data)`c`t;
  config[`monitoring;`schema;`monitor]:1b;
  .[{[fpath;config] fpath 0: enlist .j.j config};
    (fpath;config);
    {'"Could not persist configuration to JSON file with error: ",x}
    ];
  .ml.monitor.config.model::config;
  }
