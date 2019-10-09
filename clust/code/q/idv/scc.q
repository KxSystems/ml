\l ../kdtree.q
\d .ml

/ User Functions

/HC -- SC
clust.hc:{[d;k;df;lf;c]
 d:`float$d;w:clust.i.errchk[df;lf];
 if[b:lf in`complete`average`ward;t:clust.i.buildtab[d;df]];
 clust.i.rtab[d]$[b;;clust.i.algoscc[d;k;;ceiling count[d]%100;lf;();;0b].
  $[c;(clust.ccure.dfd df;clust.ccure);(df;clust)]]}

/CURE
clust.cure:{[d;k;r;i]
 i:(`df`c`b`s!(`e2dist;0;0b;0b)),i;
 d:`float$d;if[not i[`df]in key clust.i.dd;'clust.i.err`dist];
 clust.i.algoscc[d;k;;r;i`c;();;i`s]. $[i`b;(clust.ccure.dfd i`df;clust.ccure);(i`df;clust)]}

/ Utilities
clust.i.calc:{[df;pts;p;rp]im:min mm:clust.i.dc[df;rp;p;pts];ir:p mm?im;(first ir;im)}
clust.i.dc:{[df;rp;i;j]{[df;rp;i;j]clust.i.dd[df]rp[i]-rp[j]}[df;rp;;j]each i}
clust.i.axdist:{[t;bd;os;df;ns;p;rp]
 raze{[t;bd;os;df;ns;p;rp]
  $[t[2]p;p;bd>=clust.i.dd[df]rp[ns;t[5]p]-t[4]p;t[3]p;(raze clust.i.findl[rp ns;t;p])except os]
  }[t;bd;os;df;ns;;rp]each p}
clust.i.clvars:{[d;k;df;t;ns]
 r2l:((pc:count d)#0N){[t;x;y]@[x;t[3]y;:;y]}[t]/where t 2;
 c2p:enlist each r2c:til pc;
 ndists:flip ns[`kd][`i][`nns][;t;r2c;d;df]each r2c;
 `oreps`r2l`r2c`gone`c2r`c2p`ndists`pc!(d;r2l;r2c;pc#0b;c2p;c2p;ndists;pc)}
clust.i.curerep:{[d;df;x;r;c]
 maxp:x clust.i.imax clust.i.dd[df]each d[x]-\:m:avg d x;
 rp:d(r-1){[d;df;x;p]p,i clust.i.imax{[d;df;i;p]min{[d;df;i;p]clust.i.dd[df]d[p]-d[i]
  }[d;df;i]each p}[d;df;;p]each i:x except p}[d;df;x]/maxp;
 (rp*1-c)+\:c*m}
clust.i.dc:{[df;rp;i;j]{[df;rp;i;j]clust.i.dd[df]rp[i]-rp[j]}[df;rp;;j]each i}
clust.i.dd:`e2dist`edist`mdist`cshev`nege2dist!
 ({x wsum x};{sqrt x wsum x};{sum abs x};{min abs x};{neg x wsum x})
clust.i.err:`dist`link`ward`kmns!
 (`$"invalid distance metric - must be in .ml.clust.i.dd";
  `$"invalid linkage - must be in .ml.clust.i.ld";
  `$"ward must be used with e2dist";
  `$"kmeans must be used with edist/e2dist")
clust.i.findl:{y[3;z]first`int$y[4;z]<=x y[5;z]}
clust.i.imax:{x?max x}
clust.i.imin:{x?min x}
clust.i.rtab:{update pts:x from @[clust.i.cln;`idx`clt`pts#y;y]}
clust.i.algoscc:{[d;k;df;r;c;m;ns;b]
 t:clust.kd.buildtree[flip d;r];
 v:clust.i.clvars[d;k;df;t;ns];                                              / variables
 if[l:98h=type m;v[`ilm]:v`r2c];                                            / add variable for linkage matrix
 i:0;N:v[`pc]-k;                                                            / counter and n iterations
 while[i<N;
  mci:u,v[`ndists;0;u:clust.i.imin v[`ndists]1];                            / clusts to merge
  orl:v[`r2l]ori:raze v[`c2r]mci;                                           / old reps and their leaf nodes
  m,:v[`ilm;mci],v[`ndists;1;u],count ori;                                  / update linkage matrix
  npi:raze v[`c2p] mci;
  $[c~`single;nri:ori;
   [nreps:$[not c~`centroid;ns[`i][`curerep][v[`oreps];df;npi;r;c];enlist avg v[`oreps]npi]; / reps of new clust
  d[nri:(count nreps)#ori]:nreps;                                           / overwrite any old reps w/ new ones
  v[`r2l;nri]:nrl:ns[`kd][`searchfrom][t;;0]each nreps;        / leaf nodes for new reps, update tree
  t:.[t;(3;distinct orl);{y except x}ori];                                  / update tree w/ new reps, delete old reps
  t:t{.[x;(3;y 0);{y,x}y 1]}/flip(nrl;nri)]];                               / add new reps
  v[`r2c;nri]:v[`r2c]ori 0;                                                 / new clust is 1st of old clusts
  if[l;v[`ilm;nri]:1+max v`ilm];                                            / update indeces for linkage matrix
  v:{.[x;y;:;z]}/[v;flip(`c2p`c2r`gone;(mci;mci;mci 1));((npi;0#0);(nri;0#0);1b)];
  cnc:ns[`kd][`nnc][nri;t;v`r2c;d;df];
  w:(where v[`ndists;0]in mci)except wg:where v[`gone];
  $[c~`single;v[`ndists;0;w]:mci 0;[v[`ndists;0 1;w]:$[count w;
    flip ns[`kd][`nnc][;t;v`r2c;d;df]each v[`c2r]w;(0#0;0#0f)]]];
  / update all for clust d and closest clust, nearest clust and dist to new clust
  v[`ndists]:{.[x;y;:;z]}/[v`ndists;((::;mci 0);(::;mci 1));(cnc;(0N;0w))];
  i+:1];
  $[b;
    `reps`tree`r2c`r2l!(d ii;.[t;(3;j);:;{x?y}[ii]each t[3;]j:where t[2;]];{x?y}[distinct c]each c:v[`r2c]ii;v[`r2l]ii:raze v`c2r);
    l;m;([]idx:u;clt:raze{where y in'x}[v[`c2p]where not v`gone]each u:til count v`oreps;pts:v`oreps)]}

/
/ new cure
\d .ml

clust.cure:{[d;k;r;i]
 i:clust.i.cureparam i;
 t:clust.kd.buildtree[flip d:`float$d;r];
 v:clust.i.clvars[d;k;i`df;t;i`ns];                                            
 clust.i.rtabcure[;i](v[`pc]-k)clust.i.algocure[r;i]/`d`t`v!(d;t;v)}

clust.i.algocure:{[r;i;l]
 mci:u,l[`v;`ndists;0]u:clust.i.imin l[`v;`ndists]1;                          
 orl:l[`v;`r2l]ori:raze l[`v;`c2r]mci;                                          
 m:l[`v;`ilm;mci],l[`v;`ndists;1;u],count ori;                                
 npi:raze l[`v;`c2p]mci;
 nreps:i[`ns;`i;`curerep][l[`v]`oreps;i`df;npi;r;i`c];
 l[`d;nri:count[nreps]#ori]:nreps;                                          
 l[`v;`r2l;nri]:nrl:i[`ns;`kd;`searchfrom][l`t;;0]each nreps;       
 l[`t]:.[l`t;(3;distinct orl);{y except x}ori];                                
 l[`t]:l[`t]{.[x;(3;y 0);{y,x}y 1]}/flip(nrl;nri);
 l[`v;`r2c;nri]:l[`v;`r2c]ori 0;
 l[`v]:{.[x;y;:;z]}/[l`v;flip(`c2p`c2r`gone;(mci;mci;mci 1));((npi;0#0);(nri;0#0);1b)];
 cnc:i[`ns;`kd;`nnc][nri;l`t;l[`v]`r2c;l`d;i`df];
 w:(where l[`v;`ndists;0]in mci)except wg:where l[`v]`gone;
 l[`v;`ndists;0 1;w]:$[count w;
   flip i[`ns;`kd;`nnc][;l`t;l[`v]`r2c;l`d;i`df]each l[`v;`c2r]w;(0#0;0#0f)];
 l[`v;`ndists]:{.[x;y;:;z]}/[l[`v]`ndists;((::;mci 0);(::;mci 1));(cnc;(0N;0w))];
 l}

clust.i.curetab:{
 `idx xcols update idx:i from([]clt:raze{where y in'x}[x[`c2p]where not x`gone]each til count x`oreps;pts:x`oreps)}
clust.i.curetree:{
 `reps`tree`r2c`r2l!
  (x[`d]k;
   .[x`t;(3;j);:;{x?y}[k]each x[`t][3]j:where x[`t]2];
   {x?y}[distinct c]each c:x[`v;`r2c]k;
   x[`v;`r2l]k:raze x[`v]`c2r)}
clust.i.cureparam:{
 x:(`df`c`b`s`m!(`e2dist;0;0b;0b;())),x;
 x,`df`ns!$[x`b;(clust.ccure.dfd x`df;clust.ccure);(x`df;clust)]}
clust.i.rtabcure:{$[y`s;clust.i.curetree x;clust.i.curetab x`v]}