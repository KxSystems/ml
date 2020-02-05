\d .ml

/Affinity propagation algorithm
/* d   = data points
/* dmp = damping coefficient, number between 0 and 1
/* p   = preference, either number or symbol, e.g. `min`med`avg 0 5 etc.
/* b   = boolean for plot, 1b: each iteration, 0b: final iteration, (): don't plot
clust.ap:{[d;dmp;p;b]
 clust.i.dd,:enlist[`nege2dist]!enlist{neg x wsum x};
 m:clust.i.createmtx d;
 m[`s]:clust.i.updpref[m`s;p];
 r:{not x[1]~x 2}clust.i.apalgo[d;dmp;b]/(m;(),0;(),1);
 if[b~0b;pltex[d;r 2]];
 clust.i.rtabkm[d]clust.i.apout[r 2]}

/CURE algorithm
/* k = number of clusters
/* r = number of representative points
/* i = dictionary of inputs, for default use ():
/*     > df = distance function/metric
/*     > c  = compression
/*     > b  = boolean, 1b for C, 0b for q
/*     > s  = boolean, 1b to return a dictionary for the streaming notebook, 0b to return a table of clusters
clust.cure:{[d;k;r;i]
 i:(`df`c`b`s!(`e2dist;0;0b;0b)),i; /defaults
 if[100h<>type@[{get x};`.ml.clust.ccure;{x;-1"C function not available defaulting to q";0b}];i[`b]:0b];
 d:`float$d;
 if[not i[`df]in key clust.i.dd;'clust.i.errors`derr];
 $[i`b;clust.i.algoscc[d;k;clust.ccure.dfd[i`df];r;i`c;();clust.ccure;i`s];clust.i.algoscc[d;k;i`df;r;i`c;();clust;i`s]]}

/cluster new points using CURE
/* t  = dictionary with the information of the tree
/* d  = new data to be classified
clust.clustnew:{[t;df;d]
 d:`float$d;
 clust.kd.nnc[enlist n;t`tree;t[`r2c],n:count t`reps;t[`reps],d;df]0}

/DBSCAN algorithm
/* p = minimum number of points per cluster
/* e = epsilon value
clust.dbscan:{[d;df;p;e]
 d:`float$d;
 if[not df in key clust.i.dd;'clust.i.errors`derr];
 dm:clust.i.distmat[df;e;flip d]'[d;k:til count d];
 t:([]idx:k;dist:dm;clt:0N;valid:1b);
 clust.i.outlier clust.i.rtabdb[d]{0N<>x 1}clust.i.algodb[p]/(t;0;0)}

/hierarchical clustering 
/* lf = linkage function
/* bc = boolean or empty list for c or q implementation for centroid and single
clust.hc:{[d;k;df;lf;bc]
 if[100h<>type@[{get x};`.ml.clust.ccure;{x;-1"C function not available defaulting to q";0b}];bc:0b];
 d:`float$d;
 if[not df in key clust.i.dd;'clust.i.errors`derr];
 if[not lf in key clust.i.ld;'clust.i.errors`lerr];
 if[b:lf in`complete`average`ward;t:clust.i.buildtab[d;df]];
 clust.i.rtab[d]$[b;clust.i.cn[k]clust.i.algocaw[df;lf]/$[lf~`ward;$[df<>`e2dist;'clust.i.errors`werr;@[t;`nnd;%;2]];t];
                  clust.i.algoscc[d;k;$[bc;clust.ccure.dfd[df];df];ceiling count[d]%100;lf;();$[bc;clust.ccure;clust];0b]]}

/hierarchical dendrogram
clust.dgram:{[d;df;lf]
 d:`float$d;
 if[not df in key clust.i.dd;'clust.i.errors`derr];
 if[not lf in key clust.i.ld;'clust.i.errors`lerr];
 m:([]i1:`int$();i2:`int$();dist:`float$();n:`int$());
 t:$[b:lf in`centroid`single;(::);clust.i.buildtab[d;df]];
 $[b;clust.i.algoscc[d;1;df;ceiling count[d]%100;lf;m;clust;0b];({98h=type x 0}clust.i.algodgram[df;lf]/(t;m))1]}

/k-means algorithm
/* n = number of iterations
/* i = initialisation type - 1b use points in dataset or 0b random initialisation
clust.kmeans:{[d;k;n;i;df]
 if[not df in key clust.i.dd;'clust.i.errors`derr];
 dm:clust.i.typecast dm:flip d;
 init:$[i;clust.i.kpp[dm;k];clust.i.randinit[dm;k]];
 centers:n{{avg each x@\:y}[x]each value group clust.i.mindist[x;y;z]}[dm;;df]/init;
 clust.i.rtabkm[d]clust.i.mindist[dm;centers;df]}
