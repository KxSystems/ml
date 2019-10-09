\d .ml
  
/ User Functions
clust.ap:{[d;df;dmp;p]
 if[not df in key clust.i.dd;'clust.i.err`dist];
 m:clust.i.createmtx[d;df];
 m[`s]:clust.i.updpref[m`s;p];
 same:0;maxitr:floor .1*count d;
 r:clust.i.apstop[maxitr]clust.i.apalgo[d;dmp]/(m;(),0;(),1);
 clust.i.rtabkm[d]clust.i.apout[r 2]}

/ Utilities
clust.i.apalgo:{[d;dmp;i]  / i:(m;oe;ne)
 m[`r]:clust.i.updr[m:i 0;dmp];
 m[`a]:clust.i.upda[m;dmp];
 e:clust.i.imax each m[`a]+m`r;
 (m;i 2;e)}
clust.i.apout:{@[;a](!). (da;til count da:distinct a:x)}
clust.i.apstop:{$[y[1]~y 2;[same::same+1;$[same~x;:0b;:1b]];[same::0;:1b]]}
clust.i.createmtx:{
 s:clust.i.scdist[y;x]each x;
 a:r:(n;n:count x)#0f;
 `s`a`r!(s;a;r)}
clust.i.dd:`e2dist`edist`nege2dist`mdist`cshev!
 ({x wsum x};{sqrt x wsum x};{neg x wsum x};{sum abs x};{min abs x})
clust.i.imax:{x?max x}
clust.i.scdist:{clust.i.dd[x]each y-\:z}
clust.i.rtabkm:{([]idx:til count x;clt:y;pts:x)}
clust.i.upda:{[m;dmp]
 pv:{@[x;;:;0f]where x<0}each m`r;
 s:sum{@[y;x;:;0f]}'[k:til n:count first m;pv];
 a:{@[;y;:;z]@[x;;:;0f]where x>0}'[(n#enlist s+m[`r]@'k)-pv;k;s];
 (dmp*m`a)+a*1-dmp}
clust.i.updpref:{
 p:$[-11h~ty:type y;get[string y]raze x;-9h~ty;y;'clust.i.err`pref];
 {@[y;z;:;x]}[p]'[x;til count x]}
clust.i.updr:{[m;dmp]
 v:{@[x;y;:;-0w]}'[m[`s]+m`a;til n:count first m];
 mx:{@[l+count[x]#0;i;:;]max@[x;i:x?l:max x;:;-0w]}each v;
 (dmp*m`r)+(1-dmp)*m[`s]-mx}
clust.i.err:`dist`link`ward`kmns`pref!
 (`$"invalid distance metric - must be in .ml.clust.i.dd";
  `$"invalid linkage - must be in .ml.clust.i.ld";
  `$"ward must be used with e2dist";
  `$"kmeans must be used with edist/e2dist";
  `$"pref must be function (e.g. min or `min) or floating point value")
