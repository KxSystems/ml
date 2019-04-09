\d .ml

/ utils
fresh.searchsort:{1+x bin y}
ksdistrib:  .p.import[`scipy.stats]`:kstwobign.sf
kendalltau: .p.import[`scipy.stats]`:kendalltau
fisherexact:.p.import[`scipy.stats]`:fisher_exact

/ feature significance

fresh.ktaupy:{(kendalltau[x;y]`)1}
fresh.ks2samp:{
 y0:y where x=first distinct x;
 y1:y where x = last distinct x;
 n1:count y0;n2:count y1;
 ydata0:asc y0;ydata1:asc y1;
 totdata:ydata0,ydata1;
 cdf1:(fresh.searchsort[ydata0;]each totdata)%n1;
 cdf2:(fresh.searchsort[ydata1;]each totdata)%n2;
 d:max abs cdf1-cdf2;
 en:sqrt n1*n2%n1+n2;
 r:ksdistrib[d*en+0.12+0.11%en]`}
fresh.fishertest:{x0:first distinct x;x1:last distinct x;
 y0:first distinct y;y1:last distinct y;
 ny1x0:sum y1=k:y where x=x0;ny0x0:(count k)-ny1x0;
 ny1x1:sum y1=v:y where x=x1;ny0x1:(count v)-ny1x1;
 tab:((ny1x1;ny1x0);(ny0x1;ny0x0));
 [fisherexact[tab;`alternative pykw `$"two-sided"]`][1]}

fresh.sigfeat:{[t;y]
 f:fresh$[2<count distinct y;`ktaupy`ks2samp;`ks2samp`fishertest];
 raze[c]!(f[where count each c]@\:y)@'t raze c:where each(2<;2=)@\:(count distinct@)each flip t}

/ feature selection

fresh.benjhoch:  {[d;v]where d<=(v*1+til k)%(k*sums{1%1+til x}k:count d:asc d)}
fresh.ksigfeat:  {[d;k]key k#asc d}
fresh.percentile:{[d;p]where fresh.feat.quantile[d;p]>d}

fresh.significantfeatures:{[t;y;f]f fresh.sigfeat[t;y]}

/ other

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
