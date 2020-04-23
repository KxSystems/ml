.ml.loadfile`:util/init.q
\d .ml

/---Scoring metrics---\

/Davies-Bouldin index (euclidean distance only)
/* x = results table (idx, clt, pts) produced by .clust.ml.cure/dbscan/hc/kmeans
clust.daviesbouldin:{
 n:count v:value exec a:avg pts,p:pts by clt from x;
 s:avg each clust.i.scdist[`edist]'[v`p;v`a];
 (sum{[s;a;x;y]max(s[y]+s e)%'clust.i.scdist[`edist;a e:x except y;a y]}[s;v`a;t]each t:til n)%n}

/Dunn Index
/* x = results table (idx, clt, pts) produced by .clust.ml.cure/dbscan/hc/kmeans
/* y = distance metric as a symbol
clust.dunn:{
 t:til count v:value exec pts,mx:max .ml.clust.i.dintra[pts;y]by clt from x;
 mn:min raze clust.i.dinter[y;v`pts;t]each t;
 mn%max raze v`mx}

/Elbow method
/* x = data
/* y = distance
/* z = maximum number of clusters
clust.elbow:{{sum exec sum .ml.clust.i.scdist[y;pts;avg pts]by clt from clust.kmeans[x;z;100;1b;y]}[x;y]each 2+til z-1}

/Homogeneity Score
/* x = predicted cluster labels
/* y = true cluster labels
clust.homogeneity:{
 if[count[x]<>n:count y;'`$"distinct lengths - lenght of lists has to be the same"];
 if[not e:clust.i.entropy y;:1.];
 cm:value confmat[x;y];
 nm:(*\:/:).((count each group@)each(x;y))@\:til count cm;
 mi:(sum/)0^cm*.[-;log(n*cm;nm)]%n;
 mi%e}

/Silhouette coefficient for entire dataset
/* x = results table (idx, clt, pts) produced by .clust.ml.cure/dbscan/hc/kmeans
/* y = distance metric as a symbol
/* z = boolean(1b) if average coefficient
clust.silhouette:{$[z;avg;]exec .ml.clust.i.sil[y;pts;group clt;1%(count each group clt)-1]'[clt;pts]from x}

/---Utils---\

/intercluster distances
/* df = distance metric
/* p  = points per cluster
/* x = til number of clusters
/* y = index of the cluster
clust.i.dinter:{[df;p;x;y]{(min/)clust.i.scdist[x;y]each z}[df;p y]each p x except til 1+y}

/intra-cluster distances
/* x = points in the cluster
/* y = distance metric
clust.i.dintra:{raze{[df;p;x;y]clust.i.scdist[df;p x except til 1+y;p y]}[y;x;n]each n:til count x}

/entropy
/* x = distribution
clust.i.entropy:{neg sum(p%n)*(-). log(p;n:sum p:count each group x)}

/distance calc
/* x = distance metric
/* y = list of points
/* z = single point
clust.i.scdist:{clust.i.dd[x]each y-\:z}

/Silhouette coefficient
/* pts = points in the dataset
/* i   = clusters of all points
/* k   = coefficient to multiply by
/* c   = cluster of the point
/* p   = point
clust.i.sil:{[df;pts;i;k;c;p]
 d:clust.i.scdist[df;;p]each pts i;
 (%).((-).;max)@\:(min avg each;k[c]*sum@)@'d@/:(key[i]except c;c)}