\d .ml

// Affinity Propagation

// @kind function
// @category clust
// @fileoverview Fit affinity propagation algorithm
// @param data {float[][]} Each column of the data is an individual datapoint
// @param df {sym} Distance function name within '.ml.clust.df'
// @param damp {float} Damping coefficient
// @param diag {func} Function applied to the similarity matrix diagonal
// @param iter {dict} Max number of overall iterations and iterations 
//   without a change in clusters. (::) can be passed in which case the defaults
//   of (`total`noChange!200 15) will be used
// @return {dict} Data, input variables, clusters and exemplars 
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
  predictFunc:clust.ap.predict[;returnInfo];
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using AP config
// @param data {float[][]} Each column of the data is an individual datapoint
// @param config  {dict} `data`inputs`clust`exemplars returned by the modelInfo
//   key from the return of clust.ap.fit
// @return {long[]} Predicted clusters
clust.ap.predict:{[data;config]
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
