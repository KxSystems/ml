\d .ml

/ utils
fresh.i.ksdistrib:  .p.import[`scipy.stats]`:kstwobign.sf
fresh.i.kendalltau: .p.import[`scipy.stats]`:kendalltau
fresh.i.fisherexact:.p.import[`scipy.stats]`:fisher_exact

/ feature significance
fresh.i.ktau:{fresh.i.kendalltau[<;x;y]1}
fresh.i.fisher:{fresh.i.fisherexact[<;count@''@\:[group@'x get group y]distinct x]1}
fresh.i.ks:{
  k:max abs(-). value(1+d bin\:raze d)%n:count each d:asc each y group x;
  fresh.i.ksdistrib[k*en+.12+.11%en:sqrt prd[n]%sum n]`}
fresh.i.ksyx:{fresh.i.ks[y;x]}

fresh.sigfeat:{[t;y]
 f:fresh.i$[2<count distinct y;`ktau`ksyx;`ks`fisher];
 raze[c]!(f[where count each c]@\:y)@'t raze c:where each(2<;2=)@\:(count distinct@)each flip t}

/ feature selection
fresh.benjhoch:  {[v;d]where d<=(v*1+til k)%(k*sums{1%1+til x}k:count d:asc d)}
fresh.ksigfeat:  {[k;d]key k#asc d}
fresh.percentile:{[p;d]where fresh.feat.quantile[d;p]>d}

fresh.significantfeatures:{[t;y;f]f fresh.sigfeat[t;y]}
