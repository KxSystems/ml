\d .ml

// K-Means

// @kind function
// @category clust
// @fileoverview Fit k-Means algorithm to data
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param k    {long}      Number of clusters
// @param cfg  {dict}      Configuration information which can be updated, (::) allows a user
//   to use default values, allows update for to maximum iterations `iter, initialisation type
//   `init and threshold for smallest distance to move between the previous and new run `thresh
// @return     {dict}      Model config `data`df`reppts`clt where data 
//   and df are the inputs, reppts are the calculated k means and clt 
//   are the associated clusters
clust.kmeans.fit:{[data;df;k;cfg]
  data:clust.i.floatConversion[data];
  defaultDict:`iter`init`thresh!(100;1b;1e-5);
  if[cfg~(::);cfg:()!()];
  if[99h<>type cfg;'"cfg must be (::) or a dictionary"];
  // update iteration dictionary with user changes
  updDict:defaultDict,cfg;
  // fit algo to data
  r:clust.i.kmeans[data;df;k;updDict];
  // return config with new clusters
  r,`data`inputs!(data;`df`k`iter`kpp!(df;k;updDict`iter;updDict`init))
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using k-means config
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param cfg  {dict}      `data`df`reppts`clt returned from kmeans clustered training data
// @return     {long[]}    List of predicted clusters
clust.kmeans.predict:{[data;cfg]
  data:clust.i.floatConversion[data];
  // get new clusters based on latest config
  clust.i.getclust[data;cfg[`inputs]`df;cfg`reppts]
  }

// @kind function
// @category clust
// @fileoverview Update kmeans config including new data points
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg  {dict}      `data`df`reppts`clt returned from kmeans clustered on training data
// @return     {dict}      Updated model config
clust.kmeans.update:{[data;cfg]
  data:clust.i.floatConversion[data];
  // update data to include new points
  cfg[`data]:cfg[`data],'data;
  // update k means
  cfg[`reppts]:clust.i.updcenters[cfg`data;cfg[`inputs]`df;()!();cfg`reppts];
  // get updated clusters based on new means
  cfg[`clt]:clust.i.getclust[cfg`data;cfg[`inputs]`df;cfg`reppts];
  // return updated config
  cfg
  }


// Utilities

// @kind function
// @category private
// @fileoverview K-Means algorithm
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param k    {long}      Number of clusters
// @param cfg  {dict} Configuration information containing the maximum iterations `iter, 
//   initialisation type `init and threshold for smallest distance 
//   to move between the previous and new run `thresh
// @return     {dict}      Clusters or reppts depending on rep
clust.i.kmeans:{[data;df;k;cfg]
  // check distance function
  if[not df in`e2dist`edist;clust.i.err.kmeans[]];
  // initialize representative points
  initreppts:$[cfg`init;clust.i.initkpp df;clust.i.initrdm][data;k];
  // run algo until maximum number of iterations reached or convergence
  reppts0:`idx`reppts`notconv!(0;initreppts;1b);
  reppts1:clust.i.kmeansConverge[cfg] clust.i.updcenters[data;df;cfg]/reppts0;
  // return representative points and clusters
  `reppts`clt!(reppts1`reppts;clust.i.getclust[data;df;reppts1`reppts])
  }

// @kind function
// @category private
// @fileoverview Check to see if cluster centers are stable or 
//   if the maximum number of iterations allowable have been reached
// @param cfg     {dict} Configuration information containing the maximum iterations `iter, 
//   initialisation type `init and threshold for smallest distance 
//   to move between the previous and new run `thresh
// @param algorun {dict} Information about the current run of the algorithm which can have an
//   impact on early or on time stopping i.e. have the maximum number of iterations been exceeded
//   or have the cluster centers not moved more than the threshold i.e. 'stationary'
// @return    {bool} 0b indicates number of iterations has exceeded maximum and
clust.i.kmeansConverge:{[cfg;algorun]
  check1:cfg[`iter]>algorun`idx;
  check2:algorun`notconv;
  check1 & check2
  }

// @kind function
// @category private
// @fileoverview Update cluster centers
// @param data   {float[][]}      Data in matrix format, each column is an individual datapoint
// @param df     {symbol}         Distance function name within '.ml.clust.df'
// @param cfg    {dict}           Configuration information containing the maximum iterations `iter, 
//   initialisation type `init and threshold for smallest distance 
//   to move between the previous and new run `thresh
// @param reppts {float[][]/dict} Information relating to the representative points, in the case of
//   fitting the model this is a dictionary containing the current iteration index and if the data
//   has converged in addition to the representative points. In an individual update this is just
//   the representative points for the k means centers.
// @return       {float[][]}      Updated representative points  
clust.i.updcenters:{[data;df;cfg;reppts]
  // projection used for calculation of representative points
  repptFunc:clust.i.newreppts[data;df;];
  if[99h=type reppts;
    reppts[`idx]+:1;
    prevpoint:reppts`reppts;
    reppts[`reppts]:repptFunc reppts`reppts;
    reppts[`notconv]:cfg[`thresh]<max abs (raze/)prevpoint-reppts`reppts;
    :reppts
    ];
  repptFunc reppts
  }

// @kind function
// @category private
// @fileoverview Calculate new representative points based on new 
//   data and previous representatives
// @param data   {float[][]} Data in matrix format, each column is an individual datapoint
// @param df     {symbol}    Distance function name within '.ml.clust.df'
// @param reppts {float[][]} Representative points in matrix format each row 
//   is an individual datapoint
// @return       {float[][]} New representative points in matrix format each row 
//   is an individual datapoint
clust.i.newreppts:{[data;df;reppts]
    {[data;j]avg each data[;j]}[data]each value group clust.i.getclust[data;df;reppts]
    }      

// @kind function
// @category private
// @fileoverview Calculate final representative points
// @param data   {float[][]} Data in matrix format, each column is an individual datapoint
// @param df     {symbol}    Distance function name within '.ml.clust.df'
// @param reppts {float[]}   Representative points of each cluster
// @return       {long}      List of clusters
clust.i.getclust:{[data;df;reppts]
  dist:{[data;df;reppt]clust.i.df[df]reppt-data}[data;df]each reppts;
  max til[count dist]*dist=\:min dist
  }

// @kind function
// @category private
// @fileoverview Random initialization of representative points
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param k    {long}      Number of clusters
// @return     {float[][]} k representative points
clust.i.initrdm:{[data;k]
  flip data[;neg[k]?count data 0]
  }

// @kind function
// @category private
// @fileoverview K-Means++ initialization of representative points
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param k    {long}      Number of clusters
// @return     {float[][]} k representative points
clust.i.initkpp:{[df;data;k]
  info0:`point`dists!(data[;rand count data 0];0w);
  infos:(k-1)clust.i.kpp[data;df]\info0;
  infos`point
  }

// @kind function
// @category private
// @fileoverview K-Means++ algorithm
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param info {dict}      Points and distance info
// @return     {dict}      Updated info dictionary
clust.i.kpp:{[data;df;info]
  s:sums info[`dists]&:clust.i.dists[data;df;info`point;::];
  @[info;`point;:;data[;s binr rand last s]]
  }
