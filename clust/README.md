# Clustering

Clustering is a technique used in both data mining and machine learning to group similar data points together in order to identify patterns in their distributions. The task of clustering data can be carried out using a number of algorithms. The ML-Toolkit contains implementations of Affinity Propagation, CURE (Clustering Using REpresentatives), DBSCAN (Density-based spatial clustering of applications with noise), hierarchical and k-means clustering.

Each algorithm works by iteratively joining, separating or reassigning points until the desired number of clusters have been achieved. The process of finding the correct cluster for each data point is a case of trial and error, where parameters must be altered in order to find the optimum solution.

## Features

The clustering library contains the aforementioned clustering algorithms which can be used to cluster kdb+/q data. Additionally, there are scripts to create a k-d (k dimensional) tree, used for the CURE, single and centroid implementations and scoring and optimization functions which can be applied to the clustering algorithms.

## Installation

Place the `ml` library in `$QHOME` and load into a q instance using `ml/ml.q`

### C Build (optional)

To run the CURE single or centroid algorithms using the C implementation of the k-d tree, additional files must be downloaded. Instructions can be found at [code.kx.com](https://code.kx.com/v2/interfaces/c-client-for-q/#linux). The shared libraries must then be compiled by running below:

__Mac & Linux__:

```
make && make install && make clean
```

__Windows__ (within `build`):

```
call build.bat
```
**Note**: `build.bat` runs with Visual Studio 2017 and 2019 64 bit. For other versions, please set an environment variable named `VSDIR` pointing to the path of your Visual Studio batch file (vcvars32.bat, vcvars64.bat etc).

### Load

The following will load clustering functionality into the `.ml` namespace  
```q
q)\l ml/ml.q
q).ml.loadfile`:clust/init.q
```

## Documentation

Documentation is available on the [clustering](https://code.kx.com/v2/ml/toolkit/clustering/algos/) homepage.

## Status
  
The clustering library is still in development. Further functionality and improvements will be made to the library on an ongoing basis.

If you have any issues, questions or suggestions, please write to ai@kx.com.
