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

x:1000?40
y:1000?40
xf:1000?100f
yf:1000?100f
xb:010010101011111010110111b
yb:000000000001000000111000b


.ml.arange[2;100;2] ~ `long$np[`:arange][2;100;2]`

.ml.arange[2.5;50.2;0.2] ~ np[`:arange][2.5;50.2;0.2]`
.ml.shape[1 2 3*/:1 2 3] ~ np[`:shape][1 2 3*/:1 2 3]`
.ml.shape[1 2 3*/:til 10] ~ np[`:shape][1 2 3*/:til 10]`
.ml.linspace[1;10;9] ~ np[`:linspace][1;10;9]`
.ml.linspace[-0.2;109;62] ~ np[`:linspace][-0.2;109;62]`
.ml.range[til 63] ~ 62

.ml.eye[3]~"f"$(1 0 0;0 1 0;0 0 1)

1 = count distinct min each (value .ml.describe[plaintab]) = value .ml.util.df2tab .p.import[`pandas][`:DataFrame.describe][.ml.util.tab2df[plaintab]]

.ml.percentile[x;0.5]~np[`:percentile][x;50]`

.ml.accuracy[x;y] ~ skmetric[`:accuracy_score][x;y]`
.ml.mse[x;y] ~ skmetric[`:mean_squared_error][x;y]`
.ml.sse[x;y] ~ sum d*d:x-y

.ml.precision[xb;yb;1b] ~ skmetric[`:precision_score][yb;xb]`
.ml.sensitivity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb]`
.ml.specificity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb;`pos_label pykw 0]`

.ml.f1score[xb;yb;0b]~f1[xb;yb;`pos_label pykw 0]`
.ml.r2score[xf;yf]~r2[xf;yf]`

.ml.mae[xf;yf]~mae[xf;yf]`

.ml.fbscore[xb;yb;1b;0.5]~fbscore[xb;yb;`beta pykw 0.5]`

.ml.rmse[xf;yf]~sqrt mse[xf;yf]`
.ml.rmsle[xf;yf]~sqrt msle[xf;yf]`
.ml.mape[xf;yf]~mean_absolute_percentage_error[xf;yf]
.ml.smape[xf;yf]~smape[xf;yf]
.ml.matcorr[xb;yb]~mcoeff[xb;yb]`

logloss:.p.import[`sklearn.metrics]`:log_loss
rocau:.p.import[`sklearn.metrics]`:roc_auc_score
{.ml.logloss[x;y]~logloss[x;y]`}[1000?0b;(1-p),'p:1000?1f]
{.ml.crossentropy[x;y]~logloss[x;y]`}[(first idesc@)each p;p%:sum each p:1000 5#5000?1f]
{.ml.rocaucscore[x;y]~rocau[x;y]`}[10?0b;10?1f]

.ml.tscoreeq[x;y]~abs first stats[`:ttest_ind][x;y]`

.ml.cvm[flip value flip plaintab]~np[`:cov][flip value flip  plaintab;`bias pykw 1b]`
.ml.crm[(1 2;2 1)]~(2 2#1 -1 -1 1f)

(value .ml.corrmat[plaintab]) ~ "f"$([]1 1 -1 1;1 1 -1 1;-1 -1 1 -1;1 1 -1 1)
(value .ml.confmat[xb;yb]) ~ (8 12;1 3)

