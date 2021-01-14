# Numerical optimization

The functionality contained within this folder provides a number of implementations of numerical optimization techniques. Such techniques are used to find the local or global minima of user-provided objective functions and are central to many statistical models.

## Functionality

At present, the optimization folder contains an implementation of the Broyden-Fletcher-Goldfarb-Shanno algorithm. 

The Broyden-Fletcher-Goldfarb-Shanno(BFGS) algorithm is a quasi-Newton iterative method for solving unconstrained non-linear optimization problems. This is a class of hill-climbing optimization that seeks a stationary, preferably twice-differentiable, solution to the objective function.

## Requirements

- kdb+ > 3.5

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load the optimization functionality into the `.ml` namespace
```q
q)\l ml/ml.q
q).ml.loadfile`:optimize/init.q
```

## Documentation

Documentation is available on the [Optimization](https://code.kx.com/q/ml/toolkit/optimize/) homepage.

## Status

The optimization library is still in development. Further functionality and improvements will be made to the library on an ongoing basis.

If you have any issues, questions or suggestions, please write to ai@kx.com.
