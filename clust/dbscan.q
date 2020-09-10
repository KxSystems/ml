\d .ml

// Density-Based Spatial Clustering of Applications with Noise (DBSCAN)

// @kind function
// @category clust
// @fileoverview Fit DBSCAN algorithm to data
// @param data   {float[][]} Points in `value flip` format
// @param df     {fn}        Distance function
// @param minpts {long}      Minimum number of points in epsilon radius
// @param eps    {float}     Epsilon radius to search
// @return       {long[]}    List of clusters
clust.dbscan.fit:{[data;df;minpts;eps]
  // check distance function
  if[not df in key clust.i.dd;clust.i.err.dd[]];
  // create neighbourhood table
  t:clust.i.nbhoodtab[data:"f"$data;df;minpts;eps;til count data 0];
  // find cluster for remaining points and return list of clusters
  clt:-1^exec cluster from t:{[t]any t`corepoint}clust.i.dbalgo/t;
  // return config dict
  `data`inputs`clt`t!(data;`df`minpts`eps!(df;minpts;eps);clt;t)
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using DBSCAN config
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`df`minpts`eps`clt returned from DBSCAN 
//   clustered training data
// @return     {long[]}    List of predicted clusters
clust.dbscan.predict:{[data;cfg]
  // predict new clusters
  -1^exec cluster from clust.i.dbscanpredict["f"$data;cfg]
  }

// @kind function
// @category clust
// @fileoverview Update DBSCAN config including new data points
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`inputs`clt`nbh returned from DBSCAN 
//   clustered training data
// @return     {dict}      Updated model config
clust.dbscan.update:{[data;cfg]
  // predict new clusters
  rtst:clust.i.dbscanpredict[data:"f"$data;cfg];
  rtrn:update corepoint:1b from cfg[`t]where cluster<>0N;
  // include test points in training neighbourhood
  rtrn:{[trn;tst;idx]
    update nbhood:{x,'y}[nbhood;idx]from trn where i in tst`nbhood
    }/[rtrn;rtst;count[rtrn]+til count rtst];
  // update clusters
  t:{[t]any t`corepoint}.ml.clust.i.dbalgo/rtrn,rtst;
  // start clusters from 0
  t:update{(d!til count d:distinct x)x}cluster from t where cluster<>0N;
  // return updated config
  cfg,`data`t`clt!(cfg[`data],'data;t;-1^exec cluster from t)
  }

// @kind function
// @category private
// @fileoverview Predict clusters using DBSCAN config
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`inputs`clt returned from DBSCAN 
//   clustered training data
// @return     {long[]}    Cluster table
clust.i.dbscanpredict:{[data;cfg]
  idx:count[cfg[`data]0]+til count data 0;
  // create neighbourhood table
  t:clust.i.nbhoodtab[cfg[`data],'data;;;;idx]. cfg[`inputs]`df`minpts`eps;
  // find which existing clusters new data belongs to
  update cluster:{x[`clt]first y}[cfg]each nbhood from t where corepoint
  }

// @kind function
// @category private
// @fileoverview Create neighbourhood table for points at indices provided
// @param data   {float[][]} Points in `value flip` format
// @param df     {fn}        Distance function
// @param minpts {long}      Minimum number of points in epsilon radius
// @param eps    {float}     Epsilon radius to search
// @param idx    {long[]}    Data indices to find neighbourhood for
// @return       {table}     Neighbourhood table with `nbhood`cluster`corepoint
clust.i.nbhoodtab:{[data;df;minpts;eps;idx]
  // calculate distances and find all points which are not outliers
  nbhood:clust.i.nbhood[data;df;eps]each idx;
  // update outlier cluster to null
  update cluster:0N,corepoint:minpts<=1+count each nbhood from([]nbhood)
  }

// @kind function
// @category private
// @fileoverview Find all points which are not outliers
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param eps  {float}     Epsilon radius to search
// @param idx  {long}      Index of current point
// @return     {long[]}    Indices of points within the epsilon radius
clust.i.nbhood:{[data;df;eps;idx]
  where eps>@[;idx;:;0w]clust.i.dd[df]data-data[;idx]
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
// @param idxs {long[]} Indices to search neighborhood of
// @return     {long[]} Indices in neighborhood
clust.i.nbhoodidxs:{[t;idxs]
  nbh:exec nbhood from t[distinct idxs,raze t[idxs]`nbhood]where corepoint;
  asc distinct idxs,raze nbh
  }
