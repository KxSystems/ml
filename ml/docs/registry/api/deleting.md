# Deleting

While the ML Registry provides a common location for the storage of versioned models, parameters and metrics it is often the case that models/experiments need to be deleted due to changes in team requirements or focus. The `.ml.registry.delete` namespace provides all the callable functions used for the removal of objects from a registry. All functionality within this namespace is described below.

## `.ml.registry.delete.registry`

_Delete a registry at a specified location_

```q
.ml.registry.delete.registry[folderPath;config]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::`     | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `config` | `::` |This parameter is presently unused, provided here for future use. |

**Returns:**

|type  |description|
|------|---|
| `::` |   |

**Examples:**

**Example 1:** Delete a registry from the present working directory
```q
q).ml.registry.delete.registry[::;::]
./KX_ML_REGISTRY deleted.
```

**Example 2:** Delete the registry from a specified folder
```q
q).ml.registry.delete.registry["test/directory";::]
test/directory/KX_ML_REGISTRY deleted.
```

### `.ml.registry.delete.experiment`

_Delete an experiment from a specified registry_

```q
.ml.registry.delete.experiment[folderPath;experimentName]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::`     | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string` |Name of the experiment to be deleted.  This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|

**Returns:**

|type|description|
|------|---|
| `::` |   |

**Examples:**

**Example 1:** Delete experiment 'test1'
```q
// Generate a number of models associated with different experiments
q).ml.registry.set.model[::;"test";{x};"model";"q";::]
q).ml.registry.set.model[::;"test";{x+1};"model";"q";::]
q).ml.registry.set.model[::;"test1";{x+2};"model1";"q";::]
q).ml.registry.set.model[::;"test1";{x+2};"model1";"q";::]

// Show current contents of the modelStore
q)modelStore
registrationTime              experimentName modelName uniqueID              ..
-----------------------------------------------------------------------------..
2021.06.01D10:13:19.517546000 "test"         "model"   38e69f30-8956-24a8-0bc..
2021.06.01D10:13:19.550791000 "test"         "model"   7e1eb13b-aa21-cc7f-800..
2021.06.01D10:13:19.584704000 "test1"        "model1"  466c92d0-f610-dbbd-9da..
2021.06.01D10:13:19.620767000 "test1"        "model1"  d68d2286-01e0-0867-446..

// Delete experiment 'test1'
q).ml.registry.delete.experiment[::;"test1"]
Removing all contents of ./KX_ML_REGISTRY/namedExperiments/test1/
q)modelStore
registrationTime              experimentName modelName uniqueID              ..
-----------------------------------------------------------------------------..
2021.06.01D10:13:19.517546000 "test"         "model"   38e69f30-8956-24a8-0bc..
2021.06.01D10:13:19.550791000 "test"         "model"   7e1eb13b-aa21-cc7f-800..
```

### `.ml.registry.delete.model`

_Delete a model from a specified registry_

```q
.ml.registry.delete.model[folderPath;experimentName;modelName;version]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::`     | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string | ::` |Name of the experiment the model to be deleted is located within.  This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `modelName` | `string | ::` |The name of the model to delete. |
| `version` | `long[] | ::` |The version of the model to delete, a list of length 2 with (major;minor) version number,, if (::) all versions will be deleted. |

**Returns:**

| type |description|
|------|---|
| `::` |   |

**Examples:**

**Example 1:** Delete version 1.0 of 'model1'
```q
// Generate a number of models within a registry
q).ml.registry.set.model[::;::;{x};"model1";"q";::]
q).ml.registry.set.model[::;::;{x+1};"model1";"q";::]
q).ml.registry.set.model[::;::;{x+2};"model2";"q";::]
q).ml.registry.set.model[::;::;{x+3};"model3";"q";::]
q).ml.registry.set.model[::;::;{x+4};"model3";"q";::]

// Display current registry contents
q)modelStore
registrationTime              experimentName modelName uniqueID              ..
-----------------------------------------------------------------------------..
2021.06.01D10:22:47.360569000 "undefined"    "model1"  5c279367-6eac-d645-2f0..
2021.06.01D10:22:47.393568000 "undefined"    "model1"  fb56b644-d9f8-22d6-b33..
2021.06.01D10:22:47.420959000 "undefined"    "model2"  c9dfd663-500f-8fbf-77e..
2021.06.01D10:22:47.456099000 "undefined"    "model3"  e56f9d8f-5dc3-a043-cb9..
2021.06.01D10:22:47.491306000 "undefined"    "model3"  fe0f9d6c-f774-9318-941..

// Delete all models named 'model3'
q).ml.registry.delete.model[::;::;"model3";::]
Removing all contents of ./KX_ML_REGISTRY/unnamedExperiments/model3

q)modelStore
-----------------------------------------------------------------------------..
2021.06.01D10:22:47.360569000 "undefined"    "model1"  5c279367-6eac-d645-2f0..
2021.06.01D10:22:47.393568000 "undefined"    "model1"  fb56b644-d9f8-22d6-b33..
2021.06.01D10:22:47.420959000 "undefined"    "model2"  c9dfd663-500f-8fbf-77e..

// Delete version 1.0 of 'model1'
q).ml.registry.delete.model[::;::;"model1";1 0]
Removing all contents of ./KX_ML_REGISTRY/unnamedExperiments/model1/1

q)modelStore
registrationTime              experimentName modelName uniqueID              ..
-----------------------------------------------------------------------------..
2021.06.01D10:22:47.393568000 "undefined"    "model1"  fb56b644-d9f8-22d6-b33..
2021.06.01D10:22:47.420959000 "undefined"    "model2"  c9dfd663-500f-8fbf-77e..
```

### `.ml.registry.delete.parameters`

_Delete a parameter file from a specified model_

```q
.ml.registry.delete.parameters[folderPath;experimentName;modelName;version;paramFile]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::`     | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string | ::` | Name of the experiment folder in which the parameters live.  This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `modelName` | `string` | The name of the model associated to the parameters. |
| `version` | `long[]` |The version of the model to retrieve, a list of length 2 with (major;minor) version number. |
| `paramFile` | `string` | Name of the parameter file to delete. |

**Returns:**

| type |description|
|------|---|
| `::` |   |

**Examples:**

**Example 1:** Delete parameter file
```q
// Generate a model with a parameter set
q).ml.registry.set.model[::;::;{x};"model1";"q";::]
q).ml.registry.set.parameters[::;::;"model1";1 0;"paramFile";`param1`param2!1 2]

// Get parameter file
q).ml.registry.get.parameters[::;::;"model1";1 0;`paramFile]
param1| 1
param2| 2

// Delete parameter file
q).ml.registry.delete.parameters[::;::;"model1";1 0;"paramFile"]

// Get parameter file
q).ml.registry.get.parameters[::;::;"model1";1 0;`paramFile]
'./KX_ML_REGISTRY/unnamedExperiments/model1/1/params/paramFile.json. OS reports: The system cannot find the path specified.
```

### `.ml.registry.delete.metrics`

_Delete a metric table from a specified model_

```q
.ml.registry.delete.metrics[folderPath;experimentName;modelName;version]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::`     | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string | ::` | Name of the experiment folder in which the metrics live.  This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `modelName` | `string` | The name of the model associated to the metrics. |
| `version` | `long[]` |The version of the model to delete metrics from, a list of length 2 with (major;minor) version number. |

**Returns:**

| type |description|
|------|---|
| `::` |   |

**Examples:**

**Example 1:** Delete parameter file
```q
// Generate a model with a metrics table
q).ml.registry.set.model[::;::;{x};"model1";"q";::]
q).ml.registry.log.metric[::;::;"model1";1 0;`metricName1;1]
q).ml.registry.log.metric[::;::;"model1";1 0;`metricName2;2]

// Get metrics
q).ml.registry.get.metric[::;::;"model1";1 0;`metricName1`metricName2]
timestamp                     metricName  metricValue
-----------------------------------------------------
2021.06.04D17:02:38.200280000 metricName1 1
2021.06.04D17:02:43.723946000 metricName2 2

// Delete parameter file
q).ml.registry.delete.metrics[::;::;"model1";1 0]

// Get metrics
q).ml.registry.get.metric[::;::;"model1";1 0;`metricName1`metricName2]
'./KX_ML_REGISTRY/unnamedExperiments/model1/1/metrics/metric. OS reports: The system cannot find the path specified.
```

### `.ml.registry.delete.code`

_Delete a code file from a specified model_

```q
.ml.registry.delete.code[folderPath;experimentName;modelName;version;codeFile]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::`     | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string |::` | Name of the experiment folder in which the code lives.  This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `modelName` | `string` | The name of the model associated to the code. |
| `version` | `long[]` |The version of the model to delete code from, a list of length 2 with version number (major;minor). |
| `codeFile` | `string` |Name of file to be deleted with file extension eg "myfile.py". |

**Returns:**

| type |description|
|------|---|
| `::` |   |

**Examples:**

**Example 1:** Delete code file my.py
```q
q).ml.registry.delete.code[::;::;"model1";1 0;"my.py"]
```

### `.ml.registry.delete.metric`

_Delete a metric from a specified metric table_

```
.ml.registry.delete.metric[folderPath;experimentName;modelName;version;metricName]
```

**Parameters:**

|name|type|description|
|---|---|---|
| `folderPath` | `dictionary | string | ::`     | A folder path indicating the location of the registry. Can be one of 3 options: a dictionary containing the vendor and location as a string, e.g. ```enlist[`local]!enlist"myReg"```; a string indicating the local path; or a generic null to use the current `.ml.registry.location` pulled from CLI/JSON.|
| `experimentName` | `string | ::` | Name of the experiment folder in which the metric lives.  This may contain details of a subexperiment Eg. EXP1/SUBEXP1.|
| `modelName` | `string` | The name of the model associated to the metric. |
| `version` | `long[]` |The version of the model to delete metric from, a list of length 2 with version number (major;minor). |
| `metricName` | `string` |Name of metric to be deleted. |

**Returns:**

| type |description|
|------|---|
| `::` |   |

**Examples:**

**Example 1:** Delete first metric

```q
// Set metric values
q).ml.registry.log.metric[::;::;"model1";1 0;`metricName1;1]
q).ml.registry.log.metric[::;::;"model1";1 0;`metricName2;2]

// Show metric values
q).ml.registry.get.metric[::;::;"model1";1 0;`metricName1`metricName2]
timestamp                     metricName  metricValue
-----------------------------------------------------
2021.06.07D08:49:18.296326000 metricName1 1
2021.06.07D08:49:20.643205000 metricName2 2

// Delete first metric
q).ml.registry.delete.metric[::;::;"model1";1 0;"metricName1"]

// Show metric values
q).ml.registry.get.metric[::;::;"model1";1 0;`metricName1`metricName2]
timestamp                     metricName  metricValue
-----------------------------------------------------
2021.06.07D08:49:20.643205000 metricName2 2
```
