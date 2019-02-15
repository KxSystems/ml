# X-Validation
## Introduction

The functions contained in this folder surround the implementation of various cross-validation procedures both time-series and non time-series in nature. The goal of this is to make such procedures available using a q-like syntax.
## Functionality
Within this folder is two script that constitutes the cross validation procedures which have been implemented to date. These scripts are broken down as follows.

1. Base level algorithm implementations (These do not include any distribution procedures)
2. Distributed versions of a number of these algorithms. This will be expanded on to include each of the available algorithms.

## Requirements

- embedPy

The python dependencies for this library can be installed by following the instructions outlined in the README.md at the root of this library

## Installation

Place the library file in `$QHOME` and load the utils files into a q instance via;
```q
$ q
q)\l ml/ml.q
q).ml.loadfile`:xval/init.q
```

## Documentation

Documentation is available on the [Cross-Validation](https://code.kx.com/q/ml/toolkit/utils/) homepage.

## Status

The machine learning utilities library is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.


