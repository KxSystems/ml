\d .ml

/---Scoring metrics---\

/Davies-Bouldin index (euclidean distance only)
/* x = cluster results table (idx, clt, pts)
clust.dbindex:{
 n:count a:avg each p:value exec pts by clt from x;
 s:avg each clust.i.scdist[`edist]'[p;a];
 dm:clust.i.scdist[`edist;a]each a;
 (sum clust.i.dbi[s;dm;t]each t:til n)%n}

clust.dbindex1:{
 n:count v:select a,s:avg each .ml.clust.i.scdist[`edist]'[pts;a]from select pts,a:avg pts by clt from x; 
 /n:count v:value select a:avg pts,s:avg .ml.clust.i.scdist[`edist;pts;a:avg pts]by clt from x;
 (sum{max(x[z;`s]+x[`s]e)%'clust.i.scdist[`edist;x[`a]e:y except z;x[`a]z]}[v;t]each t:til n)%n}

clust.dbindex2:{
 n:count v:value exec a:avg pts,p:pts by clt from x;
 s:avg each clust.i.scdist[`edist]'[v`p;v`a];
 (sum{[s;a;x;y]max(s[y]+s e)%'clust.i.scdist[`edist;a e:x except y;a y]}[s;v`a;t]each t:til n)%n
 }


/Dunn Index
/* x = cluster results table (idx, clt, pts)
/* y = distance metric as a symbol
clust.dunn:{
 t:til count p:value exec pts by clt from x;
 mn:min raze clust.i.dinter[y;p;t]each t;
 mx:max(max/)each{clust.i.scdist[y;x]each x}[;y]each p;
 mn%mx}

clust.dunn1:{
 t:til count v:value exec pts,mx:max .ml.clust.i.dintra[pts;y]by clt from x;
 mn:min raze clust.i.dinter1[y;v`pts;t]each t;
 mn%max raze v`mx}

/Silhouette coefficient for entire dataset
/* x = cluster results table (idx, clt, pts)
/* y = distance metric as a symbol
clust.silhouette:{
 e;
 t:til count p:value exec pts by clt from x;
 avg raze clust.i.silc[y;p;t]'[t;p]}

/---Utils---\

/dbindex given inter/intra cluster distances
/* s = sigma, avg intracluster distances
/* c = intercluster distances between centroids
/* x = distinct cluster indicies
/* y = index of current cluster
clust.i.dbi:{[s;c;x;y]
 m:@[;where x<>y]x,\:y;
 max{%[(+). x z;y[;]. z]}[s;c]each m}

/intercluster distances
/* df = distance metric
/* p  = points per cluster
clust.i.dinter:{[df;p;x;y]{j:y z;(min/)clust.i.scdist[x;j 0]each j 1}[df;p]each@[;where x<>y]x,\:y}
clust.i.dinter1:{[df;p;x;y]{(min/)clust.i.scdist[x;y]each z}[df;p y]each p x except til 1+y}
clust.i.dintra:{raze{[df;p;x;y]clust.i.scdist[df;p x except til 1+y;p y]}[y;x;n]each n:til count x}

/Silhouette coefficient for each cluster
/* pcl = points in cluster
clust.i.silc:{[df;p;x;y;pcl]k:1%count[pcl]-1;clust.i.silp[df;p;x;y;pcl;k]each pcl}

/Silhouette coefficient for single point
/* k = 1/(n-1), where n is the number of points in cluster y
/* j = single point
clust.i.silp:{[df;p;x;y;pcl;k;j]
 e;
 a:k*sum{x where 0<>x}clust.i.scdist[df;pcl;j];
 b:min avg each clust.i.scdist[df;;j]each p x except y;
 (b-a)%max(a;b)}

/distance calc
/* x = distance metric
/* y = list of points
/* z = single point
clust.i.scdist:{clust.i.dd[x]each y-\:z}
