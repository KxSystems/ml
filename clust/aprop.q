\d .ml

// Affinity Propagation

// @kind function
// @category clust
// @fileoverview Fit affinity propagation algorithm
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param dmp  {float}     Damping coefficient
// @param diag {fn}        Similarity matrix diagonal value function
// @param iter {dict}      Max number of overall iterations and iterations 
//   without a change in clusters. (::) can be passed in where the defaults
//   of (`total`nochange!200 15) will be used
// @return     {dict}      Data, input variables, clusters and exemplars 
//   (`data`inputs`clt`exemplars) required for the predict method
clust.ap.fit:{[data;df;dmp;diag;iter]
  // update iteration dictionary with user changes
  iter:(`run`maxrun`maxmatch!0 200 15),$[iter~(::);();iter];
  // cluster data using AP algo
  clust.i.runap["f"$data;df;dmp;diag;til count data 0;iter]
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using AP config
// @param data {float[][]} Points in `value flip` format
// @param cfg  {dict}      `data`inputs`clt`exemplars returned by clust.ap.fit
// @return     {long[]}    List of predicted clusters
clust.ap.predict:{[data;cfg]
  if[-1~first cfg`clt;
    '"Clusters = -1. AP fit did not converge. Not possible to predict clusters."];
  // retrieve cluster centres from training data
  ex:cfg[`data][;distinct cfg`exemplars];
  // predict testing data clusters
  clust.i.appreddist[ex;cfg[`inputs]`df]each flip data
  }

// @kind function
// @category private
// @fileoverview Run affinity propagation algorithm
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param dmp  {float}     Damping coefficient
// @param diag {fn}        Similarity matrix diagonal value function
// @param idxs {long[]}    List of indicies to find distances for
// @param iter {dict}      Max number of overall iterations and iterations 
//   without a change in clusters. (::) can be passed in where the defaults
//   of (`total`nochange!200 15) will be used
// @return     {long[]}    List of clusters
clust.i.runap:{[data;df;dmp;diag;idxs;iter]
  // check negative euclidean distance has been given
  if[not df~`nege2dist;clust.i.err.ap[]];
  // calculate distances, availability and responsibility
  info0:clust.i.apinit[data;df;diag;idxs];
  // initialize exemplar matrix and convergence boolean
  info0,:`emat`conv`iter!((count data 0;iter`maxmatch)#0b;0b;iter);
  // run ap algo until maxrun or convergence
  info1:clust.i.apstop clust.i.apalgo[dmp]/info0;
  // return data, inputs, clusters and exemplars
  inputs:`df`dmp`diag`iter!(df;dmp;diag;iter);
  clt:$[info1`conv;clust.i.reindex ex:info1`exemplars;count[data 0]#-1];
  `data`inputs`clt`exemplars!(data;inputs;clt;ex)
  }

// @kind function
// @category private
// @fileoverview Initialize matrices
// @param data {float[][]} Points in `value flip` format
// @param df   {fn}        Distance function
// @param diag {fn}        Similarity matrix diagonal value function
// @param idxs {long[]}    List of point indices
// @return     {dict}      Similarity, availability and responsibility matrices
//   and keys for matches and exemplars to be filled during further iterations
clust.i.apinit:{[data;df;diag;idxs]
  // calculate similarity matrix values
  s:clust.i.dists[data;df;data]each idxs;
  // update diagonal
  s:@[;;:;diag raze s]'[s;k:til n:count data 0];
  // create lists/matrices of zeros for other variables
  `matches`exemplars`s`a`r!(0;0#0;s),(2;n;n)#0f
  }

// @kind function
// @category private
// @fileoverview Run affinity propagation algorithm
// @param dmp  {float} Damping coefficient
// @param info {dict}  Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return     {dict}  Updated inputs
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
  .[;(`iter;`run);+[1]]clust.i.apconv info
  }

// @kind function
// @category private
// @fileoverview Check affinity propagation algorithm for convergence
// @param info {dict} Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return     {dict} Updated info dictionary
clust.i.apconv:{[info]
  // iteration dictionary
  iter:info`iter;
  // exemplar matrix
  emat:info`emat;
  // existing exemplars
  ediag:0<sum clust.i.diag each info`a`r;
  emat[;iter[`run]mod iter`maxmatch]:ediag;
  // check for convergence
  if[iter[`maxmatch]<=iter`run;
    unconv:count[info`s]<>sum(se=iter`maxmatch)+0=se:sum each emat;
    conv:$[(iter[`maxrun]=iter`run)|not[unconv]&sum[ediag]>0;1b;0b]];
  // return updated info
  info,`emat`conv!(emat;conv)
  }

// @kind function
// @category private
// @fileoverview Retrieve diagonal of square matrix
// @param m {any[][]} Square matrix
// @return  {any[]}   Diagonal
clust.i.diag:{[m]
  {x y}'[m;til count m]
  }

// @kind function
// @category private
// @fileoverview Update responsibility matrix
// @param dmp  {float}     Damping coefficient
// @param info {dict}      Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
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
// @param info {dict}      Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
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

// @kind function
// @category private
// @fileoverview Stopping condition for affinity propagation algorithm
// @param info {dict} Similarity, availability, responsibility, exemplars,
//   matches, iter dictionary, no_conv boolean and iter dict
// @return     {bool} Indicates whether to continue or stop running AP (1/0b)
clust.i.apstop:{[info]
  (info[`iter;`maxrun]>info[`iter]`run)&not 1b~info`conv
  }

// @kind function
// @category private
// @fileoverview Predict clusters using AP training exemplars
// @param ex {float[][]} Training cluster centres in `value flip` format
// @param df {fn}        Distance function
// @param pt {float[]}   Current data point
// @return   {long[]}    Predicted clusters
clust.i.appreddist:{[ex;df;pt]
  d?max d:clust.i.dists[ex;df;pt]each til count ex 0
  }