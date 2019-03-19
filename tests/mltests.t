\l p.q
\l ml.q
\l util/util.q
\l tests/mlpy.p

np:.p.import[`numpy]
plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
skmetric:.p.import[`sklearn.metrics]
stats:.p.import[`scipy.stats]
f1:.p.import[`sklearn.metrics][`:f1_score]
mae:.p.import[`sklearn.metrics]`:mean_absolute_error
mcoeff:.p.import[`sklearn.metrics][`:matthews_corrcoef]
fbscore:.p.import[`sklearn.metrics][`:fbeta_score]
r2:.p.import[`sklearn.metrics]`:r2_score
msle:.p.import[`sklearn.metrics]`:mean_squared_log_error
mse:.p.import[`sklearn.metrics]`:mean_squared_error


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

(`int$.ml.arange[2;20;2]) ~ `int$np[`:arange][2;20;2]`
.ml.arange[2;100;2.5] ~ np[`:arange][2;100;2.5]`
.ml.arange[2.5;50.2;0.2] ~ np[`:arange][2.5;50.2;0.2]`

.ml.shape[1 2 3*/:til 10] ~ np[`:shape][1 2 3*/:til 10]`
.ml.shape[enlist 1] ~ np[`:shape][enlist 1]`
.ml.shape[1 2] ~ np[`:shape][1 2]`
.ml.shape[plaintab]~3 4
.ml.shape[xm]~100 10

.ml.linspace[1;10;9] ~ np[`:linspace][1;10;9]`
.ml.linspace[-0.2;109;62] ~ np[`:linspace][-0.2;109;62]`
.ml.linspace[-0.2;10.4;20] ~ np[`:linspace][-0.2;10.4;20]`

.ml.range[til 63] ~ 62
.ml.range[5] ~ 0

.ml.eye[3] ~ "f"$(1 0 0;0 1 0;0 0 1)
first[.ml.eye[1]] ~ enlist 1f

("f"$flip value .ml.describe[plaintab])~flip value .ml.util.df2tab .p.import[`pandas][`:DataFrame.describe][.ml.util.tab2df[plaintab]]

.ml.percentile[x;0.75]~np[`:percentile][x;75]`
.ml.percentile[x;0.02]~np[`:percentile][x;2]`
.ml.percentile[xf;0.5]~np[`:percentile][xf;50]`

.ml.accuracy[x;y] ~ skmetric[`:accuracy_score][x;y]`
.ml.accuracy[xb;yb] ~ 0.4583333333333

.ml.mse[x;y] ~ skmetric[`:mean_squared_error][x;y]`
.ml.mse[xf;yf] ~ skmetric[`:mean_squared_error][xf;yf]`

.ml.sse[x;y] ~ sum d*d:x-y
.ml.sse[xf;yf] ~ sum d*d:xf-yf

.ml.precision[xb;yb;1b] ~ skmetric[`:precision_score][yb;xb]`
.ml.precision[xb;yb;0b] ~ 0.8888888888889

.ml.sensitivity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb]`
.ml.sensitivity[xb;yb;0b] ~ 0.4

.ml.specificity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb;`pos_label pykw 0]`
.ml.specificity[xb;yb;0b] ~ skmetric[`:recall_score][yb;xb;`pos_label pykw 1]`
.ml.specificity[xb;yb;0b] ~ 0.75

.ml.f1score[xb;yb;0b] ~ f1[xb;yb;`pos_label pykw 0]`
.ml.f1score[xb;yb;1b] ~ f1[xb;yb;`pos_label pykw 1]`

.ml.r2score[xf;yf] ~ r2[xf;yf]`
.ml.r2score[xf;xf] ~ r2[xf;xf]`
.ml.r2score[1 2 3;2 2 2] ~ r2[1 2 3;2 2 2]`

.ml.mae[x;y] ~ mae[x;y]`
.ml.mae[xf;yf] ~ mae[xf;yf]`

.ml.fbscore[xb;yb;1b;0.02] ~ fbscore[yb;xb;`beta pykw 0.02]`
.ml.fbscore[xb;yb;1b;0.5] ~ fbscore[yb;xb;`beta pykw 0.5]`
.ml.fbscore[xb;yb;1b;1.5] ~ fbscore[yb;xb;`beta pykw 1.5]`


.ml.rmse[xf;yf]~sqrt mse[xf;yf]`
.ml.rmse[xm;ym]~{sqrt mse[x;y]`}'[flip xm;flip ym]
.ml.rmse[x;y]~sqrt mse[x;y]`
.ml.rmse[x;x]~sqrt mse[x;x]`
.ml.rmsle[xf;yf]~sqrt msle[xf;yf]`
.ml.rmsle[xm;ym]~{sqrt msle[x;y]`}'[flip xm;flip ym]
.ml.rmsle[x;y]~sqrt msle[x;y]`
.ml.rmsle[x;x]~sqrt msle[x;x]`
(.ml.mape[x;y])~mean_absolute_percentage_error[x;y]
.ml.mape[xf;yf]~mean_absolute_percentage_error[xf;yf]
.ml.mape[xm;ym]~{mean_absolute_percentage_error[x;y]}'[flip xm;flip ym]
(.ml.smape[x;y])~smape[x;y]
.ml.smape[xf;yf]~smape[xf;yf]
.ml.smape[xm;ym]~{smape[x;y]}'[flip xm;flip ym]
.ml.matcorr[xb;yb]~mcoeff[xb;yb]`
.ml.matcorr[110010b;111111b]~0n
.ml.matcorr[111111b;110010b]~0n

logloss:.p.import[`sklearn.metrics]`:log_loss
rocau:.p.import[`sklearn.metrics]`:roc_auc_score
{.ml.logloss[x;y]~logloss[x;y]`}[1000?0b;(1-p),'p:1000?1f]
{.ml.logloss[x;y]~logloss[x;y]`}[1000?0b;(1-p),'p:1000?1i]
(floor .ml.logloss[1000?0b;(1-p),'p:1000#0n])~34
{.ml.crossentropy[x;y]~logloss[x;y]`}[(first idesc@)each p;p%:sum each p:1000 5#5000?1f]

{.ml.rocaucscore[x;y]~rocau[x;y]`}[10?0b;10?1f]
.ml.rocaucscore[10?0b;10#1f]~0f
.ml.rocaucscore[10#0b;10?1f]~0f
.ml.rocaucscore[10#1b;10#0f]~0f

.ml.tscoreeq[x;y]~abs first stats[`:ttest_ind][x;y]`
.ml.tscoreeq[xf;yf]~abs first stats[`:ttest_ind][xf;yf]`
.ml.tscoreeq[xb;yb]~abs first stats[`:ttest_ind][xb;yb]`


.ml.cvm[flip value flip plaintab]~np[`:cov][flip value flip  plaintab;`bias pykw 1b]`
.ml.cvm[(10110b;01110b)]~(0.24 0.04;0.04 0.24)
.ml.crm[(1 2;2 1)]~(2 2#1 -1 -1 1f)
.ml.crm[(011b;001b)]~(1 0.5;0.5 1)

(value .ml.corrmat[plaintab]) ~ "f"$([]1 1 -1 1;1 1 -1 1;-1 -1 1 -1;1 1 -1 1)
.ml.corrmat[(0011b;1010b)]~(1 0f;0 1f)
(value .ml.confmat[xb;yb]) ~ (8 12;1 3)
(value .ml.confmat[2 3# 0 0 1 1 0 0;2 3# 1 0 1 0 0 1]) ~ (0 1 0;0 0 0;1 0 0)
(value .ml.confmat[1 2 3;3 2 1])~(0 0 1;0 1 0;1 0 0)
(value .ml.confmat[1 2 3f;3 2 1f])~(0 0 1;0 1 0;1 0 0)
(value .ml.confmat[3#1b;3#0b])~(0 3;0 0)
