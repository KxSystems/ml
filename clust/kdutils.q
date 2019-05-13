\d .ml

/utils
clust.kd.i.imax:{x?max x}
clust.kd.i.imin:{x?min x}

/distance and linkage dictionaries
clust.kd.i.dd:`e2dist`edist`mdist`cshev!({x wsum x};{sqrt x wsum x};{sum abs x};{min abs x})
clust.kd.i.ld:`single`complete`average`centroid`ward!(min;max;avg;raze;{z%(1%y)+1%x})

/updated kd-tree with new node inserted
/* t   = kd-tree
/* p   = parent node dimension and index
/* nsd = new splitting dimension
/* d   = data points
/* ii  = initial index
/* ci  = cluster index
/* sd  = splitting dimension

clust.kd.i.insertn:{[t;p;nsd;d;ci;k;sd]
 $[not 0b in t`valid;
 t upsert([]idx:1+max t`idx;initi:1+max t`idx;clt:ci;cltidx:k;pts:enlist d;dim:mod[1+p`dim;sd];valid:1b;par:p`idx;dir:nsd);
  update idx:1+max t`idx,initi:1+max t`idx,clt:ci,pts:enlist d,valid:1b,cltidx:k,dim:mod[1+p`dim;sd],dir:nsd,par:p`idx 
   from t where idx=first exec idx from t where not valid]}

/returns list of next node to split on, previous node and splitting dimensions
clust.kd.i.nodedir:{[d;t;nn]
 a:nn 0;
 sd:$[d[first a`dim]>raze[a`pts]first a`dim;1;0];
 i:select from t where dir=sd,par=first a`idx,valid;
 (i;a;sd)}

/children of node X
clust.kd.i.branches:{[t;X]raze exec idx from t where par in X,valid}

/tree node of child with minimum dimension
clust.kd.i.mindim:{[t;X;child]
 newP:child clust.kd.i.imin raze({[t;x]first exec pts from t where idx=x,valid
  }[t]each child)[;first exec dim from t where idx=X,valid];
 select from t where idx=newP,valid}

/updated kd-tree with new node n inserted
clust.kd.i.updatet:{[t;n;X]
 update pts:n`pts,initi:n`initi,nnd:n`nnd,clt:n`clt,
  cltidx:n`cltidx,nni:n`nni from t where idx=X,valid}

/new splitting dimension of node looking at parent
clust.kd.i.splitdim:{[t;bd;p;df;nn]
 a:select from t where idx=nn,valid;
 nsd:$[(qdim:p d)<rdim:first[a`pts]d:first a`dim;0;1];
 $[bd[0]>=clust.kd.i.dd[df]rdim-qdim;exec idx from t where par=nn,valid;
  exec idx from t where par=nn,dir=nsd,valid],a`par}
