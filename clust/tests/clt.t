\l ml.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q

\S 10

// Python imports
lnk   :.p.import[`scipy.cluster.hierarchy]`:linkage
fclust:.p.import[`scipy.cluster.hierarchy]`:fcluster

// q utilities
mat:{"f"$flip value flip x}

// Datasets
d1:flip(60#"F";",")0:`:clust/tests/data/ss5.csv
d1tts:flip each(0;45)_flip d1
d2:@[;`AnnualIncome`SpendingScore]("SSIII";(),",")0:`:clust/tests/data/Mall_Customers.csv

// Results
d1clt:(15*til 4)+\:til 15
tab1:.ml.clust.hc.fit[d1;`mdist;`single]
tab2:.ml.clust.hc.fit[d1;`e2dist;`average]
tab3:.ml.clust.hc.fit[d2;`e2dist;`centroid]
tab4:.ml.clust.hc.fit[d2;`edist;`complete]

// Affinity Propagation

// Fit
.[.ml.clust.ap.fit;(d1;`e2dist;0.7;min;(::));1b]
value[group .ml.clust.ap.fit[d1;`nege2dist;0.7;min;(::)]`clt]~d1clt
value[group .ml.clust.ap.fit[d1;`nege2dist;0.9;med;(::)]`clt]~d1clt
key[group .ml.clust.ap.fit[d2;`nege2dist;0.95;{[x] -20000.};enlist[`maxsame]!enlist 150]`clt]~til 5
key[group .ml.clust.ap.fit[d2;`nege2dist;0.5;min;(::)]`clt]~til 5
asc[key .ml.clust.ap.fit[d2;`nege2dist;0.5;min;(::)]]~`clt`data`exemplars`inputs
.ml.clust.ap.fit[d2;`nege2dist;0.01;{[x] -10.};(::)][`clt]~200#-1
.ml.clust.ap.fit[d1tts 0;`nege2dist;0.3;min;`maxrun`maxmatch!100 10][`clt]~45#-1

// Predict
.ml.clust.ap.predict[d1tts 1;.ml.clust.ap.fit[d1tts 0;`nege2dist;0.7;min;(::)]]~2 2 2 2 2 2 0 2 0 0 0 2 2 2 2
.ml.clust.ap.predict[d1tts 1;.ml.clust.ap.fit[d1tts 0;`nege2dist;0.7;med;`maxrun`maxmatch!100 10]]~2 2 2 2 2 2 0 2 0 0 0 2 2 2 2

// K-Means

// Fit
kMeansCfg:enlist[`iter]!enlist 2
.[.ml.clust.kmeans.fit;(d1;`mdist;4;kMeansCfg);1b]
value[group .ml.clust.kmeans.fit[d1;`e2dist;4;kMeansCfg]`clt]~d1clt
value[group .ml.clust.kmeans.fit[d1;`edist ;4;kMeansCfg]`clt]~d1clt
asc[key .ml.clust.kmeans.fit[d2;`edist ;4;kMeansCfg]]~`clt`data`inputs`reppts

// Predict
count[.ml.clust.kmeans.predict[d1tts 1;.ml.clust.kmeans.fit[d1tts 0;`e2dist;4;kMeansCfg]]]~15
count[.ml.clust.kmeans.predict[d1tts 1;.ml.clust.kmeans.fit[d1tts 0;`edist;4;kMeansCfg]]]~15

// Update
value[group .ml.clust.kmeans.update[d1tts 1;.ml.clust.kmeans.fit[d1tts 0;`e2dist;4;kMeansCfg]]`clt]~d1clt
`clt`data`inputs`reppts~asc key .ml.clust.kmeans.update[d1tts 1;.ml.clust.kmeans.fit[d1tts 0;`edist;4;kMeansCfg]]

// DBSCAN

// Fit
value[group .ml.clust.dbscan.fit[d1;`e2dist;5;5]`clt]~d1clt
value[group .ml.clust.dbscan.fit[d1;`edist;5;5]`clt]~d1clt
value[group .ml.clust.dbscan.fit[d1;`mdist;5;5]`clt]~d1clt
value[group .ml.clust.dbscan.fit[d2;`e2dist;4;300]`clt]~(til[197],198;197 199)
value[group .ml.clust.dbscan.fit[d2;`edist;4;17.2]`clt]~(til[197],198;197 199)
value[group .ml.clust.dbscan.fit[d2;`mdist;7;24]`clt]~(til 196;196 197 198 199)

// Predict
.ml.clust.dbscan.predict[d1tts 1;.ml.clust.dbscan.fit[d1tts 0;`e2dist;5;5]]~15#-1
.ml.clust.dbscan.predict[d1tts 1;.ml.clust.dbscan.fit[d1tts 0;`edist;5;5]]~15#-1
.ml.clust.dbscan.predict[d1tts 1;.ml.clust.dbscan.fit[d1tts 0;`mdist;5;5]]~15#-1

// Update
value[group .ml.clust.dbscan.update[d1tts 1;.ml.clust.dbscan.fit[d1tts 0;`e2dist;5;5]]`clt]~d1clt
value[group .ml.clust.dbscan.update[d1tts 1;.ml.clust.dbscan.fit[d1tts 0;`edist;5;5]]`clt]~d1clt
value[group .ml.clust.dbscan.update[d1tts 1;.ml.clust.dbscan.fit[d1tts 0;`mdist;5;5]]`clt]~d1clt
`clt`data`inputs`t~asc key .ml.clust.dbscan.update[d1tts 1;.ml.clust.dbscan.fit[d1tts 0;`mdist;5;5]]

// CURE

// Fit
value[group .ml.clust.cure.cutk[.ml.clust.cure.fit[d1;`e2dist;5;0];4]`clt]~d1clt
value[group .ml.clust.cure.cutk[.ml.clust.cure.fit[d1;`edist;10;0.2];4]`clt]~d1clt
value[group .ml.clust.cure.cutk[.ml.clust.cure.fit[d1;`mdist;3;0.15];4]`clt]~d1clt
value[group .ml.clust.cure.cutk[.ml.clust.cure.fit[d2;`e2dist;20;0];4]`clt]~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)
value[group .ml.clust.cure.cutk[.ml.clust.cure.fit[d2;`edist;20;0.2];4]`clt]~(0 1 3 4,.ml.arange[5;16;2],16 17 18 19 20 21 23 25 26 27 28 29 31 33 35,(37+til 86),124 126 132 142 146 160;2 6 8 10 12 14 22 24 30 32 34 36;.ml.arange[123;200;2];128 130 134 136 138 140 144,.ml.arange[148;199;2]except 160)
value[group .ml.clust.cure.cutk[.ml.clust.cure.fit[d2;`mdist;10;0.1];4]`clt]~(til[122],.ml.arange[122;191;2];.ml.arange[123;194;2];192 194 196 198;195 197 199)

// Predict
.ml.clust.cure.predict[d1tts 1;.ml.clust.cure.cutk[.ml.clust.cure.fit[d1tts 0;`e2dist;5;0];4]]~1 2 1 1 2 2 1 1 1 1 1 2 1 2 2
.ml.clust.cure.predict[d1tts 1;.ml.clust.cure.cutk[.ml.clust.cure.fit[d1tts 0;`edist;10;0.2];4]]~0 3 0 0 3 3 0 0 0 0 0 3 0 3 3
.ml.clust.cure.predict[d1tts 1;.ml.clust.cure.cutk[.ml.clust.cure.fit[d1tts 0;`mdist;3;0.15];4]]~1 3 1 3 3 3 1 1 1 1 1 3 1 3 3

// Hierarchical

// Fit
(asc each mat .ml.clust.hc.fit[d1;`e2dist;`single]`dgram)~asc each lnk[flip d1;`single;`sqeuclidean]`
(asc each mat .ml.clust.hc.fit[d1;`mdist;`complete]`dgram)~asc each lnk[flip d1;`complete;`cityblock]`
(asc each mat .ml.clust.hc.fit[d1;`edist;`centroid]`dgram)~asc each lnk[flip d1;`centroid;`euclidean]`
(asc each mat .ml.clust.hc.fit[d1;`mdist;`average]`dgram)~asc each lnk[flip d1;`average;`cityblock]`
.ml.clust.hc.fit[d2;`e2dist;`single][`dgram][`dist]~(lnk[flip d2;`single;`sqeuclidean]`)[;2]

value[group .ml.clust.hc.cutk[.ml.clust.hc.fit[d2;`e2dist;`single];4]`clt]~((til 195),196;195 197;enlist 198;enlist 199)
value[group .ml.clust.hc.cutk[.ml.clust.hc.fit[d2;`e2dist;`ward];4]`clt]~(.ml.arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(.ml.arange[1;43;2]);.ml.arange[123;200;2];(.ml.arange[128;200;2])except 132 142 146 160)
value[group .ml.clust.hc.cutk[.ml.clust.hc.fit[d2;`edist;`centroid];4]`clt]~((til 123);.ml.arange[123;194;2];.ml.arange[124;199;2];195 197 199)
value[group .ml.clust.hc.cutk[.ml.clust.hc.fit[d2;`edist;`complete];4]`clt]~(.ml.arange[0;43;2],(43+(til 80));(.ml.arange[1;43;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])
value[group .ml.clust.hc.cutk[.ml.clust.hc.fit[d2;`mdist;`average];4]`clt]~(.ml.arange[0;27;2],27,.ml.arange[28;43;2],43+(til 80);(.ml.arange[1;27;2],.ml.arange[29;42;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])
value[group .ml.clust.hc.cutk[tab2;4]`clt]~value group fclust[mat tab2`dgram;4;`maxclust]`
value[group .ml.clust.hc.cutk[tab3;4]`clt]~value group fclust[mat tab3`dgram;4;`maxclust]`
value[group .ml.clust.hc.cutk[tab4;4]`clt]~value group fclust[mat tab4`dgram;4;`maxclust]`
(1+.ml.clust.hc.cutk[tab1;4]`clt)~"j"$fclust[mat tab1`dgram;4;`maxclust]`

value[group .ml.clust.hc.cutdist[tab1;.45]`clt]~value group fclust[mat tab1`dgram;.45;`distance]`
value[group .ml.clust.hc.cutdist[tab2;4]`clt]~value group fclust[mat tab2`dgram;34;`distance]`
value[group .ml.clust.hc.cutdist[tab3;500]`clt]~value group fclust[mat tab3`dgram;500;`distance]`
value[group .ml.clust.hc.cutdist[tab4;30]`clt]~value group fclust[mat tab4`dgram;30;`distance]`

// Predict
.ml.clust.hc.predict[d1tts 1;.ml.clust.hc.cutk[.ml.clust.hc.fit[d1tts 0;`e2dist;`single];4]]~1 2 1 1 2 2 1 1 1 1 1 2 1 2 2
.ml.clust.hc.predict[d1tts 1;.ml.clust.hc.cutk[.ml.clust.hc.fit[d1tts 0;`e2dist;`ward];4]]~1 3 1 1 3 3 1 1 1 1 1 3 1 3 3
.ml.clust.hc.predict[d1tts 1;.ml.clust.hc.cutk[.ml.clust.hc.fit[d1tts 0;`edist;`centroid];4]]~1 3 1 1 3 3 1 1 1 1 1 3 1 3 3

