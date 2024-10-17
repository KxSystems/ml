
\l ml.q
.ml.loadfile`:util/init.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:mlops/init.q
.ml.loadfile`:registry/init.q

registry:"RegistryTests";
registryDict:enlist[`local]!enlist registry;
@[system"mkdir -p ",;registry;{}];

/ Have set .ml.registry.location to expected location
/ Default registry to be root local directory
.ml.registry.location~enlist[`local]!enlist"."

/ Create a new registry at a supplied location
/ A folder KX_ML_REGISTRY to exist in the 'RegistryTests' folder
.ml.registry.new.registry[registryDict;::];
`KX_ML_REGISTRY~first key`:RegistryTests

/ Populate a modelStore within a new registry
/ The modelStore to be a table
.ml.registry.get.modelStore[registry;::];
98h=type modelStore

/ The modelStore to contain the expected columns
~[cols modelStore;`registrationTime`experimentName`modelName`uniqueID`modelType`version`description]

/ Add a new experiment to the registry
/ To be able to list a new experiment within the ML Registry
.ml.registry.new.experiment[registry;"ExperimentTest";::];
`ExperimentTest in key`:RegistryTests/KX_ML_REGISTRY/namedExperiments

/ The newly created experiment to contain only one file
1=count key`:RegistryTests/KX_ML_REGISTRY/namedExperiments/ExperimentTest

/ Set q functions generated within a q process to a registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
basicName:"basic-model";
basicModel1:{x}  ;basicModel2:{x+1};
basicModel3:{x+2};basicModel4:{x+3};
basicModel5:{x+4};basicModel6:{x+5};
major:enlist[`major]!enlist 1b;
majorVersion:enlist[`majorVersion]!enlist 1;

/ Add q models to a registry and be appropriately versioned
/ In sequence major/minor versioning of q models is appropriately applied
.ml.registry.set.model[registry;::;basicModel1;basicName;"q";enlist[`description]!enlist"test description"];
.ml.registry.set.model[registry;::;basicModel2;basicName;"q";::];
.ml.registry.set.model[registry;::;basicModel3;basicName;"q";::];
.ml.registry.set.model[registry;::;basicModel4;basicName;"q";major];
.ml.registry.set.model[registry;::;basicModel5;basicName;"q";::];
.ml.registry.set.model[registry;::;basicModel6;basicName;"q";majorVersion];
~[exec version from modelStore;(1 0; 1 1; 1 2; 2 0; 2 1; 1 3)]

/ Add q models to a registry and be appropriately versioned
/ Guid type returned from set model
g:.ml.registry.set.model[registry;::;basicModel1;"testName";"q";::];
type[g]=-2h

/ Set Sklearn models generated within a q process to a registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
major:enlist[`major]!enlist 1b;
blobs :.p.import[`sklearn.datasets][`:make_blobs;<];
skdata:blobs[`n_samples pykw 1000;`centers pykw 2;`random_state pykw 500];
skAP  :.p.import[`sklearn.cluster][`:AffinityPropagation];
sklearnAP1:skAP[`damping pykw 0.8][`:fit]skdata 0;
sklearnAP2:skAP[`damping pykw 0.5][`:fit]skdata 0;
expName:"cluster";

/ Add models generated using Pythons Scikit-Learn package to the registry
/ That two major versioned Scikit-learn models are added to the registry
.ml.registry.set.model[registry;expName;sklearnAP1;"skAPmodel";"sklearn";::];
.ml.registry.set.model[registry;"cluster";sklearnAP2;"skAPmodel";"sklearn";major];
~[exec version from modelStore where modelName like "skAPmodel";(1 0;2 0)]

/ Set and retrieve a XGBoost model from the registry and use it for prediction

.ml.registry.delete.registry[::;::];
X: ([]1000?1f;1000?1f;1000?1f);
y: 1000?2;
Xtest: ([]1000?1f;1000?1f;1000?1f);
clf: .p.import[`xgboost;`:XGBClassifier][][`:fit][flip X`x`x1`x2; y];

/ Set and retrieve a model and use it for prediction
/ Predictions to be the same after retrieving the model from the registry
.ml.registry.set.model[::;::;clf;"xgb";"xgboost";::];
mdl: .ml.registry.get.model[::;::;"xgb";::];
predict: .ml.registry.get.predict[::;::;"xgb";::];
predict[Xtest]~clf[`:predict][flip Xtest`x`x1`x2]`

/ Set and retrieve a pyspark model from the registry and use it for prediction

.ml.registry.delete.registry[::;::];
PySpark:.p.import`pyspark;
V:.p.import[`pyspark.ml.linalg]`:Vectors;
LR:.p.import[`pyspark.ml.classification]`:LogisticRegression;
spark:PySpark[`:sql.SparkSession.builder][`:getOrCreate][];
training : spark[`:createDataFrame][((1.0; V[`:dense][(0.0; 1.1; 0.1)]`);(0.0; V[`:dense][(2.0; 1.0; -1.0)]`);(0.0; V[`:dense][(2.0; 1.3; 1.0)]`);(1.0; V[`:dense][(0.0; 1.2; -0.5)]`));$[.pykx.loaded;.pykx.topy `label`features;("label"; "features")]];
lr:LR[`maxIter pykw 10;`regParam pykw 0.01];
model:lr[`:fit][training];
xtest:([]10?1f;10?1f;10?1f);

/ Set and retrieve a model and use it for prediction
/ Predictions to be the same after retrieving the model from the registry
.ml.registry.set.model[::;::;model;"pysp";"pyspark";::];
mdl: .ml.registry.get.model[::;::;"pysp";::];
predict: .ml.registry.get.predict[::;::;"pysp";::];
a:predict[xtest];
all(all all(a in (0.0;1.0));10=count a)

/ Set q functions generated using the ML-Toolkit to a registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
axis:enlist[`axis]!enlist 1b;
blobs :.p.import[`sklearn.datasets][`:make_blobs;<];
skdata:blobs[`n_samples pykw 1000;`centers pykw 2;`random_state pykw 500];
qAP1:.ml.clust.ap.fit[flip skdata 0;`nege2dist;0.8;min;::];
qAP2:.ml.clust.ap.fit[flip skdata 0;`nege2dist;0.5;min;::];

/ Add q Affinity propagation models associated within the ML-Toolkit to the registry
/ That two minor versioned q Affinity propagation models are added to the registry
.ml.registry.set.model[registry;"cluster";qAP1;"qAPmodel";"q";axis];
.ml.registry.set.model[registry;"cluster";qAP2;"qAPmodel";"q";axis];
~[exec version from modelStore where modelName like "qAPmodel";(1 0; 1 1)]

/ Add basic q model to a subexperiment within the registry
/ model to be addded to subexperiment
.ml.registry.set.model[registry;"exp/subexp";{x};"subExModel";"q";::];
~[exec version from modelStore where modelName like "subExModel";enlist 1 0]

/ Retrieve Models from the Registry based on different conditions

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
basicName:"basic-model";
skName:"skAPmodel";

/ Retrieve retrieve previously generated models from the registry
/ To retrieve the highest versioned 'basic-model'
basicModel5~.ml.registry.get.model[registry;::;basicName;::]`model

/ To retrieve version 1.1 of 'basic-model'
basicModel2~.ml.registry.get.model[registry;::;basicName;(1 1)]`model

/ To retrieve the most recently added model to the registry
qModel:.ml.registry.get.model[registry;::;::;::];
qModelInfo:qModel[`modelInfo;`registry;`modelInformation;`modelName`version];
~[qModelInfo;("subExModel";1 0f)]

/ To retrieve version 1.0 of the 'skAPmodel'
skModel:.ml.registry.get.model[registry;"cluster";skName;1 0];
skModelInfo:skModel[`modelInfo;`registry;`modelInformation;`modelName`version];
~[skModelInfo;("skAPmodel";1 0f)]

/ Set and retrieve PyTorch models from a registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
torchName:"torchModel";
system"l examples/code/torch/torch.p";
system"l examples/code/torch/torch.q";
torchData  :flip value flip ([]100?1f;asc 100?1f;100?10);
torchTarget:100?5;
mdl:.p.get[`classifier][count first torchData;200];
torchModel:.torch.fitModel[torchData;torchTarget;mdl];
torchCode :enlist[`code]!enlist `:examples/code/torch/torch.p;

/ Add and retrieve Torch models from a registry
/ The model to be added and retrieved appropriately
.ml.registry.set.model[registry;::;torchModel;torchName;"torch";torchCode];
.ml.registry.set.model[registry;::;torchModel;torchName;"torch";torchCode];
getTorchModel:.ml.registry.get.model[registry;::;torchName;1 0];
torchModelInfo:getTorchModel[`modelInfo;`registry;`modelInformation;`modelName`version];
~[torchModelInfo;(torchName;1 0f)]

/ The prediction model when retrieved and invoked to returns an appropriate type
getTorchPredict:.ml.registry.get.predict[registry;::;torchName;1 0];
type[getTorchPredict torchData]in 8 9h


/Skipping any tests that use online analytics as functionality is not required

/Update functions can be retrieved from the registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
X:100 2#200?1f;
/yReg:100?1f;
yClass:100?0b;
/online1:.ml.online.clust.sequentialKMeans.fit[flip X;`e2dist;3;::;::];
/online2:.ml.online.sgd.linearRegression.fit[X;yReg;1b;::];
sgdClass:.p.import[`sklearn.linear_model][`:SGDClassifier];
sgdModel:sgdClass[pykwargs `max_iter`tol!(1000;0.003)][`:fit] . (X;yClass);

/ should Add and retrieve update functions from the registry
/ expect The q clustering model to be added and retrieved appropriately
/.ml.registry.set.model[registry;::;online1;"onlineCluster";"q";::];
/mdl1:.ml.registry.get.update[registry;::;"onlineCluster";::;0b];
/(99h;`modelInfo`predict`update)~(type;key)@\:mdl1 flip X

/ expect The q Linear Regression model to be added and retrieved appropriately
/.ml.registry.set.model[registry;::;online2;"onlineRegression";"q";::];
/mdl2:.ml.registry.get.update[registry;::;"onlineRegression";::;1b];
/(99h;`modelInfo`predict`update`updateSecure)~(type;key)@\:mdl2[X;yReg]

/ expect An sklearn model to be added and retrieved appropriately
.ml.registry.set.model[registry;::;sgdModel;"SklearnSGD";"sklearn";::];
mdl3:.ml.registry.get.update[registry;::;"SklearnSGD";::;1b];
105h~type mdl3[X;yClass]

/ expect The models retrieved models once used to be suitable for registry setting
/.ml.registry.set.model[registry;::;mdl1 flip X   ;"onlineCluster";"q";::];
/.ml.registry.set.model[registry;::;mdl2[X;yReg]  ;"onlineRegression";"q";::];
.ml.registry.set.model[registry;::;mdl3[X;yClass];"SklearnSGD";"sklearn";::];
modelNames:("SklearnSGD");
modelTypes:1b;
models:.ml.registry.get.update[registry;::;;::;][modelNames;modelTypes];
(105h)~type each models


/ Users can set non-unique models in different experiments

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
qName:"qmodel";
exp1Name:"experiment1";
exp2Name:"experiment2";

/ Delete experiment
.ml.registry.delete.experiment[registry]each(exp1Name;exp2Name);

/ allow multiple models to be added which have the same name
/ multiple models to be added to the registry in different experiments
.ml.registry.set.model[registry;exp1Name;{x};qName;"q";::];
.ml.registry.set.model[registry;exp2Name;{x+1};qName;"q";::];
store:.ml.registry.get.modelStore[registry;::];
not(~/)exec experimentName from store where modelName like qName

/ be able to retrieve models from different experiments that are named equivalently
/ multiple models to be retrieved with the same name
models:(.ml.registry.get.model[registry;exp1Name;qName;::][`modelInfo;`registry;`modelInformation;`modelName];.ml.registry.get.model[registry;exp2Name;qName;::][`modelInfo;`registry;`modelInformation;`modelName]);
all models~\:"qmodel"

/ Prediction function wrappers can handle various data formats as input

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
qName:"qAPmodel";
skName:"skAPmodel";
expName:"cluster";
dsetNew:2 10#20?1f;
clustDict:`col1`col2!dsetNew;
clustTab:flip clustDict;

/ Ensure that matrix, dictionary and tabular data can be supplied to Python/q registry models
/ A q model to be invoked correctly with dict/tab/matrix input
qPredict:.ml.registry.get.predict[registry;expName;qName;1 0];
return:qPredict@/:(dsetNew;clustDict;clustTab);
all raze(7h=type@/:;not 1_differ::)@\:return

/ An Sklearn model to be invoked correctly with tab/matrix input
skPredict:.ml.registry.get.predict[registry;expName;skName;1 0];
return:skPredict@/:(flip dsetNew;clustTab);
all raze(7h=type@/:;not 1_differ::)@\:return

/ Models can be added to and retrieved from a registry from disk

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
getLatest:{[]
  mlModel:.ml.registry.get.model[registry;::;::;::];
  mlModel[`modelInfo;`registry;`modelInformation;`modelName`version]
 };

/ Ensure models can be added and retrieved based on name from disk
/ A q model to be saved and retrieved based on file
model:`:examples/models/qModel;
.ml.registry.set.model[registry;::;model;"qmdl";"q";::];
~[getLatest[];("qmdl";1 0f)]

/ A py model to be saved and retrieved based on file
model:`:examples/models/pythonModel.pkl;
.ml.registry.set.model[registry;::;model;"pymdl";"python";::];
~[getLatest[];("pymdl";1 0f)]

/ A keras model to be saved and retrieved based on file
model:`:examples/models/kerasModel.h5;
.ml.registry.set.model[registry;::;model;"kmdl";"keras";::];
~[getLatest[];("kmdl";1 0f)]

/ A sklearn model to be saved and retrieved based on file
model:`:examples/models/sklearnModel.pkl;
.ml.registry.set.model[registry;::;model;"smdl";"sklearn";::];
~[getLatest[];("smdl";1 0f)]

/ A PyTorch model to be saved, retrieved and run based on a file
model:`:examples/models/torchModel.pt;
.ml.registry.set.model[registry;::;model;"ptmdl";"torch";::];
~[getLatest[];("ptmdl";1 0f)]

/ Configuration information related to a model's characteristics can be added to a registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
readBasicJson:{[metric]
  cfg:`$":RegistryTests/KX_ML_REGISTRY/unnamedExperiments/basic-model/3.0/config/modelInfo.json";
  info:.j.k raze read0 cfg;
  info[`monitoring;metric;`values]
 };
readSklearnJson:{[metric]
  skConfig:`:RegistryTests/KX_ML_REGISTRY/namedExperiments/cluster/skAPmodel/2.0/config/modelInfo.json;
  info:.j.k raze read0 skConfig;
  info[`monitoring;metric;`values]
 };
configData:([] 0N,0W,0N,til 50);
majorData:`major`data!(1b;configData);
basicName:"basic-model";
skName:"skAPmodel";
expName:"cluster";
skRequire:`:RegistryTests/KX_ML_REGISTRY/namedExperiments/cluster/skAPmodel/2.0/requirements.txt;
requirements:("numpy";"pandas==2.0.0";"scikit-learn>=1.0.0");
configDict:`requirements`data`supervise!(requirements;configData;1b);

/ Populate latency/null/infinite/schema configuration when setting a model
/ Model latency information to be persisted with a model
.ml.registry.set.model[registry;::;{x};basicName;"q";majorData];
~[key readBasicJson`latency;`avg`std]

/ The saved schema to contain the appropriate data
~[readBasicJson`schema;enlist[`x]!enlist enlist "j"]

/ The null replacement to contain only reference to appropriate schema
~[key readBasicJson`nulls;enlist[`x]]

/ The infinity replace functionality to have appropriate keys
~[key readBasicJson`infinity;`negInfReplace`posInfReplace]

/ Populate latency/null/infinite/schema configuration after a model has been added to registry
/ Model latency information to be persisted with the newest Scikit-Learn AP model
.ml.registry.update.config[registry;expName;skName;::;configDict];
~[key readSklearnJson`latency;`avg`std]

/ The saved schema to contain the appropriate data
~[readSklearnJson`schema;enlist[`x]!enlist enlist "j"]

/ The null replacement to contain only reference to appropriate schema
~[key readSklearnJson`nulls;enlist[`x]]

/ The infinity replace functionality to have appropriate keys
~[key readSklearnJson`infinity;`negInfReplace`posInfReplace]

/ Python requirements needed for execution of a model can be associated with a given model

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
reqName:"requireModel";
requirements:("numpy";"pandas";"scikit-learn");
reqFile:enlist[`requirements]!enlist `$"registry/tests/requirements.txt";
reqList:enlist[`requirements]!enlist requirements;
readRequire:{[version]
  read0 hsym`$"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/requireModel/",
  version,"/requirements.txt"
 };

/ Associate Python requirements with a model
/ Requirements to be added based on reference to a known requirements file location
.ml.registry.set.model[registry;::;{x};reqName;"q";reqFile];
saved:readRequire "1.0";
~[saved;requirements]

/ A list of requirements to be saved with a model
.ml.registry.set.model[registry;::;{x};reqName;"q";reqList];
saved:readRequire "1.1";
~[saved;requirements]

/ Parameter information can be added to and retrieved from the Model registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
basicName:"basic-model";
paramList:1 2 3 4f;
paramDict:`param1`param2!1 2f;

/ Add and retrieve parameter information associated with a model
/ To retrieve dictionary parameters saved to disk
.ml.registry.set.parameters[registry;::;basicName;::;"paramFile";paramDict];
.ml.registry.set.parameters[registry;::;basicName;::;`symParams;paramDict];
paramList:("paramFile";"symParams");
params:.ml.registry.get.parameters[registry;::;basicName;::;]each paramList;
all paramDict~/:params

/ To retrieve list parameters saved to disk
.ml.registry.set.parameters[registry;::;basicName;::;"paramFile2";paramList];
getParams:.ml.registry.get.parameters[registry;::;basicName;::;"paramFile2"];
~[getParams;paramList]

/ Attempts to pass paramName as an inappropriate type
err:@[.ml.registry.set.parameters[registry;::;basicName;::;;1 2];1;{x}];
err~"ParamName must be of type string or symbol"

/ Metrics information can be added to and retrieved from a registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
basicName:"basic-model";

/ Add and retrieve metric information related to a model from a registry
/ To retrieve all metrics in the order they were associated with a model (1)
.ml.registry.log.metric[registry;::;basicName;::;`func1_sym;2.4];
.ml.registry.log.metric[registry;::;basicName;::;`func1_sym;4];
.ml.registry.log.metric[registry;::;basicName;::;`func2_sym;0.1];
metrics:.ml.registry.get.metric[registry;::;basicName;::;::];
all(~[exec metricValue from metrics;(2.4; 4j; 0.1)];~[type exec metricName from metrics;11h])

/ To retrieve all metrics in the order they were associated with a model (2)
.ml.registry.log.metric[registry;::;basicName;::;"func1_str";2.4];
.ml.registry.log.metric[registry;::;basicName;::;"func1_str";4];
.ml.registry.log.metric[registry;::;basicName;::;"func2_str";0.1];
metrics:.ml.registry.get.metric[registry;::;basicName;::;::];
all(~[exec metricValue from metrics;(2.4; 4j; 0.1; 2.4; 4j; 0.1)];~[type exec metricName from metrics;11h])

/ To retrieve all metrics in the order they were associated with a model (3)
.ml.registry.log.metric[registry;::;basicName;::;`func3;"hello"];
.ml.registry.log.metric[registry;::;basicName;::;`func4;`world];
.ml.registry.log.metric[registry;::;basicName;::;`func5;2021.10.05];
metrics:.ml.registry.get.metric[registry;::;basicName;::;::];
all(~[6_(exec metricValue from metrics);("hello"; `world; 2021.10.05)];~[type exec metricName from metrics;11h])

/ To retrieve only metrics related to a specific name (1)
metrics:.ml.registry.get.metric[registry;::;basicName;::;"func1_str"];
all(~[exec metricValue from metrics;(2.4;4)];~[type exec metricName from metrics;11h])

/ To retrieve only metrics related to a specified name
metrics:.ml.registry.get.metric[registry;::;basicName;::;`func1_sym];

all(~[exec metricValue from metrics;(2.4;4)];~[type exec metricName from metrics;11h])

/ Delete items from a registry

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
basicName:"basic-model";
lsModelAll:{[file;str]
  path:hsym `$"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/basic-model",str;
  key .Q.dd[path;file]
 };
lsModel:lsModelAll[;"/3.0/"];
lsModel2:lsModelAll[;"/3.1/"];


/system"rm -rf RegistryTests";


/ Delete code associated with a model
/ Deletion of code to not be possible if code file doesnt exist
err:.[.ml.registry.delete.code;(registry;::;torchName;1 0;"test");{x}];
err~"No such code exists at this location, unable to delete."

/ Deletion of code to be completed appropriately if the code file exists
.ml.registry.delete.code[registry;::;torchName;1 0;"torch.p"];
path:"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/torchName/1.0/code";
show key hsym`$path;
0~count key hsym`$path

/ Deletion of code to be completed appropriately if the code file exists using defaults
.ml.registry.delete.code[registry;::;torchName;::;"torch.p"];
path:"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/torchName/1.0/code";
show key hsym`$path;
0~count key hsym`$path

/ Delete information associated with a single model
/ A metric to be deleted from the metrics table with/without default
name: "xyz_123";
num_models: count .ml.registry.get.metric[registry;::;basicName;::;::];
.ml.registry.log.metric[registry;::;basicName;::;name;1.0];
.ml.registry.delete.metric[registry;::;basicName;3 0;name];
.ml.registry.log.metric[registry;::;basicName;::;name;1.0];
.ml.registry.delete.metric[registry;::;basicName;::;name];
~[count .ml.registry.get.metric[registry;::;basicName;::;::];num_models]

/ The metric table to be deleted from a model
.ml.registry.delete.metrics[registry;::;basicName;3 0];
~[lsModel`metrics;`symbol$()]

/ The metric table to be deleted from a model defaults
name: "xyz_123";
.ml.registry.set.model[registry;::;{x};basicName;"q";()!()];
.ml.registry.log.metric[registry;::;basicName;::;name;1.0];
.ml.registry.delete.metrics[registry;::;basicName;::];
~[lsModel2`metrics;`symbol$()]

/ Attempts to delete metrics/tables that dont exist will fail
err1:.[.ml.registry.delete.metrics;(registry;::;basicName;1 0);{x}];
err2:.[.ml.registry.delete.metric;(registry;::;basicName;1 0;"func");{x}];
errCode:"No metric table exists at this location, unable to delete.";
all errCode~/:(err1;err2)

/ A parameter associated with a model to be deleted
.ml.registry.delete.parameters[registry;::;basicName;3 0;"paramFile"];
not `paramFile.json in lsModel`params

/ A parameter associated with a model to be deleted default
.ml.registry.set.parameters[registry;::;basicName;3 1;"number";7f];
.ml.registry.delete.parameters[registry;::;basicName;::;"number"];
not `number.json in lsModel2`params

/ Attempts to delete parameters that dont exist to fail
params:(registry;::;basicName;1 0;"paramFile");
err:.[.ml.registry.delete.parameters;params;{x}];
err~"No parameter files exists with the given name, unable to delete."

/ Delete an experiment from the registry
/ ExperimentTest to be removed from the registry
.ml.registry.delete.experiment[registry;"ExperimentTest"];
not `ExperimentTest in key`:RegistryTests/KX_ML_REGISTRY/namedExperiments

/ Delete models from the registry
/ A specific versioned model to be deleted from the registry
.ml.registry.delete.model[registry;::;basicName;1 3];
not (1 3) in exec version from modelStore where modelName like basicName

/ An entire model to be deleted from the registry
.ml.registry.delete.model[registry;::;basicName;::];
not count select from modelStore where modelName like basicName

/ Delete an entire registry
/ The registry located in the RegistryTests folder to be removed
.ml.registry.delete.registry[registry;::];
not count key`:RegistryTests

/ Config can be updated

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];
configName:"config-model";
.ml.registry.set.model[registry;::;{x};configName;"q";::];
readConfig:{
  cfgPath:hsym `$"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/config-model/1.0/config/modelInfo.json";
  .j.k raze read0 cfgPath
 };

/ Update requirements information associated with a model
/ To set a boolean indicating that Python requirements are required
req:("numpy";"pandas");
.ml.registry.update.requirements[registry;::;configName;1 0;req];
path:"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/","config-model/1.0/requirements.txt";
req~read0 hsym`$path

/ Update null information in monitoring config
/ To retreive monitoring data for nulls
.ml.registry.update.nulls[registry;::;configName;1 0;([] 100?1f)];
d:readConfig[];
d[`monitoring;`nulls;`values;`x] within (0.2;0.8)

/ Update infinity information in monitoring config
/ To retreive monitoring data for infinities
.ml.registry.update.infinity[registry;::;configName;1 0;([] 100?1f)];
d:readConfig[];
d[`monitoring;`infinity;`values;`posInfReplace;`x] within (0.8;1.2)

/ Update type information in config
/ To retreive data for type
.ml.registry.update.type[registry;::;configName;1 0;"sklearn"];
d:readConfig[];
d[`model;`type]~"sklearn"

/ Update supervise information in config
/ To retreive data for supervised metrics
.ml.registry.update.supervise[registry;::;configName;1 0;enlist ".ml.mse"];
d:readConfig[];
d[`monitoring;`supervised;`values]~enlist[".ml.mse"]

/ Update schema information in config
/ To retreive data for monitoring schema
.ml.registry.update.schema[registry;::;configName;1 0;([]til 100)];
d:readConfig[];
d[`monitoring;`schema;`values;`x]~enlist "j"

/ Update latency information in config
/ To retreive data for monitoring latency
.ml.registry.update.latency[registry;::;configName;1 0;{x};([]til 100)];
d:readConfig[];
d[`monitoring;`latency;`values;`avg]<1f

/ Update csi information in config
/ To retreive data for monitoring csi
.ml.registry.update.csi[registry;::;configName;1 0;([]1000?1f)];
d:readConfig[];
d[`monitoring;`csi;`monitor]

/ Update psi information in config
/ To retreive data for monitoring psi
.ml.registry.update.psi[registry;::;configName;1 0;{flip value flip x};([]1000?1f)];
d:readConfig[];
d[`monitoring;`psi;`monitor]

/ Language/Library version information is stored with a persisted model

registry:"RegistryTests";
@[system"mkdir -p ",;registry;{}];

/Delete registry
system"rm -rf ",registry;

/ Persist a q model and have q version information persisted and associated with the model
/ a file to be persisted which contains version information
.ml.registry.set.model[registry;::;{x};"q-version-model";"q";::];
path:hsym`$"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/","q-version-model/1.0/.version.info";
path~key path

/ the version information to indicate it is a q model and contain only modelType and q information
versionInfo:.ml.registry.get.version[registry;::;::;::];
all(`q_version`model_type~key versionInfo;enlist["q"]~versionInfo`model_type)

/ Persist a Pythonic models and have version information persisted and associated with the model
/ a file to be persited which contains version information
.ml.registry.set.model[registry;::;sklearnAP1;"sklearn-version-model";"sklearn";::];
path:hsym`$"RegistryTests/KX_ML_REGISTRY/unnamedExperiments/","sklearn-version-model/1.0/.version.info";
path~key path

/ the version information to indicate the q+Python versions along with sklearn library version
versionInfo:.ml.registry.get.version[registry;::;::;::];
all(
 `q_version`model_type`python_version`python_library_version~key versionInfo;
 versionInfo[`model_type]~"sklearn";
 versionInfo[`python_library_version]~.ml.pygetver "sklearn";
 versionInfo[`python_version]~$[.pykx.loaded;string .p.import[`sys][`:version]`;.p.import[`sys][`:version]`]
 )


 
/ Set and retrieve keyed models

.ml.registry.delete.registry[::;::];
/X:([] 100?1f;asc 100?1f);
/y: asc 100?1f;
/m:.ml.online.sgd.linearRegression.fit[X;y;1b;enlist[`maxIter]!enlist[10000]];
m:{x+1};
models:`EURUSD`GBPUSD!(m;m);
.ml.registry.set.model[::;::;models;"forex";"q";::];

/ write a keyed model in stages

.ml.registry.set.model[::;::;models;"forexTri";"q";::];
.ml.registry.set.model[::;::;models,enlist[`EURGBP]!enlist m;"forexTri";"q";enlist[`version]!enlist(1;0)];

/ try to overwrite a model

.ml.registry.set.model[::;::;models,enlist[`EURGBP]!enlist {x};"forexTri";"q";enlist[`version]!enlist(1;0)];

/ should Retrieve a models
/ expect retrieve keyed model as a dictionary
models:.ml.registry.get.model[::;::;"forex";::];
key[models]~`EURUSD`GBPUSD

/ expect retrieve individual keyed model
model:.ml.registry.get.keyedmodel[::;::;"forex";::;`EURUSD];
key[model]~`modelInfo`model

/ expect retrieve keyed model set in stages
models:.ml.registry.get.model[::;::;"forexTri";::];
`EURGBP`EURUSD`GBPUSD ~ asc key[models]

/ expect model EURGBP was not over written
models:.ml.registry.get.model[::;::;"forexTri";::];
not models[`EURGBP;`model]~{x}
