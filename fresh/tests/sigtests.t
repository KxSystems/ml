/
The tests outlined in this script relate to the individual steps taken within the
function .fresh.significant features; namely:
1a. Fisher-Exact test (Binary target & Binary feature)
1b. Kolmogorov-Smirnov test (Binary target & Real feature)
1c. Kendall Tau-b (Real target & Real feature) 
{It is important to note here that Kendall Tau-b operates currently using embedPy as the
 q implementation is yet to be completed to a satisfactory standard}

2. Benjamini-Hochberg-Yekutieli(BHY) procedure

In each case significance tests implemented within freshq are compared to
equivalent significance tests implemented previously in python.
\

\l p.q
\l fresh/fresh.q
\l fresh/ts_feature_significance.q
\l fresh/tests/significancetests.p

xreal:5000?1000f
xbin:rand each 5000#0b
yreal:5000?1000f
ybin:rand each 5000#0b

/ 1a.
.ml.fresh.fishertest[xbin;ybin] ~ binary_feature_binary_test[xbin;ybin]

/ 1b.
.ml.fresh.ks2samp[ybin;xreal] ~ target_binary_feature_real_test[ybin;xreal]

/ 1c.
.ml.fresh.ktaupy[xreal;yreal] ~ target_real_feature_real_test[xreal;yreal]

/
2.
The testing of the BHY procedure is more involved, the metric which is being
used to determine if the implementation has been successful is that the same
number of features would be determined to be insignificant given their
p-value and the set FDR level.
\
pddf:.p.import[`pandas]`:DataFrame
asmatrix:pddf`:as_matrix
tab2df:{r:.p.import[`pandas;`:DataFrame.from_dict;flip 0!x][@;cols x];$[count k:keys x;r[`:set_index]k;r]}
pdict:(5000?`5)!asc 5000?1f
ptable:([]label:key pdict;p_value:value pdict)
dfptable:tab2df[ptable]
pdmatrix:{asmatrix[benjamini_hochberg_test[dfptable;x]]}
k:{pdmatrix[x]`}
vec:{k[x][;2]}

("i"$count .ml.fresh.benjhochfind[pdict;0.01]) ~ sum vec[0.01]<>1b
("i"$count .ml.fresh.benjhochfind[pdict;0.05]) ~ sum vec[0.05]<>1b
("i"$count .ml.fresh.benjhochfind[pdict;0.5]) ~ sum vec[0.5]<>1b
("i"$count .ml.fresh.benjhochfind[pdict;0.75]) ~ sum vec[0.75]<>1b
("i"$count .ml.fresh.benjhochfind[pdict;0.90]) ~ sum vec[0.90]<>1b
("i"$count .ml.fresh.benjhochfind[pdict;0.99]) ~ sum vec[0.99]<>1b
