\d .ml

// Hierarchical Clustering
/* data = data points in `value flip` format
/* df   = distance function
/* lf   = linkage function
/* k    = number of clusters
/. r    > return list of clusters
clust.hc:{[data;df;lf;k]
 // check distance and linkage functions
 if[not df in key clust.i.dd;clust.i.err.dd[]];
 if[not lf in key clust.i.ld;clust.i.err.ld[]];
 // convert to floating values
 data:"f"$data;
 if[lf in`complete`average`ward;:clust.hccaw[data;df;lf;k]];
 if[lf in`single`centroid;:clust.hcscc[data;df;lf;k;::;::]];
 }

// CURE algorithm
/* data = data points in `value flip` format
/* df   = distance function
/* k    = number of clusters
/* n    = number of representative points per cluster
/* c    = compression factor for representative points
/. r    > return list of clusters
clust.cure:{[data;df;k;n;c]
 if[not df in key clust.i.dd;clust.i.err.dd[]];
 // convert to floating values
 data:"f"$data;
 clust.hcscc[data;df;`cure;k;n;c]}

// Complete, Average, Ward (CAW) Linkage
/* data = data points in `value flip` format
/* df   = distance function
/* lf   = linkage function
/* k    = number of clusters
/. r    > return list of clusters
clust.hccaw:{[data;df;lf;k]
 // check distance function for ward
 if[(not df in`edist`e2dist)&lf=`ward;clust.i.err.ward[]];
 // create initial cluster table
 t0:clust.i.initcaw[data;df];
 // merge clusters based on chosen algorithm
 t1:{[k;t]k<count distinct t`clt}[k]clust.i.algocaw[data;df;lf]/t0;
 // return file clusters
 clust.i.reindex t1`clt}

// Initialize cluster table
/* data = data points in `value flip` format
/* df   = distance function
/. r    > returns a table with distances, neighbors, clusters and representatives
clust.i.initcaw:{[data;df]
 // create table with distances and nearest neighhbors noted
 t:{[data;df;i]`nni`nnd!(d?m;m:min d:@[;i;:;0w]clust.i.dists[data;df;data;i])}[data;df]each til count data 0;
 // update each points cluster and representatives
 update clt:i,reppt:flip data from t}

// CAW algo
/* data = data points in `value flip` format
/* df   = distance function
/* lf   = linkage function
/* t    = cluster table
/. r    > returns updated cluster table
clust.i.algocaw:{[data;df;lf;t]
 // merge closest clusters
 merge:distinct value first select clt,nni from t where nnd=min nnd;
 // add new cluster and reppt into table
 t:update clt:1+max t`clt,reppt:count[i]#enlist sum[reppt]%count[i] from t where clt in merge;
 // exec pts by cluster
 cpts:exec pts:data[;i],n:count i,last reppt by clt from t;
 // find points initially closest to new cluster points
 chks:exec distinct clt from t where nni in merge;
 // run specific algo and return updated table
 clust.i.hcupd[lf][cpts;df;lf]/[t;chks]}


// Complete linkage
/* cpts = points in each cluster
/* df   = distance function
/* lf   = linkage function
/* t    = cluster table
/* chk  = points to check
/. r    > returns updated cluster table
clust.i.hcupd.complete:{[cpts;df;lf;t;chk]
 // calculate cluster distances using complete method
 dsts:{[df;lf;x;y]clust.i.ld[lf]raze clust.i.dd[df]x[`pts]-\:'y`pts}[df;lf;cpts chk]each cpts _ chk;
 // find nearest neighbors
 nidx:dsts?ndst:min dsts;
 // update cluster table
 update nni:nidx,nnd:ndst from t where clt=chk}

// Average linkage
/* cpts = points in each cluster
/* df   = distance function
/* lf   = linkage function
/* t    = cluster table
/* chk  = points to check
/. r    > returns updated cluster table
clust.i.hcupd.average:clust.i.hcupd.complete

// Ward linkage
/* cpts = points in each cluster
/* df   = distance function
/* lf   = linkage function
/* t    = cluster table
/* chk  = points to check
/. r    > returns updated cluster table
clust.i.hcupd.ward:{[cpts;df;lf;t;chk]
 // calculate distances using ward method
 dsts:{[df;lf;x;y]2*clust.i.ld[lf][x`n;y`n]clust.i.dd[df]x[`reppt]-y`reppt}[df;lf;cpts chk]each cpts _ chk;
 // find nearest neighbors
 nidx:dsts?ndst:min dsts;
 // update cluster table and rep pts
 update nni:nidx,nnd:ndst from t where clt=chk}

// Single, Centroid, Cure (SCC) Linkage
/* data = data points in `value flip` format
/* df   = distance function
/* lf   = linkage function
/* k    = number of clusters
/* n    = number of representative points per cluster
/* c    = compression factor for representative points
/. r    > return list of clusters
clust.hcscc:{[data;df;lf;k;n;c]
 r:(count[data 0]-k).[clust.i.algoscc[data;df;lf]]/clust.i.initscc[data;df;k;n;c];
 @[;;:;]/[count[data 0]#0N;vres`points;til count vres:select from r[1]where valid]}

// Initialize SCC clusters
/* data = data points in `value flip` format
/* df   = distance function
/* k    = number of clusters
/* n    = number of representative points per cluster
/* c    = compression factor for representative points
/. r    > return list of parameters, clusters, representative points and the kdtree
clust.i.initscc:{[data;df;k;n;c]
 // build kdtree
 kdtree:clust.kd.newtree[data]1000&ceiling .01*nd:count data 0;
 // create distance table with closest clusters identified
 dists:update closestClust:closestPoint from{[kdtree;data;df;i]clust.kd.nn[kdtree;data;df;i;data[;i]]}[kdtree;data;df]each til nd;
 r2l:exec self idxs?til count i from select raze idxs,self:self where count each idxs from kdtree where leaf;
 // create cluster table 
 clusts:select clust:i,valid:1b,reppts:enlist each i,points:enlist each i,closestDist,closestClust from dists;
 // create table of representative points for each cluster
 reppts:select reppt:i,clust:i,leaf:r2l,closestDist,closestClust from dists;
 reppts:reppts,'flip(rpcols:`$"x",'string til count data)!data;
 // create list of important parameters to carry forward
 params:`k`n`c`rpcols!(k;n;c;rpcols);
 // return as a list to be passed to algos
 (params;clusts;reppts;kdtree)}

// Representative points for Centroid linkage
/* p = list of data points
/. r > return representative point
clust.i.centrep:{[p]enlist avg each p}

// Representative points for CURE
/* df = distance function
/* n  = number of representative points per cluster
/* c  = compression factor for representative points
/* p  = list of data points
/. r  > return list of representative points
clust.i.curerep:{[df;n;c;p]rpts:1_first(n&count p 0).[{[df;rpts;p]
 rpts,:enlist p[;i:clust.i.imax min clust.i.dd[df]each p-/:neg[1|-1+count rpts]#rpts];
 (rpts;.[p;(::;i);:;0n])}[df]]/(enlist avgpt:avg each p;p);
 (rpts*1-c)+\:c*avgpt}

// SCC algo
/* data   = data points in `value flip` format
/* df     = distance function
/* lf     = linkage function
/* params = dictionary of parameters - k (no. clusts), n (no. reppts per clust), reppts, kdtree
/* clusts = cluster table
/* reppts = representative points and associated info
/* kdtree = k-dimensional tree storing points and distances
/. r      > return list of parameters dict, clusters, representative points and kdtree tables
clust.i.algoscc:{[data;df;lf;params;clusts;reppts;kdtree]
 // merge closest clusters
 clust0:exec clust{x?min x}closestDist from clusts where valid;
 newmrg:clusts clust0,clust1:clusts[clust0]`closestClust;
 newmrg:update valid:10b,reppts:(raze reppts;0#0),points:(raze points;0#0)from newmrg;
 // keep track of old reppts
 oldrep:reppts newmrg[0]`reppts;

 // find reps in new cluster
 $[sgl:lf~`single;
   // for single new reps=old reps -> no new points calculated 
   newrep:select reppt,clust:clust0 from oldrep;
   // if centroid reps=avg, if cure=calc reps
  [newrep:flip params[`rpcols]!flip$[lf~`centroid;clust.i.centrep;clust.i.curerep[df;params`n;params`c]]data[;newmrg[0]`points];
   newrep:update clust:clust0,reppt:count[i]#newmrg[0]`reppts from newrep;
   // new rep leaves
   newrep[`leaf]:(clust.kd.findleaf[kdtree;;kdtree 0]each flip newrep params`rpcols)`self;
   newmrg[0;`reppts]:newrep`reppt;
   // delete old points from leaf and update new point to new rep leaf
   kdtree:.[kdtree;(oldrep`leaf;`idxs);except;oldrep`reppt];
   kdtree:.[kdtree;(newrep`leaf;`idxs);union ;newrep`reppt];
 ]];
 // update clusters and reppts
 clusts:@[clusts;newmrg`clust;,;delete clust from newmrg];
 reppts:@[reppts;newrep`reppt;,;delete reppt from newrep];

 updrep:reppts newrep`reppt;
 // nneighbour to clust
 if[sgl;updrep:select from updrep where closestClust in newmrg`clust];
 updrep:updrep,'clust.kd.nn[kdtree;reppts params`rpcols;df;newmrg[0]`points]each flip updrep params`rpcols;
 updrep:update closestClust:reppts[closestPoint;`clust]from updrep;

 if[sgl;
  reppts:@[reppts;updrep`reppt;,;select closestDist,closestClust from updrep];
  updrep:reppts newrep`reppt;
 ];
 // update nneighbour of new clust  
 updrep@:raze clust.i.imin updrep`closestDist;
 clusts:@[clusts;updrep`clust;,;`closestDist`closestClust#updrep];

 $[sgl;
  // single - nneighbour=new clust
  [clusts:update closestClust:clust0 from clusts where valid,closestClust=clust1;
   reppts:update closestClust:clust0 from reppts where       closestClust=clust1];
   // else do nneighbour search
   if[count updcls:select from clusts where valid,closestClust in(clust0;clust1);
   updcls:updcls,'{x clust.i.imin x`closestDist}each clust.kd.nn[kdtree;reppts params`rpcols;df]/:'
     [updcls`reppts;flip each reppts[updcls`reppts]@\:params`rpcols];
   updcls[`closestClust]:reppts[updcls`closestPoint]`clust;
   clusts:@[clusts;updcls`clust;,;select closestDist,closestClust from updcls];
 ]];

 (params;clusts;reppts;kdtree)}
