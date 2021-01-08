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
fresh.i.pyfeat     :`aggautocorr`augfuller`fftaggreg`fftcoeff`numcwtpeaks`partautocorrelation`spktwelch

// Extract utilities

// @kind private 
// @category freshUtility
// @fileoverview
// @param x {}
// @return {}
fresh.i.getlenseqwhere:{[x]
  i:where differ x;
  (1_deltas i,count x)where x i
  }

// @kind private 
// @category freshUtility
// @fileoverview
// @param x {}
// @param y {}
// @param z {}
// @return {}
fresh.i.peakfind:{[x;y;z]
  neg[y]_y _min x>/:xprev\:[-1 1*z]x
  }

// Select utilities

// @kind private 
// @category freshUtility
// @fileoverview
// @param x {}
// @param y {}
// @return {}
fresh.i.ktau:{[x;y]
  fresh.i.kendalltau[<;x;y]1
  }

// @kind private 
// @category freshUtility
// @fileoverview
// @param x {}
// @param y {}
// @return {}
fresh.i.fisher:{[x;y]
  fresh.i.fisherexact[<;count@''@\:[group@'x value group y]distinct x]1
  }

// @kind private 
// @category freshUtility
// @fileoverview
// @param x {}
// @param y {}
// @return {}
fresh.i.ks:{[x;y]
  k:max abs(-). value(1+d bin\:raze d)%n:count each d:asc each y group x;
  en:prd[n]%sum n;
  fresh.i.ksdistrib .$[sci_ver;(k;ceiling en);enlist k*sqrt en]
  }

// @kind private 
// @category freshUtility
// @fileoverview
// @param x {}
// @param y {}
// @return {}
fresh.i.ksyx:{[x;y]
  fresh.i.ks[y;x]
  }
