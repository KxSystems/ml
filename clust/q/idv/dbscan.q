\d .ml

/ User Functions
clust.dbscan:{[d;df;p;e]
 if[not df in key clust.i.dd;'clust.i.err`dist];
 m:clust.i.nbhmat[df;e;flip d]'[d;k:til count d:`float$d];
 t:update valid:p<=count each nbh from([]idx:k;nbh:m;clt:0N);
 clust.i.rtabdb[d]{0N<>x 1}clust.i.dbalgo/(t;exec first i from t where valid)}

/ Utilities
clust.i.dbalgo:{
 n:last{not asc[x 0]~asc x 1}clust.i.nbhidx[t:x 0]/(();enlist c:x 1);
 t:update clt:c,valid:0b from t where valid,idx in n;
 (t;exec first i from t where valid)}
clust.i.dd:`e2dist`edist`mdist`cshev`nege2dist!
 ({x wsum x};{sqrt x wsum x};{sum abs x};{min abs x};{neg x wsum x})
clust.i.err:`dist`link`ward`kmns!
 (`$"invalid distance metric - must be in .ml.clust.i.dd";
  `$"invalid linkage - must be in .ml.clust.i.ld";
  `$"ward must be used with e2dist";
  `$"kmeans must be used with edist/e2dist")
clust.i.nbhmat:{[df;e;x;y;n]where e>=@[;n;:;0w]clust.i.dd[df]x-y}
clust.i.nbhidx:{[t;l]
 (l 1;distinct raze exec nbh from t where valid,idx in(raze/)t[l 1]`idx`nbh)}
clust.i.rtabdb:{[d;t]select idx,clt,pts:d from update clt:idx from t 0 where i in(where 0N=clt)}