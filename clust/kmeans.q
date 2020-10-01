\d .ml

// K-Means

// @kind function
// @category clust
// @fileoverview Fit k-Means algorithm to data
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param k    {long}      Number of clusters
// @param iter {long}      Number of iterations
// @param kpp  {bool}      Use kmeans++ or random initialization (1/0b)
// @return     {dict}      Model config `data`df`reppts`clt where data 
//   and df are the inputs, reppts are the calculated k means and clt 
//   are the associated clusters
clust.kmeans.fit:{[data;df;k;iter;kpp]
  // fit algo to data
  r:clust.i.kmeans[data:"f"$data;df;k;iter;kpp];
  // return config with new clusters
  r,`data`inputs!(data;`df`k`iter`kpp!(df;k;iter;kpp))
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using k-means config
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`df`reppts`clt returned from kmeans 
//   clustered training data
// @return     {long[]}    List of predicted clusters
clust.kmeans.predict:{[data;cfg]
  // get new clusters based on latest config
  clust.i.getclust["f"$data;cfg[`inputs]`df;cfg`reppts]
  }

// @kind function
// @category clust
// @fileoverview Update kmeans config including new data points
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`df`reppts`clt returned from kmeans 
//   clustered on training data
// @return     {dict}      Updated model config
clust.kmeans.update:{[data;cfg]
  // update data to include new points
  cfg[`data]:cfg[`data],'"f"$data;
  // update k means
  cfg[`reppts]:clust.i.updcentres[cfg`data;cfg[`inputs]`df;cfg`reppts];
  // get updated clusters based on new means
  cfg[`clt]:clust.i.getclust[cfg`data;cfg[`inputs]`df;cfg`reppts];
  // return updated config
  cfg
  }

// @kind function
// @category clust
// @fileoverview K-Means algorithm
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param k    {long}      Number of clusters
// @param iter {long}      Number of iterations
// @param kpp  {bool}      Use kmeans++ or random initialization (1/0b)
// @return     {dict}      Clusters or reppts depending on rep
clust.i.kmeans:{[data;df;k;iter;kpp]
  // check distance function
  if[not df in`e2dist`edist;clust.i.err.kmeans[]];
  // initialize representative points
  reppts0:$[kpp;clust.i.initkpp df;clust.i.initrdm][data;k];
  // run algo `iter` times
  reppts1:iter clust.i.updcentres[data;df]/reppts0;
  // return representative points and clusters
  `reppts`clt!(reppts1;clust.i.getclust[data;df;reppts1])
  }

// @kind function
// @category private
// @fileoverview Update cluster centres
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @return     {float[][]} Updated representative points  
clust.i.updcentres:{[data;df;reppt]
  {[data;j]
    avg each data[;j]
    }[data]each value group clust.i.getclust[data;df;reppt]
  }

// @kind function
// @category private
// @fileoverview Calculate final representative points
// @param data   {float[][]} Points in `value flip` format
// @param df     {fn}        Distance function
// @param reppts {float[]}   Representative points of each cluster
// @return       {long}      List of clusters
clust.i.getclust:{[data;df;reppts]
  dist:{[data;df;reppt]clust.i.dd[df]reppt-data}[data;df]each reppts;
  max til[count dist]*dist=\:min dist
  }

// @kind function
// @category private
// @fileoverview Random initialization of representative points
// @param data {float[][]} Points in `value flip` format
// @param k    {long}      Number of clusters
// @return     {float[][]} k representative points
clust.i.initrdm:{[data;k]
  flip data[;neg[k]?count data 0]
  }

// @kind function
// @category private
// @fileoverview K-Means++ initialization of representative points
// @param df   {fn}        Distance function
// @param data {float[][]} Points in `value flip` format
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
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param info {dict}      Points and distance info
// @return     {dict}      Updated info dictionary
clust.i.kpp:{[data;df;info]
  s:sums info[`dists]&:clust.i.dists[data;df;info`point;::];
  @[info;`point;:;data[;s binr rand last s]]
  }
