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
\l fresh/extract.q
\l fresh/select.q
\l fresh/tests/significancetests.p
xreal:5000?1000f
xbin:rand each 5000#0b
yreal:5000?1000f
ybin:rand each 5000#0b
/ 1a.
.ml.fresh.i.fisher[xbin;ybin] ~ binary_feature_binary_test[xbin;ybin]

/ 1b.
.ml.fresh.i.ks[ybin;xreal] ~ target_binary_feature_real_test[ybin;xreal]
/ 1c.
.ml.fresh.i.ktau[xreal;yreal] ~ target_real_feature_real_test[xreal;yreal]

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
table1:([]1000000?100f;asc 1000000?100f;desc 1000000?100f;1000000?100f;1000000?100f;asc 1000000?100f)
table2:([]asc 1000000?100f;asc 1000000?100f;desc 1000000?100f;1000000?0b;desc 1000000?100f;asc 1000000?100f)
table3:([]desc 1000000?1f;1000000?10f;asc 1000000?1f)
table4:([]1000000?0b;1000000?1f;1000000?1f)
target1:asc 1000000?100f;target2:desc 1000000?1f;target3:target4:1000000?0b
bintest:{2=count distinct x}
pdmatrix:{asmatrix[benjamini_hochberg_test[y;"FALSE";x]]}
k:{pdmatrix[x;y]`}
vec:{k[x;y][;2]}
bhfn:{[table;target]
	pdict:.ml.fresh.sigfeat[table;target];
	ptable:([]label:key pdict;p_value:value pdict);
	dfptable:tab2df[ptable];
	("i"$count .ml.fresh.benjhoch[0.05;pdict]) ~ sum vec[0.05;dfptable]=1b
	}
bhfn[table1;target1]
bhfn[table2;target2]
bhfn[table3;target3]
bhfn[table4;target4]
