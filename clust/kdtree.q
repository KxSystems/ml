\d .ml

// Create new k-d tree
/* data   = data points in `value flip` format
/* leafsz = number of points per leaf (<2*number of representatives)
/. r      > returns k-d tree structure as a table
clust.kd.newtree:{[data;leafsz]clust.kd.i.tree[data;leafsz]`leaf`left`parent`self`idxs!(0b;0b;0N;0;til count data 0)}

// Find nearest neighhbors in k-d tree
/* tree  = k-d tree table
/* data  = data points in `value flip` format
/* df    = distance function
/* xidxs = points to exclude in search
/* pt    = point to find nearest neighbor for
/. r     > returns nearest neighbor dictionary with closest point, distance, points searched and points to search
clust.kd.nn:{[tree;data;df;xidxs;pt]
 start:`closestPoint`closestDist`xnodes`node!(0N;0w;0#0;clust.kd.i.findleaf[tree;pt;tree 0]);
 2#{[nninfo]not null nninfo[`node;`self]}clust.kd.i.nncheck[tree;data;df;xidxs;pt]/start}

// Create tree table where each row represents a node
/* data   = data points in `value flip` format
/* leafsz = number of points per leaf (<2*number of representatives)
/* node   = dictionary with info for a given node in the tree
/. r      > returns kdtree table
clust.kd.i.tree:{[data;leafsz;node]
 if[leafsz<=.5*count node`idxs;
  chk:xdata<med xdata@:ax:clust.i.imax dvar:var each xdata:data[;node`idxs];
  if[all leafsz<=count each(lIdxs:where chk;rIdxs:where not chk);
   n:count lTree:.z.s[data;leafsz]update left:1b,parent:self,self+1  ,idxs:idxs lIdxs from node;
           rTree:.z.s[data;leafsz]update left:0b,parent:self,self+1+n,idxs:idxs rIdxs from node;
   node:select leaf,left,self,parent,children:self+1+(0;n),axis:ax,midval:"f"$min xdata rIdxs,idxs:0#0 from node;
   :enlist[node],lTree,rTree]];
 enlist select leaf:1b,left,self,parent,children:0#0,axis:0N,midval:0n,idxs from node}

// Search each node and check nearest neighbors
/* tree   = k-d tree table
/* data   = data points in `value flip` format
/* df     = distance function
/* xidxs  = points to exclude in search
/* pt     = point to find nearest neighbor for
/* nninfo = dictionary with nearest neighbor info of a point
/. r      > returns updated nearest neighbor info dictionary
clust.kd.i.nncheck:{[tree;data;df;xidxs;pt;nninfo]
 if[nninfo[`node]`leaf;
   closest:clust.i.closest[data;df;pt]nninfo[`node;`idxs]except xidxs;
   if[closest[`distance]<nninfo`closestDist;
     nninfo[`closestPoint`closestDist]:closest`point`distance;
 ]];
 if[not null childidx:first nninfo[`node;`children]except nninfo`xnodes;
   childidx:$[(nninfo`closestDist)<clust.i.dd[df]pt[nninfo[`node]`axis]-nninfo[`node]`midval;
     0N;clust.kd.i.findleaf[tree;pt;tree childidx]`self
 ]];
 if[null childidx;nninfo[`xnodes],:nninfo[`node]`self];
 nninfo[`node]:tree nninfo[`node;`parent]^childidx;
 nninfo}

// Find the next direction to take in the tree
/* tree = k-d tree table
/* pt   = current point to put in tree
/* node = current node to check
/. r    > returns next direction to take
clust.kd.i.findnext:{[tree;pt;node]tree node[`children]node[`midval]<=pt node`axis}

// Find the leaf node point belongs to
/* tree = k-d tree table
/* pt   = current point to put in tree
/* node = current node to check
/. r    > returns dictionary of leaf node pt belongs to
clust.kd.i.findleaf:{[tree;pt;node]{[node]not node`leaf}clust.kd.i.findnext[tree;pt]/node}

// K-D tree C functions

if[112=type clust.kd.c.findleaf:.[2:;(`:kdnn;(`kd_findleaf;3));::];
 clust.kd.i.findleaf:{[tree;point;node]tree clust.kd.c.findleaf[tree;"f"$point;node`self]}]

if[112=type clust.kd.c.nn:.[2:;(`:kdnn;(`kd_nn;5));::];
 clust.kd.nn:{[tree;data;df;xidxs;pt]`closestPoint`closestDist!clust.kd.c.nn[tree;"f"$data;(1_key clust.i.dd)?df;@[count[data 0]#0b;xidxs;:;1b];"f"$pt]}]
