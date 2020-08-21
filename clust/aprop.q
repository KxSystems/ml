\d .ml

// Affinity Propagation

// @kind function
// @category clust
// @fileoverview Affinity propagation algorithm
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param dmp  {float}     Damping coefficient
// @param diag {fn}        Similarity matrix diagonal value function
// @return     {long[]}    List of clusters
clust.ap:{[data;df;dmp;diag]
  // check distance function and diagonal value
  if[not df in key clust.i.dd;clust.i.err.dd[]];
  // create initial table with exemplars/matches and similarity, availability
  //   and responsibility matrices
  info0:clust.i.apinit["f"$data;df;diag];
  // run AP algo until there is no change in results over `0.1*count data` runs
  info1:{[iter;info]iter>info`matches}[.1*count data]clust.i.apalgo[dmp]/info0;
  // return list of clusters
  clust.i.reindex info1`exemplars
  }

// @kind function
// @category private
// @fileoverview Initialize matrices
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param diag {fn}        Similarity matrix diagonal value function
// @return     {dict}      Similarity, availability and responsibility matrices
//   and keys for matches and exemplars to be filled during further iterations
clust.i.apinit:{[data;df;diag]
  // calculate similarity matrix values
  s:clust.i.dists[data;df;data]each k:til n:count data 0;
  s:@[;;:;diag raze s]'[s;k];
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
