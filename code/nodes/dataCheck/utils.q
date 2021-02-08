\d .automl

// Error presentation

// @kind function
// @category dataCheckUtility
// @fileoverview print to standard out flagging the removal of inappropriate columns
// @param clist {sym[]} list of all columns in the dataset
// @param slist {sym[]} sublist of columns appropriate for the use case
// @param typ {sym} Feature extraction type being implemented
// @param config {dict} Configuration information assigned by the user and related to the current run
// @return  {(Null;stdout)} generic null if all columns suitable, appropriate print out
//   in the case there are outstanding issues
dataCheck.i.errColumns:{[clist;slist;typ;config]
  if[count[clist]<>count slist;
    errString:utils.printDict[`errColumns],string typ;
    removedCols:", "sv string clist where not clist in slist;
    config[`logFunc] errString,": ",removedCols
    ]
  }

// Parameter retrieval functionality

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve default parameters and update with custom information
// @param feat {tab} The feature data as a table
// @param config {dict} Configuration information assigned by the user and related to the current run
// @param default {dict} Default dictionary which may need to be updated
// @param ptyp {sym} problem type being solved (`nlp/`normal/`fresh)
/. returns > configuration dictionary modified with any custom information
dataCheck.i.getCustomConfig:{[feat;config;default;ptyp]
  dict:$[(typ:type config)in 10 -11 99h;
      [if[10h~typ ;config:dataCheck.i.getData[config;ptyp]];
       if[-11h~typ;config:dataCheck.i.getData[;ptyp]$[":"~first config;1_;]config:string config];
       $[min key[config]in key default;
         default,config;
         '`$"Inappropriate key provided for configuration input"
        ]
      ];
      not any config;d;
      '`$"config must be passed the identity `(::)`, a filepath to a parameter flatfile",
         " or a dictionary with appropriate key/value pairs"
    ];
  if[ptyp=`fresh;
     aggcols:dict`aggregationColumns;
     dict[`aggregationColumns]:$[100h~typagg:type aggcols;aggcols feat;
                   11h~abs typagg;aggcols;
                   '`$"aggcols must be passed function or list of columns"
                   ]
  ];
  dict
  }

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve a json flatfile from disk 
// @param  fileName {char[]} name of the file from which the dictionary is being extracted
// @param  ptype {sym} The problem type being solved(`nlp`normal`fresh)
// @return {dict} configuration dictionary retrieved from a flatfile
dataCheck.i.getData:{[fileName;ptype]
  customFile:cli.i.checkCustom fileName;
  customJson:.j.k raze read0 `$customFile;
  (,/)cli.i.parseParameters[customJson]each(`general;ptype)
  }

// Save path generation functionality

// @kind function
// @category dataCheckUtility
// @fileoverview create the folders that are required for the saving of the config,
//   models, images and reports
// @param config {dict} Configuration information assigned by the user and related to the current run
// @return {dict} File paths relevant for saving reports/config etc to file, both as full path format 
//   and truncated for use in outputs to terminal
dataCheck.i.pathConstruct:{[config]
  names:`config`models;
  if[config[`saveOption]=2;names:names,`images`report];
  pname:$[`~config`savedModelName;dataCheck.i.dateTimePath;dataCheck.i.customPath]config;
  paths:pname,/:string[names],\:"/";
  dictNames:`$string[names],\:"SavePath";
  (dictNames!paths),enlist[`mainSavePath]!enlist pname
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct save path using date and time of the run
// @param config {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed based on run date and time 
dataCheck.i.dateTimePath:{[config]
  date:string config`startDate;
  time:string config`startTime;
  dirString:"outputs/dateTimeModels/",date,"/run_",time,"/";
  path,"/",dataCheck.i.dateTimeStr[dirString]
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct save path using custom model name
// @param config {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed based on user defined custom model name
dataCheck.i.customPath:{[config]
  modelName:config[`savedModelName];
  modelName:$[10h=type modelName;modelName;
   -11h=type modelName;string modelName;
   '"unsupported input type, model name must be a symbol atom or string"];
  config[`savedModelName]:modelName;
  path,"/outputs/namedModels/",modelName,"/"
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct saved logged file path
// @param config {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed to log file based on user defined paths
dataCheck.i.logging:{[config]
  if[0~config`saveOption;
    if[`~config`loggingDir;
      -1"\nIf saveOption is 0 and loggingDir is not defined, logging is disabled.\n";
    .automl.utils.printing:1b;.automl.utils.logging:0b;:config]];
  if[10h<>type config`loggingDir;string config`loggingDir]
  printDir:$[`~config`loggingDir;
    config[`mainSavePath],"/log/";
    [typeLogDir:type config`loggingDir;
     loggingDir:$[10h=typeLogDir;;
       -11h=typeLogDir;string;
       '"type must be a char array or symbol"]config`loggingDir;
    path,"/",loggingDir,"/"]
    ];
  if[`~config`loggingFile;
    date:string config`startDate;
    time:string config`startTime;
    logStr:"logFile_",date,"_",time,".txt";
    config[`loggingFile]:dataCheck.i.dateTimeStr logStr
    ];
  typeLoggingFile:type config[`loggingFile];
  loggingFile:$[10h=typeLoggingFile;;
    -11h=typeLoggingFile;string;
    '"loggingFile input must be a char array or symbol"]config`loggingFile;
  config[`printFile]:printDir,loggingFile;
  config
  }

// @kind function	
// @category dataCheckUtility	
// @fileoverview Construct date time string path in appropriate format	
// @param strPath {str} Date time path string	
// @return {str} Date and time path converted to appropriate format	
dataCheck.i.dateTimeStr:{[strPath]ssr[strPath;":";"."]}


// @kind function
// @category dataCheckUtility
// @fileoverview Check if directories to be created already exist
// @param config {dict} Configuration information assigned by the user and related to the current run
// @return {null;err} Error if logfile or savePath already exists
dataCheck.i.fileNameCheck:{[config]
  ignore:utils.ignoreWarnings;
  if[config`overWriteFiles;ignore:0];
  mainFileExists:$[0<config`saveOption;count key hsym`$config`mainSavePath;0];
  loggingExists :$[utils.logging;count key hsym`$config`printFile;0];
  dataCheck.i.delFiles[config;ignore;mainFileExists;loggingExists];
  dataCheck.i.printWarning[config;ignore;mainFileExists;loggingExists];
  modelName:$[-11h=type config`savedModelName;string;]config`savedModelName;
  if[not`~config`savedModelName;
    h:hopen hsym`$path,"/outputs/timeNameMapping.txt";
    h .Q.s enlist[sum config`startDate`startTime]!enlist modelName;
    hclose h;
    ]
  }
 

// @kind function
// @category dataCheckUtility
// @fileoverview Delete any previous save paths and logging paths if warnings are to be ignored
// @param config {dict} Configuration information assigned by the user and related to the current run
// @param ignore {int}  The ignoreWarnings option set i.e. 0, 1 or 2
// @param mainFileExists {bool} Whether the savePath exists if saveOption is greater than 0
// @param loggingExists {bool} Whether the logging path exists if logging option is chosen
// @return {null} Delete save paths and logging files
dataCheck.i.delFiles:{[config;ignore;mainFileExists;loggingExists]
  if[ignore=2;:()];
  if[mainFileExists;system"rm -rf ",config[`mainSavePath]];
  if[loggingExists;system"rm -rf ",config[`printFile]];
  }


// @kind function
// @category dataCheckUtility
// @fileoverview If savePath and logging already exist, give warning or error out depening on
//  ignoreWarning option
// @param config {dict} Configuration information assigned by the user and related to the current run
// @param ignore {int}  The utils.ignoreWarnings options set i.e. 0, 1 or 2
// @param mainFileExists {bool} Whether the savePath exists if saveOption is greater than 0
// @param loggingExists {bool} Whether the logging path exists if logging option is chosen
// @return {null;err} Error if logfile or savePath already exists or give warning
dataCheck.i.printWarning:{[config;ignore;mainFileExists;loggingExists]
  if[ignore=0;:()];
  index:$[ignore=2;0;1];
  if[mainFileExists;
      dataCheck.i.warningOption[config;ignore] utils.printWarnings[`savePathExists]index];
  if[loggingExists;
       dataCheck.i.warningOption[config;ignore] utils.printWarnings[`loggingPathExists]index];
  }


// @kind function
// @category dataCheckUtility
// @fileoverview How the warning should be handled depending on the ignoreWarning
//  option chosen 
// @param config {dict} Configuration information assigned by the user and related to the current run
// @param ignore {int}  The utils.ignoreWarnings options set i.e. 0, 1 or 2
// @return {err;str} Print warning to screen/log file or error out
dataCheck.i.warningOption:{[config;ignore]
  $[ignore=2;{'x};ignore=1;config`logFunc;]
  }
