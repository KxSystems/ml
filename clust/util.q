\d .ml

// Distance metric dictionary
clust.i.dd.edist:{sqrt x wsum x}
clust.i.dd.e2dist:{x wsum x}
clust.i.dd.mdist:{sum abs x}
clust.i.dd.cshev:{min abs x}
clust.i.dd.nege2dist:{neg x wsum x}

// Linkage dictionary
clust.i.ld.single:min
clust.i.ld.complete:max
clust.i.ld.average:avg
clust.i.ld.centroid:raze
clust.i.ld.ward:{z*x*y%x+y}

// Distance calculations
clust.i.dists:{[data;df;pt;idxs]clust.i.dd[df]pt-data[;idxs]}
clust.i.closest:{[data;df;pt;idxs]`point`distance!(idxs dists?md;md:min dists:clust.i.dists[data;df;pt;idxs])}

// Index functions
clust.i.imax:{x?max x}
clust.i.imin:{x?min x}
clust.i.reindex:{distinct[x]?x}

// Error dictionary
clust.i.err.dd:{'`$"invalid distance metric"}
clust.i.err.ld:{'`$"invalid linkage"}
clust.i.err.ward:{'`$"ward must be used with e2dist"}
clust.i.err.kmeans:{'`$"kmeans must be used with edist/e2dist"}
