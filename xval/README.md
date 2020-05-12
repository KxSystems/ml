# Cross-Validation

The functions contained in this folder surround the implementation of various cross-validation procedures both time-series and non time-series in nature. The goal of this is to make such procedures available using a q-like syntax.

## Functionality

Within this folder are two scripts that constitutes the cross-validation procedures which have been implemented to date. These scripts are:

1. Base-level algorithm implementations (These do not include any distribution procedures)
2. Distributed versions of a number of these algorithms. This will be expanded on to include each of the available algorithms.

## Requirements

- embedPy

The Python dependencies for the FRESH library can be installed by following the instructions laid out in the ML-Toolkit level of this library.

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load cross-validation functionality into the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:xval/init.q
```

## Documentation

Documentation is available on the [Cross-Validation](https://code.kx.com/v2/ml/toolkit/xval/) homepage.

## Status

The cross-validation library is still in development and is available here as a beta release. Further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
