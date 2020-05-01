\d .ml

// K-Means algorithm
/* data = data points in `value flip` format
/* df   = distance function
/* k    = number of clusters
/* iter = number of iterations
/* kpp  = boolean indicating whether to use random initialization (`0b`) or k-means++ (`1b`)
clust.kmeans:{[data;df;k;iter;kpp]
 // check distance function
 if[not df in`e2dist`edist;clust.i.err.kmeans[]];
 // initialize representative points
 reppts0:$[kpp;clust.i.initkpp df;clust.i.initrdm][data;k];
 // run algo `iter` times
 reppts1:iter{[data;df;reppt]{[data;j]avg each data[;j]}[data]each value group clust.i.getclust[data;df;reppt]}[data;df]/reppts0;
 // return list of clusters
 clust.i.getclust[data;df;reppts1]}

// Calculate final representative points
/* data   = data points in `value flip` format
/* df     = distance function
/* reppts = representative points of each cluster
/. r      > return list of clusters
clust.i.getclust:{[data;df;reppts]max til[count dist]*dist=\:min dist:{[data;df;reppt]clust.i.dd[df]reppt-data}[data;df]each reppts}

// Random initialization of representative points
/* data = data points in `value flip` format
/* k    = number of clusters
/. r    > returns k representative points
clust.i.initrdm:{[data;k]flip data[;neg[k]?count data 0]}

// K-Means++ initialization of representative points
/* df   = distance function
/* data = data points in `value flip` format
/* k    = number of clusters
/. r    > returns k representative points
clust.i.initkpp:{[df;data;k]
 info0:`point`dists!(data[;rand count data 0];0w);
 infos:(k-1)clust.i.kpp[data;df]\info0;
 infos`point}

// K-Means++ algorithm
/* data = data points in `value flip` format
/* df   = distance function
/* info = dictionary with points and distance info
/. r    > returns updated info dictionary
clust.i.kpp:{[data;df;info]@[info;`point;:;data[;s binr rand last s:sums info[`dists]&:clust.i.dists[data;df;info`point;::]]]}
