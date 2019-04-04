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
fresh.feat.longstrikeltmean:{max 0,fresh.getlenseqwhere x<avg x}
fresh.feat.longstrikegtmean:{max 0,fresh.getlenseqwhere x>avg x}
fresh.feat.max:{max x}
fresh.feat.mean:{avg x}
fresh.feat.meanabschange:{avg abs 1_deltas x}
fresh.feat.meanchange:{(x[n]-x 0)%n:-1+count x}
fresh.feat.mean2dercentral:{avg(.5*x+prev p)-p:prev x}
fresh.feat.med:{med x}
fresh.feat.min:{min x}
fresh.feat.numcrossingm:{sum 1_differ x>y}
fresh.feat.numcwtpeaks:{count(fresh.findpeak[x;fresh.arange[1;y+1;1]]`)}                   // 'ricker wavelet specification removed... it is default in find_peak_cwt
fresh.feat.numpeaks:{sum all each flip fresh.peakfind[x;y;]each 1+til y}                   // number of peaks of support y in time series x (peak defined as x[i] larger than y values left and right)
fresh.feat.perrecurtoalldata:{sum[1<g]%count g:count each group x}
fresh.feat.perrecurtoallval:{sum[g where 1<g:count each group x]%count x}                  // ratio of count[reoccuring points]%count points
fresh.feat.quantile:{r[0]+(p-i 0)*last r:0^deltas asc[x]i:0 1+\:floor p:y*-1+count x}
fresh.feat.rangecount:{sum(x>=y)&x<z}
fresh.feat.ratiobeyondrsigma:{avg abs[x-avg x]>y*dev x}
fresh.feat.ratiovalnumtserieslength:{count[distinct x]%count x}
fresh.feat.skewness:{n*sum[m*m*m:x-avg x]%(s*s*s:sdev x)*(n-1)*-2+n:count x}               //
fresh.feat.stddev:{dev x}
fresh.feat.sumrecurringdatapoint:{sum k*g k:where 1<g:count each group x}
fresh.feat.sumrecurringval:{sum where 1<count each group x}
fresh.feat.sumval:{sum x}
fresh.feat.symmetriclooking:{abs[avg[x]-med x]<y*max[x]-min x}
fresh.feat.treverseasymstat:{0^avg x1*(x*x)-x2*x2:xprev[y]x1:xprev[y]x}
fresh.feat.valcount:{sum x=y}
fresh.feat.var:{var x}
fresh.feat.vargtstddev:{1<var x}

/ multi-outputs
fresh.aggdict:``max`min`var`avg!(::;max;min;var;avg)
/ aggregates the data in chunks and then calculates linear properties of the data
fresh.feat.agglintrend:{
 raze{(`$enlist[string y]cross("slope";"intercept";"rval";"p";"stderr"))!
  value fresh.feat.lintrend fresh.aggdict[y]each z cut x}[x;;y]each`max`min`var`avg}

fresh.feat.lintrend:{
 k:1+til count x;df:(n:count k)-2; 
 rnum:cov[k;x];rden:sqrt cov[k;k]*cov[x;x];rval:$[rden=0;0f;rnum%rden];
 slope:rnum%cov[k;k];intercept:avg[x]-slope*avg k-1;
 $[n=2;$[x[0]=x[1];[p:1f;stderr:0f];[p:0f;stderr:0n]];
  [t:rval*sqrt df%(1f-rval+tiny)*1f+rval+tiny:1e-20;
	stderr:sqrt(1-rval*rval)*cov[x;x]%cov[k;k]*df;p:2*fresh.tdistrib[abs t;df]`;]];
 `slope`intercept`rval`p`stderr!slope,intercept,rval,p,stderr
 }
/ outputs from fft (not called yet)
fresh.fftaggreg:{[x] getmoment:{[y;moment](("f"$y)$("f"$fresh.arange[0;count y;1])xexp moment)%(sum y)};
 l:fresh.absolute[fresh.rfft[x]`]`;
 centroid:getmoment[l;1];m2:getmoment[l;2];m3:getmoment[l;3];m4:getmoment[l;4];
 getvariance:{x-(y xexp 2)};
 variance:getvariance[m2;centroid];
 getskew:{[l;y;z;k]$[z<0.5;0n;((k-3*y*z)-(y xexp 3))%(z xexp 1.5)]};
 skew:getskew[l;centroid;variance;m3];
 getkurtosis:{[l;y;z;m2;m3;m4]$[z<0.5;0n;((m4-4*y*m3-3*y)+(6*m2*y*y))%(z xexp 2)]};
 kurtosis:getkurtosis[l;centroid;variance;m2;m3;m4];
 `centroid`variance`skew`kurtosis!centroid,variance,skew,kurtosis}

fresh.feat.partautocorrelation:{[x;lag]
 maxreqlag:max lag;
 n:count x;
 $[(n<=1)|0~maxreqlag;
  paccoeff:(1+maxreqlag)#0n;
 [$[n<=maxreqlag;maxlag:maxreqlag-1;maxlag:maxreqlag];
  paccoeff:fresh.pacf[x;`nlags pykw maxlag;`method pykw `ld]`;
  paccoeff:paccoeff[lag],(max 0,maxreqlag-maxlag)#0n]];
 paccoeff}

fresh.feat.spktwelch:{[x;coeff]
 dict:`freq`pxx!fresh.welch[x]`;
 $[((n:count dict[`pxx])<=max coeff)&(1>count coeff);			 
   [reducedcoeff:coeff where coeff>n;
   notreducedcoeff:coeff except reducedcoeff;
   pxx:dict[`pxx][reducedcoeff],((count notreducedcoeff)#0n)];
 pxx:dict[`pxx][coeff]];
 pxx}

fresh.fkey:`angle`real`imag`abs
fresh.feat.fftcoeff:{[x;y]
 fx:fresh.rfft x;$[y<count k:fresh.angle[fx;`deg pykw 1b]`;
	fresh.fkey!(k y;[fresh.real[fx]`]y;[fresh.imag[fx]`]y;[fresh.abso[fx]`]y);fresh.fkey!4#0n]}
 
/ This function currently needs median,variance,mean and standard deviation to be defined separate to the initial q implementation.
fresh.aggautocorr:{
 n:count x;
 $[((abs var x) < 10 xexp -10) or n=1;a:0;a:1 _fresh.acf[x;`unbiased pykw 1b;`fft pykw n>1250]`];
 `mean`variance`median`dev!(avg a;var a;med a;dev a)}

/ This can be implemented now but is a time consuming calculation (4th behind sample entropy, approx entropy and numcwtpeaks)
fresh.augfuller:{`teststat`pvalue`usedlag!3#@[{fresh.adfuller[x]`};x;0n]}

/ py utils for the above
fresh.tdistrib:.p.import[`scipy.stats]`:t.sf;
fresh.rfft:.p.import[`numpy]`:fft.rfft;
fresh.absolute:.p.import[`numpy]`:abs;
fresh.findpeak:.p.import[`scipy.signal]`:find_peaks_cwt;
fresh.pacf:.p.import[`statsmodels.tsa.stattools]`:pacf
fresh.adfuller:.p.import[`statsmodels.tsa.stattools]`:adfuller
fresh.acf:.p.import[`statsmodels.tsa.stattools]`:acf
fresh.welch:.p.import[`scipy.signal]`:welch
fresh.real:.p.import[`numpy]`:real
fresh.angle:.p.import[`numpy]`:angle
fresh.imag:.p.import[`numpy]`:imag
fresh.abso:.p.import[`numpy]`:abs

/ q utils for the above
fresh.aggonchunk:{y cut x} /x:data;y:agg function;z:chunk length 
fresh.getlenseqwhere:{(1_deltas i,count x)where x i:where differ x}
fresh.arange:{x+z*til ceiling(y-x)%z}                                                      / x until y
fresh.peakfind:{
 xreduced:neg[y] _y _x;
 droproll:{neg[y] _y _z xprev x};
 if[z=1;res:xreduced>droproll[x;y;z];res&:xreduced>droproll[x;y;(neg z)]];
 if[z<>1;res&:xreduced>droproll[x;y;z];res&:xreduced>droproll[x;y;(neg z)]];
 r:res}

/ params
fresh.params:update pnum:{count 1_get[.ml.fresh.feat x]1}each f,pnames:count[i]#(),pvals:count[i]#()from([]f:1_key fresh.feat) 
fresh.params:1!`pnum xasc update valid:pnum=count each pnames from fresh.params
fresh.loadparams:{
 pp:{value each(!).("S=;")0:x}each(!).("S*";"|")0:x;
 fresh.params[([]f:key pp);`pvals]:value each value pp:inter[key pp;exec f from fresh.params]#pp;
 fresh.params[([]f:key pp);`pnames]:key each value pp;
 fresh.params:update valid:pnum=count each pnames from fresh.params where f in key pp;}
fresh.loadparams hsym`$.ml.path,"/fresh/hyperparam.txt"; / load default params

/ feature extraction
/ can make this shorter by ignoring the pnum>0 ?
fresh.createfeatures:{[data;aggs;cnames]
  p1:select from(p:0!select from .ml.fresh.params where valid)where pnum>0;
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
