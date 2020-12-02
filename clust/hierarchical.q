\d .ml

// Clustering Using REpresentatives (CURE) and Hierarchical Clustering

// @kind function
// @category clust
// @fileoverview Fit CURE algorithm to data
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df' 
// @param n    {long}      Number of representative points per cluster
// @param c    {float}     Compression factor for representative points
// @return     {dict}      Data, input variables and dendrogram 
//   (`data`inputs`dgram) required for predict method
clust.cure.fit:{[data;df;n;c]
  data:clust.i.floatConversion[data];
  if[not df in key clust.i.df;clust.i.err.df[]];
  dgram:clust.i.hcscc[data;df;`cure;1;n;c;1b];
  `data`inputs`dgram!(data;`df`n`c!(df;n;c);dgram)
  }

// @kind function
// @category clust
// @fileoverview Fit Hierarchical algorithm to data
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df' 
// @param lf   {symbol}    Linkage function name within '.ml.clust.lf' 
// @return     {dict}      Data, input variables and dendrogram 
//   (`data`inputs`dgram) required for predict method
clust.hc.fit:{[data;df;lf]
  // check distance and linkage functions
  data:clust.i.floatConversion[data];
  if[not df in key clust.i.df;clust.i.err.df[]];
  dgram:$[lf in`complete`average`ward;
    clust.i.hccaw[data;df;lf;2;1b];
    lf in`single`centroid;
    clust.i.hcscc[data;df;lf;1;::;::;1b];
    clust.i.err.lf[]
    ];
  `data`inputs`dgram!(data;`df`lf!(df;lf);dgram)
  }

// @kind function
// @category clust
// @fileoverview Convert CURE cfg to k clusters
// @param cfg {dict} Output of .ml.clust.cure.fit
// @param k   {long} Number of clusters
// @return    {dict} Updated config with clusters labels added
clust.cure.cutk:{[cfg;k]
  cfg,enlist[`clt]!enlist clust.i.cutdgram[cfg`dgram;k-1]
  }

// @kind function
// @category clust
// @fileoverview Convert hierarchical cfg to k clusters
// @param cfg {dict} Output of .ml.clust.hc.fit
// @param k   {long} Number of clusters
// @return    {dict} Updated config with clusters added
clust.hc.cutk:clust.cure.cutk

// @kind function
// @category clust
// @fileoverview Convert CURE dendrogram to clusters based on distance 
//   threshold
// @param cfg     {dict}   Output of .ml.clust.cure.fit
// @param dthresh {float}  Cutting distance threshold
// @return        {dict}   Updated config with clusters added
clust.cure.cutdist:{[cfg;dthresh]
  dgram:cfg`dgram;
  k:0|count[dgram]-exec first i from dgram where dist>dthresh;
  cfg,enlist[`clt]!enlist clust.i.cutdgram[dgram;k]
  }

// @kind function
// @category clust
// @fileoverview Convert hierarchical dendrogram to clusters based on distance
//   threshold
// @param cfg     {dict}   Output of .ml.clust.hc.fit
// @param dthresh {float}  Cutting distance threshold
// @return        {dict}   Updated config with clusters added
clust.hc.cutdist:clust.cure.cutdist

// @kind function
// @category clust
// @fileoverview Predict clusters using CURE config
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg  {dict}      `data`df`n`c`clt returned from .ml.clust.(cutk/cutdist)
// @return     {long[]}    List of predicted clusters
clust.cure.predict:{[data;cfg]
  clust.i.hccpred[`cure;data;cfg]
  }

// @kind function
// @category clust
// @fileoverview Predict clusters using hierarchical config
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg  {dict}      `data`df`lf`clt returned from .ml.clust.(cutk/cutdist)
// @return     {long[]}    List of predicted clusters
clust.hc.predict:{[data;cfg]
  clust.i.hccpred[`hc;data;cfg]
  }


// Utilities

// @kind function
// @category private
// @fileoverview Complete, Average, Ward (CAW) Linkage
// @param data  {float[][]}    Data in matrix format, each column is an individual datapoint
// @param df    {symbol}       Distance function name within '.ml.clust.df'
// @param lf    {symbol}       Linkage function name within '.ml.clust.lf'
// @param k     {long}         Number of clusters
// @param dgram {bool}         Generate dendrogram or not (1b/0b)
// @return      {table/long[]} Dendrogram or list of clusters
clust.i.hccaw:{[data;df;lf;k;dgram]
  // check distance function for ward
  if[(not df~`e2dist)&lf=`ward;clust.i.err.ward[]];
  // create initial cluster table
  t0:clust.i.initcaw[data;df];
  // create linkage matrix
  m:([]i1:`int$();i2:`int$();dist:`float$();n:`int$());
  // merge clusters based on chosen algorithm
  r:{[k;r]k<count distinct r[0]`clt}[k]clust.i.algocaw[data;df;lf]/(t0;m);
  // return dendrogram or list of clusters
  $[dgram;clust.i.upddgram[r 0;r 1];clust.i.reindex r[0]`clt]
  }

// @kind function
// @category private
// @fileoverview Single, Centroid, Cure (SCC) Linkage
// @param data  {float[][]} Data in matrix format, each column is an individual datapoint
// @param df    {symbol}    Distance function name within '.ml.clust.df'
// @param lf    {fn}        Linkage function
// @param k     {long}      Number of clusters
// @param n     {long}      Number of representative points per cluster
// @param c     {float}     Compression factor for representative points
// @param dgram {bool}      Generate dendrogram or not (1b/0b)
// @return      {long[]}    List of clusters
clust.i.hcscc:{[data;df;lf;k;n;c;dgram]
  if[(not df in`edist`e2dist)&lf=`centroid;clust.i.err.centroid[]];
  clustinit:clust.i.initscc[data;df;k;n;c;dgram];
  r:(count[data 0]-k).[clust.i.algoscc[data;df;lf]]/clustinit;
  vres:select from r[1]where valid;
  $[dgram;
    clust.i.dgramidx last[r]0;
    enlist @[;;:;]/[count[data 0]#0N;vres`points;til count vres]
  ]
  }

// @kind function
// @category private
// @fileoverview Update dendrogram for CAW with final cluster of all the points
// @param t  {table}     Cluster table
// @param m  {float[][]} Linkage matrix
// @return   {float[][]} Updated linkage matrix
clust.i.upddgram:{[t;m]
  m,:value exec first clt,first nni,first nnd,count reppt from t where nnd=min nnd;
  m
  }

// @kind function
// @category private
// @fileoverview Predict clusters using hierarchical or CURE config
// @param ns   {symbol}    Namespace to use - `hc or `cure
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg  {dict}      dict output of .ml.clust.(cutk/cutdist)
// @return     {long[]}    List of predicted clusters
clust.i.hccpred:{[ns;data;cfg]
  data:clust.i.floatConversion[data];
  // check correct namespace and clusters given
  if[not ns in`hc`cure;'"Incorrect namespace - please use `hc or `cure"];
  if[not`clt in key cfg;
    '"Clusters must be contained within cfg - please run .ml.clust.",
    $[ns~`hc;"hc";"cure"],".(cutk/cutdist)"];
  // add namespace and linkage to config dictionary for cure
  if[ns~`cure;cfg[`inputs],:`ns`lf!(ns;`single)];
  // recalc reppts for training clusters in asc order to ensure correct labels
  reppt:clust.i.getrep[cfg]each gc kc:asc key gc:group cfg`clt;
  // training indicies
  idxs:til each c:count each reppt[;0];
  // return closest clusters to testing points
  clust.i.predclosest[data;cfg;reppt;c;idxs]each til count data 0
  }

// @kind function
// @category private
// @fileoverview Recalculate representative points from training clusters
// @param cfg  {dict}      Dict output of .ml.clust.(cutk/cutdist)
// @param idxs {long[][]}  Training data indices
// @return     {float[][]} Training data points
clust.i.getrep:{[cfg;idxs]
  $[cfg[`inputs;`ns]~`cure;
      flip(clust.i.curerep . cfg[`inputs;`df`n`c])::;
    cfg[`inputs;`lf]in`ward`centroid;
      enlist each avg each;]cfg[`data][;idxs]
  }

// @kind function
// @category private
// @fileoverview Predict new cluster for given data point
// @param data   {float[][]} Data in matrix format, each column is an individual datapoint
// @param cfg    {dict}      dict output of .ml.clust.(cutk/cutdist)
// @param reppt  {float[][]} Representative points in matrix format
// @param c      {long}      Number of points in training clusters
// @param cltidx {long[][]}  Training data indices
// @param ptidx  {long[][]}  Index of current data point
// @return       {long[]}    List of predicted clusters
clust.i.predclosest:{[data;cfg;reppt;c;cltidx;ptidx]
  // intra cluster distances
  dist:.ml.clust.i.dists[;cfg[`inputs]`df;data[;ptidx];]'[reppt;cltidx];
  // apply linkage
  dist:$[`ward~lf:cfg[`inputs]`lf;
    2*clust.i.lf[lf][1]'[c;dist];
    clust.i.lf[lf]each dist];
  // find closest cluster
  dist?ndst:min dist
  }

// @kind function
// @category private
// @fileoverview Initialize cluster table
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df' 
// @return     {table}     Distances, neighbors, clusters and representatives
clust.i.initcaw:{[data;df]
  // create table with distances and nearest neighhbors noted
  t:clust.i.nncaw[data;df;data]each til count data 0;
  // update each points cluster and representatives
  update clt:i,reppt:flip data from t
  }

// @kind function
// @category private
// @fileoverview Find nearest neighbour index and distance
// @param data {float[][]} Data in matrix format, each column is an individual datapoint
// @param df   {symbol}    Distance function name within '.ml.clust.df' 
// @param pt   {float[][]} Points in `value flip` format
// @param idxs {long}      Index of point in 'pt' to find nearest neighbour for
// @return     {dict}      Index of and distance to nearest neighbour
clust.i.nncaw:{[data;df;pt;idxs]
  `nni`nnd!(d?m;m:min d:@[;idxs;:;0w]clust.i.dists[data;df;pt;idxs])
  }

// @kind function
// @category private
// @fileoverview CAW algo
// @param data {float[][]}         Data in matrix format, each column is an individual datapoint
// @param df   {symbol}            Distance function name within '.ml.clust.df'
// @param lf   {symbol}            Linkage function name within '.ml.clust.lf' 
// @param l    {(table;float[][])} List with cluster table and linkage matrix
// @return     {(table;float[][])} Updated l
clust.i.algocaw:{[data;df;lf;l]
  t:l 0;m:l 1;
  // update linkage matrix
  m,:value exec first clt,first nni,first nnd,count reppt from t where nnd=min nnd;
  // merge closest clusters
  merge:distinct value first select clt,nni from t where nnd=min nnd;
  // add new cluster and reppt into table
  t:update clt:1+max t`clt,reppt:count[i]#enlist sum[reppt]%count[i] from t where clt in merge;
  // exec pts by cluster
  cpts:exec pts:data[;i],n:count i,last reppt by clt from t;
  // find points initially closest to new cluster points
  chks:exec distinct clt from t where nni in merge;
  // run specific algo and return updated table
  t:clust.i.hcupd[lf][cpts;df;lf]/[t;chks];
  // return updated table and matrix
  (t;m)
  }

// @kind function
// @category private
// @fileoverview Complete linkage
// @param cpts {float[][]} Points in each cluster
// @param df   {symbol}    Distance function name within '.ml.clust.df' 
// @param lf   {symbol}    Linkage function name within '.ml.clust.lf' 
// @param t    {table}     Cluster table
// @param chk  {long[]}    Points to check
// @return     {table}     Updated cluster table
clust.i.hcupd.complete:{[cpts;df;lf;t;chk]
  // calculate cluster distances using complete method
  dsts:clust.i.completedist[df;lf;cpts;chk];
  // find nearest neighbors
  nidx:dsts?ndst:min dsts;
  // update cluster table
  update nni:nidx,nnd:ndst from t where clt=chk
  }

// @kind function
// @category private
// @fileoverview Average linkage
// @param cpts {float[][]} Points in each cluster
// @param df   {symbol}    Distance function name within '.ml.clust.df' 
// @param lf   {symbol}    Linkage function name within '.ml.clust.lf' 
// @param t    {table}     Cluster table
// @param chk  {long[]}    Points to check
// @return     {table}     Updated cluster table
clust.i.hcupd.average:clust.i.hcupd.complete

// @kind function
// @category private
// @fileoverview Ward linkage
// @param cpts {float[][]} Points in each cluster
// @param df   {symbol}    Distance function name within '.ml.clust.df' 
// @param lf   {symbol}    Linkage function name within '.ml.clust.lf'
// @param t    {table}     Cluster table
// @param chk  {long[]}    Points to check
// @return     {table}     Updated cluster table
clust.i.hcupd.ward:{[cpts;df;lf;t;chk]
 // calculate distances using ward method
 dsts:clust.i.warddist[df;lf;cpts;chk];
 // find nearest neighbors
 nidx:dsts?ndst:min dsts;
 // update cluster table and rep pts
 update nni:nidx,nnd:ndst from t where clt=chk}

// @kind function
// @category private
// @fileoverview Calculate distances between points based on specified
//   linkage and distance functions
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param lf   {symbol}    Linkage function name within '.ml.clust.lf'
// @param data {float[][]} Points in each cluster
// @param idxs {long[]}    Indices for which to produce distances
// @return     {float[]}   list of distances between all data points and those in idxs
clust.i.completedist:{[df;lf;data;idxs]
  {[df;lf;xdata;ydata]
    dists:raze clust.i.df[df]xdata[`pts]-\:'ydata`pts;
    clust.i.lf[lf]dists}[df;lf;data idxs]each data _ idxs
  }

// @kind function
// @category private
// @fileoverview Calculate distances between points based on ward linkage and
//   specified distance function
// @param df   {symbol}    Distance function name within '.ml.clust.df'
// @param lf   {symbol}    Linkage function name within '.ml.clust.lf'
// @param data {float[][]} Points in each cluster
// @param idxs {long[]}    Indices for which to produce distances
// @return     {float[]}   list of distances between all data points and those in idxs
clust.i.warddist:{[df;lf;data;idxs]
  {[df;lf;xdata;ydata]
   dists:clust.i.df[df]xdata[`reppt]-ydata`reppt;
   2*clust.i.lf[lf][xdata`n;ydata`n;dists]}[df;lf;data idxs]each data _ idxs
  }

// @kind function
// @category private
// @fileoverview Initialize SCC clusters
// @param data {float[][]}  Data in matrix format, each column is an individual datapoint
// @param df   {symbol}     Distance function name within '.ml.clust.df' 
// @param k    {long}       Number of clusters
// @param n    {long}       Number of representative points per cluster
// @param c    {float}      Compression factor for representative points
// @return     {(dict;long[];table;table)} Parameters, clusters, representative
//   points and the kdtree
clust.i.initscc:{[data;df;k;n;c;dgram]
  // build kdtree
  kdtree:clust.kd.newtree[data]1000&ceiling .01*nd:count data 0;
  // generate distance table with closest clusters identified
  dists:clust.i.gendisttab[kdtree;data;df;nd];
  lidx:select raze idxs,self:self where count each idxs from kdtree where leaf;
  r2l:exec self idxs?til count i from lidx;
  // create cluster table 
  clusts:select clusti:i,clust:i,valid:1b,reppts:enlist each i,
                points:enlist each i,closestDist,closestClust from dists;
  // create table of representative points for each cluster
  reppts:select reppt:i,clust:i,leaf:r2l,closestDist,closestClust from dists;
  reppts:reppts,'flip(rpcols:`$"x",'string til count data)!data;
  // create list of important parameters to carry forward
  params:`k`n`c`rpcols!(k;n;c;rpcols);
  lnkmat:([]i1:`int$();i2:`int$();dist:`float$();n:`int$());
  // return as a list to be passed to algos
  (params;clusts;reppts;kdtree;(lnkmat;dgram))
  }


// @kind function
// @category private
// @fileoverview Generate distance table indicating closest cluster
// @param kdtree {tab}       initial representation of the k-d tree
// @param data   {float[][]} Data in matrix format, each column is an individual datapoint
// @param df     {symbol}    Distance function name within '.ml.clust.df'
// @param npts   {long}      Number of points in the dataset 
// @return       {tab}       Distance table containing an indication of the closest cluster
clust.i.gendisttab:{[kdtree;data;df;npts]
  // generate the distance table
  gentab:{[kdtree;data;df;idx]
    clust.kd.nn[kdtree;data;df;idx;data[;idx]]
    }[kdtree;data;df]each til npts;
  // update naming convention
  update closestClust:closestPoint from gentab
  }

// @kind function
// @category private
// @fileoverview Representative points for Centroid linkage
// @param p {float[][]} Data points
// @return  {float[]}   Representative point
clust.i.centrep:{[p]
  enlist avg each p
  }

// @kind function
// @category private
// @fileoverview Representative points for CURE
// @param df {symbol}    Distance function name within '.ml.clust.df' 
// @param n  {long}      Number of representative points per cluster
// @param c  {float}     Compression factor for representative points
// @param p  {float[][]} List of data points
// @return   {float[][]} List of representative points
clust.i.curerep:{[df;n;c;p]
  rpts:1_first(n&count p 0).[{[df;rpts;p]
    i:imax min clust.i.df[df]each p-/:neg[1|-1+count rpts]#rpts;
    rpts,:enlist p[;i];
    (rpts;.[p;(::;i);:;0n])
    }[df]]/(enlist avgpt:avg each p;p);
  (rpts*1-c)+\:c*avgpt
  }

// @kind function
// @category private
// @fileoverview Update initial dendrogram structure to show path of merges so
//   that the dendrogram can be plotted with scipy
// @param dgram {table} Dendrogram stucture produced using 
//   .ml.clust.hc[...;...;...;...;1b]
// @return      {table} Updated dendrogram
clust.i.dgramidx:{[dgram]
  // initial cluster indices, number of merges and loop counter
  cl:raze dgram`i1`i2;n:count dgram;i:0;
  // increment a cluster for every occurrence in the tree
  while[n>i+1;cl[where[cl=cl i]except i]:1+max cl;i+:1];
  // update dendrogram with new indices
  ![dgram;();0b;`i1`i2!n cut cl]
  }

// @kind function
// @category private
// @fileoverview Convert dendrogram table to clusters
// @param t {table}  Dendrogram table
// @param k {long}   Define splitting value in dendrogram table
// @return  {long[]} List of clusters
clust.i.cutdgram:{[t;k]
  // get index of cluster made at cutting point k
  idx:(2*cntt:count t)-k-1;
  // exclude any clusters made after point k
  exclt:i where idx>i:raze neg[k]#'allclt:t`i1`i2;
  // extract indices within clusters made until k, excluding any outliers
  nout:exclt except outliers:exclt where exclt<=cntt;
  clt:{last{count x 0}clust.i.extractclt[x;y]/(z;())}[allclt;cntt+1]each nout;
  // update points to the cluster they belong to
  @[;;:;]/[(1+cntt)#0N;clt,enlist each outliers;til k+1]
  }

// @kind function
// @category private
// @fileoverview Extract points within merged cluster
// @param clts {long[]} List of cluster indices
// @param cntt {long}   Count of dend table 
// @param inds {long[]} Index in list to search and indices points found within
//   that cluster
// @return     {long[]} Next index to search, and additional points found 
//   within cluster
clust.i.extractclt:{[clts;cntt;inds]
  // extract the points that were merged at this point
  mrgclt:raze clts[;inds[0]-cntt];
  // Store any single clts, break down clts more than single point
  (mrgclt where inext;inds[1],mrgclt where not inext:mrgclt>=cntt)
  }

// @kind function
// @category private
// @fileoverview SCC algo
// @param data {float[][]} Data in matrix format, each column is 
//   an individual datapoint
// @param df   {symbol}      Distance function name within '.ml.clust.df'
// @param lf   {symbol}      Linkage function name within '.ml.clust.lf' 
// @param params {dict}      Parameters - k (no. clusts), n (no. reppts per clust), reppts, kdtree
// @param clusts {table}     Cluster table
// @param reppts {float[][]} Representative points and associated info
// @param kdtree {table}     k-dimensional tree storing points and distances
// @return       {(dict;long[];float[][];table)} Parameters dict, clusters, 
//   representative points and kdtree tables
clust.i.algoscc:{[data;df;lf;params;clusts;reppts;kdtree;lnkmat]
  // merge closest clusters
  clust0:exec clust{x?min x}closestDist from clusts where valid;
  newmrg:clusts clust0,clust1:clusts[clust0]`closestClust;
  newmrg:update valid:10b,reppts:(raze reppts;0#0),points:(raze points;0#0)from newmrg;
  // make dendrogram if required
  if[lnkmat 1;
    m:lnkmat 0;
    m,:newmrg[`clusti],fnew[`closestDist],count(fnew:first newmrg)`points;
    lnkmat[0]:m
  ];
  // keep track of old reppts
  oldrep:reppts newmrg[0]`reppts;
  // find reps in new cluster
  $[sgl:lf~`single;
    // for single new reps=old reps -> no new points calculated 
    newrep:select reppt,clust:clust0 from oldrep;
    [
    // generate new representative points table (centroid -> reps=avg; cure -> calc reps)
    newrepfunc:$[lf~`centroid;clust.i.centrep;clust.i.curerep[df;params`n;params`c]];
    newrepkeys:params[`rpcols];
    newrepvals:flip newrepfunc[data[;newmrg[0]`points]];
    newrep:flip newrepkeys!newrepvals;
    newrep:update clust:clust0,reppt:count[i]#newmrg[0]`reppts from newrep;
    // new rep leaves
    newrep[`leaf]:(clust.kd.findleaf[kdtree;;kdtree 0]each flip newrep params`rpcols)`self;
    newmrg[0;`reppts]:newrep`reppt;
    // delete old points from leaf and update new point to new rep leaf
    kdtree:.[kdtree;(oldrep`leaf;`idxs);except;oldrep`reppt];
    kdtree:.[kdtree;(newrep`leaf;`idxs);union ;newrep`reppt]
    ]
  ];
  // update clusters and reppts
  clusts:@[clusts;newmrg`clust;,;delete clust from newmrg];
  reppts:@[reppts;newrep`reppt;,;delete reppt from newrep];
  updrep:reppts newrep`reppt;
  // nneighbour to clust
  if[sgl;updrep:select from updrep where closestClust in newmrg`clust];
  // calculate and append to representative point table the nearest neighbours
  // of columns containing representative points
  updrepdata:flip updrep params`rpcols;
  updrepdatann:clust.kd.nn[kdtree;reppts params`rpcols;df;newmrg[0]`points] each updrepdata;
  updrep:updrep,'updrepdatann;
  updrep:update closestClust:reppts[closestPoint;`clust]from updrep;
  if[sgl;
    reppts:@[reppts;updrep`reppt;,;select closestDist,closestClust from updrep];
    updrep:reppts newrep`reppt];
  // update nneighbour of new clust  
  updrep@:raze imin updrep`closestDist;
  clusts:@[clusts;updrep`clust;,;`closestDist`closestClust#updrep];
  $[sgl;
    // single - nneighbour=new clust
    [clusts:update closestClust:clust0 from clusts where valid,closestClust=clust1;
     reppts:update closestClust:clust0 from reppts where       closestClust=clust1];
    // else do nneighbour search
    if[count updcls:select from clusts where valid,closestClust in(clust0;clust1);
      updcls:updcls,'{x imin x`closestDist}each clust.kd.nn[kdtree;reppts params`rpcols;df]/:'
        [updcls`reppts;flip each reppts[updcls`reppts]@\:params`rpcols];
      updcls[`closestClust]:reppts[updcls`closestPoint]`clust;
      clusts:@[clusts;updcls`clust;,;select closestDist,closestClust from updcls]
    ]
  ];
  (params;clusts;reppts;kdtree;lnkmat)
  }
