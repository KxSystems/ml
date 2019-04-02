\d .ml

/ shape of matrix/table
shape:{-1_count each first scan x}
/ values between x and y in steps of length z
arange:{x+z*til ceiling(y-x)%z}
/ z evenly spaced values between x and y
linspace:{x+til[z]*(y-x)%z-1}
/ identity matrix
eye:{@[x#0.;;:;1.]each til x}

util.i.ap:{$[0=type y;x each y;98=type y;flip x each flip y;99<>type y;x y;98=type key y;key[y]!.z.s value y;x each y]}
util.i.fndcols:{m[`c]where(m:0!meta x)[`t]in y}

/ q tab to pandas dataframe
util.tab2df:{
 r:.p.import[`pandas;`:DataFrame.from_dict;flip 0!x][@;cols x];
 $[count k:keys x;r[`:set_index]k;r]}
/ pandas dataframe to q tab
util.df2tab:{
 n:$[.p.isinstance[x`:index;.p.import[`pandas]`:RangeIndex]`;0;x[`:index.nlevels]`];
 n!flip $[n;x[`:reset_index][];x][`:to_dict;`list]`}

/ combinations of k elements from 0,1,...,n-1
util.combs:{[n;k]flip(k-1){[n;x]j@:i:where 0<>k:n-j:1+last x;(x@\:where k),enlist -1_sums@[(1+sum k i)#1;0,sums k i;:;(j,0)-0,-1+j+k i]}[n]/enlist til n}

/ split into train/test sets with sz% in test
util.traintestsplit:{[x;y;sz]`xtrain`ytrain`xtest`ytest!raze(x;y)@\:/:(0,floor n*1-sz)_neg[n]?n:count x}