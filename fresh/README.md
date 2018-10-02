# FRESH
## Introduction
Feature extraction and feature selection are some of the most important tasks in machine learning applications. They provide the opportunity to explore datasets in depth prior to the application of a machine learning algorithm and have been shown to improve the accuracy, and facilitate the use of less complex models thus reducing computation time.

In the case of structured time series data which q is designed to deal with, these techniques provide the opportunity to explore the area of time series forecasting and data extraction within the areas of finance and manufacturing primarily.

## Features

FreshQ is an implementation of the [FRESH algorithm](https://arxiv.org/pdf/1610.07717v3.pdf) which is an acronym for FeatuRe Extraction and Scalable Hypothesis testing. This algorithm allows users to produce 1000’s of features from their input dataset based on a set of unique ids (date / hour / run# / chamber etc.). These features vary in complexity from min and max to kurtosis and  fourier coefficients. The majority of these functions are implemented in q with a small number dependent on python modules via embedPy given their complexity.

In conjunction with this the library also allows users to complete statistical tests comparing input data with the target vector being predicted. This feature along with the Benjamini-Hochberg-Yekutieli procedure to choose the statistically significant features can be used separately to the feature extraction step in the case where a user does not wish to use the expanded dataset.

Included in the library in addition to the extraction and significance procedures are functions to allow the following;
- Creation of polynomial features which allow extraction on interdependant features.
- Tailored filling of data by column (fill/median/mean/linear/zero).
- Completion of linear and fills like interpolation on time series data. 

## Requirements

- embedPy

The python dependencies for the FRESH library can be installed by following the instructions layed out in the ML-Toolkit level of this library.

## Installation
To test that all the requirements have been installed correctly and the library is ready for use run the following in console provided the folder ml is placed in $QHOME using the syntax;

```q
$ q

q)\l ml/ml.q
q).ml.loadfile`:fresh/init.q
```

## Documentation

Documentation is available on the [FRESH](https://code.kx.com/q/ml/toolkit/fresh/) homepage.

## Status
  
The FRESH library is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.