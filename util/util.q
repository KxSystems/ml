\d .ml
/ data preprocessing
/ these functions all work on unkeyed numeric tables
/drop columns with zero variance (1 value)
util.dropconstant:{(where 0=0^var each flip x)_x}
/ TODO, these should work on the same type of data

util.i.ap:{$[0=type y;x each y;98=type y;flip x each flip y;99<>type y;x y;98=type key y;key[y]!.z.s value y;x each y]}
/ scale data between 0 and 1
util.minmaxscaler:{util.i.ap[{(x-mnx)%max[x]-mnx:min x};x]}
/ remove mean and standardize by standard deviation.
util.stdscaler:{util.i.ap[{(x-avg x)%dev x};x]}

/ replace +/- float infinities with max/min values in the column
util.infreplace:{
 f:{f:{z[x]^x:@[x;where y=x;:;0n]};f[;0w;max]f[;-0w;min]x};
 util.i.ap[f;x]}

/produce features which are combinations of n features from table x
util.polytab:{[x;n]flip(`$ssr[;".";"_"]each string each` sv'c)!prd each x c:util.combs[n;cols x]}
/ fill func,  avg. median, zero, forward, interpolated
/ tab, tcol, gcols, dict
/ dict contains 
/ TODO
util.filltab:{[tab;gcols;tcol;dict]
 if[not 98=t:type tab;'`type];
 fcols:cols[tab]except tcol,gcols,:();
 fm:fcols!count[fcols]#`forward;
 fm,:raze{y!count[y,:()]#x}'[key dict;value dict];
 :![tab;();$[count gcols;gcols!gcols;0b];key[fm]!{(x z;y)}[@[util.i.fillmap;`linear;{y x}tab tcol]]'[key fm;value fm]];
 }
/ fill methods
util.i.fill0:{0.^x}
util.i.fillmed:{med[x]^x}
util.i.fillavg:{avg[x]^x}
util.i.filllin:{[t;v]                 / fill values by linear interpolation/extrapolation
 if[2>count i:where not n:null v;:v]; / can't interpolate/extrapolate without at least 2 points
 g:1_deltas[v i]%deltas t i;
 "f"$@[v;n;:;v[i][u]+g[u]*t[n]-t[i]u:0|(i:-1_i)bin n:where n]}
util.i.fillfwd:{"f"$(x first where not null x)^fills x} / forward fill, then back fill nulls at start
util.i.fillmap:select zero:.ml.util.i.fill0,median:.ml.util.i.fillmed,mean:.ml.util.i.fillavg,linear:.ml.util.i.filllin,forward:.ml.util.i.fillfwd from (0#`)!()

/encode a list of symbols using one-hot encoding
util.onehot:{eye[count d](d:asc distinct x)?x}
/ all combinations of x (distinct) entries from y or til y
util.combs:{$[0>type y;raze(flip enlist flip enlist til y-:x){(x+z){raze x,''y}'x#\:y}[1+til y]/til x-:1;y .z.s[x]count y]}


/ pandas manipulation q tab to df or df to q tab
util.tab2df:{
 r:.p.import[`pandas;`:DataFrame.from_dict;flip 0!x][@;cols x];
 $[count k:keys x;r[`:set_index]k;r]}
util.df2tab:{
 n:$[.p.isinstance[x`:index;.p.import[`pandas]`:RangeIndex]`;0;x[`:index.nlevels]`];
 n!flip $[n;x[`:reset_index][];x][`:to_dict;`list]`}

/split data into train and test datasets where sz is the % of data in test
util.traintestsplit:{[x;y;sz]`xtrain`ytrain`xtest`ytest!raze(x;y)@\:/:(0,floor n*1-sz)_neg[n]?n:count x}
/split data into train and test with an applied random seed to force a certain splitting
util.traintestsplitseed:{[x;y;sz;seed]system"S ",string seed;util.traintestsplit[x;y;sz]}

