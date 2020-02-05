\d .ml

/ User Functions
clust.kmeans:{[d;df;k;n;b]
 if[not df in`edist`e2dist;'clust.i.err`kmns];
 m:flip d;i:$[b;clust.i.initkpp[df;d];clust.i.initrdm m]k;
 c:n{{avg each x@\:y}[x]each value group clust.i.mindist[x;y;z]}[m;;df]/i;
 clust.i.rtabkm[d]clust.i.mindist[m;c;df]}

/ Utilities
clust.i.dd:`e2dist`edist`mdist`cshev`nege2dist!
 ({x wsum x};{sqrt x wsum x};{sum abs x};{min abs x};{neg x wsum x})
clust.i.err:`dist`link`ward`kmns!
 (`$"invalid distance metric - must be in .ml.clust.i.dd";
  `$"invalid linkage - must be in .ml.clust.i.ld";
  `$"ward must be used with e2dist";
  `$"kmeans must be used with edist/e2dist")
clust.i.imin:{x?min x}
clust.i.initkpp:{[df;d;k]
 (k-1){z,y clust.i.rdmidx[1]min each flip{clust.i.dd[x]y-z}[x;flip y]'[z]}[df;d]/1?d}
clust.i.initrdm:{flip x@\:neg[y]?til count x 0}
clust.i.mindist:{{clust.i.imin@[x;where x=0;:;0n]}each(,'/)clust.i.dd[z]each x-/:y}
clust.i.rdmidx:{s binr x?last s:sums y}
clust.i.rtabkm:{([]idx:til count x;clt:y;pts:x)}
