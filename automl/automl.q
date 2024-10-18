// automl.q - Setup automl namespace
// Copyright (c) 2021 Kx Systems Inc
//
// Define version, path, and loadfile.
// Execute algo if run from cmd line.


\d .automl

if[not `e in key `.p;
    @[{system"l ",x;.pykx.loaded:1b};"pykx.q";
        {@[{system"l ",x;.pykx.loaded:0b};"p.q";
        {'"Failed to load PyKX or embedPy with error: ",x}]}]];

if[not `loaded in key `.pykx;.pykx.loaded:`import in key `.pykx];
if[.pykx.loaded;.p,:.pykx];

// Coerse to string/sym
coerse:{$[11 10h[x]~t:type y;y;not[x]&-11h~t;y;0h~t;.z.s[x] each y;99h~t;.z.s[x] each y;t in -10 -11 10 11h;$[x;string;`$]y;y]}
cstring:coerse 1b;
csym:coerse 0b;

// Ensure plain python string (avoid b' & numpy arrays)
pydstr:$[.pykx.loaded;{.pykx.eval["lambda x:x.decode()"].pykx.topy x};::]

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
