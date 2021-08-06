\l ml.q
\l util/init.q
\l util/tests/mlpy.p

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
mae:.p.import[`sklearn.metrics]`:mean_absolute_error

x:1000?1000
y:1000?1000
xf:1000?100f
yf:1000?100f
xb:1000#0101101011b
yb:1000#0000111000b
xm:100 10#1000?100f
ym:100 10#1000?100f
xmb:100 10#xb
ymb:100 10#yb
plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
plaintabn:plaintab,'([]x4:1 3 0n)

.ml.accuracy[x;y] ~ skmetric[`:accuracy_score][x;y]`
.ml.accuracy[xb;yb] ~ 0.5
.ml.accuracy[3 2 2 0n 4;0n 4 3 2 4]~0.2
.ml.accuracy[10#1b;10#0b]~0f

.ml.precision[xb;yb;1b] ~ skmetric[`:precision_score][yb;xb]`
.ml.precision[xb;yb;0b] ~ 0.75
.ml.precision[1000#1b;yb;1b]~skmetric[`:precision_score][yb;1000#1b]`
.ml.precision[1000#0b;yb;0b]~0.7
.ml.precision[1000#1b;yb;1b]~0.3
.ml.precision[10#1b;10#1b;1b]~1f
.ml.precision[10#1b;10#0b;1b]~0f

.ml.sensitivity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb]`
.ml.sensitivity[xb;yb;0b] ~ 0.428571428571429
.ml.sensitivity[1000#1b;yb;0b]~0f
.ml.sensitivity[1000#1b;yb;1b]~1f
.ml.sensitivity[10#1b;10#1b;1b]~1f

.ml.specificity[xb;yb;1b] ~ skmetric[`:recall_score][yb;xb;`pos_label pykw 0]`
.ml.specificity[xb;yb;0b] ~ skmetric[`:recall_score][yb;xb;`pos_label pykw 1]`
.ml.specificity[1000#1b;yb;0b]~1f
.ml.specificity[1000#1b;yb;1b]~0f
.ml.specificity[10#1b;10#0b;1b]~0f
.ml.specificity[10#1b;10#1b;0b]~1f

.ml.fBetaScore[xb;yb;1b;0.02] ~ fbscore[yb;xb;`beta pykw 0.02]`
.ml.fBetaScore[xb;yb;1b;0.5] ~ fbscore[yb;xb;`beta pykw 0.5]`
.ml.fBetaScore[xb;yb;1b;1.5] ~ fbscore[yb;xb;`beta pykw 1.5]`
.ml.fBetaScore[xb;yb;0b;1.5] ~ 0.493670886075949
.ml.fBetaScore[1000#1b;yb;0b;.5]~0f
.ml.fBetaScore[xb;1000#1b;0b;.5]~0f
.ml.fBetaScore[1000#0b;1000#1b;1b;.2]~0f

.ml.f1Score[xb;yb;0b] ~ f1[xb;yb;`pos_label pykw 0]`
.ml.f1Score[xb;yb;1b] ~ f1[xb;yb;`pos_label pykw 1]`
.ml.f1Score[xb;1000#0b;1b]~0f
.ml.f1Score[1000#1b;yb;1b]~f1[1000#1b;yb;`pos_label pykw 1]`
.ml.f1Score[10#1b;10#0b;1b]~f1[10#1b;10#0b;`pos_label pykw 1]`

.ml.matthewCorr[xb;yb]~mcoeff[xb;yb]`
.ml.matthewCorr[110010b;111111b]~0n
.ml.matthewCorr[111111b;110010b]~0n

(value .ml.confMatrix[xb;yb])~(300 400;100 200)
(value .ml.confMatrix[2 3# 0 0 1 1 0 0;2 3# 1 0 1 0 0 1]) ~ (0 1 0;0 0 0;1 0 0)
(value .ml.confMatrix[1 2 3;3 2 1])~(0 0 1;0 1 0;1 0 0)
(value .ml.confMatrix[1 2 3f;3 2 1f])~(0 0 1;0 1 0;1 0 0)
(value .ml.confMatrix[3#1b;3#0b])~(0 3;0 0)

.ml.confDict[xb;yb;1b] ~ `tn`fp`fn`tp!300 400 100 200
.ml.confDict[3#0b;3#1b;0b] ~`tn`fp`fn`tp!0 3 0 0
.ml.confDict[3#1b;3#0b;0b]~`tn`fp`fn`tp!0 0 3 0

.ml.classReport[110b;101b]~1!flip`class`precision`recall`f1_score`support!((`$string each 0 1),`$"avg/total";0 0.5 0.25; 0 0.5 0.25;0.0 0.5 0.25;1 2 3i)
.ml.classReport[3 3 5 2 5 1;3 5 2 3 5 1]~1!flip`class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 1 2 2 6i)
.ml.classReport[3 3 5 2 5 1f;3 5 2 3 5 1f]~1!flip`class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 1 2 2 6i)
.ml.classReport[3 3 5 0n 5 1;3 5 2 3 5 0n]~1!flip`class`precision`recall`f1_score`support!((`$string each 0n 2 3 5),`$"avg/total";0 0n 0.5 0.5 0.33333333333333;0 0 0.5 0.5 0.25;0 0 0.5 0.5 0.25;1 1 2 2 6i)

{.ml.logLoss[x;y]~logloss[x;y]`}[1000?0b;(1-p),'p:1000?1f]
{.ml.logLoss[x;y]~logloss[x;y]`}[1000?0b;(1-p),'p:1000?1i]
.ml.logLoss[10#0b;(1-p),'p:10?1i]~-0f
(floor .ml.logLoss[10110b;(2 0n;1 1; 3 1;0n 2; 3 3)])~floor 6
(floor .ml.logLoss[1000?0b;(1-p),'p:1000#0n])~34
{.ml.crossEntropy[x;y]~logloss[x;y]`}[(first idesc@)each p;p%:sum each p:1000 5#5000?1f]
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
.ml.mae[x;y]~mae[x;y]`
.ml.mae[xf;yf]~mae[xf;yf]`
.ml.mae[xb;yb]~mae["i"$xb;"i"$yb]`
.ml.mae[xb;xb]~0f
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
.ml.r2Score[xf;yf] ~ r2[yf;xf]`
.ml.r2Score[xf;xf] ~ r2[xf;xf]`
.ml.r2Score[2 2 2;1 2 3] ~ r2[1 2 3;2 2 2]`
.ml.r2Score[x;x]~1f
.ml.r2Score[1 0n 4 2 0n;1 2 4 2 1]~1f
.ml.tScore[x;y] ~first stats[`:ttest_1samp][x;y]`
.ml.tScore[xf;yf]~first stats[`:ttest_1samp][xf;yf]`
.ml.tScore[xb;yb]~first stats[`:ttest_1samp][xb;yb]`
.ml.tScore[x;x]~first stats[`:ttest_1samp][x;x]`
.ml.tScoreEqual[x;y]~abs first stats[`:ttest_ind][x;y]`
.ml.tScoreEqual[xf;yf]~abs first stats[`:ttest_ind][xf;yf]`
.ml.tScoreEqual[xb;yb]~abs first stats[`:ttest_ind][xb;yb]`
.ml.tScoreEqual[x;x]~abs first stats[`:ttest_ind][x;x]`
.ml.covMatrix[flip value flip plaintab]~np[`:cov][flip value flip  plaintab;`bias pykw 1b]`
.ml.covMatrix[(10110b;01110b)]~(0.24 0.04;0.04 0.24)
.ml.covMatrix[(10110b;11111b)]~(0.24 0f;0 0f)
.ml.covMatrix[(11111b;11111b)]~(0 0f;0 0f)
.ml.covMatrix[(10110b;1101b,0n)]~(0.24 0n;2#0n)
.ml.corrMatrix[(1 2;2 1)]~(2 2#1 -1 -1 1f)
.ml.corrMatrix[(011b;001b)]~(1 0.5;0.5 1)
.ml.corrMatrix[(1111b;1111b)]~(2 2#4#0n)
.ml.corrMatrix[(1 1 2;1 2 0n)]~(1 0n;2#0n)
(value .ml.corrMatrix[plaintab]) ~ "f"$([]1 1 -1 1;1 1 -1 1;-1 -1 1 -1;1 1 -1 1)
.ml.corrMatrix[(0011b;1010b)]~(1 0f;0 1f)
.ml.corrMatrix[(0011b;1111b)]~(1 0n;2#0n)
.ml.corrMatrix[(1111b;1111b)]~(2 2#2#0n)
.ml.corrMatrix[(1 1 2;1 2 0n)]~(1 0n;2#0n)
{.ml.rocAucScore[x;y]~rocau[x;y]`}[10?0b;10?1f]
.ml.rocAucScore[10#01b;10#1f]~0.5
.ml.rocAucScore[10#0b;10?1f]~0f
.ml.rocAucScore[10#1b;10#0f]~0f
.ml.rocAucScore[1011000110b;0n 0.1 0.2 0.1 0.3 0.4 0.2 0.4 0.3 0.2]~0.525
.ml.sharpe[0 1 0 1; 1 1 1 1]~sqrt[252]
.ml.sharpe[0 0 0 0; 1 1 1 1]~0n
