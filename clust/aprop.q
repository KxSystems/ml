\d .ml

// Affinity Propagation

// @kind function
// @category clust
// @fileoverview Fit affinity propagation algorithm
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param dmp  {float}     Damping coefficient
// @param diag {fn}        Similarity matrix diagonal value function
// @param iter {dict}      Max number of overall iterations and iterations without a change in clusters. (::) can be used where the defaults of (`total`nochange!200 15) will be used
// @return     {long[]}    List of clusters
clust.ap.fit:{[data;df;dmp;diag;iter]
  // update iteration dictionary with user changes
  iter:(`run`maxrun`maxmatch!0 200 15),$[iter~(::);();iter];
  clust.i.runap["f"$data;df;dmp;diag;til count data 0;iter]
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using AP config
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`df`reppts`clt returned from kmeans 
//   clustered training data
// @return     {long[]}    List of predicted clusters
clust.ap.predict:{[data;cfg]
  ex:cfg[`data][;distinct cfg`exemplars];
  clust.i.apPredDist[ex;cfg[`inputs]`df]each flip data
  }

// @kind function
// @category private
// @fileoverview Predict clusters using AP training exemplars
// @param ex {float[][]} Training cluster centres in `value flip` format
// @param df {fn}        Distance function
// @param pt {float[]}   Current data point
// @return   {long[]}    Predicted clusters
clust.i.apPredDist:{[ex;df;pt]
  d?max d:clust.i.dists[ex;df;pt]each til count ex 0
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
clust.i.runap:{[data;df;dmp;diag;idxs;iter]
  // check negative euclidean distance has been given
  if[not df~`nege2dist;clust.i.err.ap[]];
  // calculate distances, availability and responsibility 
  info0:clust.i.apinit[data;df;diag;idxs;iter];
  // update info to find clusters
  info1:clust.i.apstop clust.i.apalgo[dmp]/info0;
  // return config
  `data`inputs`clt`exemplars!
    (data;`df`dmp`diag`iter!(df;dmp;diag;iter);clust.i.reindex info1`exemplars;info1`exemplars)
  }

clust.i.apstop:{[info]
  iter:info`iter;
  /-1"Run: ",string iter`run;  // check -remove when fixed
  /-1"Check 1: ",string chk1:iter[`maxrun]>iter`run;
  /-1"Check 2: ",string chk2:iter[`maxmatch]>info`matches;
  /chk1&chk2
  (iter[`maxrun]>iter`run)&iter[`maxmatch]>info`matches
  }

// @kind function
// @category private
// @fileoverview Initialize matrices
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param diag {fn}        Similarity matrix diagonal value function
// @return     {dict}      Similarity, availability and responsibility matrices
//   and keys for matches and exemplars to be filled during further iterations
clust.i.apinit:{[data;df;diag;idxs;iter]
  // calculate similarity matrix values
  s:clust.i.dists[data;df;data]each idxs;
  // update diagonal
  s:@[;;:;diag raze s]'[s;k:til n:count data 0];
  // create lists/matrices of zeros for other variables
  `matches`exemplars`s`a`r`iter!(0;0#0;s),((2;n;n)#0f),enlist iter
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
  // update `info` with new exemplars/matches
  info:update exemplars:ex,matches:?[exemplars~ex;matches+1;0]from info;
  // update iter dictionary
  info[`iter;`run]+:1;
  // return updated info
  info
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
