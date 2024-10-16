# ML Registry

The ML Model Registry defines a centralised location for the storage of the following versioned entities:

1. Machine Learning Models
2. Model parameters
3. Performance metrics
4. Model configuration
5. Model monitoring information

The ML Registry is intended to allow models and all important metadata information associated with them to be stored locally.

In the context of an MLOps offering the model registry is a collaborative location allowing teams to work together on different stages of a machine learning workflow from model experimentation to publishing a model to production. It is designed to aid in this in the following ways:

1. Provide a solution with which users can store models generated in q/Python to a centralised location on-prem.
2. A common model retrieval API allowing models regardless of underlying requirements to be retrieved and used on kdb+ data.
3. The ability to store information related to model training/monitoring requirements, allowing sysadmins to control the promotion of models to production environments.
4. Enhanced team collaboration opportunities and management oversight by centralising team work to a common storage location.

## Contents

- [Quick start](#quick-start)
- [Documentation](#documentation)
- [Testing](#testing)
- [Status](#status)


## Quick start

Start by following the installation step found [here](../../../README.md) or alternatively start a q session using the code below from the `ml` folder

```
$ q init.q
q)
```

Generate a model registry in the current directory and display the contents

```
q).ml.registry.new.registry[::;::];
q)\ls
"CODEOWNERS"
"CONTRIBUTING.md"
"KX_ML_REGISTRY"
...
q)\ls KX_ML_REGISTRY
"modelStore"
"namedExperiments"
"unnamedExperiments"
```

Add an experiment folder to the registry

```
q).ml.registry.new.experiment[::;"test";::];
q)\ls KX_ML_REGISTRY/namedExperiments/
"test"
```

Add a basic q model associated with the experiment

```
q).ml.registry.set.model[::;{x+1};"mymodel";"q";enlist[`experimentName]!enlist "test"]
```

Check that the model has been added to the modelStore

```
q)modelStore
registrationTime              experimentName modelName uniqueID              ..
-----------------------------------------------------------------------------..
2021.08.02D10:27:04.863096000 "test"         "mymodel" 66f12a71-175b-cd56-7d0..
```

Retrieve the model and model information based on the model name and version

```
q).ml.registry.get.model[::;::;"mymodel";1 0]
modelInfo| `major`description`experimentName`folderPath`registryPath`modelSto..
model    | {x+1}
```

## Documentation

### Static Documentation

Further information on the breakdown of the API for interacting with the ML-Registry and extended examples can be found in [Registry API](api/setting.md) and [Registry Examples](examples/basic.md).

This provides users with:

1. A breakdown of the API for interacting with the ML-Registry
2. Examples of interacting with a registry

# Testing

Unit tests are provided for testing the operation of this interface both as a local service. In order to facilitate this users must have embedPy or pykx installed alongside the following additional Python requirements, it is also advisable to have the python requirements_pinned.txt installed before running the below.

```
$ pip install pyspark xgboost
```

The local tests are run using a bespoke q script. The local tests can be run standalone using the instructions outlined below.

## Local testing

The below tests are ran from the `ml` directory and test results will output to console

```bash
$ q ../test.q registry/tests/registry.t
```

This should present a summary of results of the unit tests.

# Status
This repository is still in active development and is provided here as a beta version, all code is subject to change.
