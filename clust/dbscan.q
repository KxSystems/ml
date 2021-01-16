\d .ml

// Density-Based Spatial Clustering of Applications with Noise (DBSCAN)

// @kind function
// @category clust
// @fileoverview Fit DBSCAN algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df'
// @param minPts {long} Minimum number of points with the epsilon radius
// @param eps {float} Epsilon radius to search
// @return {dict} Data, inputs, clusters and cluster table 
//   (`data`inputs`clust`tab) required for predict and update methods
clust.dbscan.fit:{[data;df;minPts;eps]
  data:clust.i.floatConversion[data];
  // Check distance function
  if[not df in key clust.i.df;clust.i.err.df[]];
  // Create neighbourhood table
  tab:clust.i.nbhoodTab[data;df;minPts;eps;til count data 0];
  // Apply the density based clustering algorithm over the neighbourhood table
  tab:{[t]any t`corePoint}clust.i.dbAlgo/tab;
  // Find cluster for remaining points and return list of clusters
  clust:-1^exec cluster from tab;
  // Return config dict
  inputDict:`df`minPts`eps!(df;minPts;eps);
  modelInfo:`data`inputs`clust`tab!(data;inputDict;clust;tab);
  predictFunc:clust.dbscan.predict[;modelInfo];
  updFunc:clust.dbscan.update[;modelInfo];
  `modelInfo`predict`update!(modelInfo;predictFunc;updFunc)
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using DBSCAN config
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} `data`df`minPts`eps`clust returned from DBSCAN 
//   clustered training data
// @return {long[]} Predicted clusters
clust.dbscan.predict:{[data;config]
  data:clust.i.floatConversion[data];
  // Predict new clusters
  -1^exec cluster from clust.i.dbscanPredict[data;config]
  }

// @kind function
// @category clust
// @fileoverview Update DBSCAN config including new data points
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} `data`inputs`clust`nbh returned from DBSCAN clustered 
//   training data
// @return {dict} Updated model config
clust.dbscan.update:{[data;config]
  data:clust.i.floatConversion[data];
  // Original data prior to addition of new points, with core points set
  orig:update corePoint:1b from config[`tab]where cluster<>0N;
  // Predict new clusters
  new:clust.i.dbscanPredict[data;config];
  // Include new data points in training neighbourhood
  orig:clust.i.updNbhood/[orig;new;count[orig]+til count new];
  // Fit model with new data included to update model
  tab:{[t]any t`corePoint}.ml.clust.i.dbAlgo/orig,new;
  // Reindex the clusters
  tab:update{(d!til count d:distinct x)x}cluster from tab where cluster<>0N;
  // return updated config
  clusts:-1^exec cluster from tab;
  config,`data`tab`clust!(config[`data],'data;tab;clusts)
  }
