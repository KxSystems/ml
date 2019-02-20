/fresh algorithm implementaion in q
/ https://arxiv.org/pdf/1610.07717v3.pdf 

/embedPy is required

\d .ml 

/ features from raw data, single outputs
fresh.feat.absenergy:{x wsum x}                                                           / absolute energy = sum of squares
fresh.feat.abssumchange:{sum abs 1_deltas x}                                              / sum of absolute values of deltas
fresh.feat.autocorr:{(avg(x-m)*xprev[y;x]-m:avg x)%var x}                                 / x values, y lag 
fresh.feat.binnedentropy:{neg sum p*log p:fresh.hist["f"$x;y][0]%count x}                 / measure of 'chunked' system entropy 
fresh.feat.c3:{0^avg (-2*y) _x*prd xprev\:[-1 -2*y;x]}                                    / measure of t-series non-linearity Schreiber, T. and Schmitz, A. (1997). PHYSICAL REVIEW E, VOLUME 55, NUMBER 5
fresh.feat.changequant:{[x;ql;qh;isabs]	                                                  
 diff:$[isabs;abs;]1_deltas x;
 incor:min (>[x];<[x])@'fresh.feat.quantile[x]each ql,qh;
 k:diff where 1_&':[incor];
 `max`min`mean`variance`median`stdev!(max k;min k;avg k;var k;med k;dev k)}               / mean of changes of series inside corridor
fresh.feat.cidce:{sqrt k$k:"f"$1_deltas$[not y;x;0=s:dev x;:0.;(x-avg x)%s]}              / measure of time series complexity ref- http://www.cs.ucr.edu/~eamonn/Complexity-Invariant%20Distance%20Measure.pdf
fresh.feat.count:{count x}
fresh.feat.countabovemean:{sum x>avg x}						      
fresh.feat.countbelowmean:{sum x<avg x}
/x=data;y=#chunks;z=focus chunk
fresh.feat.eratiobychunk:{val:("i"$floor((count x)%y)) cut x;
 			  [sum valfocus*valfocus:val[z]]%fresh.absenergy[x]} 	           / calculation of energy ratios by chunk
fresh.feat.firstmax:{(x?max x)%count x}                                                    / relative index of first occurence of max value (relative index = i/count x)
fresh.feat.firstmin:{(x?min x)%count x}                                                    / relative index of first occurence of min value
fresh.feat.hasdup:{count[x]<>count distinct x}
fresh.feat.hasdupmax:{1<sum x=max x}
fresh.feat.hasdupmin:{1<sum x=min x}
fresh.feat.indexmassquantile:{(1+(sums[x]%sum x:abs x)binr y)%count x}                     / relative index (into y) where y% of mass of x is to the left
fresh.feat.kurtosis:{((n-1)%(n-2)*n-3)*((n+1)*n*sum[k2*k2]%
		     s*s:sum k2:k*k:x-avg x)+3*1-n:count x} 				   / kurtosis calculation
fresh.feat.largestdev:{dev[x]>y*max[x]-min x}                                              / is standard deviation of x > y * range x ?
fresh.feat.lastmax:{(last where x=max x)%count x}                                          / relative index of last occurence of max value (relative index = i/count x)
fresh.feat.lastmin:{(last where x=min x)%count x}                                          / relative index of last occurence of min value
fresh.feat.longstrikeltmean:{p:max fresh.getlenseqwhere x<avg x;$[p<>-0W;p;0]}             / longest run of values < mean
fresh.feat.longstrikegtmean:{p:max fresh.getlenseqwhere x>avg x;$[p<>-0W;p;0]}             / longest run of values > mean
fresh.feat.max:{max x}
fresh.feat.mean:{avg x}
fresh.feat.meanabschange:{avg abs 1_deltas x}
fresh.feat.meanchange:{(x[n]-x 0)%n:-1+count x}                                            / mean absolute differences between successive t-series values
fresh.feat.mean2dercentral:{avg(.5*sum xprev\:[-1 1;x])-x}                                 / mean value of second derivative of t-series under central approximation
fresh.feat.med:{med x}
fresh.feat.min:{min x}
fresh.feat.numcrossingm:{sum 1_differ x>y}                                                 / x=data;y=threshold, number of times x crosses y, e.g if y=0, number of sign changes of x
fresh.feat.numcwtpeaks:{count(fresh.findpeak[x;fresh.arange[1;y+1;1]]`)}                   / 'ricker wavelet specification removed... it is default in find_peak_cwt
fresh.feat.numpeaks:{sum all each flip fresh.peakfind[x;y;]each 1+til y}                   / number of peaks of support y in time series x (peak defined as x[i] larger than y values left and right)
fresh.feat.perrecurtoalldata:{sum[1<g]%count g:count each group x}                         / ratio of count[distinct values which reoccur]%count distinct values
fresh.feat.perrecurtoallval:{sum[g where 1<g:count each group x]%count x}                  / ratio of count[reoccuring points]%count points
fresh.feat.quantile:{r[0]+(p-i 0)*last r:0^deltas x iasc[x]i:0 1+\:floor p:y*-1+count x}
fresh.feat.rangecount:{sum[[x>=y] and x<z]}                                                /x=data;y=min val;z=max val, TODO x within would be handier if definition does not need to match python
fresh.feat.ratiobeyondrsigma:{sum[abs[x-avg x]>y*dev x]%count x}
fresh.feat.ratiovalnumtserieslength:{count[distinct x]%count x}
fresh.feat.skewness:{n*sum[m*m*m:x-avg x]%(s*s*s:sdev x)*(n-1)*-2+n:count x}
fresh.feat.stddev:dev
fresh.feat.sumrecurringdatapoint:{sum k*g k:where 1<g:count each group x}
fresh.feat.sumrecurringval:{sum where 1<count each group x}
fresh.feat.sumval:{sum x}                                                                  / TODO, this one sums data points not values
fresh.feat.symmetriclooking:{abs[avg[x]-med x]>y*max[x]-min x}                             / distribution looks symmetric
fresh.feat.treverseasymstat:{0^avg(-2*y)_(x1*x2*x2:xprev[-2*y]x)-x*x*x1:xprev[-1*y]x}
fresh.feat.valcount:{sum x=y}
fresh.feat.var:{var x}
fresh.feat.vargtstddev:{1<var x}


/ multi-outputs
fresh.aggdict:``max`min`var`avg!(::;max;min;var;avg)
/ aggregates the data in chunks and then calculates linear properties of the data
fresh.feat.agglintrend:{raze 
			{(`$(enlist string y) cross 
			 ("slope";"intercept";"rval";"p";"stderr"))!value fresh.feat.lintrend fresh.aggdict[y] 
		          each fresh.aggonchunk[x;z]}[x;;y]each `max`min`var`avg}
fresh.feat.lintrend:{
 k:1+til count x;df:(n:count k)-2; 
 rnum:cov[k;x];rden:sqrt cov[k;k]*cov[x;x];rval:$[rden=0;0f;rnum%rden];
 slope:rnum%cov[k;k];intercept:avg[x]-slope*avg k-1;
 $[n=2;$[x[0]=x[1];[p:1f;stderr:0f];[p:0f;stderr:0n]];
  [t:rval*sqrt df%(1f-rval+tiny)*1f+rval+tiny:1e-20;
	stderr:sqrt(1-rval*rval)*cov[x;x]%cov[k;k]*df;p:2*fresh.tdistrib[abs t;df]`;]];
 `slope`intercept`rval`p`stderr!slope,intercept,rval,p,stderr
 }
/ outputs from fft
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
 $[n<=1;
 (1+maxreqlag)#0n;
 [$[n<=maxreqlag;maxlag:maxreqlag-1;maxlag:maxreqlag];
 paccoeff:fresh.pacf[x;`nlags pykw maxlag;`method pykw `ld]`;
 paccoeff:paccoeff[lag],(max 0,maxreqlag-maxlag)#0n]];
 r:({`$"lag_",string x}each lag)!paccoeff}

fresh.feat.spktwelch:{[x;coeff]
 dict:`freq`pxx!fresh.welch[x]`;
  $[(n:count dict[`pxx])<=max coeff;
  [reducedcoeff:coeff where m;notreducedcoeff:coeff except reducedcoeff;
   pxx:dict[`pxx][reducedcoeff],((count notreducedcoeff)#0n)];
 pxx:dict[`pxx][coeff]];
 $[1~count pxx;
 (enlist {`$"coeff_",string x}each coeff)!enlist pxx
  ;({`$"coeff_",string x}each coeff)!pxx]}

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
fresh.augfuller:{
 k:{fresh.adfuller[x]`};
 res:@[k;x;3#0n];
 r:`teststat`pvalue`usedlag!(res[0];res[1];res[2])}


/ utils for the above
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

fresh.aggonchunk:{y cut x} /x:data;y:agg function;z:chunk length 
fresh.getlenseqwhere:{(1_deltas i,count x)where x i:where differ x}
fresh.arange:{x+z*til ceiling(y-x)%z}                                                      / x until y
fresh.hist:{(count each value(asc key g)#g:group(-1_a) bin x;
	a:min[x]+til[1+y]*(max[x]-min x)%y)}                                               / x=data;y=#bins
fresh.peakfind:{
 xreduced:neg[y] _y _x;
 droproll:{neg[y] _y _z xprev x};
 if[z=1;res:xreduced>droproll[x;y;z];res&:xreduced>droproll[x;y;(neg z)]];
 if[z<>1;res&:xreduced>droproll[x;y;z];res&:xreduced>droproll[x;y;(neg z)]];
 r:res}


fresh.getsingleinputfeatures:{where[{1=count x y}[{$[100=type x;get[x]1;()]}]each .ml.fresh.feat]#.ml.fresh.feat}

/ This is a modified version of the feature creation procedure to allow for hyperparameter functions to be run
/ in addition to the functions that take only the data as input
/ if dict set to 0b then compute single input features
/ else the 'safe' input are hyperparameter functions for dict=.ml.i.dict
fresh.createfeatures:{[data;aggs;cnames;dict]
        $[dict~0b;
         fresh.createfeatures1[data;aggs;cnames];
         fresh.createmulfeat[data;aggs;cnames;dict]]}
fresh.createfeatures1:{[data;aggs;cnames]
 mkname:{`$"_"sv string x[0],x 2};
 r:?[data;();aggs!aggs:aggs,();mkname'[comb]!1_'comb:(flip(key;value)@\:.ml.fresh.getsingleinputfeatures[])cross cnames];
 / flatten multi output cols
 if[count mcols@:where 98=type each value[r]mcols:exec c from meta[r]where null t;
  r:key[r]!(mcols _ value r){x,'y}/{(`$"_"sv'string x,'cols y)xcol y}'[mcols;value[r]mcols]];
 r}
fresh.createmulfeat:{[data;aggs;cnames;dict]
 newDict:(!).(key dict;value each value dict)@\:til count dict;
 fnc:{value` sv(`.ml.fresh.feat;x)}each key newDict;
 colnames:raze raze{`$sv'["_";string y,'raze $[1=count z;raze[z];
     1=count distinct count each 0N!z;
     enlist[z];flip[z]],/:\:x]}[cnames]'[key newDict;vDict:value newDict];
 tab:{[col;vD;fnc;feat] col!raze raze  {$[1=count z;
     {{.[y;(x;z)]}[;y;z]each value x}[x;y]each raze z;
     1=count distinct count each z;
     {.[y;(x;z)]}[;y;z]each value x;
     {{.[y;(x;z)]}[;y;z]each value x}[x;y]each flip z]}[feat]'[fnc;vD]}[colnames;vDict;fnc]each ?[data;();aggs;
     $[1=count cnames;enlist[cnames]!enlist cnames;cnames!cnames]];
 fresh.createfeatures1[data;aggs;cnames],'value tab  
 }
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
 (realcols,bincols)!pvals}

fresh.significantfeatures:fresh.benjhochfeat:{[table;targets]fresh.benjhochfind[fresh.sigfeat[table;targets];0.05]}

/ alternate feature selections
fresh.percentilesigfeat:{[table;targets;p]where percentile[k;p]>k:fresh.sigfeat[table;targets]}
fresh.ksigfeat:{[table;targets;k]key k#asc fresh.sigfeat[table;targets]}

/dictionary of features with hyper-parameters
pdictvals:`binnedentropy`cidce`numcrossingm`ratiobeyondrsigma`largestdev`c3`autocorr`indexmassquantile`numcwtpeaks`symmetriclooking`treverseasymstat`quantile
fndict:.ml.fresh.paramdict
i.dict:pdictvals!fndict[pdictvals]
