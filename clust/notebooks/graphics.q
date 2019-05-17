plt:.p.import`matplotlib.pyplot

/plotting function
/* x = algo e.g.`hc`ward`cure`dbscan
/* y = data
/* z = inputs for the cluster functions

plot:{$[x in`ward`dbscan;plotwdb[x;y;z];plothcc[y;z]]}

/plot ward or dbscan
plotwdb:{
 s:.z.t;
 r:$[b:x~`ward;.ml.clust.hc;.ml.clust.dbscan][y;]. z;
 t:.z.t-s;
 $[2<count first y;[fig:plt[`:figure][];ax::fig[`:add_subplot][111;`projection pykw"3d"]];ax::plt];
 {ax[`:scatter]. flip x}each exec pts by clt from r;
 plt[`:title]"df/lf: e2dist/,",string[x]," - ",string t;
 plt[`:show][];}

/plot hierarchical (`single`complete`average`centroid) or cure
plothcc:{
 c:y[;0]0;
 d:1_ 'y;
 is3d::2<count first x;
 ishc::2~count first d;
 $[is3d;fig::plt[`:figure][];[subplots::plt[`:subplots]. $[ishc;3 4;1 3]; fig::subplots[@;0];axarr::subplots[@;1]]];
 fig[`:set_size_inches;18.5;8.5];
 fig[`:subplots_adjust][`hspace pykw .5];
 {[d;c;f;i]
  if[is3d;ax:fig[`:add_subplot][;;i+1;`projection pykw"3d"]. $[ishc;3 4;1 3]];
  s:.z.t;
  r:$[ishc;.ml.clust.hc;.ml.clust.ccure][d;c]. f;
  t:.z.t-s;
  j:cross[til 3;til 4]i;
  if[not is3d;ax:$[ishc;axarr[@;j 0][@;j 1];axarr[@;i]]];
  {x[`:scatter]. flip y}[ax]each exec pts by clt from r;
  ax[`:set_title]"df/",$[ishc;["lf: ",string[f 0],"/",string f 1];["C: ",string[f 0],"/",string[f 3],"b"]]," - ",string t;
  }[x;c]'[d;til count d];
 plt[`:show][];}