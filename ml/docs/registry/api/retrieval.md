# Loading

Once saved to the ML Registry following the instructions outlined [here](./setting.md), entities that have been persisted should be accessible to any user permissioned with access to the registry save location. The `.ml.registry.get` namespace provides all the callable functions used for the retrieval of objects from a registry. All functionality within this namespace is described below.

## `.ml.registry.get.model`

_Retrieve a model from an ML Registry_

```q
.ml.registry.get.model[folderPath;experimentName;modelName;version]
```

**Parameters:**

|name|type|description|
|------------------|---------------|-----------|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::` | The name of an experiment from which to retrieve a model, if no modelName is provided the newest model within this experiment will be used. If neither modelName or experimentName are defined the newest model within the "unnamedExperiments" section is chosen. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName`      | `string | ::` | The name of the model to be retrieved in the case this is null, the newest model associated with the experiment is retrieved. |
| `version`        | `long[] | ::` | The specific version of a named model to retrieve, a list of length 2 with (major;minor) version number, in the case that this is null the newest model is retrieved. |

**Returns:**

|type|description|
|---|---|
| `dictionary` | The model and information related to the generation of the model. |

When using [`.ml.registry.set.model`](setting.md#mlregistrysetmodel) users can include `code` files to be loaded on model retrieval, these files can be `q`,`p`,`py` or `k` extensions. On invocation of this function these files are loaded prior to model retrieval.

**Examples:**

**Example 1:** Get the latest version of 'model'
```q
// Set a number of models within a new registry
q).ml.registry.set.model[::;::;{x};"model";"q";::]
q).ml.registry.set.model[::;::;{x+1};"model";"q";::]
q).ml.registry.set.model[::;::;{x+2};"model1";"q";::]

// Get the latest addition to the Registry
q).ml.registry.get.model[::;::;::;::]
modelInfo| `registry`model`monitoring!(`description`modelInformation`experime..
model    | {x+2}

// Get the latest version of 'model'
q).ml.registry.get.model[::;::;"model";::]
modelInfo| `registry`model`monitoring!(`description`modelInformation`experime..
model    | {x+1}
```

**Example 2:** Get version 1.0 of 'model'
```q
q).ml.registry.get.model[::;::;"model";1 0]
modelInfo| `registry`model`monitoring!(`description`modelInformation`experime..
model    | {x}
```

## `.ml.registry.get.modelStore`

_Retrieve the modelStore table associated with an ML Registry_

```q
.ml.registry.get.modelStore[folderPath;config]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `config` | `::` | Currently unused, must be passed as `::`. |

**Returns:**

|type|description|
|---|---|
|`::`||

**Examples:**

**Example 1:** Retrieve the modelStore table
```q
q).ml.registry.get.modelStore[::;::]
q)modelStore
registrationTime              experimentName modelName uniqueID              ..
-----------------------------------------------------------------------------..
2021.06.01D08:51:28.593730000 "undefined"    "mymodel" 7a214d0a-d9d2-890e-014..
```

## `.ml.registry.get.metric`

_Retrieve metric information associated with a model_

```q
.ml.registry.get.metric[folderPath;experimentName;modelName;version;param]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::` | The name of an experiment from which to retrieve metrics associated with a model, if no modelName is provided the newest model within this experiment will be used. If neither modelName or experimentName are defined the newest model within the "unnamedExperiments" section is chosen. This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `modelName` | `string | ::` | The name of the model to retrieve metrics from. In the case this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to retrieve metrics from, a list of length 2 with (major;minor) version number, in the case that this is null the newest model is retrieved. |
| `param` | `:: | dictionary | symbol | string` | Search parameters for the retrieval of metrics. In the case when this is a string, it is converted to a symbol. |

**Returns:**

|type     |description|
|---------|---|
| `table` | The metric table for a specific model, which may potentially be filtered. |

**Examples:**

**Example 1:** Retrieve all metrics named `metric1`
```q
// Log a number of metrics associated with a model
q).ml.registry.set.model[::;::;{x};"mymodel";"q";::]
q).ml.registry.log.metric[::;::;::;::;`metric1;2.0]
q).ml.registry.log.metric[::;::;::;::;`metric1;2.1]
q).ml.registry.log.metric[::;::;::;::;`metric2;1.0]
q).ml.registry.log.metric[::;::;::;::;`metric2;1.0]
q).ml.registry.log.metric[::;::;::;::;`metric3;3.0]

// Retrieve all metrics associated with the model
q).ml.registry.get.metric[::;::;::;::;::]
timestamp                     metricName metricValue
----------------------------------------------------
2021.06.01D09:51:35.638489000 metric1    2
2021.06.01D09:51:35.652863000 metric1    2.1
2021.06.01D09:51:35.666593000 metric2    1
2021.06.01D09:51:35.679152000 metric2    1
2021.06.01D09:51:35.694630000 metric3    3

// Retrieve all metrics named `metric1
q).ml.registry.get.metric[::;::;::;::;`metric1]
timestamp                     metricName metricValue
----------------------------------------------------
2021.06.01D09:51:35.638489000 metric1    2
2021.06.01D09:51:35.652863000 metric1    2.1
```

**Example 2:** Retrieve multiple metrics
```q
q).ml.registry.get.metric[::;::;::;::;`metric2`metric3]
timestamp                     metricName metricValue
----------------------------------------------------
2021.06.01D09:51:35.666593000 metric2    1
2021.06.01D09:51:35.679152000 metric2    1
2021.06.01D09:51:35.694630000 metric3    3
```

**Example 3:** Equivalently this can be done using a dictionary input
```q
q).ml.registry.get.metric[::;::;::;::;enlist[`metricName]!enlist `metric2`metric3]
timestamp                     metricName metricValue
----------------------------------------------------
2021.06.01D09:51:35.666593000 metric2    1
2021.06.01D09:51:35.679152000 metric2    1
2021.06.01D09:51:35.694630000 metric3    3
```

## `.ml.registry.get.parameters`

_Retrieve parameter information associated with a model_

```q
.ml.registry.get.parameters[folderPath;experimentName;modelName;version;paramName]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::` | The name of an experiment from which to retrieve parameters associated with a model. If no modelName is provided the newest model within this experiment will be used. If neither modelName or experimentName are defined the newest model within the "unnamedExperiments" section is chosen. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model from which parameters are to be retrieved. In the case this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to retrieve, a list of length 2 with (major;minor) version number, in the case that this is null the newest model is retrieved. |
| `paramName` | `symbol | string` | The name of the parameter to retrieve. |

**Returns:**

|type|description|
|---|---|
| `string | dictionary | table | float` | The value of the parameter associated with a named parameter saved for the model. |

**Examples:**

**Example 1:** Retrieve set parameters
```q
// Set a number of parameters associated with a model
q).ml.registry.set.parameters[::;::;"mymodel";1 0;"paramFile1";`param1`param2!1 2]
q).ml.registry.set.parameters[::;::;"mymodel";1 0;"paramFile2";("value1";"value2")]

// Retrieve the set parameters
q).ml.registry.get.parameters[::;::;::;::;`paramFile1]
param1| 1
param2| 2

q).ml.registry.get.parameters[::;::;::;::;`paramFile2]
"value1"
"value2"
```


## `.ml.registry.get.predict`

_Retrieve a model from the ML Registry wrapping in a common interface_

```q
.ml.registry.get.predict[folderPath;experimentName;modelName;version]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::` | The name of an experiment from which to retrieve a model, if no modelName is provided the newest model within this experiment will be used. If neither modelName or experimentName are defined the newest model within the "unnamedExperiments" section is chosen. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be retrieved in the case this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::`| The specific version of a named model to retrieve, a list of length 2 with (major;minor) version number, in the case that this is null the newest model is retrieved. |

**Returns:**

|type|description|
|---|---|
| `function` | A wrapped version of the `model` providing a common callable interface for all models within the ML Registry. This model can accept vector/matrix/table/dictionary input and will return predictions generated by the model. |

Models within the ML Registry can be of many forms `q`/`Python`/`sklearn`/`keras` etc. As such this function provides a common entry point to allow the models to be retrieved such that they are all callable using the same function call.

When using [`.ml.registry.set.model`](setting.md#mlregistrysetmodel) users can include `code` files to be loaded on model retrieval, these files can be `q`,`p`,`py` or `k` extensions. On invocation of this function these files are loaded prior to model retrieval.

**Examples:**

**Example 1:** Get the latest addition to the Registry
```q
// Set a number of models within a new registry
q).ml.registry.set.model[::;::;{x};"model";"q";::]
q).ml.registry.set.model[::;::;{x+1};"model";"q";::]
q).ml.registry.set.model[::;::;{x+2};"model1";"q";::]

// Get the latest addition to the Registry
q).ml.registry.get.predict[::;::;::;::]
{x+2}{[data;bool]
  dataType:type data;
  if[dataType<=20;:data];
  data:$[98h=dat..
```

**Example 2:** Get the latest version of 'model'
```q
q).ml.registry.get.predict[::;::;"model";::]
{x+1}{[data;bool]
  dataType:type data;
  if[dataType<=20;:data];
  data:$[98h=dat..
```

**Example 3:** Get version 1.0 of 'model'
```q
q).ml.registry.get.predict[::;::;"model";1 0]
{x}{[data;bool]
  dataType:type data;
  if[dataType<=20;:data];
  data:$[98h=dat..
```

## `.ml.registry.get.update`

_Retrieve the update method for models within the ML Registry wrapping in a common interface_

```q
.ml.registry.get.update[folderPath;experimentName;modelName;version;supervised]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::` | The name of an experiment from which to retrieve a model, if no modelName is provided the newest model within this experiment will be used. If neither modelName or experimentName are defined the newest model within the "unnamedExperiments" section is chosen. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName`| `string | ::` | The name of the model to be retrieved in the case this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to retrieve, a list of length 2 with (major;minor) version number, in the case that this is null the newest model is retrieved. |
| `supervised` | `boolean` | Is the model being retrieved a supervised (`1b`) or unsupervised (`0b`) model. This changes the number of expected inputs to the returned function. |

**Returns:**

|type|description|
|---|---|
| `function` | A wrapped version of the `model` providing a common callable interface for all models within the ML Registry. This model can accept vector/matrix/table/dictionary input and will return an updated version of the originally persisted model. |

Models stored within the ML Registry can be of many forms ```q/sklearn/keras``` etc. Many of these formats can have an 'update' capability to allow these models to be updated as new data becomes available. As such this function provides a common entry point to allow the models update functionality to be retrieved in a common format.

In order to be retrieved from the registry the model must contain the following characteristics

| Model Type | Supported | Requirements |
|------------|-----------|--------------|
| q          | Yes       | Model originally saved to registry must contain an `update` key. |
| sklearn    | Yes       | Model originally saved to registry must support the `partial_fit` method. |
| keras      | No        | |
| Pytorch    | No        | |

When using [`.ml.registry.set.model`](setting.md#mlregistrysetmodel) users can include `code` files to be loaded on model retrieval, these files can be `q`,`p`,`py` or `k` extensions. On invocation of this function these files are loaded prior to model retrieval.

**Examples:**

**Example 1:** Get the latest sklearn updatable model from the Registry
```q
// Fit models to be persisted to the registry
q)X:100 2#200?1f
q)yReg:100?1f
q)yClass:100?0b
q)online1:.ml.online.clust.sequentialKMeans.fit[flip X;`e2dist;3;::;::]
q)online2:.ml.online.sgd.linearRegression.fit[X;yReg;1b;::]
q)sgdClass:.p.import[`sklearn.linear_model][`:SGDClassifier]
q)sgdModel:sgdClass[pykwargs `max_iter`tol!(1000;0.003)][`:fit] . (X;yClass)

// Set a number of models within a new registry
q).ml.registry.set.model[::;:::online1;"onlineCluster";"q";::]
q).ml.registry.set.model[::;::;online2;"onlineRegression";"q";::]
q).ml.registry.set.model[::;::;sgdModel;"SklearnSGD";"sklearn";::]

// Get the latest sklearn updatable model from the Registry
q).ml.registry.get.update[::;::;"SklearnSGD";::;1b]
.[{[f;x]embedPy[f;x]}[foreign]enlist]{(x y;z)}[locked[;0b]]
```

**Example 2:** Get a q updatable supervised model from the Registry
```q
q).ml.registry.get.update[::;::;"onlineRegression";::;1b]
.[{[config;secure;features;target]
  modelInfo:config`modelInfo;
  theta:mode..{(x y;z)}[locked[;0b]]
```

**Example 3:** Get a q updatable unsupervised model from the Registry
```q
q).ml.registry.get.update[::;::;"onlineCluster";::;0b]
{[returnInfo;data]
  modelInfo:returnInfo`modelInfo;
  inputs:modelInfo`input..locked[;0b]
```
