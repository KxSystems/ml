\d .automl

// @kind description
// @name pathGeneration
// @desc If a user had defined that a configuration file should be used on 
//   command line using the -config command line argument, this section will
//   retrieve the custom config from either the folder:
//   .automl.path,"/code/customization/configuration/customConfig/"
//   or the current directory. If no config command line argument is provided
//   the default JSON file will be used.
cli.path:$[`config in key commandLineInput;
  cli.i.checkCustom commandLineInput`config;
  path,"/code/customization/configuration/default.json"
  ]

// @kind description
// @name systemConfig
// @desc Parse the JSON file into a q dictionary and retrieve all configuration
//   information required for the application of AutoML in both command line 
//   and non command line mode:
//   'paramDict'   -> all the AutoML parameters for customizing a run i.e. 
//     'seed'/'testingSize' etc.
//   'problemDict' -> instructions regarding how the framework is to retrieve 
//     data and name models
cli.input:.j.k raze read0`$cli.path
paramTypes:`general`fresh`normal`nlp
paramDict:paramTypes!cli.i.parseParameters[cli.input]each paramTypes
problemDict:cli.input`problemDetails
