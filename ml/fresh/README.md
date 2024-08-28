# FRESH

Feature extraction and selection are important tasks in machine learning. They provide an opportunity to explore datasets in depth and can also improve prediction accuracy and allow the use of less complex models. 

## Features

FRESH is an implementation of the [FRESH](https://arxiv.org/pdf/1610.07717v3.pdf) (FeatuRe Extraction and Scalable Hypothesis testing) algorithm. FRESH allows users to derive new features from their input dataset, in order to characterize the underlying time series. Features vary in complexity from min and max values, to kurtosis and fourier coefficients. The majority of these functions are implemented in q, with a small number dependent on python modules, accessed via embedPy.

FRESH also allows users to complete statistical tests, comparing the input data with the target vector being predicted. Thus, the most statistically significant features can be selected from the expanded dataset.

FRESH can be used in conjunction with the util library, which contains functions for:
- Creation of polynomial features
- Tailored filling and interpolation of data by column (fill/median/mean/linear/zero).

## Requirements

- embedPy

The python dependencies for the FRESH library can be installed by following the instructions laid out in the ML-Toolkit level of this library.

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load FRESH functionality into the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:fresh/init.q
```

## Documentation

Documentation is available on the [FRESH](../docs/fresh.md) homepage.

## Status
  
The FRESH library is still in development. Further functionality and improvements will be made to the library on an ongoing basis.

If you have any issues, questions or suggestions, please write to ai@kx.com.
