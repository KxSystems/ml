\d .ml

// K-Means

// @kind function
// @category clust
// @fileoverview Fit k-Means algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df'
// @param k {long} Number of clusters
// @param config {dict} Configuration information which can be updated, (::) 
//   allows a user to use default values, allows update for to maximum 
//   iterations `iter, initialisation type `init and threshold for smallest 
//   distance to move between the previous and new run `thresh
// @return {dict} Model config `data`df`repPts`clt where data and df are the
//   inputs, repPts are the calculated k means and clt are the associated 
//   clusters
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
  predictFunc:clust.kmeans.predict[;modelInfo];
  updFunc:clust.kmeans.update[;modelInfo];
  `modelInfo`predict`update!(modelInfo;predictFunc;updFunc)
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using k-means config
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df'
// @param config {dict} `data`df`repPts`clt returned from kmeans clustered 
//   training data
// @return {long[]} Predicted clusters
clust.kmeans.predict:{[data;config]
  data:clust.i.floatConversion[data];
  // Get new clusters based on latest config
  clust.i.getClust[data;config[`inputs]`df;config`repPts]
  }

// @kind function
// @category clust
// @fileoverview Update kmeans config including new data points
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} `data`df`repPts`clt returned from kmeans clustered 
//   on training data
// @return {dict} Updated model config
clust.kmeans.update:{[data;config]
  data:clust.i.floatConversion[data];
  // Update data to include new points
  config[`data]:config[`data],'data;
  // Update k means
  config[`repPts]:clust.i.updCenters
    [config`data;config[`inputs]`df;()!();config`repPts];
  // Get updated clusters based on new means
  config[`clust]:clust.i.getClust
    [config`data;config[`inputs]`df;config`repPts];
  // Return updated config
  config
  }