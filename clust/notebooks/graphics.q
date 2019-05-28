plt:.p.import`matplotlib.pyplot

/plotting function
/* x = algo e.g.`hc`ward`cure`dbscan
/* y = data
/* z = inputs for the cluster functions
plot:{$[x~`ward;plotw[x;y;z];plotcl[x;y;z]]}

/plot ward or dbscan
plotw:{
 s:.z.t;
 r:$[b:x~`ward;.ml.clust.hc;.ml.clust.dbscan][y;]. z;
 t:.z.t-s;
 $[2<count first y;[fig:plt[`:figure][];ax::fig[`:add_subplot][111;`projection pykw"3d"]];ax::plt];
 {ax[`:scatter]. flip x}each exec pts by clt from r;
 plt[`:title]"df/lf: e2dist/",string[x]," - ",string t;
 plt[`:show][];}

/plot hierarchical, kmeans or cure
plotcl:{
 $[b::2<count first y;fig::plt[`:figure][];
  [subplots::plt[`:subplots]. ud[x;0];fig::subplots[@;0];axarr::subplots[@;1]]];
 fig[`:set_size_inches;18.5;8.5];
 fig[`:subplots_adjust][`hspace pykw .5];
 {[a;d;f;i]
  if[b;ax:fig[`:add_subplot][;;i+1;`projection pykw"3d"]. ud[a]0];
  s:.z.t;r:ud[a;1][d]. f;t:.z.t-s;
  j:@[;i]cross[;]. til each ud[a]0;
  if[not b;ax:$[a in`kmeans`dbscan;axarr[@;i];axarr[@;j 0][@;j 1]]];
  {x[`:scatter]. flip y}[ax]each exec pts by clt from r;
  ax[`:set_title]ud[a;2;f]," - ",string t;
  }[x;y]'[z;til count z];
 plt[`:show][];}

/utils dictionary for plothkc
ud:`hc`cure`kmeans`dbscan!(enlist each(3 4;2 3;1 4;1 3)),'
 (.ml.clust.hc;.ml.clust.cure;.ml.clust.kmeans;.ml.clust.dbscan),'
 ({"df/lf: ",string[x 1],"/",string x 2};{"df/C: ",string[x[2;`df]],"/",string[x[2;`b]],"b"};{"df: ",string x 3};{"df: ",string x 0})