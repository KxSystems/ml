// automl.q - Setup automl namespace
// Copyright (c) 2021 Kx Systems Inc
//
// Define version, path, and loadfile. 
// Execute algo if run from cmd line.


\l p.q

\d .automl
version:@[{AUTOMLVERSION};`;`development]
path:{string`automl^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
loadfile:{$[.z.q;;-1]"Loading ",x:_[":"=x 0]x:$[10=type x;;string]x;system"l ",path,"/",x;}

// @kind description
// @name commandLineParameters
// @desc Retrieve command line parameters and convert to a kdb+ dictionary
commandLineInput:first each .Q.opt .z.x

// @kind description
// @name commandLineExecution
// @desc If a user has defined both config and run command line arguments, the
//   interface will attempt to run the fully automated version of AutoML. The 
//   content of the JSON file provided will be parsed to retrieve data 
//   appropriately via ipc/from disk, then the q session will exit.
commandLineArguments:lower key commandLineInput
if[all`config`run in commandLineArguments;
  loadfile`:init.q;
  .ml.updDebug[];
  testRun:`test in commandLineArguments;
  runCommandLine[testRun];
  exit 0]

