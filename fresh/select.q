\d .ml

/ py utils
fresh.i.ksdistrib:  .p.import[`scipy.stats]`:kstwo.sf
fresh.i.kendalltau: .p.import[`scipy.stats]`:kendalltau
fresh.i.fisherexact:.p.import[`scipy.stats]`:fisher_exact

/ q utils
fresh.i.ktau:{fresh.i.kendalltau[<;x;y]1}
fresh.i.fisher:{fresh.i.fisherexact[<;count@''@\:[group@'x value group y]distinct x]1}

/ Function change due to scipy update https://github.com/scipy/scipy/commit/aa319bcfeb38b90f3c4b46c9477f02618583570d
fresh.i.ks:{
 k:max abs(-). value(1+d bin\:raze d)%n:count each d:asc each y group x;
 fresh.i.ksdistrib[k;ceiling en:prd[n]%sum n]`}
fresh.i.ksyx:{fresh.i.ks[y;x]}

/ feature significance
fresh.sigfeat:{[t;y]
 f:fresh.i$[2<count distinct y;`ktau`ksyx;`ks`fisher];
 raze[c]!(f[where count each c]@\:y)@'t raze c:where each(2<;2=)@\:(count distinct@)each flip t}

/ feature selection
fresh.benjhoch:{[v;d]where d<=v*s%k*sums 1%s:1+til k:count d:asc d}
fresh.ksigfeat:{[k;d]key k sublist asc d}
fresh.percentile:{[p;d]where d<fresh.feat.quantile[value d]p}

fresh.significantfeatures:{[t;y;f]f fresh.sigfeat[t;y]}
