\d .ml

// Density-Based Spatial Clustering of Applications with Noise (DBSCAN)

// @kind function
// @category clust
// @fileoverview Fit DBSCAN algorithm to data
// @param data   {float[][]} Data in matrix format, each column is an individual datapoint
// @param df     {symbol}    Distance function name within '.ml.clust.df'
// @param minpts {long}      Minimum number of points with the epsilon radius
// @param eps    {float}     Epsilon radius to search
// @return       {dict}      Data, inputs, clusters and cluster table 
//   (`data`inputs`clt`t) required for predict and update methods
clust.dbscan.fit:{[data;df;minpts;eps]
  data:clust.i.floatConversion[data];
  // check distance function
  if[not df in key clust.i.df;clust.i.err.df[]];
  // create neighbourhood table
  t:clust.i.nbhoodtab[data;df;minpts;eps;til count data 0];
  // apply the density based clustering algorithm over the neighbourhood table
  t:{[t]any t`corepoint}clust.i.dbalgo/t;
  // find cluster for remaining points and return list of clusters
  clt:-1^exec cluster from t;
  // return config dict
  `data`inputs`clt`t!(data;`df`minpts`eps!(df;minpts;eps);clt;t)
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using DBSCAN config
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg  {dict}      `data`df`minpts`eps`clt returned from DBSCAN 
//   clustered training data
// @return     {long[]}    List of predicted clusters
clust.dbscan.predict:{[data;cfg]
  data:clust.i.floatConversion[data];
  // predict new clusters
  -1^exec cluster from clust.i.dbscanpredict[data;cfg]
  }

// @kind function
// @category clust
// @fileoverview Update DBSCAN config including new data points
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg  {dict}      `data`inputs`clt`nbh returned from DBSCAN clustered training data
// @return     {dict}      Updated model config
clust.dbscan.update:{[data;cfg]
  data:clust.i.floatConversion[data];
  // original data prior to addition of new points, with core points set
  orig:update corepoint:1b from cfg[`t]where cluster<>0N;
  // predict new clusters
  new:clust.i.dbscanpredict[data;cfg];
  // include new data points in training neighbourhood
  orig:clust.i.updnbhood/[orig;new;count[orig]+til count new];
  // fit model with new data included to update model
  t:{[t]any t`corepoint}.ml.clust.i.dbalgo/orig,new;
  // reindex the clusters
  t:update{(d!til count d:distinct x)x}cluster from t where cluster<>0N;
  // return updated config
  cfg,`data`t`clt!(cfg[`data],'data;t;-1^exec cluster from t)
  }


// Utilities

// @kind function
// @category private
// @fileoverview Update the neighbourhood of a previously fit original dbscan model based on new data
// @param orig {tab}    Original table of data with all points set as core points
// @param new  {tab}    Table generated from new data with the previously generated model
// @param idx  {long[]} Indices used to update the neighbourhood of the original table
// @return     {tab}    Table with neighbourhood updated appropriately for the newly introduced data
clust.i.updnbhood:{[orig;new;idx]
  update nbhood:{x,'y}[nbhood;idx]from orig where i in new`nbhood
  }

// @kind function
// @category private
// @fileoverview Predict clusters using DBSCAN config
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg  {dict}      `data`inputs`clt returned from DBSCAN clustered training data
// @return     {tab}       Cluster table
clust.i.dbscanpredict:{[data;cfg]
  idx:count[cfg[`data]0]+til count data 0;
  // create neighbourhood table
  t:clust.i.nbhoodtab[cfg[`data],'data;;;;idx]. cfg[`inputs;`df`minpts`eps];
  // find which existing clusters new data belongs to
  update cluster:{x[`clt]first y}[cfg]each nbhood from t where corepoint
  }

// @kind function
// @category private
// @fileoverview Create neighbourhood table for points at indices provided
// @param data   {float[][]} Data in matrix format, each column is an individual datapoint
// @param df     {symbol}    Distance function name within '.ml.clust.df'
// @param minpts {long}      Minimum number of points with the epsilon radius
// @param eps    {float}     Epsilon radius to search
// @param idx    {long[]}    Data indices to find neighbourhood for
// @return       {table}     Neighbourhood table with columns `nbhood`cluster`corepoint
clust.i.nbhoodtab:{[data;df;minpts;eps;idx]
  // calculate distances and find all points which are not outliers
  nbhood:clust.i.nbhood[data;df;eps]each idx;
  // update outlier cluster to null
  update cluster:0N,corepoint:minpts<=1+count each nbhood from([]nbhood)
  }

// @kind function
// @category private
// @fileoverview Find all points which are not outliers
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param eps  {float}     Epsilon radius to search
// @param idx  {long}      Index of current point
// @return     {long[]}    Indices of points within the epsilon radius
clust.i.nbhood:{[data;df;eps;idx]
  where eps>@[;idx;:;0w]clust.i.df[df]data-data[;idx]
  }

// @kind function
// @category private
// @fileoverview Run DBSCAN algorithm and update cluster of each point
// @param t {table} Cluster info table
// @return  {table} Updated cluster table with old clusters merged
clust.i.dbalgo:{[t]
  nbh:.ml.clust.i.nbhoodidxs[t]/[first where t`corepoint];
  update cluster:0|1+max t`cluster,corepoint:0b from t where i in nbh
  }

// @kind function
// @category private
// @fileoverview Find indices in each points neighborhood
// @param t    {table}  Cluster info table
// @param idxs {long[]} Indices to search the neighborhood of
// @return     {long[]} Indices in neighborhood
clust.i.nbhoodidxs:{[t;idxs]
  nbh:exec nbhood from t[distinct idxs,raze t[idxs]`nbhood]where corepoint;
  asc distinct idxs,raze nbh
  }
