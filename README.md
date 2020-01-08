# Machine learning toolkit


[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kxsystems/ml)](https://github.com/kxsystems/ml/releases) [![Travis (.org) branch](https://img.shields.io/travis/kxsystems/embedpy/master?label=travis%20build)](https://travis-ci.org/KxSystems/ml.svg?branch=master)

## Introduction
This repository contains the following sections:
*  An implementation of the FRESH (FeatuRe Extraction and Scalable Hypothesis testing) algorithm for use in the extraction of features from time series data and the reduction in the number of features through statistical testing. 
*  Utility functions relating to areas including statistical analysis, data preprocessing and array manipulation.
*  Cross validation and grid-search functions allowing for testing of the stability of models to changes in the volume of data or the specific subsets of data used in training.

The contents of these sections are explained in greater depth within [FRESH](https://code.kx.com/v2/ml/toolkit/fresh/), [Utilities](https://code.kx.com/v2/ml/toolkit/utilities/metric) and [Cross Validation](https://code.kx.com/v2/ml/toolkit/xval) documentation.
## Requirements

- embedPy

The python packages required to allow successful exectution of all functions within the machine learning toolkit can be installed via:

pip:
```bash
pip install -r requirements.txt
```

or via conda:
```bash
conda install --file requirements.txt
```

*Running of the notebook examples contained within the FRESH section of this library will require the installation of JupyterQ however this is not a dependancy for the running of functions at an individual level.*

## Installation

Place the library file in `$QHOME` and load into a q instance using `ml/ml.q`

This will load all the functions contained within the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:init.q
```

## Documentation

Documentation for all sections of the machine learning toolkit are available [here](https://code.kx.com/v2/ml/toolkit/).

## Status

The machine learning toolkit is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
