# Clustering

## Introduction

Clustering is a technique used in both data mining and machine learning to group similar data points together in order to identify patterns in their distributions. The task of clustering data can be carried out using a number of algorithms. The ML-Toolkit contains implementations of Affinity Propagation, CURE (Clustering Using REpresentatives), DBSCAN (Density-based spatial clustering of applications with noise), hierarchical and k-means clustering. These algorithms work based on distinct clustering methodologies namely; connectivity-based, centroid-based or density-based models.

-   Connectivity models, which include hierarchical and CURE, cluster data based on distances between individual data points.
-   Centroid models such as affinity propagration and k-means define clusters based on distances from single points which represent the cluster.
-   Density-based models such as DBSCAN define clusters based on data points being within a certain distance of each other and in defined concentrations.

Each algorithm works by iteratively joining, separating or reassigning points until the desired number of clusters have been achieved. The process of finding the correct cluster for each data point is a case of trial and error, where parameters must be altered in order to find the optimum solution.

## Features

The clustering library contains the aforementioned clustering algorithms which can be used to cluster kdb+/q data. Additionally, there are scripts to create and build a k-d (k dimensional) tree, used for the CURE, single and centroid implementations and scoring and optimization functions which can be applied to the clustering algorithms.

## Requirements

- embedPy
- Matplotlib 2.1.1
- Sklearn 0.19.1
- Scipy 1.1.0
- PyClustering

## Installation

Place the ml library file in `$QHOME` and check that requirements have been met.

### C Build

To run the CURE single or centroid algorithms using the C implementation of the k-d tree, additional files must be downloaded. Instructions can be found at [code.kx.com](https://code.kx.com/v2/interfaces/c-client-for-q/#linux). The shared libraries must then be compiled by running below:

__Mac & Linux__:

```
make && make install && make clean
```

__Windows__ (within `build`):

```
call build.bat 2017
```
**Note**: `build.bat` runs with Visual Studio 2019 and 2017. For other versions, please modify file accordingly.

## Load

Check that the library is ready for use by running the following:

```q
$ q
q)\l ml/ml.q
q).ml.loadfile`:clust/init.q
```

## Documentation

Documentation is available on the [clustering](https://code.kx.com/v2/ml/toolkit/clustering/algos/) homepage.

## Status
  
The clustering library is still in development and is available here as a beta release, further functionality and improvements will be made to the library in the coming months.

If you have any issues, questions or suggestions, please write to ai@kx.com.
