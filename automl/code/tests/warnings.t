\l automl/automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

.automl.updateIgnoreWarnings[1]
.automl.updatePrinting[]
.ml.graphDebug:1b

\S 42

// Create feature and target data
nGeneral:100

featureDataNormal:([]nGeneral?1f;asc nGeneral?1f;nGeneral?`a`b`c)

targetRegression :desc 100?1f
targetBinary     :100?0b
targetMulti      :100?4


//Create function to ensure fit runs correctly
.test.checkFit:{[params]fitReturn:(key;value)@\:.automl.fit . params;type[first fitReturn],type each last fitReturn}

// Create savedModel and config file
.automl.newConfig["testConfig"]

-1"\nTesting appropriate inputs when ignoreWarnings is 0\n";

.automl.updateIgnoreWarnings[0]

passingTest[.test.checkFit;(featureDataNormal;targetMulti     ;`normal;`class;`savedModelName`targetLimit!("testModel";10));1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetRegression;`normal;`reg  ;enlist[`savedModelName]!enlist "testModel");1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetBinary    ;`normal;`class;enlist[`saveOption]!enlist 0);1b;11 101 104h]

passingTest[.automl.newConfig;"testConfig";1b;::]

-1"\nTesting appropriate when inputs when ignoreWarnings is 1\n";

.automl.updateIgnoreWarnings[1]

passingTest[.test.checkFit;(featureDataNormal;targetRegression;`normal;`reg  ;enlist[`targetLimit]!enlist 10);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetBinary    ;`normal;`class;enlist[`savedModelName]!enlist "testModel");1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetMulti     ;`normal;`class;enlist[`saveOption]!enlist 0);1b;11 101 104h]

passingTest[.automl.newConfig;"testConfig";1b;::]

-1"\nTesting inputs when ignoreWarnings is 2\n";

.automl.updateIgnoreWarnings[2]

overWriteError:"The savePath chosen already exists, this run will be exited"
configError   :"A configuration file of this name already exists"

failingTest[.test.checkFit;(featureDataNormal;targetMulti     ;`normal;`class;enlist[`savedModelName]!enlist "testModel");1b;overWriteError]
passingTest[.test.checkFit;(featureDataNormal;targetMulti     ;`normal;`class;`targetLimit`savedModelName`overWriteFiles!(10;"testModel";1b));1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetRegression;`normal;`reg  ;enlist[`saveOption]!enlist 0);1b;11 101 104h]

failingTest[.automl.newConfig;"testConfig";1b;configError]

-1"\nRemoving any directories created";

savePath  :.automl.path,"/outputs/namedModels/testModel";
configPath:.automl.path,"code/customization/configuration/customConfig/testConfig"

// Remove any files created
system"rm -rf ",savePath;
system"rm -rf ",configPath;
