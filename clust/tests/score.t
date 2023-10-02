\l ml.q
.ml.loadfile`:clust/tests/passfail.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q

// Initialize datasets

\S 10

// Python imports
pydb:  .p.import[`sklearn.metrics]`:davies_bouldin_score
pysil: .p.import[`sklearn.metrics]`:silhouette_score
hscore:.p.import[`sklearn.metrics]`:homogeneity_score

// q Utilities
applyScoring:{ceiling y*x . z}

// Datasets
d1:flip(60#"F";",")0:`:clust/tests/data/ss5.csv
d2:@[;`AnnualIncome`SpendingScore]("SSIII";(),",")0:`:clust/tests/data/Mall_Customers.csv

// Expected Results
clt1:.ml.clust.hc.cutK[.ml.clust.hc.fit[d1;`edist;`single];4]
clt2:.ml.clust.hc.cutK[.ml.clust.hc.fit[d2;`e2dist;`ward];4]
clt3:.ml.clust.hc.cutK[.ml.clust.cure.fit[d2;`edist;20;0.2];4]
rnd1:count[flip d1]?4
rnd2:count[flip d2]?4

// Dave Bouldin Score
passingTest[.ml.clust.daviesBouldin;(d1;clt1`clust);0b;pydb[.p.toraw flip d1;clt1`clust]`]
passingTest[.ml.clust.daviesBouldin;(d2;clt2`clust);0b;pydb[.p.toraw flip d2;clt2`clust]`]
passingTest[.ml.clust.daviesBouldin;(d2;clt3`clust);0b;pydb[.p.toraw flip d2;clt3`clust]`]

// Silhouette Score
passingTest[.ml.clust.silhouette;(d1;`edist;clt1`clust;1b);0b;pysil[.p.toraw flip d1;clt1`clust]`]
passingTest[.ml.clust.silhouette;(d2;`edist;clt2`clust;1b);0b;pysil[.p.toraw flip d2;clt2`clust]`]
passingTest[.ml.clust.silhouette;(d2;`edist;clt3`clust;1b);0b;pysil[.p.toraw flip d2;clt3`clust]`]

// Dunn Score
passingTest[applyScoring[.ml.clust.dunn;1  ];(d1;`e2dist;clt1`clust);1b;20]
passingTest[applyScoring[.ml.clust.dunn;100];(d2;`edist;clt2`clust);1b;13]
passingTest[applyScoring[.ml.clust.dunn;100];(d2;`mdist;clt3`clust);1b;10]

// Elbow Scoring
passingTest[applyScoring[.ml.clust.elbow;1];(d1;`e2dist;2);1b;enlist 548]
passingTest[applyScoring[.ml.clust.elbow;1];(d2;`e2dist;2);1b;enlist 183654]
passingTest[applyScoring[.ml.clust.elbow;1];(d2;`e2dist;2);1b;enlist 186363]
failingTest[.ml.clust.elbow;(d2;`mdist;3);0b;"kmeans must be used with edist/e2dist"]

// Homogeneity Score
passingTest[.ml.clust.homogeneity;(clt1`clust;rnd1);0b;hscore[rnd1;clt1`clust]`]
passingTest[.ml.clust.homogeneity;(clt2`clust;rnd2);0b;hscore[rnd2;clt2`clust]`]
passingTest[.ml.clust.homogeneity;(clt3`clust;rnd2);0b;hscore[rnd2;clt3`clust]`]
failingTest[.ml.clust.homogeneity;(100?0b;10?0b);0b;"pred and true must have equal lengths"]
