\d .ml
\l p.q
np:.p.import[`numpy]
scipy:.p.import[`scipy.stats]
ksdistrib:scipy[`:kstwobign.sf]
kendalltau:scipy[`:kendalltau]
fisherexact:.p.import[`scipy.stats]`:fisher_exact
special:.p.import[`scipy][`:special]

fresh.ks2samp:{y0:y where x = first distinct x;y1:y where x = last distinct x;
 n1:count y0;n2:count y1;
 ydata0:asc y0;ydata1:asc y1;
 totdata:ydata0,ydata1;
 cdf1:(fresh.searchsort[ydata0;]each totdata)%n1;
 cdf2:(fresh.searchsort[ydata1;]each totdata)%n2;
 d:max abs cdf1-cdf2;
 en:sqrt n1*n2%n1+n2;
 r:ksdistrib[d*en+0.12+0.11%en]`}

fresh.ktaupy:{[x;y][kendalltau[x;y]`][1]}

fresh.fishertest:{x0:first distinct x;x1:last distinct x;
 y0:first distinct y;y1:last distinct y;
 ny1x0:sum y1=k:y where x=x0;ny0x0:(count k)-ny1x0;
 ny1x1:sum y1=v:y where x=x1;ny0x1:(count v)-ny1x1;
 tab:((ny1x1;ny1x0);(ny0x1;ny0x0));
 [fisherexact[tab;`alternative pykw `$"two-sided"]`][1]}

fresh.benjhoch:{(y*1+til k)%(k*sums{1%1+til x}k:count x)}
fresh.benjhochfind:{v:asc x;where v>=fresh.benjhoch[v;y]}

/utils
fresh.searchsort:{1+x bin y}

