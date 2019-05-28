\d .ml

/CURE algorithm
/* r = number of representative points
/* c = compression
/* b = boolean, 1b for C, 0b for q
/* s = boolean, 1b to return a dictionary for the streaming notebook, 0b to return a table of clusters
clust.cure:{[d;k;r;i]
 i:(`df`c`b`s!(`e2dist;0;0b;0b)),i; /defaults
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
 clust.i.rtabdb[d]{0N<>x 1}clust.i.algodb[p]/(t;0;0)}

/hierarchical clustering
/* d  = data
/* k  = number of clusters
/* df = distance function/metric   
/* lf = linkage function
clust.hc:{[d;k;df;lf]
 d:`float$d;
 if[not df in key clust.i.dd;'clust.i.errors`derr];
 if[not lf in key clust.i.ld;'clust.i.errors`lerr];
 if[b:lf in`complete`average`ward;t:clust.i.buildtab[d;df]];
 clust.i.rtab[d]$[b;clust.i.cn[k]clust.i.algocaw[df;lf]/$[lf~`ward;$[df<>`e2dist;'clust.i.errors`werr;@[t;`nnd;%;2]];t];
                  clust.i.algoscc[d;k;df;ceiling count[d]%100;lf;();clust;0b]]}

/hierarchical dendrogram
clust.dgram:{[d;df;lf]
 d:`float$d;
 if[not df in key clust.i.dd;'clust.i.errors`derr];
 if[not lf in key clust.i.ld;'clust.i.errors`lerr];
 m:([]i1:`int$();i2:`int$();dist:`float$();n:`int$());
 t:$[b:lf in`centroid`single;clust.kd.buildtree[flip d;r:ceiling count[d]%100];clust.i.buildtab[d;df]];
 $[b;clust.i.algoscc[d;1;df;r;lf;m;clust;0b];({98h=type x 0}clust.i.algodgram[df;lf]/(t;m))1]}

/k-means algorithm
/* n = number of iterations
/* i = initialisation type - 1b use points in dataset or 0b random initialisation
clust.kmeans:{[d;k;n;i;df]
 if[not df in key clust.i.dd;'clust.i.errors`derr];
 dm:clust.i.typecast dm:flip d;
 init:$[i;clust.i.kpp[dm;k];clust.i.randinit[dm;k]];
 centers:n{{avg each x@\:y}[x]each value group clust.i.mindist[x;y;z]}[dm;;df]/init;
 clust.i.rtabkm[d]clust.i.mindist[dm;centers;df]}
