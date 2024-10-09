\l automl/automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

\S 42

.automl.updatePrinting[]
.ml.graphDebug:1b

// Create feature and target data
nGeneral:100

featureDataNormal:([]nGeneral?1f;asc nGeneral?1f;nGeneral?`a`b`c)

targetRegression :desc 100?1f
targetBinary     :asc 100?0b
targetMulti      :desc 100?4


// Create params dictionary
params0   :enlist[`seed]!enlist 42
params1   :enlist[`loggingFile]!enlist"logFile"
params2   :enlist[`loggingDir ]!enlist"logDir"
params3   :params1,params2
paramsFail:enlist[`loggingFile]!enlist 123

// Create function to check that appropriate logging file exists depending on 
//  logOption used
test.checkLogging:{[params]
  model:.automl.fit . params;
  config:last params;
  dict:model`modelInfo;
  date:string dict`startDate;
  time:ssr[string dict`startTime;":";"."];
  if[not .automl.utils.logging;:0Nd~dict`printFile];
  dir:$[`loggingDir in key config;
    config[`loggingDir],"/";
    .automl.path,"/outputs/",date,"/",time,"/log/"];
  fileName:$[`loggingFile in key config;
    config`loggingFile;
    "logFile_",date,"_",time,".txt"];
  logPath:dir,fileName;
  $[count hsym`$logPath;
    [system"rm -rf ",logPath;1b];
    0b]
  }

-1"\nTesting appropriate inputs for logging";

// Test when logging is disabled
passingTest[test.checkLogging;(featureDataNormal;targetBinary;`normal;`class;params0);1b;1b]

// Turn on logging functionality
.automl.updateLogging[]

// Test when logging is enabled
passingTest[test.checkLogging;(featureDataNormal;targetRegression;`normal;`reg  ;params0);1b;1b]
passingTest[test.checkLogging;(featureDataNormal;targetBinary    ;`normal;`class;params1);1b;1b]
passingTest[test.checkLogging;(featureDataNormal;targetMulti     ;`normal;`class;params2);1b;1b]
passingTest[test.checkLogging;(featureDataNormal;targetBinary    ;`normal;`class;params3);1b;1b]

-1"\nTesting inappropriate inputs for logging";

// Create error statement
typeError     :"loggingFile input must be a char array or symbol"
overWriteError:"The logging path chosen already exists, this run will be exited"

logPath:"logDir/logFile"
h:hopen hsym`$logPath
hclose h

failingTest[.automl.fit;(featureDataNormal;targetMulti     ;`normal;`class;paramsFail);0b;typeError]
failingTest[.automl.fit;(featureDataNormal;targetRegression;`normal;`reg  ;params3   );0b;overWriteError]

-1"\nRemoving any directories created";

// Remove any files created
system "rm -rf logDir";
