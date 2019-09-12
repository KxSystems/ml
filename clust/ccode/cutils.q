\d .ml

clust.kdtree.i.searchfrom:`:kdtree 2:`kdtree_searchfrom,3
clust.ccure.kd.searchfrom:{[x;y;z]$[not type[y]~type x 4;'`type;clust.kdtree.i.searchfrom[x;y;z]]}

clust.ccure.i.:(::)
clib:`:cure 2:
impf:{clust.ccure.i[u]:clib(u:`$"_"sv string(x;y)),z}
impf'[`cure_cluster_dists;`F`E;4];
impf'[`cure_cluster_reps;`F`E;4];
impf'[`cure_nn;`F`E;5];

/ shrink points towards their mean
clust.ccure.shrink:{z-x*z-\:y}
/ x - representative points shrunk by y - compression towards mean from z - a list of points
clust.ccure.i.curerep:{[rp;df;n;r;c]t$clust.ccure.shrink[c;m]$["f"=t;clust.ccure.i.cure_cluster_reps_F;"e"=t;clust.ccure.i.cure_cluster_reps_E;'`type][rp n;r;(t:.Q.t type rp[n] 0)$m:avg rp[n];df]}
/ from pi - a list of indices into reps - a list of representative points, find the closest (other) cluster and distance to it
clust.ccure.kd.nnc:{[pi;tree;clusters;reps;df]@[;0;clusters]{mi:u?mn:min u:x[;1];(x[;0]mi;mn)}clust.ccure.kd.i.nns[;tree;clusters;reps;df]each pi}
/ closest (other) cluster and distance to it from x - a point index (into w - a list of reps) given a tree y and mapping from 
/ w - a list 
clust.ccure.kd.i.nns:{[x;y;z;w;df]$["f"=.Q.t type w 0;clust.ccure.i.cure_nn_F;"e"=t;clust.ccure.i.cure_nn_E;'`type][x;y;z;w;df]}
clust.ccure.dfd:`e2dist`edist`mdist!1 2 3;
