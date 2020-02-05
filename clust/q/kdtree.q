\d .ml

/----Tree functions----\

/Build a k-d tree
/* d = data points
/* r = value restricting how many datapoints can be held per leaf within the tree (<=2*r)
clust.kd.buildtree:{[d;r]clust.kd.create[clust.kd.pivot[d;r];-1;1;0b;til count d 0]}

/Each nearest neighbouring cluster and corresponding distance
/* rp = representative points 
/* t  = k-d tree
/* cl = list linking points to their clusters
/* df = distance function/metric
clust.kd.nnc:{[rp;t;cl;d;df]
 u:{(x[y 0];y 1)}[cl]each clust.kd.i.nns[;t;cl;d;df]each rp;
 raze u clust.i.imin u[;1]}

/Search where the point belongs to in the tree
/* x = tree
/* y = point to search
/* z = node in tree to start search
clust.kd.searchfrom:{
 {not x y}[x 2]clust.i.findl[y;x]/z}

/----Utilities----\

/Return kd-tree:(parent;isleft;isleaf;children|datainds;pivotvalue;pivotaxis)
/* f    = function -> clust.kd.pivot[d;r;] used above
/* p    = parent node
/* o    = 1, added to parent index, loop counter
/* left = boolean flag for left or right
/* idx  = data index
clust.kd.create:{[f;p;o;left;idx]
 if[1b~u:f idx;:enlist each(p;left;1b;idx;0n;0N)]; / leaf node
 l:.z.s[f;p+o;1;1b;u[0;0]];                        / left subtree
 r:.z.s[f;p+o;1+count l 0;0b;u[0;1]];              / right subtree
 (p;left;0b;enlist p+o+1+0,count l 0;u[1;0];u[1;1]),'l,'r}

/Return 1b if at a leaf or if all datapoints are a repeated value, or ((leftinds;rightinds);(pivot value;pivot axis)) if we can split further
clust.kd.pivot:{[d;r;idx]                                                
 if[count[idx]<=2*r;:1b];
 axis:clust.i.imax var each d[;idx];
 // Get the values of the datapoints at the defined splitting axis
 // bin these points based on the average of their 2 midpoints values
 pivi:usi bin piv:avg(usi:u si:iasc u)floor .5*-1 0+count u:d[axis;idx];
 if[pivi in -1+0,count usi;:1b];
 // Split points into the left and right branches
 u:(0,pivi+1)cut idx si;
 piv:min d[axis;u 1];
 (u;piv,axis)}

/nearest neighbours search
clust.kd.i.nns:{[rp;t;cl;d;df]
 clt:where cl=cl rp;
 leaves:(raze lst wi:where rp in'lst:(t 3)v:where t 2)except clt;
 lmin:$[count leaves;clust.i.calc[df;rp;leaves;d];(rp;0w)];
 sp:$[count v wi;v wi;clust.kd.searchfrom[t;d rp;0]];
 ({0<=first x 0}clust.kd.i.nn[t;df;rp;d;clt]/(par;lmin;(sp),par:t[0]sp))[1]}
 

/calculating distances in the tree to get nearest neighbour
/* cp = points in the same cluster as rp
/* l  = list with (next node to be search;closest point and distance;points already searched)
clust.kd.i.nn:{[t;df;rp;d;cp;l]
 dist:{not min x[2;y]}[t]clust.i.axdist[t;l[1;1];raze l 2;df;rp;;d]/first l 0;
 bdist:$[0=min(count nn:raze[t[3;dist]]except cp;count dist);l 1;
         first[l[1;1]]>m:min mm:raze clust.i.dc[df;d;nn;rp];(nn mm?m;m);l 1];
 (t[0]l 0;bdist;l[2],l 0)}
