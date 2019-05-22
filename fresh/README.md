# FRESH
## Introduction
Feature extraction and selection are important tasks in machine learning. They provide an opportunity to explore datasets in depth and can also improve prediction accuracy and allow the use of less complex models.

## Features
FreshQ is an implementation of the [FRESH](https://arxiv.org/pdf/1610.07717v3.pdf) (FeatuRe Extraction and Scalable Hypothesis testing) algorithm. FRESH allows users to derive new features from their input dataset, in order to characterize the underlying time series. Features vary in complexity from min and max to kurtosis and fourier coefficients. The majority of these functions are implemented in q with a small number dependent on python modules via embedPy.

FRESH also allows users to complete statistical tests, comparing input data with the target vector being predicted. Thus, the most statistically significant features can be selected from the expanded dataset.

FRESH can be used in conjunction with the util library, which contains functions for;
- Creation of polynomial features
- Tailored filling and interpolation of data by column (fill/median/mean/linear/zero).

## Requirements

- embedPy

The python dependencies for the FRESH library can be installed by following the instructions laid out in the ML-Toolkit level of this library.

## Installation
To test that all the requirements have been installed correctly and the library is ready for use run the following in console provided the folder ml is placed in $QHOME using the syntax;

```q
$ q

q)\l ml/ml.q
q).ml.loadfile`:fresh/init.q
```

## Documentation

Documentation is available on the [FRESH](https://code.kx.com/v2/ml/toolkit/fresh/) homepage.

## Status
  
The FRESH library is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
