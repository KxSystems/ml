\d .ml

// Density-Based Spatial Clustering of Applications with Noise (DBSCAN)

// @kind function
// @category clust
// @fileoverview Fit DBSCAN algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df'
// @param minPts {long} Minimum number of points with the epsilon radius
// @param eps {float} Epsilon radius to search
// @return {dict} A dictionary containing:
//   modelInfo - Encapsulates all relevant infromation needed to fit
//     the model `data`inputs`clust`tab, where data is the original data,
//     inputs are the user defined minPts and eps, clust are the cluster
//     assignments and tab is the neighbourhood table defining items in the
//     clusters.
//   predict - A projection allowing for prediction on new input data
//   update - A projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
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
  returnInfo:enlist[`modelInfo]!enlist modelInfo;
  predictFunc:clust.dbscan.predict returnInfo;
  updFunc:clust.dbscan.update returnInfo;
  returnInfo,`predict`update!(predictFunc;updFunc)
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using DBSCAN config
// @param config {dict} A dictionary returned from '.ml.clust.dbscan.fit'
//   containing:
//   modelInfo - Encapsulates all relevant infromation needed to fit
//     the model `data`inputs`clust`tab, where data is the original data,
//     inputs are the user defined minPts and eps, clust are the cluster
//     assignments and tab is the neighbourhood table defining items in the 
//     clusters.
//   predict - A projection allowing for prediction on new input data
//   update - A projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param data {float[][]} Each column of the data is an individual datapoint
// @return {long[]} Predicted clusters
clust.dbscan.predict:{[config;data]
  config:config[`modelInfo];
  data:clust.i.floatConversion[data];
  // Predict new clusters
  -1^exec cluster from clust.i.dbscanPredict[data;config]
  }

// @kind function
// @category clust
// @fileoverview Update DBSCAN config including new data points
// @param config {dict} A dictionary returned from '.ml.clust.dbscan.fit'
//   containing:
//   modelInfo - Encapsulates all relevant infromation needed to fit
//     the model `data`inputs`clust`tab, where data is the original data,
//     inputs are the user defined minPts and eps, clust are the cluster
//     assignments and tab is the neighbourhood table defining items in the 
//     clusters.
//   predict - A projection allowing for prediction on new input data
//   update - A projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param data {float[][]} Each column of the data is an individual datapoint
//   and update functions
// @return {dict} Updated model configuration (config), including predict
clust.dbscan.update:{[config;data]
  modelConfig:config[`modelInfo];
  data:clust.i.floatConversion[data];
  // Original data prior to addition of new points, with core points set
  orig:update corePoint:1b from modelConfig[`tab]where cluster<>0N;
  // Predict new clusters
  new:clust.i.dbscanPredict[data;modelConfig];
  // Include new data points in training neighbourhood
  orig:clust.i.updNbhood/[orig;new;count[orig]+til count new];
  // Fit model with new data included to update model
  tab:{[t]any t`corePoint}.ml.clust.i.dbAlgo/orig,new;
  // Reindex the clusters
  tab:update{(d!til count d:distinct x)x}cluster from tab where cluster<>0N;
  // return updated config
  clusts:-1^exec cluster from tab;
  modelConfig,:`data`tab`clust!(modelConfig[`data],'data;tab;clusts);
  returnInfo:enlist[`modelInfo]!enlist modelConfig;
  returnKeys:`predict`update;
  returnVals:(clust.dbscan.predict returnInfo;
    clust.dbscan.update returnInfo);
  returnInfo,returnKeys!returnVals
  }
