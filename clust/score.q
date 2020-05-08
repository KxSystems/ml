// load in toolkit utilities for confmat
.ml.loadfile`:util/init.q

\d .ml

// Unsupervised Learning

// Davies-Bouldin index - Euclidean distance only (edist)
/* data = data points in `value flip` format
/* clt  = list of clusters produced by .ml.clust algos
clust.daviesbouldin:{[data;clt]
 s:avg each clust.i.dists[;`edist;;::]'[p;a:avg@''p:{x[;y]}[data]each group clt];
 (sum{[s;a;x;y]max(s[y]+s e)%'clust.i.dists[flip a e:x _y;`edist;a y;::]}[s;a;t]each t:til n)%n:count a}

// Dunn index
/* data = data points in `value flip` format
/* df   = distance function
/* clt  = list of clusters produced by .ml.clust algos
clust.dunn:{[data;df;clt]
 mx:clust.i.maxintra[df]each p:{x[;y]}[data]each group clt;
 mn:min raze clust.i.mininter[df;p]each -2_({1_x}\)til count p;
 mn%max raze mx}

// Silhouette score
/* data = data points in `value flip` format
/* df   = distance function
/* clt  = list of clusters produced by .ml.clust algos
/* isavg = boolean indicating whether to return a list of scores or the average score
clust.silhouette:{[data;df;clt;isavg]
 $[isavg;avg;]clust.i.sil[data;df;group clt;1%(count each group clt)-1]'[clt;flip data]}

// Supervised Learning

// Homogeneity Score
/* x = predicted cluster labels
/* y = true cluster labels
clust.homogeneity:{[pred;true]
 if[count[pred]<>n:count true;'`$"distinct lengths - lenght of lists has to be the same"];
 if[not e:clust.i.entropy true;:1.];
 cm:value confmat[pred;true];
 nm:(*\:/:).((count each group@)each(pred;true))@\:til count cm;
 mi:(sum/)0^cm*.[-;log(n*cm;nm)]%n;
 mi%e}

// Optimum number of clusters

// Elbow method
/* data = data points in `value flip` format
/* df   = distance function
/* k    = maximum number of clusters
clust.elbow:{[data;df;k]
 {[data;df;k]
  sum raze clust.i.dists[;df;;::]'[p;a:avg@''p:{x[;y]}[data]each group clust.kmeans[data;df;k;100;1b]]
  }[data;df]each 2+til k-1}

// Utilities

// Entropy
/* x = distribution
clust.i.entropy:{neg sum(p%n)*(-). log(p;n:sum p:count each group x)}

// Maximum intra-cluster distance
/* df  = distance function
/* pts = data points in `value flip` format
clust.i.maxintra:{[df;pts]
 max raze{[df;pts;x;y]clust.i.dists[pts;df;pts[;y];x except til 1+y]}[df;pts;n]each n:til count first pts}

// Minimum inter-cluster distance
/* df   = distance function
/* pts  = data points in `value flip` format
/* idxs = cluster indices
clust.i.mininter:{[df;pts;idxs]
 {[df;pts;i;j](min/)clust.i.dists[pts[i];df;pts[j]]each til count pts[i]0}[df;pts;first idxs]each 1_idxs}

// Silhouette coefficient
/* data = data points in `value flip` format
/* df   = distance function
/* idxs = point indices grouped by cluster
/* k    = coefficient to multiply by
/* clt  = cluster of the current point
/* pt   = current point
clust.i.sil:{[data;df;idxs;k;clt;pt]
 d:clust.i.dists[data;df;pt]each idxs;
 (%).((-).;max)@\:(min avg each;k[clt]*sum@)@'d@/:(key[idxs]except clt;clt)}
