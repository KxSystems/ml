\d .ml

// K-Dimensional (k-d) Tree

// @kind function
// @category clust
// @fileoverview Create new k-d tree
// @param data   {float[][]} Points in `value flip` format
// @param leafsz {long}      Number of points per leaf (<2*number of reppts)
// @return       {table}     k-d tree
clust.kd.newtree:{[data;leafsz]
  args:`leaf`left`parent`self`idxs!(0b;0b;0N;0;til count data 0);
  clust.kd.i.tree[data;leafsz]args
  }

// @kind function
// @category clust
// @fileoverview Find nearest neighhbors in k-d tree
// @param tree  {table}     k-d tree
// @param data  {float[][]} Points in `value flip` format
// @param df    {fn}        Distance function
// @param xidxs {long[][]}  Points to exclude in search
// @param pt    {long[]}    Point to find nearest neighbor for
// @return      {dict}      Nearest neighbor dictionary with closest point,
//   distance, points searched and points to search
clust.kd.q.nn:clust.kd.nn:{[tree;data;df;xidxs;pt]
  nninit:(0N;0w;0#0;clust.kd.findleaf[tree;pt;tree 0]);
  start:`closestPoint`closestDist`xnodes`node!nninit;
  stop:{[nninfo]not null nninfo[`node;`self]};
  2#stop clust.kd.i.nncheck[tree;data;df;xidxs;pt]/start
  }

// @kind function
// @category private
// @fileoverview Create tree table where each row represents a node
// @param data   {float[][]} Points in `value flip` format
// @param leafsz {long}      Points per leaf (<2*number of representatives)
// @param node   {dict}      Info for a given node in the tree
// @return       {table}     k-d tree table
clust.kd.i.tree:{[data;leafsz;node]
  if[leafsz<=.5*count node`idxs;
    chk:xdata<med xdata@:ax:imax dvar:var each xdata:data[;node`idxs];
    if[all leafsz<=count each(lIdxs:where chk;rIdxs:where not chk);
	  lnode:update left:1b,parent:self,self+1,idxs:idxs lIdxs from node;
      n:count lTree:.z.s[data;leafsz]lnode;
	  rnode:update left:0b,parent:self,self+1+n,idxs:idxs rIdxs from node;
      rTree:.z.s[data;leafsz]rnode;
      node:select leaf,left,self,parent,children:self+1+(0;n),axis:ax,
	    midval:"f"$min xdata rIdxs,idxs:0#0 from node;
      :enlist[node],lTree,rTree
	]
  ];
  enlist select leaf:1b,left,self,parent,children:0#0,axis:0N,midval:0n,idxs from node
  }

// @kind function
// @category private
// @fileoverview Search each node and check nearest neighbors
// @param tree   {table}     k-d tree table
// @param data   {float[][]} Points in `value flip` format
// @param df     {fn}        Distance function
// @param xidxs  {long[][]}  Points to exclude in search
// @param pt     {long[]}    Point to find nearest neighbor for
// @param nninfo {dict}      Nearest neighbor info of a point
// @return       {dict}      Updated nearest neighbor info
clust.kd.i.nncheck:{[tree;data;df;xidxs;pt;nninfo]
  if[nninfo[`node]`leaf;
    closest:clust.i.closest[data;df;pt]nninfo[`node;`idxs]except xidxs;
    if[closest[`distance]<nninfo`closestDist;
      nninfo[`closestPoint`closestDist]:closest`point`distance;
    ]
  ];
  if[not null childidx:first nninfo[`node;`children]except nninfo`xnodes;
    nndist:clust.i.dd[df]pt[nninfo[`node]`axis]-nninfo[`node]`midval;
    childidx:$[(nninfo`closestDist)<nndist;
      0N;
	  clust.kd.findleaf[tree;pt;tree childidx]`self
    ]
  ];
  if[null childidx;nninfo[`xnodes],:nninfo[`node]`self];
  nninfo[`node]:tree nninfo[`node;`parent]^childidx;
  nninfo
  }

// @kind function
// @category private
// @fileoverview Find the next direction to take in the tree
// @param tree {table}   k-d tree table
// @param pt   {float[]} Current point to put in tree
// @param node {dict}    Current node to check
// @return     {long}    Next direction to take
clust.kd.i.findnext:{[tree;pt;node]
  tree node[`children]node[`midval]<=pt node`axis
  }

// @kind function
// @category private
// @fileoverview Find the leaf node point belongs to
// @param tree {table}   k-d tree table
// @param pt   {float[]} Current point to put in tree
// @param node {dict}    Current node to check
// @return     {dict}    Leaf node pt belongs to
clust.kd.q.findleaf:clust.kd.findleaf:{[tree;pt;node]
  {[node]not node`leaf}clust.kd.i.findnext[tree;pt]/node
  }

// @kind function
// @category private
// @fileoverview Sets k-d tree q or C functions
// @param b {bool} Type of code to use q or C (1/0b)
// @return  {null} No return. Updates nn and findleaf functions.
clust.kd.qC:{[b]
  clust.kd.c.nn:.[2:;(`:kdnn;(`kd_nn;5));::];
  clust.kd.c.findleaf:.[2:;(`:kdnn;(`kd_findleaf;3));::];
  cnn:{[tree;data;df;xidxs;pt]
    args:(tree;"f"$data;(1_key clust.i.dd)?df;@[count[data 0]#0b;xidxs;:;1b];"f"$pt);
    `closestPoint`closestDist!clust.kd.c.nn . args
    };
  cfl:{[tree;point;node]
    tree clust.kd.c.findleaf[tree;"f"$point;node`self]
    };
  fntyp:not(112=type clust.kd.c.nn)&112=type clust.kd.c.findleaf;
  clust.kd[`nn`findleaf]:$[b|fntyp;(clust.kd.q.nn;clust.kd.q.findleaf);(cnn;cfl)]
  }

// Default to C implementations

clust.kd.qC[0b];
