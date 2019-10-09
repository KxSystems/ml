\d .ml

clust.kdtree.i.searchfrom:`:kdtree 2:(`kdtree_searchfrom;3)
clust.ccure.kd.searchfrom:{$[type[y]~type x 4;clust.kdtree.i.searchfrom[x;y;z];'`type]}

clust.ccure.i.:(::)
clib:`:cure 2:
impf:{clust.ccure.i[u]:clib(u:`$"_"sv string(x;y)),z}
impf'[`cure_cluster_dists;`F`E;4];
impf'[`cure_cluster_reps;`F`E;4];
impf'[`cure_nn;`F`E;5];

clust.ccure.dfd:`e2dist`edist`mdist!1 2 3;
clust.ccure.i.curerep:{[rp;df;n;r;c]
 t:.Q.t type rp[n]0;
 z:$["f"=t;clust.ccure.i.cure_cluster_reps_F;
     "e"=t;clust.ccure.i.cure_cluster_reps_E;
     '`type];
 t$clust.ccure.shrink[c;m]z[rp n;r;t$m:avg rp n;df]}

/ from idx (pi) to reps - find closest (other) clust/dist
clust.ccure.kd.nnc:{[pi;t;cl;rp;df]
 @[;0;cl]{mi:u?mn:min u:x[;1];(x[;0]mi;mn)}clust.ccure.kd.i.nns[;t;cl;rp;df]each pi}

/ from closest (other) clust/dist from x (pt idx) into w (list of reps) given tree (y)
clust.ccure.kd.i.nns:{[x;y;z;w;df]
 t:.Q.t type w 0;
 f:$["f"=t;clust.ccure.i.cure_nn_F;
     "e"=t;clust.ccure.i.cure_nn_E;
     '`type];
 f[x;y;z;w;df]}

/ shrink pts towards mean
clust.ccure.shrink:{z-x*z-\:y}
