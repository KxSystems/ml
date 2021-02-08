\l ml.q
\l util/init.q
\l stats/init.q

np:.p.import[`numpy]
ols:.p.import[`statsmodels.api]`:OLS
wls:.p.import[`statsmodels.api]`:WLS

plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
x:1000?1000
xf:1000?100f
plaintabn:plaintab,'([]x4:1 3 0n)
plaintabn2:plaintab,'([]x4:`a`a`b)

.ml.stats.percentile[x;0.75]~np[`:percentile][x;75]`
.ml.stats.percentile[x;0.02]~np[`:percentile][x;2]`
.ml.stats.percentile[xf;0.5]~np[`:percentile][xf;50]`
.ml.stats.percentile[3 0n 4 4 0n 4 4 3 3 4;0.5]~3.5

descKeys:`count`mean`std`min`q1`q2`q3`max
.ml.stats.describeFuncs:descKeys!.ml.stats.describeFuncs[descKeys]
("f"$flip value .ml.stats.describe[plaintab])~flip .ml.df2tab .p.import[`pandas][`:DataFrame.describe][.ml.tab2df[plaintab]]
("f"$flip value .ml.stats.describe[plaintabn])~flip (.ml.df2tab .p.import[`pandas][`:DataFrame.describe][.ml.tab2df[plaintab]]),'"f"$([]x4:3 2,sdev[1 3 0n],1 0 1 2 3)
all all(flip value .ml.stats.describe[plaintabn2])=flip (.ml.df2tab .p.import[`pandas][`:DataFrame.describe][.ml.tab2df[plaintab]]),'([]x4:3f,7#(::))

vec1: 6 2 5 1 9 2 4
vec2:1 9 7 2 3 4 1
mdlOLS1:.ml.stats.OLS.fit[7+2*til 10;til 10;1b]
mdlOLS2:.ml.stats.OLS.fit[7+2*til 10;til 10;0b]
mdlOLS3:.ml.stats.OLS.fit[vec2;vec1;0b]
mdlOLS1.modelInfo.coef~ols[7+2*til 10;1f,'til 10][`:fit][][`:params]`
mdlOLS2.modelInfo.coef~ols[7+2*til 10;til 10][`:fit][][`:params]`
mdlOLS3.modelInfo.coef~ols[vec2;vec1][`:fit][][`:params]`
mdlOLS1.predict[vec1]~19 11 17 9 25 11 15f
mdlOLS2.predict[7+2*til 10]~ols[7+2*til 10;til 10][`:fit][][`:predict][7+2*til 10]`
mdlOLS3.predict[vec2]~ols[vec2;vec1][`:fit][][`:predict][vec2]`

mdlWLS1:.ml.stats.WLS.fit[7+2*til 10;til 10;(5#1),(5#2);1b]
mdlWLS2:.ml.stats.WLS.fit[7+2*til 10;til 10;(5#1),(5#2);0b]
mdlWLS3:.ml.stats.WLS.fit[vec2;vec1;til count vec1;0b]
mdlWLS1.modelInfo.coef~wls[7+2*til 10;1f,'til 10;(5#1),(5#2)][`:fit][][`:params]`
mdlWLS2.modelInfo.coef~wls[7+2*til 10;til 10;(5#1),(5#2)][`:fit][][`:params]`
mdlWLS3.modelInfo.coef~wls[vec2;vec1;til count vec1][`:fit][][`:params]`
mdlWLS1.predict[vec2]~9 25 21 11 13 15 9f
mdlWLS2.predict[7+2*til 10]~wls[7+2*til 10;til 10;(5#1),(5#2)][`:fit][][`:predict][7+2*til 10]`
mdlWLS3.predict[vec2]~wls[vec2;vec1;til count vec1][`:fit][][`:predict][vec2]`
