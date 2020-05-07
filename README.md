# Machine learning toolkit

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kxsystems/ml)](https://github.com/kxsystems/ml/releases) [![Travis (.org) branch](https://img.shields.io/travis/kxsystems/embedpy/master?label=travis%20build)](https://travis-ci.org/kxsystems/ml/branches)

## Introduction
This repository contains the following sections:
*  An implementation of the FRESH (FeatuRe Extraction and Scalable Hypothesis testing) algorithm for use in the extraction of features from time series data and the reduction in the number of features through statistical testing. 
*  Utility functions relating to areas including statistical analysis, data preprocessing and array manipulation.
*  Cross validation and grid-search functions allowing for testing of the stability of models to changes in the volume of data or the specific subsets of data used in training.
*  Clustering algorithms used to group data points and to identify patterns in their distributions. The algorithms make use of a k-dimensional tree to store points and scoring functions to analyze how well they performed.

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

## Installation

Place the library file in `$QHOME` and load into a q instance using `ml/ml.q`

This will load all the functions contained within the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:init.q
```

## Examples

Examples showing implementations of several components of this toolkit can be found [here](https://github.com/KxSystems/mlnotebooks/). These notebooks include examples of the following sections of the toolkit.

*  Pre-processing functions
*  Implementations of the FRESH algorithm
*  Cross validation and grid search capabilities
*  Results Scoring functionality
*  Clustering methods applied to datasets


## Documentation

Documentation for all sections of the machine learning toolkit are available [here](https://code.kx.com/v2/ml/toolkit/).

## Status

The machine learning toolkit is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
