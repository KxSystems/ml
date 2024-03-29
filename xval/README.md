# Cross validation

The functions contained in this folder surround the implementation of various cross-validation procedures, both timeseries and non-timeseries in nature. The goal of this library is to make such procedures available to you through a q-like syntax.

## Functionality

Within this folder `xval.q` contains base-level implementations of cross-validation procedures, grid/random/Sobol-random hyperparameter searching methods and multi-processing procedures.

## Requirements

- embedPy
- [sobol-seq](https://pypi.org/project/sobol-seq/)

The Python dependencies for the FRESH library can be installed by following the instructions laid out in the ML-Toolkit level of this library. **Note** that `sobol-seq` must be installed using pip.

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load cross validation functionality into the `.ml` namespace  

```q
\l ml/ml.q
.ml.loadfile`:xval/init.q
```

## Documentation

Documentation is available on the [Cross Validation](../docs/xval.md) homepage.

## Status

The cross-validation library is still in development. Further functionality and improvements will be made to the library on an ongoing basis.

If you have any issues, questions or suggestions, please write to ai@kx.com.
