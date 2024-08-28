# Automated machine learning in kdb+

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kxsystems/automl)](https://github.com/kxsystems/automl/releases) [![Build Status](https://travis-ci.com/KxSystems/automl.svg?branch=master)](https://travis-ci.com/KxSystems/automl)


The automated machine learning library described here is built largely on the tools available within the [Machine Learning Toolkit](https://github.com/kxsystems/ml). The purpose of this framework is help you automate the process of applying machine learning techniques to real-world problems. In the absence of expert machine-learning engineers this handles the following processes within a traditional workflow.

- Data preprocessing
- Feature engineering and feature selection
- Model selection
- Hyperparameter Tuning
- Report generation and model persistence

Each of these steps is outlined in depth within the [documentation](docs).
This allows you to understand how decisions are being made and the transformations which their data undergo during the production of the output models.

At present the machine learning frameworks supported for this are based on:

1. One-to-one feature to target non time-series
2. FRESH based feature extraction and model production
3. NLP-based feature creation and word2vec transformation.

The problems which can be solved by this framework will be expanded over time as will the available functionality.

## Requirements

The following requirements cover all those needed to run the libraries in the current build of the toolkit.

- [embedPy](https://github.com/KxSystems/embedPy)
- ML-Toolkit ≥ 3.0.0

A number of Python dependencies also exist for the running of embedPy functions within both the the machine-learning utilities and FRESH libraries. Install  as follows:

pip:
```bash
pip install -r requirements.txt
```

or via conda:
```bash
conda install --file requirements.txt
```

### Optional requirements for advanced modules

The above requirements allow you to access the base functionality of AutoML. Additional modules are available – including Sobol sequence hyperparameter search, LaTeX report generation and Keras, PyTorch and NLP models. However, given the large memory requirement for the dependencies of these modules, they are not included in the base functionality and must be installed if required.

**Sobol search** - via pip (see package details [here](https://pypi.org/project/sobol-seq/)):
```bash
sobol-seq
```

**LaTeX** - via conda or pip:
```bash
pylatex
```

**Keras** - via conda or pip:
```bash
keras
tensorflow
```

**PyTorch** - via conda or pip:
```bash
torch
```

**Theano** - via conda or pip:
```bash
theano
```

**NLP**

The NLP functionality in AutoML requires the [KX NLP library](https://github.com/KxSystems/nlp) along with `gensim` which can be installed using conda or pip.


## Installation

Place the library file in `$QHOME` and load into a q instance using `automl/automl.q`

This will load all the functions contained within the `.ml` namespace  
```q
$q automl/automl.q
q).automl.loadfile`:init.q
```

## Documentation

:open_file_folder: [`docs`](docs)

## Status

Automated machine learning in kdb+ is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

Any issues with the framework should be raised in the issues section of this repository. Functionality suggestions or more general questions should be submitted via email to ai@kx.com

