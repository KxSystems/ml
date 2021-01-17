\d .ml

// Clustering Using REpresentatives (CURE) and Hierarchical Clustering

// @kind function
// @category clust
// @fileoverview Fit CURE algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df' 
// @param n {long} Number of representative points per cluster
// @param c {float} Compression factor for representative points
// @return {dict} Data, input variables and dendrogram (`data`inputs`dgram) 
//   along with a projection of the predict function
clust.cure.fit:{[data;df;n;c]
  data:clust.i.floatConversion[data];
  if[not df in key clust.i.df;clust.i.err.df[]];
  dgram:clust.i.hcSCC[data;df;`cure;1;n;c;1b];
  modelInfo:`data`inputs`dgram!(data;`df`n`c!(df;n;c);dgram);
  predictFunc:clust.cure.predict[;modelInfo;];
  `modelInfo`predict!(modelInfo;predictFunc)
  }

// @kind function
// @category clust
// @fileoverview Fit Hierarchical algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df' 
// @param lf {sym} Linkage function name within '.ml.clust.lf' 
// @return {dict} Data, input variables and dendrogram (`data`inputs`dgram) 
//   along with a projection of the predict functin
clust.hc.fit:{[data;df;lf]
  // Check distance and linkage functions
  data:clust.i.floatConversion[data];
  if[not df in key clust.i.df;clust.i.err.df[]];
  dgram:$[lf in`complete`average`ward;
    clust.i.hcCAW[data;df;lf;2;1b];
    lf in`single`centroid;
    clust.i.hcSCC[data;df;lf;1;::;::;1b];
    clust.i.err.lf[]
    ];
  modelInfo:`data`inputs`dgram!(data;`df`lf!(df;lf);dgram);
  predictFunc:clust.hc.predict[;modelInfo;];
  `modelInfo`predict!(modelInfo;predictFunc)
  }

// @kind function
// @category clust
// @fileoverview Convert CURE config to k clusters
// @param config {dict} Output of .ml.clust.cure.fit
// @param k {long} Number of clusters
// @return {dict} Updated config with clusters labels added
clust.cure.cutK:{[config;k]
  config,enlist[`clust]!enlist clust.i.cutDgram[config`dgram;k-1]
  }

// @kind function
// @category clust
// @fileoverview Convert hierarchical config to k clusters
// @param config {dict} Output of .ml.clust.hc.fit
// @param k {long} Number of clusters
// @return {dict} Updated config with clusters added
clust.hc.cutK:clust.cure.cutK

// @kind function
// @category clust
// @fileoverview Convert CURE dendrogram to clusters based on distance 
//   threshold
// @param config {dict} Output of .ml.clust.cure.fit
// @param distThresh {float} Cutting distance threshold
// @return {dict} Updated config with clusters added
clust.cure.cutDist:{[config;distThresh]
  dgram:config`dgram;
  k:0|count[dgram]-exec first i from dgram where dist>distThresh;
  config,enlist[`clust]!enlist clust.i.cutDgram[dgram;k]
  }

// @kind function
// @category clust
// @fileoverview Convert hierarchical dendrogram to clusters based on distance
//   threshold
// @param config {dict} Output of .ml.clust.hc.fit
// @param distThresh {float} Cutting distance threshold
// @return {dict} Updated config with clusters added
clust.hc.cutDist:clust.cure.cutDist

// @kind function
// @category clust
// @fileoverview Predict clusters using CURE config
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} Clustering information returned from `fit`
// @param cutDict {dict} The key defines what cutting algo to use when 
//   splitting the data into clusters (`k/`cut) and the value defines the
//   cutting threshold
// @return {long[]} Predicted clusters
clust.cure.predict:{[data;config;cutDict]
  updConfig:clust.i.prepPred[config;cutDict];
  clust.i.hCCpred[`cure;data;updConfig]
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using hierarchical config
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} Clustering information returned from `fit`
// @param cutDict {dict} The key defines what cutting algo to use when 
//   splitting the data into clusters (`k/`cut) and the value defines the
//   cutting threshold
// @return {long[]} Predicted clusters
clust.hc.predict:{[data;config;cutDict]
  updConfig:clust.i.prepPred[config;cutDict];
  clust.i.hCCpred[`hc;data;updConfig]
  }

// @kind function
// @category clust
// @fileoverview Fit CURE algorithm to data and convert dendrogram to clusters
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df' 
// @param n {long} Number of representative points per cluster
// @param c {float} Compression factor for representative points
// @param cutDict {dict} The key defines what cutting algo to use when 
//   splitting the data into clusters (`k/`cut) and the value defines the
//   cutting threshold
// @return {dict} Updated config with clusters added
clust.cure.fitPredict:{[data;df;n;c;cutDict]
  fitModel:clust.cure.fit[data;df;n;c]`modelInfo;
  clust.i.prepPred[fitModel;cutDict]
  }

// @kind function
// @category clust
// @fileoverview Fit hierarchial algorithm to data and convert dendrogram 
//   to clusters
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df' 
// @param lf {sym} Linkage function name within '.ml.clust.lf' 
// @param cutDict {dict} The key defines what cutting algo to use when 
//   splitting the data into clusters (`k/`cut) and the value defines the
//   cutting threshold
// @return {dict} Updated config with clusters added
clust.hc.fitPredict:{[data;df;lf;cutDict]
  fitModel:clust.hc.fit[data;df;lf]`modelInfo;
  clust.i.prepPred[fitModel;cutDict]
  }
