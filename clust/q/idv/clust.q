// utils

clust.i.err.dd:{'`$"invalid distance metric"}
clust.i.err.ld:{'`$"invalid linkage"}
clust.i.err.ward:{'`$"ward must be used with e2dist"}
clust.i.err.kmeans:{'`$"kmeans must be used with edist/e2dist"}
clust.i.err.pref:{'`$"pref must be a function (e.g. min/`min) or floating point value"}

clust.i.dd.edist:{sqrt x wsum x}
clust.i.dd.e2dist:{x wsum x}
clust.i.dd.mdist:{sum abs x}
clust.i.dd.cshev:{min abs x}
clust.i.dd.nege2dist:{neg x wsum x}

clust.i.ld.single:min
clust.i.ld.complete:max
clust.i.ld.average:avg
clust.i.ld.centroid:raze
clust.i.ld.ward:{z%(1%y)+1%x}

clust.i.dists:{[data;df;pt;idxs]clust.i.dd[df]pt-data[;idxs]}
clust.i.closest:{[data;df;pt;idxs]`point`distance!(idxs dists?md;md:min dists:clust.i.dists[data;df;pt;idxs])}

// kd tree

clust.kd.newtree:{[data;leafsz]clust.kd.i.tree[data;leafsz]`leaf`left`parent`self`idxs!(0b;0b;0N;0;til count data 0)}

clust.kd.i.tree:{[data;leafsz;node]
  if[leafsz<=.5*count node`idxs;
    chk:xdata<med xdata@:ax:dvar?max dvar:var each xdata:data[;node`idxs];
    if[all leafsz<=count each(lIdxs:where chk;rIdxs:where not chk);
     n:count lTree:.z.s[data;leafsz]update left:1b,parent:self,self+1  ,idxs:idxs lIdxs from node;
             rTree:.z.s[data;leafsz]update left:0b,parent:self,self+1+n,idxs:idxs rIdxs from node;
     node:select leaf,left,self,parent,children:self+1+(0;n),axis:ax,midval:min xdata rIdxs,
                 idxs:0#0 from node;
     :enlist[node],lTree,rTree]];
  enlist select leaf:1b,left,self,parent,children:0#0,axis:0N,midval:0n,idxs from node}

clust.kd.nn:{[tree;data;df;xidxs;pt]
  start:`closestPoint`closestDist`xnodes`node!(0N;0w;0#0;clust.kd.i.findleaf[tree;pt;tree 0]);
  {[nninfo]not null nninfo[`node;`self]}clust.kd.i.nncheck[tree;data;df;xidxs;pt]/start}

clust.kd.i.nncheck:{[tree;data;df;xidxs;pt;nninfo]
  if[nninfo[`node]`leaf;
    closest:clust.i.closest[data;df;pt]nninfo[`node;`idxs]except xidxs;
    if[closest[`distance]<nninfo`closestDist;
      nninfo[`closestPoint`closestDist]:closest`point`distance]];
  if[not null childidx:first nninfo[`node;`children]except nninfo`xnodes;
    childidx:$[(nninfo`closestDist)<clust.i.dd[df]pt[nninfo[`node]`axis]-nninfo[`node]`midval;
      0N;clust.kd.i.findleaf[tree;pt;tree childidx]`self]];
  if[null childidx;nninfo[`xnodes],:nninfo[`node]`self];
  nninfo[`node]:tree nninfo[`node;`parent]^childidx;
  nninfo}

clust.kd.i.findnext:{[tree;pt;node]tree node[`children]node[`midval]<=pt node`axis}
clust.kd.i.findleaf:{[tree;pt;node]{[node]not node`leaf}clust.kd.i.findnext[tree;pt]/node}

// k means

clust.kmeans:{[data;df;k;iter;kpp]
  if[not df in`e2dist`edist;clust.i.err.kmeans[]];
  reppts0:$[kpp;clust.i.initkpp df;clust.i.initrdm][data;k];
  reppts1:iter{[data;df;reppt]
    flip{[data;j]avg each data[;j]}[data]each value group clust.i.getclust[data;df;reppt]
    }[data;df]/reppts0;
  clust.i.getclust[data;df;reppts1]}

clust.i.getclust:{[data;df;reppts]
  max til[count dist]*dist=\:min dist:{[data;df;reppt]clust.i.dd[df]reppt-data}[data;df]each flip reppts}

clust.i.initrdm:{[data;k]data[;neg[k]?count data 0]}

clust.i.initkpp:{[df;data;k]
  info0:`point`dists!(data[;rand count data 0];0w);
  infos:(k-1)clust.i.kpp[data;df]\info0;
  flip infos`point}

clust.i.kpp:{[data;df;info]@[info;`point;:;data[;s binr rand last s:sums info[`dists]&:clust.i.dists[data;df;info`point;::]]]}

// dbscan

clust.dbscan:{[data;df;minpts;eps]
  if[not df in key clust.i.dd;clust.i.err.dd[]];
  nbhood:clust.i.nbhood[data;df;eps]each til count data 0;
  t:update cluster:0N,corepoint:minpts<=1+count each nbhood from([]nbhood);
  exec cluster from{[t]any t`corepoint}clust.i.dbalgo/t}

clust.i.nbhood:{[data;df;eps;idx]where eps>@[;idx;:;0w]clust.i.dd[df]data-data[;idx]}
clust.i.dbalgo:{[t]update cluster:0|1+max t`cluster,corepoint:0b from t where i in clust.i.nbhoodidxs[t]/[first where t`corepoint]}
clust.i.nbhoodidxs:{[t;idxs]asc distinct idxs,raze exec nbhood from t[distinct idxs,raze t[idxs]`nbhood]where corepoint}
