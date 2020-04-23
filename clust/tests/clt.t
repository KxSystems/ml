\l ml.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q
\S 10

d1:flip (60#"F";",")0:`:clust/notebooks/data/ss5.csv
d2:@[;`AnnualIncome`SpendingScore]("SSFFF";(),",")0:`:clust/notebooks/data/Mall_Customers.csv

/kmeans
value[group .ml.clust.kmeans[d1;`e2dist;4;2;1b]]~d1clt:((til 15);15+(til 15);30+(til 15);45+(til 15))

value[group .ml.clust.kmeans[d1;`edist;4;2;1b]]~d1clt


/dbscan

value[group .ml.clust.dbscan[d1;`e2dist;5;5]]~d1clt

value[group .ml.clust.dbscan[d1;`edist;5;5]]~d1clt

value[group .ml.clust.dbscan[d1;`mdist;5;5]]~d1clt

value[group .ml.clust.dbscan[d2;`e2dist;4;300]]~(til[197],198;197 199)

value[group .ml.clust.dbscan[d2;`edist;4;17.2]]~(til[197],198;197 199)

value[group .ml.clust.dbscan[d2;`mdist;7;24]]~(til 196;196 197 198 199)

/cure
value[group .ml.clust.cure[d1;`e2dist;4;5;0]]~d1clt

value[group .ml.clust.cure[d1;`edist;4;10;0.2]]~d1clt

value[group .ml.clust.cure[d1;`mdist;4;3;0.15]]~d1clt

value[group .ml.clust.cure[d2;`e2dist;4;20;0]]~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)

value[group .ml.clust.cure[d2;`edist;4;20;0.2]]~(0 1 3 4,.ml.arange[5;16;2],16 17 18 19 20 21 23 25 26 27 28 29 31 33 35,(37+til 86),124 126 132 142 146 160;2 6 8 10 12 14 22 24 30 32 34 36;.ml.arange[123;200;2];128 130 134 136 138 140 144,.ml.arange[148;199;2]except 160)

value[group .ml.clust.cure[d2;`mdist;4;10;0.1]]~(til[122],.ml.arange[122;191;2];.ml.arange[123;194;2];192 194 196 198;195 197 199)

/hierarchical

value[group .ml.clust.hc[d1;`e2dist;`single;4]]~d1clt

value[group .ml.clust.hc[d1;`e2dist;`ward;4]]~d1clt

value[group .ml.clust.hc[d1;`e2dist;`centroid;4]]~d1clt

value[group .ml.clust.hc[d1;`e2dist;`average;4]]~d1clt

value[group .ml.clust.hc[d1;`e2dist;`complete;4]]~d1clt

value[group .ml.clust.hc[d2;`e2dist;`single;4]]~((til 195),196;195 197;enlist 198;enlist 199)

value[group .ml.clust.hc[d2;`e2dist;`ward;4]]~(.ml.arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(.ml.arange[1;43;2]);.ml.arange[123;200;2];(.ml.arange[128;200;2])except 132 142 146 160)

value[group .ml.clust.hc[d2;`edist;`centroid;4]]~((til 123);.ml.arange[123;194;2];.ml.arange[124;199;2];195 197 199)

value[group .ml.clust.hc[d2;`edist;`complete;4]]~(.ml.arange[0;43;2],(43+(til 80));(.ml.arange[1;43;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])

// ap

value[group .ml.clust.ap[d1;`e2dist;0.7;min]]~d1clt

value[group .ml.clust.ap[d1;`mdist;0.3;avg]]~((til[15] except 12),30;12,31+til 14;(15,45+til 15)except 47;(16+til[14]),47)

count[value group .ml.clust.ap[d2;`edist;0.2;max]]~ 199






