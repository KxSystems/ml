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

/ produce features which are combinations of n features from table x
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

/ encode a list of symbols or a table using one-hot encoding
util.onehot:{$[98h~type x;
 [n:util.i.fndcols[x;"s"];$[0=count n;x;{m:(,'/){flip (`$(string[y],"_"),/:string asc distinct l)!flip .ml.util.onehot l:x y}[x]each y;y _ x^m}[x;n]]];
 eye[count d](d:asc distinct x)?x]}

/ all combinations of x (distinct) entries from y or til y
util.combs:{$[0>type y;raze(flip enlist flip enlist til y-:x){(x+z){raze x,''y}'x#\:y}[1+til y]/til x-:1;y .z.s[x]count y]}


/ pandas manipulation q tab to df or df to q tab
util.tab2df:{
 r:.p.import[`pandas;`:DataFrame.from_dict;flip 0!x][@;cols x];
 $[count k:keys x;r[`:set_index]k;r]}
util.df2tab:{
 n:$[.p.isinstance[x`:index;.p.import[`pandas]`:RangeIndex]`;0;x[`:index.nlevels]`];
 n!flip $[n;x[`:reset_index][];x][`:to_dict;`list]`}

/ split data into train and test datasets where sz is the % of data in test
util.traintestsplit:{[x;y;sz]`xtrain`ytrain`xtest`ytest!raze(x;y)@\:/:(0,floor n*1-sz)_neg[n]?n:count x}
/ split data into train and test with an applied random seed to force a certain splitting
util.traintestsplitseed:{[x;y;sz;seed]system"S ",string seed;util.traintestsplit[x;y;sz]}

util.classreport:{[x;y]k:distinct y;rnd2:{0.01*"j"$100*x};
 tab:([]class:`$string each k;
  precision:rnd2 precision[x;y]each k;
  recall:rnd2 sensitivity[x;y]each k;
  f1_score:rnd2 f1score[x;y]each k;
  support:{sum x=y}[y;]each k);
   `class xasc tab,([]class:enlist `$"avg/total";
   precision:enlist avg tab[`precision];
   recall:enlist avg tab[`recall];
   f1_score:enlist avg tab[`f1_score];
   support:sum tab[`support])}

/ convert a timespan into its constituent parts(if no timespan return original table)
util.timespantransform:{n:util.i.fndcols[x;"p"];;
 $[0=count n;x;
    {t:x y;qtr:raze 4#/:1 2 3 4;yr:`year$t;
    mon:`mm$t;q:qtr mon;dom:`dd$t;
    wd:1<dw:(`date$t)mod 7;dow:dw;
    hr:`hh$t;mn:`uu$t;sec:`ss$t;
    nms:raze(,'/)`$("yr_";"qtr_";"mm_";"dom_";"dow_";"wd_";"hr_";"mn_";"sec_"),\:/:string y;
    m:flip nms!yr,q,mon,dom,dow,wd,hr,mn,sec;y _ m^x}[x;n]]}

/ this should is used to fill nulls with avg/med/min/max of the column
/ it also adds columns which encode where nulls for the columns had been
util.nullencode:{[x;y]vals:l k:where 0<sum each l:null each flip x;nms:`$"null_",/:string k;$[0=count k;x;flip y[x]^flip[x],nms!vals]}

/ encode categorical features (symbs) with the frequency of occurrance of individual categories.
util.freqencode:{n:util.i.fndcols[x;"s"];;$[0=count n;x;n _ (^/){ind:?[x;();enlist[y]!enlist y;enlist[`$"freq_",string y]!enlist(%;(count;`i);(count;x))];x lj ind}[x]each n]}

/ label categorical features based on their lexigraphical order (alpha-numeric)
util.lexiencode:{n:util.i.fndcols[x;"s"];nms:`$"lexi_label_",/:string n;vals:{(l!til count l:asc distinct k) k:x y}[x]each n;n _ x^flip nms!vals}

/ util
util.i.fndcols:{?[meta[x];enlist(in;`t;y);();`c]}
