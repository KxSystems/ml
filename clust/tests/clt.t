\l ml.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q
\S 10

plt:   .p.import`matplotlib.pyplot
fcps:  .p.import[`pyclustering.samples.definitions]`:FCPS_SAMPLES
read:  .p.import[`pyclustering.utils]`:read_sample
pydb:  .p.import[`sklearn.metrics]`:davies_bouldin_score
pysil: .p.import[`sklearn.metrics]`:silhouette_score
hscore:.p.import[`sklearn.metrics]`:homogeneity_score

d1:(60#"F";",")0:`:clust/notebooks/data/ss5.csv
d2:flip@[;`AnnualIncome`SpendingScore]("SSFFF";(),",")0:`:clust/notebooks/data/Mall_Customers.csv
d3:flip (2#"F";",")0:`:clust/notebooks/data/sample1.csv
d4:read[fcps`:SAMPLE_TARGET]`
d5:read[fcps`:SAMPLE_LSUN]`

/kmeans
(value exec idx by clt from .ml.clust.kmeans[d1;4;2;1b;`e2dist])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.kmeans[d1;4;2;1b;`edist])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.kmeans[d1;4;2;1b;`mdist])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.kmeans[distinct d2;5;5;1b;`e2dist])~(til[121]except 7 11 19 25 29 33 35 39 41;7 11 19 25 29 33 35 39 41,.ml.arange[121;128;2],.ml.arange[130;155;2],155,157,159;122,124,126,128,.ml.arange[129;154;2],.ml.arange[156;187;2];.ml.arange[161;196;2];188 190 192 194)

(value exec idx by clt from .ml.clust.kmeans[distinct d2;5;5;1b;`edist])~(.ml.arange[0;45;2];.ml.arange[1;42;2];43,(45+til[74]),120;119,.ml.arange[122;129;2],.ml.arange[129;154;2],.ml.arange[156;195;2];.ml.arange[121;128;2],.ml.arange[130;155;2],.ml.arange[155;196;2])

(value exec idx by clt from .ml.clust.kmeans[distinct d2;5;5;0b;`mdist])~(.ml.arange[0;41;2],44;.ml.arange[1;46;2];42,(46+til 75),124 129 139;.ml.arange[121;128;2],.ml.arange[130;155;2],.ml.arange[155;196;2];(122,.ml.arange[126;129;2],.ml.arange[131;154;2],.ml.arange[156;195;2])except 139)


/dbscan

(value exec idx by clt from .ml.clust.dbscan[d1;`e2dist;5;5])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.dbscan[d2;`e2dist;4;300])~((til 197),198;enlist 197;enlist 199)

(value exec idx by clt from .ml.clust.dbscan[d1;`edist;5;5])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.dbscan[d2;`edist;4;18])~((til 197),198;enlist 197;enlist 199)

(value exec idx by clt from .ml.clust.dbscan[d1;`mdist;5;5])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.dbscan[d2;`mdist;4;25])~(til[197],198;enlist 197;enlist 199)

/cure
(value exec idx by clt from .ml.clust.cure[d1;4;5;()])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;5;`df`c`b!(`e2dist;0;1b)])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;5;`df`c`b!(`edist;0;0b)])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;5;`df`c`b!(`edist;0;1b)])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;5;`df`c`b!(`mdist;0;0b)])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;5;`df`c`b!(`mdist;0;1b)])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d2;4;20;()])~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.cure[d2;4;20;`df`c`b!(`e2dist;0;1b)])~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.cure[d2;4;20;`df`c`b!(`edist;0;0b)])~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.cure[d2;4;20;`df`c`b!(`edist;0;1b)])~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.cure[d2;4;10;`df`c`b!(`mdist;0;0b)])~(til[123],.ml.arange[124;195;2];.ml.arange[123;200;2];enlist 196;enlist 198)

(value exec idx by clt from .ml.clust.cure[d2;4;10;`df`c`b!(`mdist;0;1b)])~(til[123],.ml.arange[124;195;2];.ml.arange[123;200;2];enlist 196;enlist 198)

/hierarchial

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`single;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`ward;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`centroid;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`average;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`complete;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`single;0b])~((til 195),196;195 197;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.hc[d2;4;`edist;`centroid;0b])~((til 123);.ml.arange[123;194;2];.ml.arange[124;199;2];195 197 199)

(value exec idx by clt from .ml.clust.hc[d2;4;`edist;`average;0b])~(.ml.arange[0;43;2],(43+(til 80));(.ml.arange[1;42;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`edist;`complete;0b])~(.ml.arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(.ml.arange[1;43;2]);.ml.arange[123;200;2];(.ml.arange[128;200;2])except 132 142 146 160)

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`ward;0b])~(.ml.arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(.ml.arange[1;43;2]);.ml.arange[123;200;2];(.ml.arange[128;200;2])except 132 142 146 160)

(value exec idx by clt from .ml.clust.hc[d1;4;`mdist;`single;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`ward;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`mdist;`centroid;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`mdist;`average;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`single;0b])~((til 195),196;195 197;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`centroid;0b])~(.ml.arange[0;43;2],43+(til 80);.ml.arange[1;43;2];.ml.arange[123;200;2];.ml.arange[124;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`average;0b])~(.ml.arange[0;27;2],27,.ml.arange[28;43;2],43+(til 80);(.ml.arange[1;27;2],.ml.arange[29;42;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`complete;0b])~((.ml.arange[0;45;2]),46 47 48 49 50 52,(54+til 69);(.ml.arange[1;46;2]),51 53;.ml.arange[123;200;2];.ml.arange[124;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`ward;0b])~(.ml.arange[0;41;2],(42+til 81),124,126,132,142,146,160;.ml.arange[1;42;2];.ml.arange[123;200;2];128,130,134,136,138,140,144,(.ml.arange[148;199;2])except 160)


/dendogram
(select i1,i2,n from .ml.clust.dgram[d3;`edist;`centroid])~([]i1:1 0 5 6 11 14 12 16 15i;i2:3 2 8 9 10 4 7 13 17i;n:2i)

(select i1,i2,n from .ml.clust.dgram[d3;`edist;`single])~([]i1:1 0 5 11 6 13 14 12 15i;i2:3 2 8 10 9 4 7 16 17i;n:2 2 2 4 2 5 3 5 10i)

(select i1,i2,n from .ml.clust.dgram[d3;`edist;`average])~([]i1:1 0 5 6 10 11 12 16 15i;i2:3 2 8 9 4 14 7 13 17i;n:2 2 2 2 3 5 3 5 10i)

(select i1,i2,n from .ml.clust.dgram[d3;`edist;`complete])~([]i1:1 0 5 6 10 12 11 15 16i;i2:3 2 8 9 4 7 14 13 17i;n:2 2 2 2 3 3 5 5 10i)

(select i1,i2,n from .ml.clust.dgram[d3;`mdist;`centroid])~([]i1:1 5 0 12 7 11 15 13 17i;i2:3 8 2 10 9 14 6 4 16i;n:2i)

(select i1,i2,n from .ml.clust.dgram[d3;`mdist;`single])~([]i1:1 5 0 12 7 13 6 11 15i;i2:3 8 2 10 9 4 14 16 17i;n:2 2 2 4 2 5 3 5 10i)

(select i1,i2,n from .ml.clust.dgram[d3;`mdist;`average])~([]i1:1 5 0 12 7 13 11 16 15i;i2:3 8 2 10 9 4 14 6 17i;n:2 2 2 4 2 5 4 5 10i)

(select i1,i2,n from .ml.clust.dgram[d3;`mdist;`complete])~([]i1:1 5 0 7 12 11 15 14 17i;i2:3 8 2 9 10 13 6 4 16i;n:2 2 2 2 4 4 5 5 10i)
/streaming
.ml.clust.cure[d3;4;30;`b`s!1 1]~`reps`tree`r2c`r2l!(d3[0 2 1 3 4 5 8 6 9 7];enlist each (neg 1;0b;1b;9 5 6 7 8 0 1 2 3 4;0n;0N);0 0 0 0 0 1 1 2 2 3;10#0)

.ml.clust.cure[d3;4;30;`df`b`s!(`edist;1;1)]~`reps`tree`r2c`r2l!(d3[0 2 1 3 4 5 8 6 9 7];enlist each (neg 1;0b;1b;9 5 6 7 8 0 1 2 3 4;0n;0N);0 0 0 0 0 1 1 2 2 3;10#0)

.ml.clust.cure[d3;4;30;`df`b`s!(`mdist;1;1)]~`reps`tree`r2c`r2l!(d3[0 2 1 3 4 5 8 6 7 9];enlist each (neg 1;0b;1b;7 5 6 8 9 0 1 2 3 4;0n;0N);0 0 0 0 0 1 1 2 3 3;10#0)

/scoring metrics
r:.ml.clust.hc[d4;6;`edist;`single;0b]
r1:.ml.clust.dbscan[d5;`e2dist;5;.3]
rnd:(count d5)?3

.ml.clust.daviesbouldin[r]~pydb[d4;r`clt]`

.ml.clust.daviesbouldin[r]~pydb[d4;r`clt]`

(ceiling(.ml.clust.dunn[r1;`edist]*1000))~148

.ml.clust.silhouette[r1;`edist;1b]~pysil[d5;raze r1`clt]`

.ml.clust.silhouette[r;`edist;1b]~pysil[d4;raze r`clt]`

(ceiling .ml.clust.elbow[d3;`mdist;2])~enlist 3

.ml.clust.homogeneity[r1`clt;rnd]~hscore[rnd;r1`clt]`
