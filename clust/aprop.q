\d .ml

// Affinity Propagation

// @kind function
// @category clust
// @fileoverview Fit affinity propagation algorithm
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param dmp  {float}     Damping coefficient
// @param diag {fn}        Similarity matrix diagonal value function
// @return     {long[]}    List of clusters
clust.ap.fit:{[data;df;dmp;diag]
  clust.i.runap[data;df;dmp;diag;til count data 0;(::)]
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using AP config
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`df`reppts`clt returned from kmeans 
//   clustered training data
// @return     {long[]}    List of predicted clusters
clust.ap.predict:{[data;cfg]
  neg[count data 0]#clust.ap.update[data;cfg]`clt
  }

// @kind function
// @category clust
// @fileoverview Update AP config including new data points
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`df`reppts`clt returned from kmeans 
//   clustered on training data
// @return     {dict}      Updated model config
clust.ap.update:{[data;cfg]
  clust.ap.fit[cfg[`data],'data]. cfg`df`dmp`diag
  }

// @kind function
// @category private
// @fileoverview Run affinity propagation algorithm
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param dmp  {float}     Damping coefficient
// @param diag {fn}        Similarity matrix diagonal value function
// @param idxs {long[]}    List of indicies to find distances for
// @param s0   {float[][]} Old similarity matrix (can be (::) for new run)
// @return     {long[]}    List of clusters
clust.i.runap:{[data;df;dmp;diag;idxs;s0]
  // check valid distance function has been given
  if[not df in key clust.i.dd;clust.i.err.dd[]];
  // calculate distances, availability and responsibility 
  info0:clust.i.apinit[data;df;diag;idxs;s0];
  // update info to find clusters
  info1:{[iter;info]iter>info`matches}[.2*count data]clust.i.apalgo[dmp]/info0;
  // return config
  `data`df`dmp`diag`info0`info1`clt!(data;df;dmp;diag;info0;info1;clust.i.reindex info1`exemplars)
  }

// @kind function
// @category private
// @fileoverview Initialize matrices
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param diag {fn}        Similarity matrix diagonal value function
// @return     {dict}      Similarity, availability and responsibility matrices
//   and keys for matches and exemplars to be filled during further iterations
clust.i.apinit:{[data;df;diag;idxs;s0]
  // calculate similarity matrix values
  s:clust.i.dists[data;df;data]each idxs;
  // if adding new points, add new similarity onto old
  if[not s0~(::);s:(s0,'count[s0]#flip s),s];
  // update diagonal
  s:@[;;:;diag raze s]'[s;k:til n:count data 0];
  // create lists/matrices of zeros for other variables
  `matches`exemplars`s`a`r!(0;0#0;s),(2;n;n)#0f
  }

// @kind function
// @category private
// @fileoverview Run affinity propagation algorithm
// @param dmp  {float} Damping coefficient
// @param info {dict}  Exemplars and matches, similarity, availability and
//   responsibility matrices
// @return     {dict}  Updated info
clust.i.apalgo:{[dmp;info]
  // update responsibility matrix
  info[`r]:clust.i.updr[dmp;info];
  // update availability matrix
  info[`a]:clust.i.upda[dmp;info];
  // find new exemplars
  ex:imax each sum info`a`r;
  // return updated `info` with new exemplars/matches
  update exemplars:ex,matches:?[exemplars~ex;matches+1;0]from info
  }

// @kind function
// @category private
// @fileoverview Update responsibility matrix
// @param dmp  {float}     Damping coefficient
// @param info {dict}      Exemplars and matches, similarity, availability and
//   responsibility matrices
// @return     {float[][]} Updated responsibility matrix
clust.i.updr:{[dmp;info]
  // create matrix with every points max responsibility
  // diagonal becomes -inf, current max is becomes second max
  mxresp:{[x;i]@[count[x]#mx;j;:;]max@[x;i,j:x?mx:max x;:;-0w]};
  mx:mxresp'[sum info`s`a;til count info`r];
  // calculate new responsibility
  (dmp*info`r)+(1-dmp)*info[`s]-mx
  }

// @kind function
// @category private
// @fileoverview Update availability matrix
// @param dmp  {float}     Damping coefficient
// @param info {dict}      Exemplars and matches, similarity, availability and
//   responsibility matrices
// @return     {float[][]} Returns updated availability matrix
clust.i.upda:{[dmp;info]
  // sum values in positive availability matrix
  s:sum@[;;:;0f]'[pv:0|info`r;k:til n:count info`a];
  // create a matrix using the negative values produced by the availability sum
  //   + responsibility diagonal - positive availability values
  a:@[;;:;]'[0&(s+info[`r]@'k)-/:pv;k;s];
  // calculate new availability
  (dmp*info`a)+a*1-dmp
  }
