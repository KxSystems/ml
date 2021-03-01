// clust/kmeans.q - K means clustering
// Copyright (c) 2021 Kx Systems Inc
// 
// K means clustering.
// K-means clustering begins by selecting k data points 
// as cluster centers and assigning data to the cluster
// with the nearest center.
// The algorithm follows an iterative refinement process
// which runs a specified number of times, updating the 
// cluster centers and assigned points to a cluster at 
// each iteration based on the nearest cluster center.

\d .ml

// K-Means

// @kind function
// @category clust
// @desc Fit k-Means algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {symbol} Distance function name within '.ml.clust.i.df'
// @param k {long} Number of clusters
// @param config {dictionary} Configuration information which can be updated,
//   (::) allows a user to use default values, allows update for to maximum 
//   iterations `iter, initialisation type `init i.e. use k++ or random and
//   the threshold for smallest distance to move between the previous and
//   new run `thresh, a distance less than thresh will result in
//   early stopping
// @return {dictionary} A dictionary containing:
//   modelInfo - Encapsulates all relevant information needed to fit
//     the model `data`df`repPts`clt, where data and df are the inputs,
//     repPts are the calculated k centers and clt are clusters associated
//     with each of the datapoints
//   predict - A projection allowing for prediction on new input data
//   update - A projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
clust.kmeans.fit:{[data;df;k;config]
  data:clust.i.floatConversion[data];
  defaultDict:`iter`init`thresh!(100;1b;1e-5);
  if[config~(::);config:()!()];
  if[99h<>type config;'"config must be (::) or a dictionary"];
  // Update iteration dictionary with user changes
  updDict:defaultDict,config;
  // Fit algo to data
  r:clust.i.kMeans[data;df;k;updDict];
  // Return config with new clusters
  inputDict:`df`k`iter`kpp!(df;k;updDict`iter;updDict`init);
  modelInfo:r,`data`inputs!(data;inputDict);
  returnInfo:enlist[`modelInfo]!enlist modelInfo;
  predictFunc:clust.kmeans.predict returnInfo;
  updFunc:clust.kmeans.update returnInfo;
  returnInfo,`predict`update!(predictFunc;updFunc)
  }

// @kind function
// @category clust
// @desc Predict clusters using k-means config
// @param config {dictionary} A dictionary returned from '.ml.clust.kmeans.fit'
//   containing:
//   modelInfo - Encapsulates all relevant information needed to fit
//     the model `data`df`repPts`clt, where data and df are the inputs,
//     repPts are the calculated k centers and clt are clusters associated
//     with each of the datapoints
//   predict - A projection allowing for prediction on new input data
//   update - A projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param data {float[][]} Each column of the data is an individual datapoint
// @return {long[]} Predicted clusters
clust.kmeans.predict:{[config;data]
  config:config[`modelInfo];
  data:clust.i.floatConversion[data];
  // Get new clusters based on latest config
  clust.i.getClust[data;config[`inputs]`df;config`repPts]
  }

// @kind function
// @category clust
// @desc Update kmeans config including new data points
// @param config {dictionary} A dictionary returned from '.ml.clust.kmeans.fit'
//   containing:
//   modelInfo - Encapsulates all relevant information needed to fit
//     the model `data`df`repPts`clt, where data and df are the inputs,
//     repPts are the calculated k centers and clt are clusters associated
//     with each of the datapoints
//   predict - A projection allowing for prediction on new input data
//   update - A projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param data {float[][]} Each column of the data is an individual datapoint
// @return {dictionary} Updated model configuration (config), including predict 
//   and update functions
clust.kmeans.update:{[config;data]
  modelConfig:config[`modelInfo];
  data:clust.i.floatConversion[data];
  // Update data to include new points
  modelConfig[`data]:modelConfig[`data],'data;
  // Update k means
  modelConfig[`repPts]:clust.i.updCenters
    [modelConfig`data;modelConfig[`inputs]`df;()!();modelConfig`repPts];
  // Get updated clusters based on new means
  modelConfig[`clust]:clust.i.getClust
    [modelConfig`data;modelConfig[`inputs]`df;modelConfig`repPts];
  // Return updated config, prediction and update functions
  returnInfo:enlist[`modelInfo]!enlist modelConfig;
  returnKeys:`predict`update;
  returnVals:(clust.kmeans.predict returnInfo;
    clust.kmeans.update returnInfo);
  returnInfo,returnKeys!returnVals
  }
