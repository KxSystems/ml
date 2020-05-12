# Utilities

The machine-learning utilities library contains a range of functions to aid kdb+/q users in applying machine-learning techniques to their datasets.

Functions are divided into three scripts, dealing with different aspects of machine learning

1.  Statistical functions for testing the performance of machine learning models, including confusion matrices, t-scores, logloss, specificity and accuracy.

2.  Preprocessing functions for the manipulation of data prior to the application of machine-learning algorithms. These include, tailored filling of data (linear, mean, median, zero, and forward filling), one-hot encoding, removal of zero-variance features from data, and the creation of polynomial features.

3.  Utilities commonly used in machine-learning applications, such as exploring the shape of data, conversion of q tables to Pandas dataframes (and vice-versa), and train-test splitting.
  
The functions contained in these scripts will be added to on an ongoing basis.

## Requirements

- embedPy

The Python dependencies for the FRESH library can be installed by following the instructions laid out in the ML-Toolkit level of this library.

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load utility functionality into the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:util/init.q
```

## Documentation

Documentation is available on the [Utilities](https://code.kx.com/v2/ml/toolkit/utils/) homepage.

## Status
  
The machine-learning utilities library is still in development and is available here as a beta release. Further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
