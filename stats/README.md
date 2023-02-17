# Statistical Analysis

This folder contains implementations of statistical methods for data exploration and estimation of models parameters.

## Functionality

The functionality contained within this section range from descriptive statistical methods to gain more insight into data, to linear regression estimation methods to investigate unknown parameters in a model. The linear regression implementations include `Ordinary Least Squares` and `Weighted Least Squares` 


## Requirements

- kdb+ > 3.5

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load the optimization functionality into the `.ml` namespace
```q
q)\l ml/ml.q
q).ml.loadfile`:stats/init.q
```

## Documentation

Documentation is available on the [Statistics](../docs/stats.md) homepage.

## Status

The optimization library is still in development. Further functionality and improvements will be made to the library on an ongoing basis.

If you have any issues, questions or suggestions, please write to ai@kx.com.
