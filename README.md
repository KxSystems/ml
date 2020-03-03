# Automated machine learning in kdb+

## Introduction

The automated machine learning platform described here is built largely on the tools available within the machine learning toolkit. The purpose of this platform is to provide users with the ability to automate the process of applying machine learning techniques to real-world problems. In the absence of expert machine learning engineers this handles the following processes within a traditional workflow.

- Data preprocessing
- Feature engineering and feature selection
- Model selection
- Hyperparameter Tuning
- Report generation and model persistence

Each of these steps is outlined in depth within the documentation for this platform [here](... INSERT THE DOCUMENTATION_LINK ...). This allows users to understand the processes by which decisions are being made and the transformations which their data undergo during the production of the output models.

At present the machine learning frameworks supported for this are based on:

1. One-to-one feature to target non time-series
2. FRESH based feature extraction and model production

The problems which can be solved by this platform will be expanded over time as will the available functionality.

## Requirements

The following requirements cover all those needed to run the libraries in the current build of the toolkit.

- embedPy
- ML-Toolkit

A number of Python dependencies also exist for the running of embedPy functions within both the the machine-learning utilities and FRESH libraries. Install of the requirements can be completed as follows

pip:
```bash
pip install -r requirements.txt
```

or via conda:
```bash
conda install --file requirements.txt
```

**Note**: Tensorflow and Keras are required for the application of the deep learning models within this platform. However given the large memory requirements of tensorflow the platform will operate without tensorflow by not running the deep learning models. In order to access the full functionality of the interface keras and tensorflow will need to be installed separately.

## Installation

Place the library file in `$QHOME` and load into a q instance using `automl/automl.q`

This will load all the functions contained within the `.ml` namespace  
```q
$q automl/automl.q
q).automl.loadfile`:init.q
```

## Documentation

Documentation for all sections of the machine learning toolkit are available [here](https://code.kx.com/v2/ml/automl/).

## Status

Automated machine learning in kdb+ is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
