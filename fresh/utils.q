\d .ml 

// Python imports

sci_ver  :1.5<="F"$3#.p.import[`scipy][`:__version__]`
numpy    :.p.import`numpy
stats    :.p.import`scipy.stats
signal   :.p.import`scipy.signal
stattools:.p.import`statsmodels.tsa.stattools

fresh.i.rfft       :numpy`:fft.rfft
fresh.i.real       :numpy`:real
fresh.i.angle      :numpy`:angle
fresh.i.imag       :numpy`:imag
fresh.i.abso       :numpy`:abs
fresh.i.ksdistrib  :stats[$[sci_ver;`:kstwo.sf;`:kstwobign.sf];<]
fresh.i.kendalltau :stats`:kendalltau
fresh.i.fisherexact:stats`:fisher_exact
fresh.i.welch      :signal`:welch
fresh.i.findpeak   :signal`:find_peaks_cwt
fresh.i.acf        :stattools`:acf
fresh.i.pacf       :stattools`:pacf
fresh.i.adfuller   :stattools`:adfuller

// Python features

fresh.i.pyfeat:`aggautocorr`augfuller`fftaggreg`fftcoeff`numcwtpeaks,
  `partautocorrelation`spktwelch

// Extract utilities

// @private
// @kind function 
// @category freshUtility
// @fileoverview Returns the length of each sequence
// @param condition {bool} Executed condition, e.g. data>avg data
// @return {long[]} Sequence length based on condition
fresh.i.getlenseqwhere:{[condition]
  idx:where differ condition;
  (1_deltas idx,count condition)where condition idx
  }

// @private
// @kind function 
// @category freshUtility
// @fileoverview Find peaks within the data
// @param data {(int;long;float)[]} List of data points
// @param support {long}
// @param idx {long}
// @return {bool[]} 1 where peak exists
fresh.i.peakfind:{[data;support;idx]
  neg[support]_support _min data>/:xprev\:[-1 1*idx]data
  }

// @private
// @kind function 
// @category freshUtility
// @fileoverview Expand results produced by FRESH
// @param results {table} Table of resulting features
// @param column {sym} Column of interest
// @return {tab} Expanded results table
fresh.i.expandResults:{[results;column]
  t:(`$"_"sv'string column,'cols t)xcol t:results column;
  ![results;();0b;enlist column],'t
  }

// Select utilities

// @private
// @kind function
// @category freshUtility
// @fileoverview Apply python function for Kendall’s tau
// @param target {(int;long;float)[]} Target vector
// @param feature {(int;long;float)[]} Feature table column
// @return {float} Kendall’s tau - Close to 1 shows strong agreement, close to
//   -1 shows strong disagreement
fresh.i.ktau:{[target;feature]
  fresh.i.kendalltau[<;target;feature]1
  }

// @private
// @kind function
// @category freshUtility
// @fileoverview Perform a Fisher exact test
// @param target {(int;long;float)[]} Target vector
// @param feature {(int;long;float)[]} Feature table column
// @return {float} Results of Fisher exact test
fresh.i.fisher:{[target;feature]
  g:group@'target value group feature;
  fresh.i.fisherexact[<;count@''@\:[g]distinct target]1
  }

// @private
// @kind function
// @category freshUtility
// @fileoverview Calculate the Kolmogorov-Smirnov two-sided test statistic
//   distribution
// @param feature {(int;long;float)[]} Feature table column
// @param target {(int;long;float)[]} Target vector
// @return {float} Kolmogorov-Smirnov two-sided test statistic distribution
fresh.i.ks:{[feature;target]
  d:asc each target group feature;
  n:count each d;
  k:max abs(-). value(1+d bin\:raze d)%n;
  en:prd[n]%sum n;
  fresh.i.ksdistrib .$[sci_ver;(k;ceiling en);enlist k*sqrt en]
  }

// @private
// @kind function
// @category freshUtility
// @fileoverview Pass data correctly to .ml.fresh.i.ks allowing for projection
//   in main function
// @param target {(int;long;float)[]} Target vector
// @param feature {(int;long;float)[]} Feature table column
// @return {float} Kolmogorov-Smirnov two-sided test statistic distribution
fresh.i.ksyx:{[target;feature]
  fresh.i.ks[feature;target]
  }
