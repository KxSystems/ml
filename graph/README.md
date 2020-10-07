# Graphing and Pipeline interface

The functionality contained in this folder surrounds the implementation of a graph and pipeline execution structural form of kdb+. This functionality is intended to provide a common structural template and execution mechanism for complex code bases require ease of modification which is common within machine learning use cases.

## Functionality

Within this folder are two scripts that contains the entirity of this graph and pipeline functionality. These scripts are:

1. graph.q: This contains all functionality required for the creation, deletion and update of nodes and edges within the graph structure.
2. pipeline.q: This contains functionality for both the compilation and execution of a user generated graph.

## Requirements

- kdb+ > 3

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### Load

The following will load the graphing and pipeline functionality into the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:graph/init.q
```

## Documentation

Documentation is available on the [Graph](https://code.kx.com/q/ml/toolkit/graph/) homepage.

## Status

The graph-pipeline library is still in development and is available here as a beta release. Further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
