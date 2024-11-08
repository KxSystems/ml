# Registry Examples

The purpose of this page is to outline some example usage of the ML-Registry.
For most users, these examples will be the first entry point to the use of the ML-Registry and outlines the function calls that are used across the interface when interacting with the Registry.

## Basic Interactions

After installing the relevant dependencies, we can explore the q model registry functionality by following the examples below:

* Start up a q session
```
$ q init.q
```

* Generate a new model registry
```q
q).ml.registry.new.registry[::;::];
```

* Retrieve the 'modelStore' defining the current models within the registry
```q
q).ml.registry.get.modelStore[::;::];
```

* Display the modelStore
```q
q)show modelStore
registrationTime experimentName modelName uniqueID modelType version
--------------------------------------------------------------------
```

* Add several models to the registry
```q
// Increment minor versions
q)modelName:"basic-model"
q).ml.registry.set.model[::;::;{x}  ;modelName;"q";::]
q).ml.registry.set.model[::;::;{x+1};modelName;"q";::]
q).ml.registry.set.model[::;::;{x+2};modelName;"q";::]

// Set major version and increment from '2.0'
q).ml.registry.set.model[::;::;{x+3};modelName;"q";enlist[`major]!enlist 1b]
q).ml.registry.set.model[::;::;{x+4};modelName;"q";::]

// Add another version of '1.x'
q).ml.registry.set.model[::;::;{x+5};modelName;"q";enlist[`majorVersion]!enlist 1]
```

* Display the modelStore
```q
q)show modelStore
registrationTime              experimentName modelName     uniqueID                             modelType version
-----------------------------------------------------------------------------------------------------------------
2021.07.20D18:26:17.904115000 "undefined"    "basic-model" e1636884-f7d8-93e5-9e72-fb23f7407473 ,"q"      1 0
2021.07.20D18:26:17.914201000 "undefined"    "basic-model" edaa5221-8e4f-4aef-52df-25d8794b28fe ,"q"      1 1
2021.07.20D18:26:17.925254000 "undefined"    "basic-model" a667b0f2-ce0c-e4bd-d870-6aab04579859 ,"q"      1 2
2021.07.20D18:26:17.932588000 "undefined"    "basic-model" 56be5696-cd31-f846-57d2-86f0dd92fe2e ,"q"      2 0
2021.07.20D18:26:17.939366000 "undefined"    "basic-model" bbf3120c-d75b-4f5a-21c0-368189291792 ,"q"      2 1
2021.07.20D18:26:21.086221000 "undefined"    "basic-model" 5386500e-7cee-fdf6-a493-d7a5c03c8280 ,"q"      1 3
```

* Add models associated with experiments
```q
q)modelName:"new-model"

// Incrementing versions from '1.0'
q).ml.registry.set.model[::;"testExperiment";{x}  ;modelName;"q";::]
q).ml.registry.set.model[::;"testExperiment";{x+1};modelName;"q";enlist[`major]!enlist 1b]
q).ml.registry.set.model[::;"testExperiment";{x+2};modelName;"q";::]
```

* Display the modelStore
```q
q)show modelStore
registrationTime              experimentName   modelName     uniqueID                             modelType version
-------------------------------------------------------------------------------------------------------------------
2021.07.20D18:26:17.904115000 "undefined"      "basic-model" e1636884-f7d8-93e5-9e72-fb23f7407473 ,"q"      1 0
2021.07.20D18:26:17.914201000 "undefined"      "basic-model" edaa5221-8e4f-4aef-52df-25d8794b28fe ,"q"      1 1
2021.07.20D18:26:17.925254000 "undefined"      "basic-model" a667b0f2-ce0c-e4bd-d870-6aab04579859 ,"q"      1 2
2021.07.20D18:26:17.932588000 "undefined"      "basic-model" 56be5696-cd31-f846-57d2-86f0dd92fe2e ,"q"      2 0
2021.07.20D18:26:17.939366000 "undefined"      "basic-model" bbf3120c-d75b-4f5a-21c0-368189291792 ,"q"      2 1
2021.07.20D18:26:21.086221000 "undefined"      "basic-model" 5386500e-7cee-fdf6-a493-d7a5c03c8280 ,"q"      1 3
2021.07.20D18:28:15.902359000 "testExperiment" "new-model"   86423ef3-cca0-7e2b-051a-e53fbaab761d ,"q"      1 0
2021.07.20D18:28:15.911149000 "testExperiment" "new-model"   ab143727-4164-2f08-fd1f-66e1994873d7 ,"q"      2 0
2021.07.20D18:28:19.294837000 "testExperiment" "new-model"   6fa608cc-0a87-46b5-d61c-ce2cf7abc0a6 ,"q"      2 1
```

* Retrieve models from the registry
```q
// Retrieve version 1.1 of the 'basic-model'
q).ml.registry.get.model[::;::;"basic-model";1 1]`model
{x+1}

// Retrieve the most up to date model associated with the 'testExperiment'
q).ml.registry.get.model[::;"testExperiment";"new-model";::]`model
{x+2}

// Retrieve the last model added to the registry
q).ml.registry.get.model[::;::;::;::]`model
{x+2}
```

* Delete models, experiments, and the registry
```q
// Delete the experiment from the registry
q).ml.registry.delete.experiment[::;"testExperiment"]

// Display the modelStore following experiment deletion
q)show modelStore
registrationTime              experimentName modelName     uniqueID                             modelType version
-----------------------------------------------------------------------------------------------------------------
2021.07.20D18:26:17.904115000 "undefined"    "basic-model" e1636884-f7d8-93e5-9e72-fb23f7407473 ,"q"      1 0
2021.07.20D18:26:17.914201000 "undefined"    "basic-model" edaa5221-8e4f-4aef-52df-25d8794b28fe ,"q"      1 1
2021.07.20D18:26:17.925254000 "undefined"    "basic-model" a667b0f2-ce0c-e4bd-d870-6aab04579859 ,"q"      1 2
2021.07.20D18:26:17.932588000 "undefined"    "basic-model" 56be5696-cd31-f846-57d2-86f0dd92fe2e ,"q"      2 0
2021.07.20D18:26:17.939366000 "undefined"    "basic-model" bbf3120c-d75b-4f5a-21c0-368189291792 ,"q"      2 1
2021.07.20D18:26:21.086221000 "undefined"    "basic-model" 5386500e-7cee-fdf6-a493-d7a5c03c8280 ,"q"      1 3

// Delete version 1.3 of the 'basic-model'
q).ml.registry.delete.model[::;::;"basic-model";1 3];

// Display the modelStore following deletion of 1.3 of the 'basic-model'
q)show modelStore
registrationTime              experimentName modelName     uniqueID                             modelType version
-----------------------------------------------------------------------------------------------------------------
2021.07.20D18:26:17.904115000 "undefined"    "basic-model" e1636884-f7d8-93e5-9e72-fb23f7407473 ,"q"      1 0
2021.07.20D18:26:17.914201000 "undefined"    "basic-model" edaa5221-8e4f-4aef-52df-25d8794b28fe ,"q"      1 1
2021.07.20D18:26:17.925254000 "undefined"    "basic-model" a667b0f2-ce0c-e4bd-d870-6aab04579859 ,"q"      1 2
2021.07.20D18:26:17.932588000 "undefined"    "basic-model" 56be5696-cd31-f846-57d2-86f0dd92fe2e ,"q"      2 0
2021.07.20D18:26:17.939366000 "undefined"    "basic-model" bbf3120c-d75b-4f5a-21c0-368189291792 ,"q"      2 1

// Delete all models associated with the 'basic-model'
q).ml.registry.delete.model[::;::;"basic-model";::]

// Display the modelStore following deletion of 'basic-model'
q)show modelStore
registrationTime experimentName modelName uniqueID modelType version
--------------------------------------------------------------------

// Delete the registry
q).ml.registry.delete.registry[::;::]
```

## Externally generated model addition

Not all models that a user may want to use within the registry will have been generated in the q session being used to add the model to the registry.
In reality, they may not have been generated using q/embedPy at all.
For example, in the case of Python objects/models saved as `pickled files`/`h5 files` in the case of Keras models.

As such, the `.ml.registry.set.model` functionality also allows users to take the following file types (with appropriate limitations) and add them to the registry such that they can be retrieved.

Model Type | File Type         | Qualifying Conditions
-----------|-------------------|----------------------
q          | q-binary          | Retrieved model must be a q projection, function or dictionary with a predict key
Python     | pickled file      | The file must be loadable using `joblib.load`
Sklearn    | pickled file      | The file must be loadable using `joblib.load` and contain a `predict` method i.e. is a `fit` scikit-learn model
Keras      | HDF5 file         | The file must be loadable using `keras.models.load_model` and contain a `predict` method i.e. is a `fit` Keras model
PyTorch    | pickled file/jit  | The file must be loadable using `torch.jit.load` or `torch.load`, invocation of the function on load is expected to return predictions as a tensor

The following example invocations shows how q and sklearn models generated previously can be added to the registry:

* Load the repository
```q
$ q init.q
q)
```

* Add a saved q model (Clustering algorithm) to the ML Registry
```q
// Generate and save to disk a q clustering model
q)`:qModel set .ml.clust.kmeans.fit[2 200#400?1f;`e2dist;3;::]

q).ml.registry.set.model[::;::;`:qModel;"qModel";"q";::]
q).ml.registry.get.model[::;::;::;::]
modelInfo| `registry`model`monitoring!(`description`modelInformation`experime..
model    | `modelInfo`predict!(`repPts`clust`data`inputs!((0.7396003 0.256620..
```

* Add a saved Sklearn model to the ML Registry
```q
// Generate and save an sklearn model to disk
q)clf:.p.import[`sklearn.svm][`:SVC][]
q)mdl:clf[`:fit][100 2#200?1f;100?3]
q).p.import[`joblib][`:dump][mdl;"skmdl.pkl"]

q).ml.registry.set.model[::;::;`:skmdl.pkl;"skModel";"sklearn";::]
q).ml.registry.get.model[::;::;::;::]
modelInfo| `registry`model`monitoring!(`description`modelInformation`experime..
model    | {[f;x]embedPy[f;x]}[foreign]enlist
```

## Adding Python requirements with individually set models

By default, the addition of models to the registry as individual analytics includes:

1. Configuration outlined within `config/modelInfo.json`.
2. The model (Python/q) within a `model` folder.
3. A `metrics` folder for the storage of metrics associated with a model
4. A `parameters` folder for the storage parameter information associated with the model or associated data
5. A `code` folder which can be used to populate code that will be loaded on retrieval of a model.

What is omitted from this are the Python requirements that are necessary for the running of the models, these can be added as part of the `config` parameter in the following ways.

1. Setting the value associated with the `requirements` key to `1b` when in a virtualenv will `pip freeze` the current environment and save as a `requirements.txt` file.
2. Setting the value associated with the `requirements` key to a `symbol`/`hsym` which points to a file will copy that file as the `requirements.txt` file for that model, thus allowing users to point to a previously generated requirements file.
3. Setting the value associated with the `requirements` key to a list of strings will populate a `requirements.txt` file for the model containing each of the strings as an independent requirement

The following example shows how each of the above cases would be invoked:

* Freezing the current environment using pip freeze when in a virtualenv
```q
q).ml.registry.set.model[::;::;{x};"reqrModel";"q";enlist[`requirements]!enlist 1b]
```

* Pointing to an existing requirements file using relative or full path
```q
q).ml.registry.set.model[::;::;{x+1};"reqrModel";"q";enlist[`requirements]!enlist `:requirements.txt]
```

* Adding a list of strings as the requirements
```q
q)requirements:enlist[`requirements]!enlist ("numpy";"pandas";"scikit-learn")
q).ml.registry.set.model[::;::;{x+2};"reqrModel";"q";requirements]
```

## Associate metrics with a model

Metric information can be persisted with a saved model to create a table within the model registry to which data associated with the model can be stored.

The following shows how interactions with this functionality are facilitated:

* Set a model within the model registry
```q
q).ml.registry.set.model[::;"test";{x+1};"metricModel";"q";::];
```

* Log various metrics associated with a named model
```q
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func1;2.4]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func1;3]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func2;10.2]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func3;9]
q).ml.registry.log.metric[::;::;"metricModel";1 0;`func3;11.2]
```

* Retrieve all metrics associated with the model `metricModel`
```q
q).ml.registry.get.metric[::;::;"metricModel";1 0;::]
timestamp                     metricName metricValue
----------------------------------------------------
2021.04.23D10:21:46.690671000 func1      2.4
2021.04.23D10:21:52.523227000 func1      3
2021.04.23D10:21:57.338468000 func2      10.2
2021.04.23D10:22:04.314963000 func3      9
2021.04.23D10:22:08.899301000 func3      11.2
```

* Retrieve metric information related to a single named model
```q
q).ml.registry.get.metric[::;::;"metricModel";1 0;enlist[`metricName]!enlist `func1]
timestamp                     metricName metricValue
----------------------------------------------------
2021.04.23D10:21:46.690671000 func1      2.4
2021.04.23D10:21:52.523227000 func1      3
```

## Associating parameters with a model

Parameter information can be added to a saved model, this creates a json file within the models registry associated with a particular parameter.

* Set a model within the model registry
```q
q).ml.registry.set.model[::;::;{x+2};"paramModel";"q";::]
```

* Set parameters associated with the model
```q
q).ml.registry.set.parameters[::;::;"paramModel";1 0;"paramFile";`param1`param2!1 2]

q).ml.registry.set.parameters[::;::;"paramModel";1 0;"paramFile2";`value1`value2]
```

* Retrieve saved parameters associated with a model
```q
q).ml.registry.get.parameters[::;::;"paramModel";1 0;"paramFile"]
param1| 1
param2| 2

q).ml.registry.get.parameters[::;::;"paramModel";1 0;"paramFile2"]
"value1"
"value2"
```
