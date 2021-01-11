\d .ml

// FRESH feature extraction functions

// @kind function
// @category fresh
// @fileoverview Calculate the absolute energy of data (sum of squares)
// @param data {(int;long;float)[]} List of data points
// @return {float} Sum of squares
fresh.feat.absenergy:{[data]
  data wsum data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the absolute sum of the differences between successive data points
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Absolute sum of the differences between successive data points within data
fresh.feat.abssumchange:{[data]
  sum abs 1_deltas data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the aggregation of an auto-correlation over all possible lags (1 - count[x]) 
// @param data {(int;long;float)[]} List of data points
// @return {dict} Aggregation (mean, median, variance and standard deviation) of an auto-correlation
fresh.feat.aggautocorr:{[data]
  n:count data;
  ac:fresh.i.acf[data;`unbiased pykw 1b;`fft pykw n>1250]`;
  a:$[(abs[var data]<1e-10)|1=n;0;1_ac];
  `mean`variance`median`dev!(avg;var;med;dev)@\:a
  }

// @kind function
// @category fresh
// @fileoverview
// @param data {(int;long;float)[]} List of data points
// @param chunkLen {long} Size of chunk to apply
// @return {dict} Slope, intercept and rvalue for the series over aggregated max, min, variance or average for chunks of size chunklen
fresh.feat.agglintrend:{[data;chunkLen]
  t:fresh.feat.lintrend each(max;min;var;avg)@/:\:chunkLen cut data;
  (`$"_"sv'string cols[t]cross`max`min`var`avg)!raze value flip t
  }

// @kind function
// @category fresh
// @fileoverview Hypothesis test to check for a unit root in series
// @param data {(int;long;float)[]} List of data points
// @return {dict} Test statistic, p-value and used lag
fresh.feat.augfuller:{[data]
  `teststat`pvalue`usedlag!3#"f"$@[{fresh.i.adfuller[x]`};data;0n]
  }

// @kind function
// @category fresh
// @fileoverview Apply auto-correlation over a user-specified lag
// @param data {(int;long;float)[]} List of data points
// @param lag {long} Lag to apply to data
// @return {float} Auto-correlation over specified lag
fresh.feat.autocorr:{[data;lag]
  $[lag=0;1f;(avg(data-m)*xprev[lag;data]-m:avg data)%var data]
  }

// @kind function
// @category fresh
// @fileoverview Calculate entropy for data binned into n equi-distant bins
// @param data {(int;long;float)[]} List of data points
// @params numBins {long} Number of bins to apply to data
// @return {float} Entropy of the series binned into nbins equidistant bins
fresh.feat.binnedentropy:{[data;numBins]
  p:(count each group(numBins-1)&floor numBins*data%max data-:min data)%count data;
  neg sum p*log p
  }

// @kind function
// @category fresh
// @fileoverview Calculate non-linearity of a time series with lag applied
// @param data {(int;long;float)[]} List of data points
// @param lag {long} Lag to apply to data
// @return {float} Measure of the non-linearity of the series lagged by lag
// Time series non-linearity: Schreiber, T. and Schmitz, A. (1997). PHYSICAL REVIEW E, VOLUME 55, NUMBER 5
fresh.feat.c3:{[data;lag]
  avg data*/xprev\:[-1-2*lag]data
  }

// @kind function
// @category fresh
// @fileoverview Calculate aggregate value of successive changes within corridor
// @param data {(int;long;float)[]} List of data points
// @param lowerQuant {float} Lower quartile
// @param upperQuant {float} Upper quartile
// @param isAbs {boolean} Whether absolute values should be considered
// @return {dict} Aggregated value of successive changes within corridor specified by lower/upperQuant
fresh.feat.changequant:{[data;lowerQuant;upperQuant;isAbs]
  quants:fresh.feat.quantile[data]lowerQuant,upperQuant;
  k:($[isAbs;abs;]1_deltas data)where 1_&':[data within quants];
  `max`min`mean`variance`median`stdev!(max;min;avg;var;med;dev)@\:k
  }

// @kind function
// @category fresh
// @fileoverview Calculated complexity of time series based on peaks and troughs in the dataset
// @param data {(int;long;float)[]} List of data points
// @param isAbs {boolean} Whether absolute values should be considered
// @return {float} Measure of series complexity
// Time series complexity - http://www.cs.ucr.edu/~eamonn/Complexity-Invariant%20Distance%20Measure.pdf
fresh.feat.cidce:{[data;isAbs]
  sqrt k$k:"f"$1_deltas$[not isAbs;data;0=s:dev data;:0.;(data-avg data)%s]
  }

// @kind function
// @category fresh
// @fileoverview Count of values in data
// @param data {(int;long;float)[]} List of data points
// @return {long} Number of values within the series
fresh.feat.count:{[data]
  count data
  }

// @kind function
// @category fresh
// @fileoverview Values greater than the average value
// @param data {(int;long;float)[]} List of data points
// @return {int} Number of values in the series with a value greater than the mean
fresh.feat.countabovemean:{[data]
  sum data>avg data
  }

// @kind function
// @category fresh
// @fileoverview Values less than the average value
// @param data {(int;long;float)[]} List of data points
// @return {int} Number of values in the series with a value less than the mean
fresh.feat.countbelowmean:{[data]
  sum data<avg data
  }

// @kind function
// @category fresh
// @fileoverview Ratio of absolute energy by chunk
// @param data {(int;long;float)[]} List of data points
// @param numSeg {long} Number of segments to split data into
// @return {dict} Sum of squares of each region of the series split into n segments, divided by the absolute energy
fresh.feat.eratiobychunk:{[data;numSeg]
  k:((numSeg;0N)#data)%fresh.feat.absenergy data;
  (`$"_"sv'string`chunk,'til[numSeg],'numSeg)!k$'k
  }

// @kind function
// @category fresh
// @fileoverview Position of first max relative to the series length
// @param data {(int;long;float)[]} List of data points
// @return {float} Position of the first occurrence of the maximum value in the series relative to the series length
fresh.feat.firstmax:{[data]
  (data?max data)%count data
  }

// @kind function
// @category fresh
// @fileoverview Position of first min relative to the series length
// @param data {(int;long;float)[]} List of data points
// @return {float} Position of the first occurrence of the minimum value in the series relative to the series length
fresh.feat.firstmin:{[data]
  (data?min data)%count data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the mean, variance, skew and kurtosis of the absolute Fourier-transform spectrum of data
// @param data {(int;long;float)[]} List of data points
// @return {dict} Spectral centroid, variance, skew and kurtosis
fresh.feat.fftaggreg:{[data]
  a:fresh.i.abso[fresh.i.rfft data]`;
  l:"f"$til count a;
  mean:1.,(sum each a*/:3(l*)\l)%sum a;
  m1:mean 1;m2:mean 2;m3:mean 3;m4:mean 4;
  variance:m2-m1*m1;
  cond:variance<.5;
  skew:$[cond;0n;((m3-3*m1*variance)-m1*m1*m1)%variance xexp 1.5];
  kurtosis:$[cond;0n;((m4-4*m1*m3-3*m1)+6*m2*m1*m1)%variance*variance];
  `centroid`variance`skew`kurtosis!(m1;variance;skew;kurtosis)
  }

// @kind function
// @category fresh
// @fileoverview Calculate the fast-fourier transform coefficient of a series
// @param data {(int;long;float)[]} List of data points
// @param coeff {}
// @return {} FFT coefficient given real inputs and extracting real, imaginary, absolute and angular components
fresh.feat.fftcoeff:{[data;coeff]
  r:(fresh.i.angle[fx;`deg pykw 1b]`;
    fresh.i.real[fx]`;
    fresh.i.imag[fx]`;
    fresh.i.abso[fx:fresh.i.rfft data]`
    );
  (`$"_"sv'string raze(`coeff,/:til coeff),\:/:`angle`real`imag`abs)!
    raze coeff#'r,\:coeff#0n
  }

// @kind function
// @category fresh
// @fileoverview Check if duplicates present
// @param data {(int;long;float)[]} List of data points
// @return {boolean} Series contains any duplicate values
fresh.feat.hasdup:{[data]
  count[data]<>count distinct data
  }

// @kind function
// @category fresh
// @fileoverview Check for duplicate of maximum value within a series
// @param data {(int;long;float)[]} List of data points
// @return {boolean} Does data contain a duplicate of the maximum value
fresh.feat.hasdupmax:{[data]
  1<sum data=max data
  }

// @kind function
// @category fresh
// @fileoverview Check for duplicate of minimum value within a series
// @param data {(int;long;float)[]} List of data points
// @return {boolean} Does data contain a duplicate of the minimum value
fresh.feat.hasdupmin:{[data]
  1<sum data=min data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the relative index of a dataset such that the chosen quantile of the series' mass lies to the left
// @param data {(int;long;float)[]} List of data points
// @param quantile {float} Quantile to check
// @return {float} Calculate index
fresh.feat.indexmassquantile:{[data;quantile]
  (1+(sums[data]%sum data:abs data)binr quantile)%count data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the adjusted G2 Fisher-Pearson kurtosis of the series
// @param data {(int;long;float)[]} List of data points
// @return {float} Adjusted G2 Fisher-Pearson kurtosis
fresh.feat.kurtosis:{[data]
  k*:k:data-avg data;
  s:sum k;
  n:count data;
  ((n-1)%(n-2)*n-3)*(3*1-n)+n*(1+n)*sum[k*k]%s*s
  }

// @kind function
// @category fresh
// @fileoverview Check if the standard deviation of a series is larger than ratio*(max-min) values
// @param data {(int;long;float)[]} List of data points
// @param ratio {float} Ratio to check
// @return {boolean} Is standard deviation larger than ratio times max - min values
fresh.feat.largestdev:{[data;ratio]
  dev[data]>ratio*max[data]-min data
  }

// @kind function
// @category fresh
// @fileoverview Find the position of the last occurrence of the maximum value in the series relative to the series length
// @param data {(int;long;float)[]} List of data points
// @return {float} Last max relative to number of data points
fresh.feat.lastmax:{[data]
  (last where data=max data)%count data
  }

// @kind function
// @category fresh
// @fileoverview Find the position of the last occurrence of the minimum value in the series relative to the series length
// @param data {(int;long;float)[]} List of data points
// @return {float} Last min relative to number of data points
fresh.feat.lastmin:{[data]
  (last where data=min data)%count data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the slope, intercept and r-value associated with the series
// @param data {(int;long;float)[]} List of data points
// @return {dict} Slope, intercept and r-value
fresh.feat.lintrend:{[data]
  k:til count data;
  slope:(xk:data cov k)%vk:var k;
  intercept:avg[data]-slope*avg k;
  rval:xk%sqrt vk*var data;
  `rval`intercept`slope!0^(rval;intercept;slope)
  }

// @kind function
// @category fresh
// @fileoverview Calculate if the length of the longest subsequence within a series is greater than the series mean
// @param data {(int;long;float)[]} List of data points
// @return {boolean} Is longest subsequence greater than the mean
fresh.feat.longstrikegtmean:{[data]
  max 0,fresh.i.getlenseqwhere data>avg data
  }

// @kind function
// @category fresh
// @fileoverview Calculate if the length of the longest subsequence within a series is less than the series mean
// @param data {(int;long;float)[]} List of data points
// @return {boolean} Is longest subsequence less than the mean
fresh.feat.longstrikeltmean:{[data]
  max 0,fresh.i.getlenseqwhere data<avg data
  }

// @kind function
// @category fresh
// @fileoverview Maximum value
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Maximum value of the series
fresh.feat.max:{[data]
  max data
  }

// @kind function
// @category fresh
// @fileoverview Average value
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Mean value of the series
fresh.feat.mean:{[data]
  avg data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the average over the absolute difference between subsequent series values
// @param data {(int;long;float)[]} List of data points
// @return {float} Mean over the absolute difference between data points
fresh.feat.meanabschange:{[data]
  avg abs 1_deltas data
  }

// @kind function
// @category fresh
// @fileoverview Calculate the average over the difference between subsequent series values
// @param data {(int;long;float)[]} List of data points
// @return {float} Mean over the difference between data points
fresh.feat.meanchange:{[data]
  n:-1+count data;
  (data[n]-data 0)%n
  }

// @kind function
// @category fresh
// @fileoverview Calculate the average central approximation of the second derivative of a series
// @param data {(int;long;float)[]} List of data points
// @return {float} Mean central approximation of the second derivative
fresh.feat.mean2dercentral:{[data]
  p:prev data;
  avg(.5*data+prev p)-p
  }

// @kind function
// @category fresh
// @fileoverview Median value
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Median value of the series
fresh.feat.med:{[data]
  med data
  }

// @kind function
// @category fresh
// @fileoverview Minimum value
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Minimum value of the series
fresh.feat.min:{[data]
  min data
  }

// @kind function
// @category fresh
// @fileoverview Number of crossings in the series over the value crossVal
// @param data {(int;long;float)[]} List of data points
// @param crossVal {}
// @return {int} Number of crossings
fresh.feat.numcrossingm:{[data;crossVal]
  sum 1_differ data>crossVal
  }

// @kind function
// @category fresh
// @fileoverview Number of peaks in a series following data smoothing via application of a Ricker wavelet of defined width
// @param data {(int;long;float)[]} List of data points
// @param width {long} Width of wavelet
// @return {long} Number of peaks
fresh.feat.numcwtpeaks:{[data;width]
  count fresh.i.findpeak[data;1+til width]`
  }

// @kind function
// @category fresh
// @fileoverview Number of peaks in the series with a specified support
// @param data {(int;long;float)[]} List of data points
// @param support {}
// @return {int} Number of peaks
fresh.feat.numpeaks:{[data;support]
  sum all fresh.i.peakfind[data;support]each 1+til support
  }

// @kind function
// @category fresh
// @fileoverview Partial auto-correlation of a series with a specified lag
// @param data {(int;long;float)[]} List of data points
// @param lag {long} Lag to apply to data
// @return {dict} Partial auto-correlation
fresh.feat.partautocorrelation:{[data;lag]
  (`$"lag_",/:string 1+til lag)!
    lag#$[1>mx:lag&count[data]-1;
      ();
      1_fresh.i.pacf[data;`nlags pykw mx;`method pykw`ld]`
      ],lag#0n
  }

// @kind function
// @category fresh
// @fileoverview Ratio of the number of non-distinct values to the number of possible values
// @param data {(int;long;float)[]} List of data points
// @return {float} Calculated ratio
fresh.feat.perrecurtoalldata:{[data]
  g:count each group data;
  sum[1<g]%count g
  }

// @kind function
// @category fresh
// @fileoverview the number of non-distinct values to the number of data points
// @param data {(int;long;float)[]} List of data points
// @return {float} Calculated ratio
fresh.feat.perrecurtoallval:{[data]
  g:count each group data;
  sum[g where 1<g]%count data
  }

// @kind function
// @category fresh
// @fileoverview The value of a series greater than a user-defined quantile percentage of the ordered series
// @param data {(int;long;float)[]} List of data points
// @param quantile {float} Quantile to check
// @return {float} Value greater than quantile
fresh.feat.quantile:{[data;quantile]
  p:quantile*-1+count data;
  idx:0 1+\:floor p;
  r:0^deltas asc[data]idx;
  r[0]+(p-idx 0)*last r
  }

// @kind function
// @category fresh
// @fileoverview The number of values greater than or equal to some minimum and less than some maximum
// @param data {(int;long;float)[]} List of data points
// @param minVal {(int;long;float)} Min value allowed
// @param maxVal {(int;long;float)} Max value allowed
// @return {int} Number of data points in specified range
fresh.feat.rangecount:{[data;minVal;maxVal]
  sum(data>=minVal)&data<maxVal
  }

// @kind function
// @category fresh
// @fileoverview Ratio of values greater than sigma from the mean value
// @param data {(int;long;float)[]} List of data points
// @param r {}
// @return {float} Calculated ratio
fresh.feat.ratiobeyondrsigma:{[data;r]
  avg abs[data-avg data]>r*dev data
  }

// @kind function
// @category fresh
// @fileoverview Ratio of the number of unique values to total number of values in a series
// @param data {(int;long;float)[]} List of data points
// @return {float} Calculated ratio
fresh.feat.ratiovalnumtserieslength:{[data]
  count[distinct data]%count data
  }

// @kind function
// @category fresh
// @fileoverview Skew of a time series indicating asymmetry within the series
// @param data {(int;long;float)[]} List of data points
// @return {float} Skew of data
fresh.feat.skewness:{[data]
  n:count data;
  s:sdev data;
  m:data-avg data;
  n*sum[m*m*m]%(s*s*s)*(n-1)*-2+n
  }

// @kind function
// @category fresh
// @fileoverview Calculate the cross power spectral density of a time series
// @param data {(int;long;float)[]} List of data points
// @param coeff {}
// @return {float} Cross power spectral density of data at given coeff
fresh.feat.spktwelch:{[data;coeff]
  fresh.i.welch[data;`nperseg pykw 256&count data][@;1][`]coeff
  }

// @kind function
// @category fresh
// @fileoverview Standard deviation
// @param data {(int;long;float)[]} List of data points
// @return {float} Standard deviation of series
fresh.feat.stddev:{[data]
  dev data
  }

// @kind function
// @category fresh
// @fileoverview Sum points that appear more than once in a series
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Sum of all points present in the series more than once
fresh.feat.sumrecurringdatapoint:{[data]
  g:count each group data;
  k:where 1<g;
  sum k*g k
  }

// @kind function
// @category fresh
// @fileoverview Sum values that appear more than once in a series
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Sum of all the values present within the series more than once
fresh.feat.sumrecurringval:{[data]
  sum where 1<count each group data
  }

// @kind function
// @category fresh
// @fileoverview Sum data points
// @param data {(int;long;float)[]} List of data points
// @return {(int;long;float)} Sum of values within the series
fresh.feat.sumval:{[data]
  sum data
  }

// @kind function
// @category fresh
// @fileoverview Measure symmetry of a time series
// @param data {(int;long;float)[]} List of data points
// @param ratio {float} Ratio in range 0->1
// @return {boolean} Measure of symmetry 
fresh.feat.symmetriclooking:{[data;ratio]
  abs[avg[data]-med data]<ratio*max[data]-min data
  }

// @kind function
// @category fresh
// @fileoverview Measure the asymmetry of a time series based on a user-defined lag
// @param data {(int;long;float)[]} List of data points
// @param lag {long} Size of lag to apply
// @return {float} Measure of asymmetry of data
fresh.feat.treverseasymstat:{[data;lag]
  x1:xprev[lag]data;
  x2:xprev[lag]x1;
  0^avg x1*(data*data)-x2*x2
  }

// @kind function
// @category fresh
// @fileoverview Return the number occurences of a specific value within a dataset
// @param data {(int;long;float)[]} List of data points
// @param val {(int;long;float)} Value to check
// @return {int} Number of occurrences of val within the series
fresh.feat.valcount:{[data;val]
  sum data=val
  }

// @kind function
// @category fresh
// @fileoverview Variance of a dataset
// @param data {(int;long;float)[]} List of data points
// @return {float} Variance of the series
fresh.feat.var:{[data]
  var data
  }

// @kind function
// @category fresh
// @fileoverview Check if the variance of a dataset is larger than its standard deviation
// @param data {(int;long;float)[]} List of data points
// @return {boolean} Indicates if variance is larger than standard deviation
fresh.feat.vargtstddev:{[data]
  1<var data
  }