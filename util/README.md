# Utils
## Introduction
The functions contained in this folder constitute a set of functions which are used extensively in machine learning applications. These range from functions for the tailored filling of data within a table to statistical functions such as calculations of sensitivity or specificity.
## Functionality
Within the folder mlutils are 3 scripts which deal with different aspects of machine learning and the functions that have been produced to aid the kdb+/q user in applying machine learning procedures to their datasets

1. Statistical functions for testing the accuracy of machine learning procedures including but not limited to, confusion matrices, t-score, logloss, specificity and accuracy.

2. Preprocessing functions for the manipulation of data prior to the application of machine learning algotithms. These include, tailored filling of data (linear/mean/median/zero and forward filling), one hot encoding, removal of zero variance features from data, creation of polynomial features and the production of rolled windowed(forecasting frame) tables.

3. Finally within utils, funcs.q contains functions found to be commonly used in ML applications, conversion of time data value to longs such that they can be used as features, conversion of q tables to pandas dataframes (and vice-versa), train-test split functions (seeded/unseeded), producing arrays and checking matrices properties
  
The functions which are currently contained in these scripts are by no means exhaustive and will be added to on an ongoing basis.
## Requirements

- embedPy

The python dependencies for this library can be installed by following the instructions outlined in the README.md at the root of this library

## Installation

Place the library file in `$QHOME` and load the utils files into a q instance via;
```q
$ q
q)\l ml/ml.q
q).ml.loadfile`:util/init.q
```

## Documentation

Documentation is available on the [Utilities](https://code.kx.com/q/ml/toolkit/utils/) homepage.

## Status
  
The machine learning utilities library is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
