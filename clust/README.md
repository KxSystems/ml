# Clustering

## Introduction

This repository contains numerous clustering methods, including hierarchical clustering, CURE (Clustering Using REpresentatives), k-means and DBSCAN (Density-Based Spatial Clustering of Applications with Noise). Clustering is a useful technique in data mining and statistical data analysis used to group similar data together and identify patterns in distributions.

The clustering algorithms above have been separated into two scripts - k-means can be found in `kmeans.q`, while the other algorithms can be found in `clust.q`. Additionally, example notebooks have been provided to show how the algorithms perform on a variety of datasets.

A k-dimensional tree (k-d tree) is used by the single and centroid hierarchical algorithms, as well as for CURE which can use both q and C implementations of the k-d tree.

## Requirements

- embedPy
- Matplotlib 2.1.1
- Scikit learn
- PyClustering (data samples)

## Status

The clustering library is still in development, further improvements will be made to the library in the coming months.
