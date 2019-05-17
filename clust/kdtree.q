\d .ml

/build kd-tree with 1st data point as root and remaining points subsequently added
/* d  = data points
/* cl = current cluster index
/* sd = splitting dimensions
/* df = distance function/metric

clust.kd.buildtree:{[d;cl;sd;df]
 r:flip`idx`initi`pts`dir`dim`par`clt`cltidx`valid!(0;0;enlist @[d;0];2;0;0;cl 0;enlist 0 0;1b);
 t:clust.kd.insertcl[sd]/[r;1_d;1_cl;1_cl];
 clust.kd.distcalc[df]/[t;t`initi]}

/insert new cluster checking if L or R of root and looking at sd of each node
/* t  = kd-tree
/* ii = initial index
/* cl = cluster index

clust.kd.insertcl:{[sd;t;d;cl;k]
 nsd:{0<=first @[x;0]`idx}clust.kd.i.nodedir[d;t]/enlist t 0;
 clust.kd.i.insertn[t;nsd 1;nsd 2;d;cl;enlist k;sd]}

/distance calculation between clusters in kd-tree and single node (pt)
clust.kd.distcalc:{[df;t;pt]
 idpts:select par,clt,pts from t where idx=pt,valid;
 dist:{0<count x 2}clust.kd.i.bestdist[t;first idpts`pts;first idpts`clt;df]/
  (0W;pt;raze[idpts[`par],raze exec idx from t where par=pt,valid]except pt;pt);
 update nnd:dist 0,nni:dist 1 from t where idx=pt}

/updated kd-tree with point X removed by moving points up the tree until X has no children
clust.kd.deletecl:{[df;t;X]
 pt:first exec idx from t where initi=X,valid;
 ni:exec initi from t where nni in pt,valid;
 delCl:{0<>count select from x[0]where par=x[1],valid}
  clust.kd.i.delnode/(t;pt);
 t:update valid:0b from first delCl where idx=last delCl;
 nn:exec idx from t where initi in ni,valid;
 clust.kd.distcalc[df]/[t;nn]}