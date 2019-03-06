\d .ml
{dd:(0#`)!();
 fresh.paramdict:select
  binnedentropy:(select lag:2 5 10 from dd),
  cidce:(select boolean:01b from dd),
  numcrossingm:(select crossing:-1 0 1 from dd),
  ratiobeyondrsigma:(select sigma:.5 1 1.5 2 2 2.5 3 5 6 6 19 from dd),
  largestdev:(select percent:.05*1+til 19 from dd),
  c3:(select lag:1 2 3 from dd),
  autocorr:(select lag:til 10 from dd),
  indexmassquantile:(select q:.1*1+til 9 from dd),
  numcwtpeaks:(select width:1 5 from dd),
  numpeaks:(select support:1 3 from dd),
  symmetriclooking:(select rangepercent:.05*til 20 from dd),
  treverseasymstat:(select lag:1 2 3 from dd),
  quantile:(select quantile:.1*1+til 9 from dd),
  valcount:(select val:0 1 0n 0w -0w from dd),
  spktwelch:(select coeff:2 5 7 from dd),
  rangecount:(select minval:-1,maxval:1 from dd),
  partautocorrelation:(select lag:til 7 from dd),
  fftcoeff:(select coeff:til 10 from dd),
  agglintrend:(select chunklen:5 10 50 from dd),
  eratiobychunk:(select numsegments:3,segmentfocus:til 3 from dd)
 from dd;}[]
