/ fresh algorithm implementation
/ https://arxiv.org/pdf/1610.07717v3.pdf 
\d .ml 

/ feature functions
fresh.feat.absenergy:{x wsum x}
fresh.feat.abssumchange:{sum abs 1_deltas x}
fresh.feat.autocorr:{(avg(x-m)*xprev[y;x]-m:avg x)%var x}
fresh.feat.binnedentropy:{neg sum p*log p:(count each group(y-1)&floor y*x%max x-:min x)%count x}
/ t-series non-linearity - Schreiber, T. and Schmitz, A. (1997). PHYSICAL REVIEW E, VOLUME 55, NUMBER 5
fresh.feat.c3:{avg x*/xprev\:[-1 -2*y]x}
fresh.feat.changequant:{[x;ql;qh;isabs]
 k:($[isabs;abs;]1_deltas x)where 1_&':[x within fresh.feat.quantile[x]ql,qh];
 `max`min`mean`variance`median`stdev!(max;min;avg;var;med;dev)@\:k}
/ time series complexity - http://www.cs.ucr.edu/~eamonn/Complexity-Invariant%20Distance%20Measure.pdf
fresh.feat.cidce:{sqrt k$k:"f"$1_deltas$[not y;x;0=s:dev x;:0.;(x-avg x)%s]}
fresh.feat.count:{count x}
fresh.feat.countabovemean:{sum x>avg x}
fresh.feat.countbelowmean:{sum x<avg x}
fresh.feat.eratiobychunk:{(`$"_"sv'string`chunk,'til[y],'y)!k$'k:((y;0N)#x)%x wsum x}
fresh.feat.firstmax:{(x?max x)%count x}
fresh.feat.firstmin:{(x?min x)%count x}
fresh.feat.hasdup:{count[x]<>count distinct x}
fresh.feat.hasdupmax:{1<sum x=max x}
fresh.feat.hasdupmin:{1<sum x=min x}
fresh.feat.indexmassquantile:{(1+(sums[x]%sum x:abs x)binr y)%count x}
fresh.feat.kurtosis:{((n-1)%(n-2)*n-3)*(3*1-n)+n*(1+n:count x)*sum[k*k]%s*s:sum k*:k:x-avg x}
fresh.feat.largestdev:{dev[x]>y*max[x]-min x}
fresh.feat.lastmax:{(last where x=max x)%count x}
fresh.feat.lastmin:{(last where x=min x)%count x}
fresh.feat.longstrikeltmean:{max 0,fresh.i.getlenseqwhere x<avg x}
fresh.feat.longstrikegtmean:{max 0,fresh.i.getlenseqwhere x>avg x}
fresh.feat.max:{max x}
fresh.feat.mean:{avg x}
fresh.feat.meanabschange:{avg abs 1_deltas x}
fresh.feat.meanchange:{(x[n]-x 0)%n:-1+count x}
fresh.feat.mean2dercentral:{avg(.5*x+prev p)-p:prev x}
fresh.feat.med:{med x}
fresh.feat.min:{min x}
fresh.feat.numcrossingm:{sum 1_differ x>y}
fresh.feat.numcwtpeaks:{count fresh.i.findpeak[x;1+til y]`}
fresh.feat.numpeaks:{sum all fresh.i.peakfind[x;y;]each 1+til y}
fresh.feat.perrecurtoalldata:{sum[1<g]%count g:count each group x}
fresh.feat.perrecurtoallval:{sum[g where 1<g:count each group x]%count x}
fresh.feat.quantile:{r[0]+(p-i 0)*last r:0^deltas asc[x]i:0 1+\:floor p:y*-1+count x}
fresh.feat.rangecount:{sum(x>=y)&x<z}
fresh.feat.ratiobeyondrsigma:{avg abs[x-avg x]>y*dev x}
fresh.feat.ratiovalnumtserieslength:{count[distinct x]%count x}
fresh.feat.skewness:{n*sum[m*m*m:x-avg x]%(s*s*s:sdev x)*(n-1)*-2+n:count x}
fresh.feat.stddev:{dev x}
fresh.feat.sumrecurringdatapoint:{sum k*g k:where 1<g:count each group x}
fresh.feat.sumrecurringval:{sum where 1<count each group x}
fresh.feat.sumval:{sum x}
fresh.feat.symmetriclooking:{abs[avg[x]-med x]<y*max[x]-min x}
fresh.feat.treverseasymstat:{0^avg x1*(x*x)-x2*x2:xprev[y]x1:xprev[y]x}
fresh.feat.valcount:{sum x=y}
fresh.feat.var:{var x}
fresh.feat.vargtstddev:{1<var x}
fresh.feat.lintrend:{`rval`intercept`slope!0^(xk%sqrt vk*var x;avg[x]-b*avg k;b:(xk:x cov k)%vk:var k:til count x)}
fresh.feat.agglintrend:{
 t:fresh.feat.lintrend each(max;min;var;avg)@/:\:y cut x;
 (`$"_"sv'string cols[t]cross`max`min`var`avg)!raze value flip t}
fresh.feat.partautocorrelation:{
 (`$"lag_",/:string 1+til y)!y#$[1>mx:y&count[x]-1;();1_fresh.i.pacf[x;`nlags pykw mx;`method pykw`ld]`],y#0n}
fresh.feat.fftcoeff:{
 r:(fresh.i.angle[fx;`deg pykw 1b]`;fresh.i.real[fx]`;fresh.i.imag[fx]`;fresh.i.abso[fx:fresh.i.rfft x]`);
 (`$"_"sv'string raze(`coeff,/:til y),\:/:`angle`real`imag`abs)!raze y#'r,\:y#0n}
fresh.feat.augfuller:{`teststat`pvalue`usedlag!3#@[{fresh.i.adfuller[x]`};x;0n]} / expensive
fresh.feat.spktwelch:{fresh.i.welch[x][@;1][@;y]`}
/ Currently needs median,variance,mean,stddev defined separate to initial q implementation
fresh.feat.aggautocorr:{
 a:$[(abs[var x]<1e-10)|1=n:count x;0;1_fresh.i.acf[x;`unbiased pykw 1b;`fft pykw n>1250]`];
 `mean`variance`median`dev!(avg;var;med;dev)@\:a}
fresh.feat.fftaggreg:{
 m:1.,(sum each a*/:3(l*)\l:til count a)%sum a:fresh.i.abso[fresh.i.rfft x]`;
 v:m[2]-m[1]*m[1];
 s:$[v<.5;0n;((m[3]-3*m[1]*v)-m[1]*m[1]*m 1)%v xexp 1.5];
 k:$[v<.5;0n;((m[4]-4*m[1]*m[3]-3*m 1)+6*m[2]*m[1]*m 1)%v*v];
 `centroid`variance`skew`kurtosis!(m 1;v;s;k)}

/ py utils
fresh.i.rfft :.p.import[`numpy]`:fft.rfft
fresh.i.real :.p.import[`numpy]`:real
fresh.i.angle:.p.import[`numpy]`:angle
fresh.i.imag :.p.import[`numpy]`:imag
fresh.i.abso :.p.import[`numpy]`:abs
fresh.i.acf     :.p.import[`statsmodels.tsa.stattools]`:acf
fresh.i.pacf    :.p.import[`statsmodels.tsa.stattools]`:pacf
fresh.i.adfuller:.p.import[`statsmodels.tsa.stattools]`:adfuller
fresh.i.welch   :.p.import[`scipy.signal]`:welch
fresh.i.findpeak:.p.import[`scipy.signal]`:find_peaks_cwt

/ q utils
fresh.i.getlenseqwhere:{(1_deltas i,count x)where x i:where differ x}
fresh.i.peakfind:{neg[y]_y _min x>/:xprev\:[-1 1*z]x}
fresh.i.getmoment:{[x;m](("f"$x)$("f"$til count x)xexp m)%sum x}

/ params
fresh.params:update pnum:{count 1_get[.ml.fresh.feat x]1}each f,pnames:count[i]#(),pvals:count[i]#()from([]f:1_key fresh.feat) 
fresh.params:1!`pnum xasc update valid:pnum=count each pnames from fresh.params
fresh.loadparams:{
 pp:{(raze value@)each(!).("S=;")0:x}each(!).("S*";"|")0:x;
 fresh.params[([]f:key pp);`pvals]:value each value pp:inter[key pp;exec f from fresh.params]#pp;
 fresh.params[([]f:key pp);`pnames]:key each value pp;
 fresh.params:update valid:pnum=count each pnames from fresh.params where f in key pp;}
fresh.loadparams hsym`$.ml.path,"/fresh/hyperparam.txt"; / default params

/ feature extraction
fresh.createfeatures:{[data;aggs;cnames;conf]
  p1:select from(p:0!select from conf where valid)where pnum>0;
  calcs:cnames cross(exec f from p where pnum=0),raze p1[`f]cross'p1[`pnames],'/:'(cross/)each p1`pvals;
  colnames:`$ssr[;".";"o"]each"_"sv'string raze each calcs;
  r:?[data;();aggs!aggs:aggs,();colnames!flip[(.ml.fresh.feat calcs[;1];calcs[;0])],'(last each)each 2_'calcs];
  1!{[r;c]![r;();0b;enlist c],'(`$"_"sv'string c,'cols t)xcol t:r c}/[0!r;exec c from meta[r]where null t]}

/ feature significance
fresh.sigfeat:{[table;targets]
 table:(where 0=var each flip table)_table;
 bintest:{2=count distinct x};
 bintarget:bintest targets;
 bincols:where bintest each flip table;
 realcols:cols[table]except bincols;
 bintab:table[bincols];
 realtab:table[realcols];
 pvals:raze$[bintarget;
 {y[x;]each z}[targets]'[fresh.ks2samp,fresh.fishertest;(realtab;bintab)];
 {y[x;]each z}[targets]'[fresh.ktaupy,fresh.ks2samp;(realtab;bintab)]];
 (realcols,bincols)!pvals
 }

fresh.significantfeatures:fresh.benjhochfeat:{[table;targets]fresh.benjhochfind[fresh.sigfeat[table;targets];0.05]}

//applies the significant features(sigfeats) to a table t filtering by the id column
fresh.sigfeatvals:{[t;sigfeat;id]
  split:{vs["_";string x]}each sigfeat;
  featidx:{where x like"feat*"}each split;
  feat:raze`${x y}'[split;featidx];
  func:{x _ first y}'[split;featidx];
  extFunc:{x[0]:".ml.fresh.feat.",x 0;x}each func;
  featDict:(!).(feat;extFunc);

  vals:{[sig;x;y;z] flip sig!enlist each{[x;y;z]base:(first y;x z);
   $[1>=count y;value base;
    $[-11h~type y[1]:{@[value;x;`$x]}y[1];[r:value base;r y 1];value base,y 1]]
   }[z]'[x;y]}[sigfeat;value featDict;key featDict]each {?[x;enlist(=;y;enlist z);0b;()]}[t;id]each idcol:distinct idcol:t id;

  (flip (enlist id)!enlist idcol)!raze vals}

/ alternate feature selections
fresh.percentilesigfeat:{[table;targets;p]where percentile[k;p]>k:fresh.sigfeat[table;targets]}
fresh.ksigfeat:{[table;targets;k]key k#asc fresh.sigfeat[table;targets]}
