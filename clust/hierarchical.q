\d .ml

// Clustering Using REpresentatives (CURE) and Hierarchical Clustering

// @kind function
// @category clust
// @fileoverview Fit CURE algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param n {long} Number of representative points per cluster
// @param c {float} Compression factor for representative points
// @return {dict} A dictionary containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
clust.cure.fit:{[data;df;n;c]
  data:clust.i.floatConversion[data];
  if[not df in key clust.i.df;clust.i.err.df[]];
  dgram:clust.i.hcSCC[data;df;`cure;1;n;c;1b];
  modelInfo:`data`inputs`dgram!(data;`df`n`c!(df;n;c);dgram);
  returnInfo:enlist[`modelInfo]!enlist modelInfo;
  predictFunc:clust.cure.predict[;returnInfo;];
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category clust
// @fileoverview Fit Hierarchical algorithm to data
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param lf {sym} Linkage function name within '.ml.clust.i.lf' 
// @return {dict} A dictionary containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
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
  returnInfo:enlist[`modelInfo]!enlist modelInfo;
  predictFunc:clust.hc.predict[;returnInfo;];
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category clust
// @fileoverview Convert CURE config to k clusters
// @param config {dict} A dictionary returned from '.ml.clust.cure.fit'
//   containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param k {long} Number of clusters
// @return {dict} Updated config with clusters labels added
clust.cure.cutK:{[config;k]
  clust.i.checkK[k];
  clustVal:clust.i.cutDgram[config[`modelInfo;`dgram];k-1];
  clusts:enlist[`clust]!enlist clustVal;
  config,clusts
  }

// @kind function
// @category clust
// @fileoverview Convert hierarchical config to k clusters
// @param config {dict} A dictionary returned from '.ml.clust.hc.fit'
//   containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param k {long} Number of clusters
// @return {dict} Updated config with clusters added
clust.hc.cutK:clust.cure.cutK

// @kind function
// @category clust
// @fileoverview Convert CURE dendrogram to clusters based on distance 
//   threshold
// @param config {dict} A dictionary returned from '.ml.clust.cure.fit'
//   containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param distThresh {float} Cutting distance threshold
// @return {dict} Updated config with clusters added
clust.cure.cutDist:{[config;distThresh]
  clust.i.checkDist[distThresh];
  dgram:config[`modelInfo;`dgram];
  k:0|count[dgram]-exec first i from dgram where dist>distThresh;
  config,enlist[`clust]!enlist clust.i.cutDgram[dgram;k]
  }

// @kind function
// @category clust
// @fileoverview Convert hierarchical dendrogram to clusters based on distance
//   threshold
// @param config {dict} A dictionary returned from '.ml.clust.cure.fit'
//   containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
// @param distThresh {float} Cutting distance threshold
// @return {dict} Updated config with clusters added
clust.hc.cutDist:clust.cure.cutDist

// @kind function
// @category clust
// @fileoverview Predict clusters using CURE config
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config {dict} A dictionary returned from '.ml.clust.cure.fit'
//   containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
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
// @param config {dict} A dictionary returned from '.ml.clust.cure.fit'
//   containing:
//   - modelInfo which encapsulates all relevant information needed to fit
//     the model `data`inputs`dgram, where data is the original data, inputs
//     are the user defined linkage and distance functions while dgram
//     is the generated dendrogram
//   - predict is a projection allowing for prediction on new input data
//   - update is a projection allowing new data to be used to update
//     cluster centers such that the model can react to new data
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
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param n {long} Number of representative points per cluster
// @param c {float} Compression factor for representative points
// @param cutDict {dict} The key defines what cutting algo to use when 
//   splitting the data into clusters (`k/`cut) and the value defines the
//   cutting threshold
// @return {dict} Updated config with clusters added
clust.cure.fitPredict:{[data;df;n;c;cutDict]
  fitModel:clust.cure.fit[data;df;n;c];
  clust.i.prepPred[fitModel;cutDict]
  }

// @kind function
// @category clust
// @fileoverview Fit hierarchial algorithm to data and convert dendrogram 
//   to clusters
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.i.df' 
// @param lf {sym} Linkage function name within '.ml.clust.i.lf' 
// @param cutDict {dict} The key defines what cutting algo to use when 
//   splitting the data into clusters (`k/`cut) and the value defines the
//   cutting threshold
// @return {dict} Updated config with clusters added
clust.hc.fitPredict:{[data;df;lf;cutDict]
  fitModel:clust.hc.fit[data;df;lf];
  clust.i.prepPred[fitModel;cutDict]
  }
