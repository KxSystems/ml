\l ml.q
.ml.loadfile`:util/init.q
.ml.loadfile`:util/tests/mlpy.p

np:.p.import[`numpy]
skmetric:.p.import[`sklearn.metrics]
stats:.p.import[`scipy.stats]
f1:.p.import[`sklearn.metrics][`:f1_score]
mcoeff:.p.import[`sklearn.metrics][`:matthews_corrcoef]
fbscore:.p.import[`sklearn.metrics][`:fbeta_score]
r2:.p.import[`sklearn.metrics]`:r2_score
msle:.p.import[`sklearn.metrics]`:mean_squared_log_error
mse:.p.import[`sklearn.metrics]`:mean_squared_error
rocau:.p.import[`sklearn.metrics]`:roc_auc_score
logloss:.p.import[`sklearn.metrics]`:log_loss

x:1000?1000
y:1000?1000
xf:1000?100f
yf:1000?100f
xb:010010101011111010110111b
yb:000000000001000000111000b
xm:100 10#1000?100f
ym:100 10#1000?100f
xmb:100 10#1000?0b
ymb:100 10#1000?0b
plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
plaintabn:plaintab,'([]x4:1 3 0n)
.ml.range[til 63] ~ 62
.ml.range[5] ~ 0
.ml.range[0 1 3 2f]~3f
.ml.range[0 1 0n 2]~2f
.ml.percentile[x;0.75]~np[`:percentile][x;75]`
.ml.percentile[x;0.02]~np[`:percentile][x;2]`
.ml.percentile[xf;0.5]~np[`:percentile][xf;50]`
.ml.percentile[3 0n 4 4 0n 4 4 3 3 4;0.5]~3.5
("f"$flip value .ml.describe[plaintab])~flip .ml.df2tab .p.import[`pandas][`:DataFrame.describe][.ml.tab2df[plaintab]]
("f"$flip value .ml.describe[plaintabn])~flip (.ml.df2tab .p.import[`pandas][`:DataFrame.describe][.ml.tab2df[plaintab]]),'"f"$([]x4:3 2,sdev[1 3 0n],1 0 1 2 3)

.ml.accuracy[x;y] ~ skmetric[`:accuracy_score][x;y]`
.ml.accuracy[xb;yb] ~ 0.4583333333333
.ml.accuracy[3 2 2 0n 4;0n 4 3 2 4]~0.2
.ml.accuracy[10#1b;10#0b]~0f

.ml.precision[xb;yb;1b] ~ skmetric[`:precision_score][yb;xb]`
.ml.precision[xb;yb;0b] ~ 0.8888888888889
.ml.precision[24#1b;yb;1b]~skmetric[`:precision_score][yb;24#1b]`
.ml.precision[24#0b;yb;0b]~0.8333333333333
.ml.precision[24#1b;yb;1b]~0.16666666666667
.ml.precision[10#1b;10#1b;1b]~1f
.ml.precision[10#1b;10#0b;1b]~0f

.ml.sensitivity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb]`
.ml.sensitivity[xb;yb;0b] ~ 0.4
.ml.sensitivity[24#1b;yb;0b]~0f
.ml.sensitivity[24#1b;yb;1b]~1f
.ml.sensitivity[10#1b;10#1b;1b]~1f

.ml.specificity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb;`pos_label pykw 0]`
.ml.specificity[xb;yb;0b] ~ skmetric[`:recall_score][yb;xb;`pos_label pykw 1]`
.ml.specificity[24#1b;yb;0b]~1f
.ml.specificity[24#1b;yb;1b]~0f
.ml.specificity[10#1b;10#0b;1b]~0f
.ml.specificity[10#1b;10#1b;0b]~1f

.ml.fbscore[xb;yb;1b;0.02] ~ fbscore[yb;xb;`beta pykw 0.02]`
.ml.fbscore[xb;yb;1b;0.5] ~ fbscore[yb;xb;`beta pykw 0.5]`
.ml.fbscore[xb;yb;1b;1.5] ~ fbscore[yb;xb;`beta pykw 1.5]`
.ml.fbscore[xb;yb;0b;1.5]~0.481481481481481481
.ml.fbscore[24#1b;yb;0b;.5]~0f
.ml.fbscore[xb;24#1b;0b;.5]~0f
.ml.fbscore[24#0b;24#1b;1b;.2]~0f

.ml.f1score[xb;yb;0b] ~ f1[xb;yb;`pos_label pykw 0]`
.ml.f1score[xb;yb;1b] ~ f1[xb;yb;`pos_label pykw 1]`
.ml.f1score[xb;24#0b;1b]~0f
.ml.f1score[24#1b;yb;1b]~f1[24#1b;yb;`pos_label pykw 1]`
.ml.f1score[10#1b;10#0b;1b]~f1[10#1b;10#0b;`pos_label pykw 1]`

.ml.matcorr[xb;yb]~mcoeff[xb;yb]`
.ml.matcorr[110010b;111111b]~0n
.ml.matcorr[111111b;110010b]~0n

(value .ml.confmat[xb;yb]) ~ (8 12;1 3)
(value .ml.confmat[2 3# 0 0 1 1 0 0;2 3# 1 0 1 0 0 1]) ~ (0 1 0;0 0 0;1 0 0)
(value .ml.confmat[1 2 3;3 2 1])~(0 0 1;0 1 0;1 0 0)
(value .ml.confmat[1 2 3f;3 2 1f])~(0 0 1;0 1 0;1 0 0)
(value .ml.confmat[3#1b;3#0b])~(0 3;0 0)

(.ml.confdict[xb;yb;1b]) ~ `tn`fp`fn`tp!8 12 1 3
.ml.confdict[3#0b;3#1b;0b] ~`tn`fp`fn`tp!0 3 0 0
.ml.confdict[3#1b;3#0b;0b]~`tn`fp`fn`tp!0 0 3 0

.ml.classreport[110b;101b]~1!flip`class`precision`recall`f1_score`support!((`$string each 0 1),`$"avg/total";0 0.5 0.25; 0 0.5 0.25;0.0 0.5 0.25;1 2 3i)
.ml.classreport[3 3 5 2 5 1;3 5 2 3 5 1]~1!flip`class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 1 2 2 6i)
.ml.classreport[3 3 5 2 5 1f;3 5 2 3 5 1f]~1!flip`class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 1 2 2 6i)
.ml.classreport[3 3 5 0n 5 1;3 5 2 3 5 0n]~1!flip`class`precision`recall`f1_score`support!((`$string each 0n 2 3 5),`$"avg/total";0 0n 0.5 0.5 0.33333333333333;0 0 0.5 0.5 0.25;0 0 0.5 0.5 0.25;1 1 2 2 6i)

{.ml.logloss[x;y]~logloss[x;y]`}[1000?0b;(1-p),'p:1000?1f]
{.ml.logloss[x;y]~logloss[x;y]`}[1000?0b;(1-p),'p:1000?1i]
.ml.logloss[10#0b;(1-p),'p:10?1i]~-0f
(floor .ml.logloss[10110b;(2 0n;1 1; 3 1;0n 2; 3 3)])~floor 6
(floor .ml.logloss[1000?0b;(1-p),'p:1000#0n])~34
{.ml.crossentropy[x;y]~logloss[x;y]`}[(first idesc@)each p;p%:sum each p:1000 5#5000?1f]
.ml.mse[x;y] ~ skmetric[`:mean_squared_error][x;y]`
.ml.mse[xf;yf] ~ skmetric[`:mean_squared_error][xf;yf]`
.ml.mse[x;x]~0f
.ml.mse[1 0n 4 2 0n;1 2 4 3 1]~0.333333333333333
.ml.sse[x;y] ~ sum d*d:x-y
.ml.sse[xf;yf] ~ sum d*d:xf-yf
.ml.sse[x;x]~0
.ml.sse[1 0n 4 2 0n;1 2 4 3 1]~1f
.ml.rmse[xf;yf]~sqrt mse[xf;yf]`
.ml.rmse[xm;ym]~{sqrt mse[x;y]`}'[flip xm;flip ym]
.ml.rmse[x;y]~sqrt mse[x;y]`
.ml.rmse[x;x]~sqrt mse[x;x]`
.ml.rmse[1 0n 4 2 0n;1 2 4 3 1]~ sqrt 0.333333333333333

.ml.rmsle[xf;yf]~sqrt msle[xf;yf]`
.ml.rmsle[xm;ym]~{sqrt msle[x;y]`}'[flip xm;flip ym]
.ml.rmsle[x;y]~sqrt msle[x;y]`
.ml.rmsle[x;x]~sqrt msle[x;x]`
.ml.rmsle[1 0n 4 2 0n;1 2 4 2 1]~0f
(.ml.mape[x;y])~mean_absolute_percentage_error[y;x]
.ml.mape[xf;yf]~mean_absolute_percentage_error[yf;xf]
.ml.mape[xm;ym]~{mean_absolute_percentage_error[x;y]}'[flip ym;flip xm]
.ml.mape[x;x]~0f
.ml.mape[1 0n 4 2 0n;1 2 4 3 1]~11.11111111111

.ml.smape[x;y]~smape[x;y]
.ml.smape[xf;yf]~smape[xf;yf]
.ml.smape[xm;ym]~{smape[x;y]}'[flip xm;flip ym]
.ml.smape[x;x]~0f
.ml.smape[1 0n 4 2 0n;1 2 4 3 1]~6.666666666666666667
.ml.r2score[xf;yf] ~ r2[xf;yf]`
.ml.r2score[xf;xf] ~ r2[xf;xf]`
.ml.r2score[1 2 3;2 2 2] ~ r2[1 2 3;2 2 2]`
.ml.r2score[x;x]~1f
.ml.r2score[1 0n 4 2 0n;1 2 4 2 1]~1f
.ml.tscore[x;y] ~first stats[`:ttest_1samp][x;y]`
.ml.tscore[xf;yf]~first stats[`:ttest_1samp][xf;yf]`
.ml.tscore[xb;yb]~first stats[`:ttest_1samp][xb;yb]`
.ml.tscore[x;x]~first stats[`:ttest_1samp][x;x]`
.ml.tscoreeq[x;y]~abs first stats[`:ttest_ind][x;y]`
.ml.tscoreeq[xf;yf]~abs first stats[`:ttest_ind][xf;yf]`
.ml.tscoreeq[xb;yb]~abs first stats[`:ttest_ind][xb;yb]`
.ml.tscoreeq[x;x]~abs first stats[`:ttest_ind][x;x]`
.ml.cvm[flip value flip plaintab]~np[`:cov][flip value flip  plaintab;`bias pykw 1b]`
.ml.cvm[(10110b;01110b)]~(0.24 0.04;0.04 0.24)
.ml.cvm[(10110b;11111b)]~(0.24 0f;0 0f)
.ml.cvm[(11111b;11111b)]~(0 0f;0 0f)
.ml.cvm[(10110b;1101b,0n)]~(0.24 0n;2#0n)
.ml.crm[(1 2;2 1)]~(2 2#1 -1 -1 1f)
.ml.crm[(011b;001b)]~(1 0.5;0.5 1)
.ml.crm[(1111b;1111b)]~(2 2#4#0n)
.ml.crm[(1 1 2;1 2 0n)]~(1 0n;2#0n)
(value .ml.corrmat[plaintab]) ~ "f"$([]1 1 -1 1;1 1 -1 1;-1 -1 1 -1;1 1 -1 1)
.ml.corrmat[(0011b;1010b)]~(1 0f;0 1f)
.ml.corrmat[(0011b;1111b)]~(1 0n;2#0n)
.ml.corrmat[(1111b;1111b)]~(2 2#2#0n)
.ml.corrmat[(1 1 2;1 2 0n)]~(1 0n;2#0n)
{.ml.rocaucscore[x;y]~rocau[x;y]`}[10?0b;10?1f]
.ml.rocaucscore[10#01b;10#1f]~0.5
.ml.rocaucscore[10#0b;10?1f]~0f
.ml.rocaucscore[10#1b;10#0f]~0f
.ml.rocaucscore[1011000110b;0n 0.1 0.2 0.1 0.3 0.4 0.2 0.4 0.3 0.2]~0.525
