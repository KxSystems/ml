\d .ml

/ data preprocessing
dropconstant:{f(where 0=var each k)_k:(f:$[tp:99=type x;;flip])x}
minmaxscaler:i.ap{(x-mnx)%max[x]-mnx:min x}
stdscaler   :i.ap{(x-avg x)%dev x}
/ replace +/- 0w with max/min vals
infreplace  :i.ap{@[x;i;:;z@[x;i:where x=y;:;0n]]}/[;-0w 0w;min,max]

/ produce features which are combinations of n features from table x
polytab:{[x;n]flip(`$"_"sv'string c)!prd each x c@:combs[count c:cols x;n]}

/ fill func (zero, median, mean, forward, linear)
filltab:{[t;gc;tc;d]
 if[0=count d;:t];
 t:flip flip[t],(`$string[k],\:"_null")!null t k:key d;
 ![t;();$[count gc,:();gc!gc;0b];@[i.fillmap;`linear;,';tc][d],'k]}

/ fill methods
i.fillmap.zero:{0^x}
i.fillmap.median:{med[x]^x}
i.fillmap.mean:{avg[x]^x}
i.fillmap.forward:{"f"$(x first where not null x)^fills x}
i.fillmap.linear:{[t;v]
 if[2>count i:where not n:null v;:v];
 g:1_deltas[v i]%deltas t i;
 "f"$@[v;n;:;v[i][u]+g[u]*t[n]-t[i]u:0|(i:-1_i)bin n:where n]}

/ encode categorical features using one-hot encoding
onehot1:{d!"f"$x=/:d:asc distinct x}
onehot:{[x;c]
  if[11<>type c,:();c:i.fndcols[x;"s"]];
  flip(c _ flip x),raze{[x;c](`$"_"sv'string c,'key r)!value r:onehot1 x c}/:[x]c}

/ encode categorical features with frequency of category occurrence
freqencode:{[x;c]
  if[11<>type c,:();c:i.fndcols[x;"s"]];
  flip(c _ flip x),(`$string[c],\:"_freq")!{(g%sum g:count each group x)x}each x c}

/ encode categorical features with lexigraphical order
lexiencode:{[x;c]
  if[11<>type c,:();c:i.fndcols[x;"s"]];
  flip(c _ flip x),(`$string[c],\:"_lexi")!{(asc distinct x)?x}each x c}

/ split temporal types into constituents
i.timesplit.d:{update wd:1<dow from update dow:dow mod 7,qtr:1+(mm-1)div 3 from`dow`year`mm`dd!`date`year`mm`dd$/:\:x}
i.timesplit.m:{update qtr:1+(mm-1)div 3 from k!(k:`year`mm)$/:\:x}
i.timesplit[`n`t`v]:{k!(k:`hh`uu`ss)$/:\:x}
i.timesplit.u:{k!(k:`hh`uu)$/:\:x}
i.timesplit[`p`z]:{raze i.timesplit[`d`n]@\:x}
timesplit1:{i.timesplit[`$.Q.t type x]x:raze x}
timesplit:{[x;c]
  if[11<>type c,:();c:i.fndcols[x;"dmntvupz"]];
  flip(c _ flip x),raze{(`$"_"sv'string y,'key r)!value r:timesplit1 x y}/:[x;c]}
