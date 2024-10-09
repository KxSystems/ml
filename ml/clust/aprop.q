// clust/init.q - Affinity propagation 
// Copyright (c) 2021 Kx Systems Inc
// 
// Clustering using affinity propagation. 
// Affinity Propagation groups data based on the similarity 
// between points and subsequently finds exemplars, which best 
// represent the points in each cluster. The algorithm does 
// not require the number of clusters be provided at run time, 
// but determines the optimum solution by exchanging real-valued 
// messages between points until a high-valued set of exemplars 
// is produced.

\d .ml

// @kind function
// @category clust
// @desc Fit affinity propagation algorithm
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {symbol} Distance function name within '.ml.clust.df'
// @param damp {float} Damping coefficient
// @param diag {fn} Function applied to the similarity matrix diagonal
// @param iter {dictionary} Max number of overall iterations and iterations 
//   without a change in clusters. (::) can be passed in which case the 
//   defaults of (`total`noChange!200 15) will be used
// @return {dictionary} Data, input variables, clusters and exemplars 
//   (`data`inputs`clust`exemplars) required, along with a projection of the
//   predict function
clust.ap.fit:{[data;df;damp;diag;iter]
  data:clust.i.floatConversion[data];
  defaultDict:`run`total`noChange!0 200 15;
  if[iter~(::);iter:()!()];
  if[99h<>type iter;'"iter must be (::) or a dictionary"];
  // Update iteration dictionary with user changes
  updDict:defaultDict,iter;
  // Cluster data using AP algo
  modelInfo:clust.i.runAp[data;df;damp;diag;til count data 0;updDict];
  returnInfo:enlist[`modelInfo]!enlist modelInfo;
  predictFunc:clust.ap.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category clust
// @desc Predict clusters using AP config
// @param config {dictionary} `data`inputs`clust`exemplars returned by the 
//   modelInfo key from the return of clust.ap.fit
// @param data {float[][]} Each column of the data is an individual datapoint
// @return {long[]} Predicted clusters
clust.ap.predict:{[config;data]
  config:config`modelInfo;
  data:clust.i.floatConversion[data];
  if[-1~first config`clust;
    '"'.ml.clust.ap.fit' did not converge, all clusters returned -1.",
     " Cannot predict new data."
    ];
  // Retrieve cluster centres from training data
  exemp:config[`data][;distinct config`exemplars];
  // Predict testing data clusters
  data:$[0h=type data;flip;enlist]data;
  clust.i.apPredDist[exemp;config[`inputs]`df]each data
  }
