\d .ml

util.i.ap:{$[0=type y;x each y;98=type y;flip x each flip y;99<>type y;x y;98=type key y;key[y]!.z.s value y;x each y]}
util.i.fndcols:{m[`c]where(m:0!meta x)[`t]in y}

/ data preprocessing
util.dropconstant:{f(where 0=var each k)_k:(f:$[tp:99=type x;;flip])x}
util.minmaxscaler:util.i.ap{(x-mnx)%max[x]-mnx:min x}
util.stdscaler   :util.i.ap{(x-avg x)%dev x}
/ replace +/- 0w with max/min vals
util.infreplace  :util.i.ap{@[x;i;:;z@[x;i:where x=y;:;0n]]}/[;-0w 0w;min,max]

/ produce features which are combinations of n features from table x
util.polytab:{[x;n]flip(`$"_"sv'string c)!prd each x c@:util.combs[count c:cols x;n]}

/ fill func (zero, median, mean, forward, linear)
util.filltab:{[t;gc;tc;d]
 if[0=count d;:t];
 t:flip flip[t],(`$string[k],\:"_null")!null t k:key d;
 ![t;();$[count gc,:();gc!gc;0b];@[util.i.fillmap;`linear;,';tc][d],'k]}

/ fill methods
util.i.fillmap.zero:{0^x}
util.i.fillmap.median:{med[x]^x}
util.i.fillmap.mean:{avg[x]^x}
util.i.fillmap.forward:{"f"$(x first where not null x)^fills x}
util.i.fillmap.linear:{[t;v]
 if[2>count i:where not n:null v;:v];
 g:1_deltas[v i]%deltas t i;
 "f"$@[v;n;:;v[i][u]+g[u]*t[n]-t[i]u:0|(i:-1_i)bin n:where n]}

/ encode categorical features using one-hot encoding
util.onehot1:{d!"f"$x=/:d:asc distinct x}
util.onehot:{[x;c]
  if[11<>type c,:();c:util.i.fndcols[x;"s"]];
  flip(c _ flip x),raze{[x;c](`$"_"sv'string c,'key r)!value r:util.onehot1 x c}/:[x]c}

/ encode categorical features with frequency of category occurrence
util.freqencode:{[x;c]
  if[11<>type c,:();c:util.i.fndcols[x;"s"]];
  flip(c _ flip x),(`$string[c],\:"_freq")!{(g%sum g:count each group x)x}each x c}

/ encode categorical features with lexigraphical order
util.lexiencode:{[x;c]
  if[11<>type c,:();c:util.i.fndcols[x;"s"]];
  flip(c _ flip x),(`$string[c],\:"_lexi")!{(asc distinct x)?x}each x c}

/ convert temporal types into constituents
util.i.timesplit.d:{update wd:1<dow from update dow:dow mod 7,qtr:1+(mm-1)div 3 from`dow`year`mm`dd!`date`year`mm`dd$/:\:x}
util.i.timesplit.m:{update qtr:1+(mm-1)div 3 from k!(k:`year`mm)$/:\:x}
util.i.timesplit[`n`t`v]:{k!(k:`hh`uu`ss)$/:\:x}
util.i.timesplit.u:{k!(k:`hh`uu)$/:\:x}
util.i.timesplit[`p`z]:{raze util.i.timesplit[`d`n]@\:x}
util.timesplit1:{util.i.timesplit[`$.Q.t type x]x:raze x}
util.timesplit:{[x;c]
  if[11<>type c,:();c:util.i.fndcols[x;"dmntvupz"]];
  flip(c _ flip x),raze{(`$"_"sv'string y,'key r)!value r:util.timesplit1 x y}/:[x;c]}

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

util.classreport:{[x;y]
 t:`precision`recall`f1_score`support!((precision;sensitivity;f1score;{sum y=z}).\:(x;y))@/:\:k:asc distinct y;
 ([]class:`$string[k],enlist"avg/total")!flip[t],(avg;avg;avg;sum)@'t}
