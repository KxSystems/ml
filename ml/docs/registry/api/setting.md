# Storing

The ML Registry allows users to persist a variety of versioned entities to disk and cloud storage applications. The ML Registry provides this persistence functionality across a number of namespaces, namely, `.ml.registry.[new/set/log/update]`. All supported functionality within these namespaces is described below.

## `.ml.registry.new.registry`

_Generate a new registry_

```q
.ml.registry.new.registry[folderPath;config]
```

**Parameters:**

| Name         | Type              | Description |
|--------------|-------------------|-------------|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `config`     | `dictionary | ::` | Any additional configuration needed for initialising the registry.|

**Returns:**

| Type         | Description |
|--------------|-------------|
| `dictionary` |Updated config dictionary containing relevant registry paths|

When generating a new registry within the context of cloud vendor interactions the `folderPath` variable is unused and a new registry will be created at the storage location provided.

**Examples:**

**Example 1:** Generate a registry in 'pwd'

```q
q).ml.registry.new.registry[::;::];
```

**Example 2:** Create a folder and generate a registry in that location
```q
q)system"mkdir -p test/folder/location"
q).ml.registry.new.registry["test/folder/location";::];
```

**Example 3:** Generate registry in cloud storage location which is different from current .ml.registry.location
```q
q).ml.registry.location
local| .
q).ml.registry.new.registry[enlist[`aws]!enlist"s3://ml-registry-test";::];
```

## `.ml.registry.new.experiment`

_Generate a new experiment within an existing registry. If the registry doesn't exist it will be created._

```q
.ml.registry.new.experiment[folderPath;experimentName;config]
```

Where:

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string` |The name of the experiment to be located under the namedExperiments folder which can be populated by new models associated with the experiment. This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `config` |`dictionary | ::` |Any additional configuration needed for initialising the experiment.|

**Returns:**

|Type|Description|
|---|---|
|dictionary|Updated config dictionary containing relevant registry paths|

**Examples:**

**Example 1:** Create an experiment 'test' in a registry location in 'pwd'
```q
q).ml.registry.new.experiment[::;"test";::];
```

**Example 2:** Create an experiment 'new_test' in a registry located at a different location
```q
q)system"mkdir -p test/folder/location"
q).ml.registry.new.experiment["test/folder/location";"new_test";::];
```

**Example 3:** Create a sub-experiment 'sub_exp' under 'new_test' in the above registry
```q
q).ml.registry.new.experiment["test/folder/location";"new_test/sub_exp";::];
```

**Example 4:** Generate experiment in a cloud storage location which is different from current .ml.registry.location
```q
q).ml.registry.location
local| .
q).ml.registry.new.experiment[enlist[`aws]!enlist"s3://ml-registry-test";"my_test";::];
```

## `.ml.registry.set.model`

_Add a new model to the ML Registry. If the registry doesn't exist it will be created._

```q
.ml.registry.set.model[folderPath;experimentName;model;modelName;modelType;config]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string | ::` |The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `model` |` embedpy | dictionary | function | projection | symbol | string` | The model to be saved to the registry. |
| `modelName` | `string` |The name to be associated with the model. |
| `modelType` | `string` |The type of model that is being saved, namely `"q"`, `"sklearn"`, `"keras"`, `"python"`, `"torch"`. |
| `config` | `dictionary` |Any additional configuration needed for setting the model. |

**Returns:**

|Type|Description|
|---|---|
|`guid`| Returns the unique id for the model |

**Model Parameter:**

The model variable defines the item that is to be saved to the registry and used as the `model` when retrieved. This can be an embedPy object defining an underlying Python model, a q function/projection/dictionary or a symbol pointing to a model saved to disk.

Models can be added under the following qualifying conditions

Model Type | Saved File Type   | Qualifying Conditions |
-----------|-------------------|-----------------------|
q          | q-binary          | Model must be a q projection, function or dictionary with a `predict` and or `update` key. |
Python     | pickled file      | The model must be saved using `joblib.dump`. |
Sklearn    | pickled file      | The model must be saved using `joblib.dump` and contain a `predict` method i.e. is a `fit` scikit-learn model. |
Keras      | HDF5 file         | The model must be saved using the `save` method provided by Keras and contain a `predict` method i.e. is a `fit` Keras model.|
PyTorch    | pickled file/jit  | The model must be saved using the `torch.save` functionality. |

When adding a model from disk the ability for the model to be loaded into the current process will be validated in order to ensure that the model can be loaded into a q process and it is not being added in a manner that will corrupt the registry.

If setting a q model to the registry the following conditions are important:

1. When passed as a function/projection a model is expected to require one parameter only, namely the data to be passed to the model for it to be used as a prediction entity
2. If the model is a dictionary
	1. It is expected to have a `predict` key which contains a model meeting the conditions of `1` above.
	2. Optionally it can have an `update` key which defines a function/projection taking feature and target data used to update the model, retrieval of the update functions can be configured for use in supervised and unsupervised use-cases as outlined [here](retrieval.md#mlregistrygetupdate).

When setting any of the `Python`/`Sklearn`/`Keras`/`PyTorch` models to the registry the following conditions are important:

1. All functions when used for prediction should accept one parameter, namely the data to be passed to the model to perform a prediction. A breakdown of expectations around how these models are stored is provided in the table above.
2. Scikit-learn models are also supported for use as `updating` models, namely on retrieval of the models using [`.ml.registry.get.update`](retrieval.md#mlregistrygetupdate) when this model has been fit and contains the `partial_fit` method for example: [sklearn.linear_model.SGDClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.SGDClassifier.html).

**Configuration Parameter:**

The `config` variable within the `.ml.registry.set.model` function is used extensively within the code to facilitate advanced options within the registry code. The following keys in particular are supported for more advanced functionality, usage of these is outlined within the examples section [here](../examples/basic.md).

| key | type | Description |
|---|---|---|
| `data` | `any` | If provided with `data` as a key the addition of the model to the registry will also attempt to parse out relevant statistical information associated with the data for use within deployment of the model. |
| `requirements` | `boolean | string[][] | symbol` | Add Python requirements information associated with a model, this can either be a boolean `1b` indicating use of `pip freeze`, a symbol indicating the path to a `requirements.txt` file or a list of strings defining the requirements to be added. |
| `major` | `boolean` | Is the incrementing of a version to be 'major' i.e. should the model be incremented from `1 0` to `2 0` rather than `1 0` to `1 1` as is default. |
| `majorVersion` | `long` | What major version is to be incremented? By default we increment major versions based on the maximal version within the registry, however users can define the major version to be incremented using this option. |
| `code` | `symbol | symbol[]` | Reference to the location of any files `*.py`/`*.p`/`*.k` or `*.q` files. These files are then loaded automatically on retrieval of the models using the `*.get.*` functionality. |
| `axis` | `boolean` | Should the data when passed to the model be `'vertical'` or `'horizontal'` i.e. should the data be retrieved from a table in `flip value flip` (`0b`) or `value flip` (`1b`) format. This allows flexibility in model design. |
| `supervise` | `string[]` | List of metrics to be used for supervised monitoring of the model. |

**Examples:**

**Example 1:** Add a vanilla model to a registry in 'pwd'
```q
q).ml.registry.set.model[::;::;{x};"model";"q";::]
440482bb-5404-b22d-6c53-c847f09acf0a
```

**Example 2:** Add a vanilla model to a registry in 'pwd' under experiment EXP1
```q
q).ml.registry.set.model[::;"EXP1";{x};"model";"q";::]
440482bb-5404-b22d-6c53-c847f09acf0a
```

**Example 3:** Add a vanilla model to a registry in 'pwd' under sub-experiment EXP1/SUBEXP1
```q
q).ml.registry.set.model[::;"EXP1/SUBEXP1";{x};"model";"q";::]
440482bb-5404-b22d-6c53-c847f09acf0a
```

**Example 4:** Add an sklearn model to a registry
```q
q)skldata:.p.import`sklearn.datasets
q)blobs:skldata[`:make_blobs;<]
q)dset:blobs[`n_samples pykw 1000;`centers pykw 2;`random_state pykw 500]
q)skmdl :.p.import[`sklearn.cluster][`:AffinityPropagation][`damping pykw 0.8][`:fit]dset 0
q).ml.registry.set.model[::;::;skmdl;"skmodel";"sklearn";::]
6048775b-01e9-33b7-302a-8307ff8e132c
```

**Example 5:** Generate a major version of the "model" within the registry
```q
q).ml.registry.set.model[::;::;{x+1};"model";"q";enlist[`major]!enlist 1b]
95ed27df-072d-6bd6-713d-c49fae255840
```

**Example 6:** Associate some Python requirements with the next version of the sklearn model
```q
q)requirements:enlist[`requirements]!enlist ("scikit-learn";"numpy")
q).ml.registry.set.model[::;::;skmdl;"skmodel";"sklearn";requirements]
440482bb-5404-b22d-6c53-c847f09acf0a
```

**Example 7:** Add a q model saved to disk (this assumes running from the root of the registry repo)
```q
q).ml.registry.set.model[::;::;`:examples/models/qModel;"qModel";"q";::]
bea225d4-f8e5-dd3a-32da-51ecc91a6d9e
```

## `.ml.registry.set.parameters`

_Generate a JSON file containing parameters to be associated with a model. These parameters define any information that a user believes to be important to the models generation, it may include hyperparameter sets used when fitting or information about training._

```q
.ml.registry.set.parameters[folderPath;experimentName;modelName;version;paramName;params]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::` | The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to which the parameters are to be set. If this is null, the newest model associated with the experiment is used. |
| `version` | `long[] | ::` | The specific version of a named model to set the parameters to, a list of length 2 with (major;minor) version number. If this is null the newest model is used. |
| `paramName` |` string | symbol` | The name of the parameter to be saved. |
| `params` | `dictionary | table | string` | The parameters to save to file. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

When adding new parameters associated with a model within the context of cloud vendor interactions the `folderPath` variable is unused and the registry location is assumed to be the storage location provided on initialisation.

**Examples:**

**Example 1:** Save a dictionary parameter associated with a model 'mymodel'
```q
// Add a model to the registry
q).ml.registry.set.model[::;::;{x+2};"mymodel";"q";::]

// Save a dictionary parameter associated with a model 'mymodel'
q).ml.registry.set.parameters[::;::;"mymodel";1 0;"paramFile";`param1`param2!1 2]
```

**Example 2:** Save a list of strings as parameters associated with a model 'mymodel'
```q
q).ml.registry.set.parameters[::;::;"mymodel";1 0;"paramFile2";("value1";"value2")]
```

## `.ml.registry.log.metric`

_Log metric values associated with a model_

```q
.ml.registry.log.metric[folderPath;experimentName;modelName;version;metricName;metricValue]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to which the metrics are to be associated. If this is null, the newest model associated with the experiment is used. |
| `version` | `long[] | ::` | The specific version of a named model to be used, a list of length 2 with (major;minor) version number. If this is null the newest model is used. |
| `metricName` | `symbol | string` | The name of the metric to be persisted. In the case when this is a string, it is converted to a symbol. |
| `metricValue` | `float` | The value of the metric to be persisted. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

When logging metrics a persisted binary table is generated within the model registry containing the following information

1. The time the metric value was added
2. The name of the persisted metric
3. The value of the persisted metric

When adding metrics associated with a model within the context of cloud vendor interactions the `folderPath` variable is unused and the registry location is assumed to be the storage location provided on initialisation.

**Examples:**

**Example 1:** Log metric values associated with various metric names
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x+1};"metricModel";"q";::]

// Log metric values associated with various metric names
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func1;2.4]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func1;3]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func2;10.2]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func3;9]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func3;11.2]
```

## `.ml.registry.update.latency`

_Update monitoring config with new latency information_

```q
.ml.registry.update.latency[cli;folderPath;experimentName;modelName;version;model;data]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::` | The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `model` | `fn` | The function whos latency is to be monitored. |
| `data` | `table` | Sample data on which to evaluate the function. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

**Examples:**

**Example 1:** Update model latency config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Get predict function
q)p:.ml.registry.get.predict[::;::;"configModel";::]

// Update model latency config
q).ml.registry.update.latency[::;::;"configModel";::;p;([]1000?1f)]
```

## `.ml.registry.update.nulls`

_Update monitoring config with new null information_

```q
.ml.registry.update.nulls[cli;folderPath;experimentName;modelName;version;data]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `data` | `table` | Sample data on which to evaluate the median value. |

**Returns:**

|Type|Description|
|---|---|
|`::`||


**Examples:**

**Example 1:** Update model nulls config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Update model nulls config
q).ml.registry.update.nulls[::;::;"configModel";::;([]1000?1f)]
```

## `.ml.registry.update.infinity`

_Update monitoring config with new infinity information_

```q
.ml.registry.update.infinity[cli;folderPath;experimentName;modelName;version;data]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `data` | `table` | Sample data on which to evaluate the min/max value. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

**Examples:**

**Example 1:** Update model infinity config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Update model infinity config
q).ml.registry.update.infinity[::;::;"configModel";::;([]1000?1f)]
```

## `.ml.registry.update.csi`

_Update monitoring config with new csi information_

```q
.ml.registry.update.csi[cli;folderPath;experimentName;modelName;version;data]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `data` | `table` | Sample data on which to evaluate the historical distributions. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

**Examples:**

**Example 1:** Update model csi config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Update model csi config
q).ml.registry.update.csi[::;::;"configModel";::;([]1000?1f)]
```

## `.ml.registry.update.psi`

_Update monitoring config with new psi information_

```q
.ml.registry.update.psi[cli;folderPath;experimentName;modelName;version;model;data]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `model` | `fn` | Prediction function. |
| `data` | `table` | Sample data on which to evaluate the historical predictions. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

**Examples:**

**Example 1:** Update model psi config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Get predict function
q)p:.ml.registry.get.predict[::;::;"configModel";::]

// Update model psi config
q).ml.registry.update.psi[::;::;"configModel";::;p;([]1000?1f)]
```

## `.ml.registry.update.type`

_Update monitoring config with new type information_

```q
.ml.registry.update.type[cli;folderPath;experimentName;modelName;version;format]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `format` | `string` | Model type. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

**Examples:**

**Example 1:** Update model type config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Update model type config
q).ml.registry.update.type[::;::;"configModel";::;"sklearn"]
```


## `.ml.registry.update.supervise`

_Update monitoring config with new supervise information_

```q
.ml.registry.update.supervise[cli;folderPath;experimentName;modelName;version;metrics]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `metrics` | `string[]` | Metrics to monitor. |

**Returns:**

|Type|Description|
|---|---|
|`::`||

**Examples:**

**Example 1:** Update model supervise config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Update model supervise config
q).ml.registry.update.supervise[::;::;"configModel";::;enlist[".ml.mse"]]
```

## `.ml.registry.update.schema`

_Update monitoring config with new schema information_

```q
.ml.registry.update.schema[cli;folderPath;experimentName;modelName;version;data]
```

**Parameters:**

|Name|Type|Description|
|---|---|---|
| `folderPath` | `dictionary | string | ::` | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON. |
| `experimentName` | `string | ::`| The name of the experiment associated with the model or generic null if none. This may contain details of a subexperiment Eg. EXP1/SUBEXP1. |
| `modelName` | `string | ::` | The name of the model to be used. If this is null, the newest model associated with the experiment is retrieved. |
| `version` | `long[] | ::` | The specific version of a named model to use, a list of length 2 with (major;minor) version number. If this is null the newest model is retrieved. |
| `data` | `table` | Table from which to retreive schema. |

**Returns:**

|Type|Description|
|---|---|
|`::`||


**Examples:**

**Example 1:** Update model supervise config
```q
// Create a model within the registry
q).ml.registry.set.model[::;::;{x};"configModel";"q";::]

// Update model supervise config
q).ml.registry.update.schema[::;::;"configModel";::;([]til 7)]
```
