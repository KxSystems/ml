\d .ml

// DBSCAN algorithm
/* data   = data points in `value flip` format
/* df     = distance function
/* minpts = minimum number of points in epsilon radius
/* eps    = epsilon radius to search
/. r      > returns list of clusters
clust.dbscan:{[data;df;minpts;eps]
 // check distance function
 if[not df in key clust.i.dd;clust.i.err.dd[]];
 // convert to floating values
 data:"f"$data;
 // calculate distances and find all points which are not outliers
 nbhood:clust.i.nbhood[data;df;eps]each til count data 0;
 // update outlier cluster to null
 t:update cluster:0N,corepoint:minpts<=1+count each nbhood from([]nbhood);
 // find cluster for remaining points and return list of clusters
 exec cluster from {[t]any t`corepoint}clust.i.dbalgo/t}

// Find all points which are not outliers
/* data = data points in `value flip` format
/* df   = distance function
/* eps  = epsilon radius to search
/* idx  = index of current point
/. r    > returns indices of points within the epsilon radius
clust.i.nbhood:{[data;df;eps;idx]where eps>@[;idx;:;0w]clust.i.dd[df]data-data[;idx]}

// Run DBSCAN algorithm and update cluster of each point
/* t = cluster info table
/. r > returns updated cluster table with old clusters merged
clust.i.dbalgo:{[t]update cluster:0|1+max t`cluster,corepoint:0b from t where i in .ml.clust.i.nbhoodidxs[t]/[first where t`corepoint]}

// Find indices in each points neighborhood
/* t    = cluster info table
/* idxs = indices to search neighborhood of
/. r    > returns list of indices in neighborhood
clust.i.nbhoodidxs:{[t;idxs]asc distinct idxs,raze exec nbhood from t[distinct idxs,raze t[idxs]`nbhood]where corepoint}
