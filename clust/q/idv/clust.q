\d .ml

// Utility functions

// Error dictionary
clust.i.err.dd:{'`$"invalid distance metric"}
clust.i.err.ld:{'`$"invalid linkage"}
clust.i.err.ward:{'`$"ward must be used with e2dist"}
clust.i.err.kmeans:{'`$"kmeans must be used with edist/e2dist"}

// Distance metric dictionary
clust.i.dd.edist:{sqrt x wsum x}
clust.i.dd.e2dist:{x wsum x}
clust.i.dd.mdist:{sum abs x}
clust.i.dd.cshev:{min abs x}
clust.i.dd.nege2dist:{neg x wsum x}

// Linkage dictionary
clust.i.ld.single:min
clust.i.ld.complete:max
clust.i.ld.average:avg
clust.i.ld.centroid:raze
clust.i.ld.ward:{z*x*y%x+y}

// Distance calculations
clust.i.dists:{[data;df;pt;idxs]clust.i.dd[df]pt-data[;idxs]}
clust.i.closest:{[data;df;pt;idxs]`point`distance!(idxs dists?md;md:min dists:clust.i.dists[data;df;pt;idxs])}

// Index functions
clust.i.imax:{x?max x}
clust.i.imin:{x?min x}
clust.i.reindex:{distinct[x]?x}

// K-D tree

// Create new k-d tree
/* data   = data points in `value flip` format
/* leafsz = number of points per leaf (<2*number of representatives)
/. r      > returns k-d tree structure as a table
clust.kd.newtree:{[data;leafsz]clust.kd.i.tree[data;leafsz]`leaf`left`parent`self`idxs!(0b;0b;0N;0;til count data 0)}

// Find nearest neighhbors in k-d tree
/* tree  = k-d tree table
/* data  = data points in `value flip` format
/* df    = distance function
/* xidxs = points to exclude in search
/* pt    = point to find nearest neighbor for
/. r     > returns nearest neighbor dictionary with closest point, distance, points searched and points to search
clust.kd.nn:{[tree;data;df;xidxs;pt]
 start:`closestPoint`closestDist`xnodes`node!(0N;0w;0#0;clust.kd.i.findleaf[tree;pt;tree 0]);
 {[nninfo]not null nninfo[`node;`self]}clust.kd.i.nncheck[tree;data;df;xidxs;pt]/start}
 
// K-D tree utility functions

// Create tree table where each row represents a node
/* data   = data points in `value flip` format
/* leafsz = number of points per leaf (<2*number of representatives)
/* node   = dictionary with info for a given node in the tree
/. r      > returns tree table
clust.kd.i.tree:{[data;leafsz;node]
 if[leafsz<=.5*count node`idxs;
  chk:xdata<med xdata@:ax:clust.i.imax dvar:var each xdata:data[;node`idxs];
  if[all leafsz<=count each(lIdxs:where chk;rIdxs:where not chk);
   n:count lTree:.z.s[data;leafsz]update left:1b,parent:self,self+1  ,idxs:idxs lIdxs from node;
           rTree:.z.s[data;leafsz]update left:0b,parent:self,self+1+n,idxs:idxs rIdxs from node;
   node:select leaf,left,self,parent,children:self+1+(0;n),axis:ax,midval:min xdata rIdxs,idxs:0#0 from node;
   :enlist[node],lTree,rTree]];
 enlist select leaf:1b,left,self,parent,children:0#0,axis:0N,midval:0n,idxs from node}

// Search each node and check nearest neighbors
/* tree   = k-d tree table
/* data   = data points in `value flip` format
/* df     = distance function
/* xidxs  = points to exclude in search
/* pt     = point to find nearest neighbor for
/* nninfo = dictionary with nearest neighbor info of a point
/. r      > returns updated nearest neighbor info dictionary
clust.kd.i.nncheck:{[tree;data;df;xidxs;pt;nninfo]
 if[nninfo[`node]`leaf;
   closest:clust.i.closest[data;df;pt]nninfo[`node;`idxs]except xidxs;
   if[closest[`distance]<nninfo`closestDist;
     nninfo[`closestPoint`closestDist]:closest`point`distance;
 ]];
 if[not null childidx:first nninfo[`node;`children]except nninfo`xnodes;
   childidx:$[(nninfo`closestDist)<clust.i.dd[df]pt[nninfo[`node]`axis]-nninfo[`node]`midval;
     0N;clust.kd.i.findleaf[tree;pt;tree childidx]`self
 ]];
 if[null childidx;nninfo[`xnodes],:nninfo[`node]`self];
 nninfo[`node]:tree nninfo[`node;`parent]^childidx;
 nninfo}

// Find the next direction to take in the tree
/* tree = k-d tree table
/* pt   = current point to put in tree
/* node = current node to check
/. r    > returns next direction to take
clust.kd.i.findnext:{[tree;pt;node]tree node[`children]node[`midval]<=pt node`axis}

// Find the leaf node point belongs to
/* tree = k-d tree table
/* pt   = current point to put in tree
/* node = current node to check
/. r    > returns dictionary of leaf node pt belongs to
clust.kd.i.findleaf:{[tree;pt;node]{[node]not node`leaf}clust.kd.i.findnext[tree;pt]/node}

// K-D tree C functions

if[112=type clust.kd.c.findleaf:.[2:;(`:kdnn;(`kd_findleaf;3));::];
 clust.kd.i.findleaf:{[tree;point;node]tree clust.kd.c.findleaf[tree;point;node`self]}]

if[112=type clust.kd.c.nn:.[2:;(`:kdnn;(`kd_nn;5));::];
 clust.kd.nn:{[tree;data;df;xidxs;pt]`closestPoint`closestDist!clust.kd.c.nn[tree;data;(1_key clust.i.dd)?df;xidxs;pt]}]

// K-Means

// K-Means algorithm
/* data = data points in `value flip` format
/* df   = distance function
/* k    = number of clusters
/* iter = number of iterations
/* kpp  = boolean indicating whether to use random initialization (`0b`) or k-means++ (`1b`)
clust.kmeans:{[data;df;k;iter;kpp]
 // check distance function
 if[not df in`e2dist`edist;clust.i.err.kmeans[]];
 // initialize representative points
 reppts0:$[kpp;clust.i.initkpp df;clust.i.initrdm][data;k];
 // run algo `iter` times
 reppts1:iter{[data;df;reppt]flip{[data;j]avg each data[;j]}[data]each value group clust.i.getclust[data;df;reppt]}[data;df]/reppts0;
 // return list of clusters
 clust.i.getclust[data;df;reppts1]}

// K-Means utility functions

// Calculate final representative points
/* data   = data points in `value flip` format
/* df     = distance function
/* reppts = representative points of each cluster
/. r      > return list of clusters
clust.i.getclust:{[data;df;reppts]max til[count dist]*dist=\:min dist:{[data;df;reppt]clust.i.dd[df]reppt-data}[data;df]each flip reppts}

// Random initialization of representative points
/* data = data points in `value flip` format
/* k    = number of clusters
/. r    > returns k representative points
clust.i.initrdm:{[data;k]data[;neg[k]?count data 0]}

// K-Means++ initialization of representative points
/* df   = distance function
/* data = data points in `value flip` format
/* k    = number of clusters
/. r    > returns k representative points
clust.i.initkpp:{[df;data;k]
 info0:`point`dists!(data[;rand count data 0];0w);
 infos:(k-1)clust.i.kpp[data;df]\info0;
 flip infos`point}

// K-Means++ algorithm
/* data = data points in `value flip` format
/* df   = distance function
/* info = dictionary with points and distance info
/. r    > returns updated info dictionary
clust.i.kpp:{[data;df;info]@[info;`point;:;data[;s binr rand last s:sums info[`dists]&:clust.i.dists[data;df;info`point;::]]]}

// DBSCAN

// DBSCAN algorithm
/* data   = data points in `value flip` format
/* df     = distance function
/* minpts = minimum number of points in epsilon radius
/* eps    = epsilon radius to search
/. r      > returns list of clusters
clust.dbscan:{[data;df;minpts;eps]
 // check distance function
 if[not df in key clust.i.dd;clust.i.err.dd[]];
 // calculate distances and find all points which are not outliers
 nbhood:clust.i.nbhood[data;df;eps]each til count data 0;
 // update outlier cluster to null
 t:update cluster:0N,corepoint:minpts<=1+count each nbhood from([]nbhood);
 // find cluster for remaining points and return list of clusters
 exec cluster from {[t]any t`corepoint}clust.i.dbalgo/t}

// Find all points which are not outliers
/* data = data points in `value flip` format
/* df   = distance function
/* eps  = epsilon radius to search
/* idx  = index of current point
/. r    > returns indices of points within the epsilon radius
clust.i.nbhood:{[data;df;eps;idx]where eps>@[;idx;:;0w]clust.i.dd[df]data-data[;idx]}

// Run DBSCAN algorithm and update cluster of each point
/* t = cluster info table
/. r > returns updated cluster table with old clusters merged
clust.i.dbalgo:{[t]update cluster:0|1+max t`cluster,corepoint:0b from t where i in clust.i.nbhoodidxs[t]/[first where t`corepoint]}

// Find indices in each points neighborhood
/* t    = cluster info table
/* idxs = indices to search neighborhood of
/. r    > returns list of indices in neighborhood
clust.i.nbhoodidxs:{[t;idxs]asc distinct idxs,raze exec nbhood from t[distinct idxs,raze t[idxs]`nbhood]where corepoint}
 
// Affinity propagation

// Affinity propagation algorithm
/* data = data points in `value flip` format
/* df   = distance function
/* dmp  = damping coefficient
/* diag = similarity matrix diagonal value function
/. r    > return list of clusters
clust.ap:{[data;df;dmp;diag]
 // check distance function and diagonal value
 if[not df in key clust.i.dd;clust.i.err.dd[]];
 // create initial table with exemplars/matches and similarity, availability and responsibility matrices
 info0:clust.i.apinit[data;df;diag];
 // run AP algo until there is no change in results over `0.1*count data` runs
 info1:{[maxiter;info]maxiter>info`matches}[.1*count data]clust.i.apalgo[dmp]/info0;
 // return list of clusters
 clust.i.reindex info1`exemplars}

// Affinity propagation utility functions

// Initialize matrices
/* data = data points in `value flip` format
/* df   = distance function
/* diag = similarity matrix diagonal value
/. r    > returns a dictionary with similarity, availability and responsibility matrices
/         and keys for matches and exemplars to be filled during further iterations
clust.i.apinit:{[data;df;diag]
 s:@[;;:;diag raze s]'[s:clust.i.dists[data;df;data]each k;k:til n:count data 0];
 `matches`exemplars`s`a`r!(0;0#0;s),(2;n;n)#0f}

// Run affinity propagation algorithm
/* dmp  = damping coefficient
/* info = dictionary containing exemplars and matches, similarity, availability and responsibility matrices
/. r    > returns updated info
clust.i.apalgo:{[dmp;info]
 // update responsibility matrix
 info[`r]:clust.i.updr[dmp;info];
 // update availability matrix
 info[`a]:clust.i.upda[dmp;info];
 // find new exemplars
 ex:clust.i.imax each sum info`a`r;
 // return updated `info` with new exemplars/matches
 update exemplars:ex,matches:?[exemplars~ex;matches+1;0]from info}

// Update responsibility matrix
/* dmp  = damping coefficient
/* info = dictionary containing exemplars and matches, similarity, availability and responsibility matrices
/. r    > returns updated responsibility matrix
clust.i.updr:{[dmp;info]
 // create matrix with every points max responsibility - diagonal becomes -inf, current max is becomes second max
 mx:{[x;i]@[count[x]#mx;j;:;]max@[x;i,j:x?mx:max x;:;-0w]}'[sum info`s`a;til count info`r];
 // calculate new responsibility
 (dmp*info`r)+(1-dmp)*info[`s]-mx}

// Update availability matrix
/* dmp  = damping coefficient
/* info = dictionary containing exemplars and matches, similarity, availability and responsibility matrices
/. r    > returns updated availability matrix
clust.i.upda:{[dmp;info]
 // sum values in positive availability matrix
 s:sum@[;;:;0f]'[pv:0|info`r;k:til n:count info`a];
 // create a matrix using the negative values produced by the availability sum + responsibility diagonal - positive availability values
 a:@[;;:;]'[0&(s+info[`r]@'k)-/:pv;k;s];
 // calculate new availability
 (dmp*info`a)+a*1-dmp}

// Hierarchical clustering

// HC
/* data = data points in `value flip` format
/* df   = distance function
/* lf   = linkage function
/* k    = number of clusters
/. r    > return list of clusters
clust.hc:{[data;df;lf;k]
 // check distance and linkage functions, plus extra check for ward
  if[not df in key clust.i.dd;clust.i.err.dd[]];
  if[not lf in key clust.i.ld;clust.i.err.ld[]];
  if[(not df in`edist`e2dist)&lf=`ward;clust.i.err.ward[]];
 // create initial cluster table
 t0:clust.i.inithc[data;df];
 // merge clusters based on chosen algorithm
 t1:{[k;t]k<count distinct t`clt}[k]clust.i.algohc[data;df;lf]/t0;
 // return file clusters
 clust.i.reindex t1`clt}

// HC utility functions

// Initialize cluster table
/* data = data points in `value flip` format
/* df   = distance function
/. r    > returns a table with distances, neighbors, clusters and representatives
clust.i.inithc:{[data;df]
 // create table with distances and nearest neighhbors noted
 t:{[data;df;i]`nni`nnd!(d?m;m:min d:@[;i;:;0w]clust.i.dists[data;df;data;i])}[data;df]each til count data 0;
 // update each points cluster and representatives
 update clt:i,reppt:flip data from t}

// HC algo
/* data = data points in `value flip` format
/* df   = distance function
/* lf   = linkage function
/* t    = cluster table
/. r    > returns updated cluster table
clust.i.algohc:{[data;df;lf;t]
 // merge closest clusters
 merge:distinct value first select clt,nni from t where nnd=min nnd;
 // add new cluster into table
 t:update clt:1+max t`clt from t where clt in merge;
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
 dsts:{[df;lf;x;y]clust.i.ld[lf]raze clust.i.dd[df]x[`pts]-\:'y`pts}[df;lf;cpts chk]each cpts _ chk;
 nidx:dsts?ndst:min dsts;
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
 dsts:{[df;lf;x;y]2*clust.i.ld[lf][x`n;y`n]clust.i.dd[df]x[`reppt]-y`reppt}[df;lf;cpts chk]each cpts _ chk;
 nn:cpts nidx:dsts?ndst:min dsts;
 rpt:{[a;b;m;n]((m*a)+(n*b))%m+n}[x`reppt;nn`reppt;x`n;nn`n];
 update nni:nidx,nnd:ndst,reppt:count[i]#enlist rpt from t where clt=chk}

// SCC Part

clust.i.scc:{[d;df;lf;k;n;c]
 r:(count[d 0]-k).[clust.i.algoscc[d;df;lf]]/clust.i.initscc[d;df;k;n;c];
 r 1}

clust.hcscc:clust.i.scc[;;;;::;::]  / [d;df;lf;k]
clust.cure :clust.i.scc[;;`cure;;;] / [d;df;k;n;c]

clust.i.initscc:{[d;df;k;n;c]
 kdtree:clust.kd.newtree[d]1000&ceiling .01*nd:count d 0;
 dists:update closestClust:closestPoint from{[kdtree;d;df;i]clust.kd.nn[kdtree;d;df;i;d[;i]]}[kdtree;d;df]each til nd;
 r2l:exec self idxs?til count i from select raze idxs,self:self where count each idxs from kdtree where leaf;
 clusts:select clust:i,valid:1b,reppts:enlist each i,points:enlist each i,closestDist,closestClust from dists;
 reppts:select reppt:i,clust:i,leaf:r2l,closestDist,closestClust from dists;
 reppts:reppts,'flip(rpcols:`$"x",'string til count d)!d;
 params:`k`n`c`rpcols!(k;n;c;rpcols);
 (params;clusts;reppts;kdtree)}

clust.i.centrep:{[p]enlist avg each p}
clust.i.curerep:{[df;n;c;p]rpts:1_first(n&count p 0).[{[df;rpts;p]
 rpts,:enlist p[;i:clust.i.imax min clust.i.dd[df]each p-/:neg[1|-1+count rpts]#rpts];
 (rpts;.[p;(::;i);:;0n])}[df]]/(enlist avgpt:avg each p;p);
 (rpts*1-c)+\:c*avgpt}

clust.i.algoscc:{[d;df;lf;params;clusts;reppts;kdtree]
 clust0:exec clust{x?min x}closestDist from clusts where valid;
 newmrg:clusts clust0,clust1:clusts[clust0]`closestClust;
 newmrg:update valid:10b,reppts:(raze reppts;0#0),points:(raze points;0#0)from newmrg;
 oldrep:reppts newmrg[0]`reppts;

 $[sgl:lf~`single;
   newrep:select reppt,clust:clust0 from oldrep;
  [newrep:flip params[`rpcols]!flip$[lf~`centroid;clust.i.centrep;clust.i.curerep[df;params`n;params`c]]d[;newmrg[0]`points];
   newrep:update clust:clust0,reppt:count[i]#newmrg[0]`reppts from newrep;
   newrep[`leaf]:(clust.kd.i.findleaf[kdtree;;kdtree 0]each flip newrep params`rpcols)`self;
   newmrg[0;`reppts]:newrep`reppt;
   kdtree:.[kdtree;(oldrep`leaf;`idxs);except;oldrep`reppt];
   kdtree:.[kdtree;(newrep`leaf;`idxs);union ;newrep`reppt];
 ]];
 clusts:@[clusts;newmrg`clust;,;delete clust from newmrg];
 reppts:@[reppts;newrep`reppt;,;delete reppt from newrep];

 updrep:reppts newrep`reppt;
 if[sgl;updrep:select from updrep where closestClust in newmrg`clust];
 updrep:updrep,'clust.kd.nn[kdtree;reppts params`rpcols;df;newmrg[0]`points]each flip updrep params`rpcols;
 updrep:update closestClust:reppts[closestPoint;`clust]from updrep;

 if[sgl;
  reppts:@[reppts;updrep`reppt;,;select closestDist,closestClust from updrep];
  updrep:reppts newrep`reppt;
 ];
 
 updrep@:raze clust.i.imin updrep`closestDist;
 clusts:@[clusts;updrep`clust;,;`closestDist`closestClust#updrep];

 $[sgl;
  [clusts:update closestClust:clust0 from clusts where valid,closestClust=clust1;
   reppts:update closestClust:clust0 from reppts where       closestClust=clust1;
  ];if[count updcls:select from clusts where valid,closestClust in(clust0;clust1);
   updcls:updcls,'{x clust.i.imin x`closestDist}each clust.kd.nn[kdtree;reppts params`rpcols;df]/:'
     [updcls`reppts;flip each reppts[updcls`reppts]@\:params`rpcols];
   updcls[`closestClust]:reppts[updcls`closestPoint]`clust;
   clusts:@[clusts;updcls`clust;,;select closestDist,closestClust from updcls];
 ]];

 (params;clusts;reppts;kdtree)}
