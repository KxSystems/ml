# Machine Learning Toolkit

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kxsystems/ml?include_prereleases)](https://github.com/kxsystems/ml/releases) [![Build Status](https://travis-ci.com/KxSystems/ml.svg?branch=master)](https://travis-ci.com/KxSystems/ml)

The Machine Learning Toolkit is at the core of kdb+/q-centered machine-learning functionality. This library contains functions that cover the following areas:
*  An implementation of the FRESH (FeatuRe Extraction and Scalable Hypothesis testing) algorithm for use in the extraction of features from time series data and the reduction in the number of features through statistical testing. 
*  Cross-validation and grid-search functions allowing for testing of the stability of models to changes in the volume of data or the specific subsets of data used in training.
*  Clustering algorithms used to group data points and to identify patterns in their distributions. The algorithms make use of a k-dimensional tree to store points and scoring functions to analyze how well they performed.
*  Statistical timeseries models and feature-extraction techniques used for the application of machine learning to timeseries problems. These models allow for the forecasting of the future behavior of a system under various conditions.
*  Numerical techniques for calculating the optimal parameters for an objective function.
*  A graphing and pipeline library for the creation of modularized executable workflow based on a structure described by a mathematical directed graph.
*  Utility functions relating to areas including statistical analysis, data preprocessing and array manipulation.

These sections are explained in greater depth within the [FRESH](docs/fresh.md), [cross validation](docs/xval.md), [clustering](docs/clustering/algos.md), [timeseries](docs/timeseries/README.md), [optimization](docs/optimize.md), [graph/pipeline](docs/graph/README.md) and [utilities](docs/utilities/metric.md) documentation.

## Requirements

- embedPy

The Python packages required to allow successful execution of all functions within the machine learning toolkit can be installed via:

pip:
```bash
pip install -r requirements.txt
```

or via conda:
```bash
conda install --file requirements.txt
```


## Installation

Place the `ml` folder in `$QHOME` and load into a q instance using `ml/ml.q`

The following will load **all** functionality into the `.ml` namespace  
```q
\l ml/ml.q
.ml.loadfile`:init.q
```

## Examples

Examples showing implementations of several components of this toolkit can be found [here](https://github.com/KxSystems/mlnotebooks/). These notebooks include examples of the following sections of the toolkit.

*  Pre-processing functions
*  Implementations of the FRESH algorithm
*  Cross validation and grid search capabilities
*  Results Scoring functionality
*  Clustering methods applied to datasets
*  Timeseries modeling examples

## Documentation

Documentation for all sections of the Machine Learning Toolkit:

:open_file_folder: [`docs`](docs)

## Status

The Machine Learning Toolkit is provided here under an Apache 2.0 license.

If you find issues with the interface or have feature requests, please [raise an issue](https://github.com/KxSystems/ml/issues).

To contribute to this project, please follow the [contributing guide](CONTRIBUTING.md).
