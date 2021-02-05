\l ml.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q

\S 10

pydb:  .p.import[`sklearn.metrics]`:davies_bouldin_score
pysil: .p.import[`sklearn.metrics]`:silhouette_score
hscore:.p.import[`sklearn.metrics]`:homogeneity_score

d1:flip(60#"F";",")0:`:clust/tests/data/ss5.csv
d2:@[;`AnnualIncome`SpendingScore]("SSIII";(),",")0:`:clust/tests/data/Mall_Customers.csv
clt1:.ml.clust.hccutk[.ml.clust.hc[d1;`edist;`single];4]
clt2:.ml.clust.hccutk[.ml.clust.hc[d2;`e2dist;`ward];4]
clt3:.ml.clust.hccutk[.ml.clust.cure[d2;`edist;20;0.2];4]
rnd1:count[flip d1]?4
rnd2:count [flip d2]?4

// Dave Bouldin Score

.ml.clust.daviesbouldin[d1;clt1]~pydb[flip d1;clt1]`
.ml.clust.daviesbouldin[d2;clt2]~pydb[flip d2;clt2]`
.ml.clust.daviesbouldin[d2;clt3]~pydb[flip d2;clt3]`

// Silhouette Score

.ml.clust.silhouette[d1;`edist;clt1;1b]~pysil[flip d1;clt1]`
.ml.clust.silhouette[d2;`edist;clt2;1b]~pysil[flip d2;clt2]`
.ml.clust.silhouette[d2;`edist;clt3;1b]~pysil[flip d2;clt3]`

// Dunn Score

ceiling[.ml.clust.dunn[d1;`e2dist;clt1]]~20
ceiling[.ml.clust.dunn[d2;`edist;clt2]*100]~13
ceiling[.ml.clust.dunn[d2;`mdist;clt3]*100]~10

// Elbow Scoring 

ceiling[.ml.clust.elbow[d1;`e2dist;2]]~enlist 548
ceiling[.ml.clust.elbow[d2;`e2dist;2]]~enlist 183654
ceiling[.ml.clust.elbow[d2;`e2dist;2]]~enlist 186363

// Homogeneity Score

.ml.clust.homogeneity[clt1;rnd1]~hscore[rnd1;clt1]`
.ml.clust.homogeneity[clt2;rnd2]~hscore[rnd2;clt2]`
.ml.clust.homogeneity[clt3;rnd2]~hscore[rnd2;clt3]`
