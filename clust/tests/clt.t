\l ml.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q

\S 10

lnk:.p.import[`scipy.cluster.hierarchy]`:linkage
fclust:.p.import[`scipy.cluster.hierarchy]`:fcluster
mat:{"f"$flip value flip x}
d1:flip(60#"F";",")0:`:clust/tests/data/ss5.csv
d2:@[;`AnnualIncome`SpendingScore]("SSIII";(),",")0:`:clust/tests/data/Mall_Customers.csv
tab1:.ml.clust.hc[d1;`mdist;`single]
tab2:.ml.clust.hc[d1;`e2dist;`average]
tab3:.ml.clust.hc[d2;`e2dist;`centroid]
tab4:.ml.clust.hc[d2;`edist;`complete]

// K-Means

value[group .ml.clust.kmeans[d1;`e2dist;4;2;1b]]~d1clt:((til 15);15+(til 15);30+(til 15);45+(til 15))
value[group .ml.clust.kmeans[d1;`edist;4;2;1b]]~d1clt
value[group .ml.clust.kmeans[d2;`e2dist;4;3;1b]]~(til[122]except 41;41 122,.ml.arange[123;180;2];.ml.arange[124;199;2];.ml.arange[181;200;2])

// DBSCAN

value[group .ml.clust.dbscan[d1;`e2dist;5;5]]~d1clt
value[group .ml.clust.dbscan[d1;`edist;5;5]]~d1clt
value[group .ml.clust.dbscan[d1;`mdist;5;5]]~d1clt
value[group .ml.clust.dbscan[d2;`e2dist;4;300]]~(til[197],198;197 199)
value[group .ml.clust.dbscan[d2;`edist;4;17.2]]~(til[197],198;197 199)
value[group .ml.clust.dbscan[d2;`mdist;7;24]]~(til 196;196 197 198 199)

// CURE 

value[group .ml.clust.dgram2clt[.ml.clust.cure[d1;`e2dist;5;0];`k;4]]~d1clt
value[group .ml.clust.dgram2clt[.ml.clust.cure[d1;`edist;10;0.2];`k;4]]~d1clt
value[group .ml.clust.dgram2clt[.ml.clust.cure[d1;`mdist;3;0.15];`k;4]]~d1clt
value[group .ml.clust.dgram2clt[.ml.clust.cure[d2;`e2dist;20;0];`k;4]]~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)
value[group .ml.clust.dgram2clt[.ml.clust.cure[d2;`edist;20;0.2];`k;4]]~(0 1 3 4,.ml.arange[5;16;2],16 17 18 19 20 21 23 25 26 27 28 29 31 33 35,(37+til 86),124 126 132 142 146 160;2 6 8 10 12 14 22 24 30 32 34 36;.ml.arange[123;200;2];128 130 134 136 138 140 144,.ml.arange[148;199;2]except 160)
value[group .ml.clust.dgram2clt[.ml.clust.cure[d2;`mdist;10;0.1];`k;4]]~(til[122],.ml.arange[122;191;2];.ml.arange[123;194;2];192 194 196 198;195 197 199)

// Hierarchical 

(asc each mat .ml.clust.hc[d1;`e2dist;`single])~asc each lnk[flip d1;`single;`sqeuclidean]`
(asc each mat .ml.clust.hc[d1;`mdist;`complete])~asc each lnk[flip d1;`complete;`cityblock]`
(asc each mat .ml.clust.hc[d1;`edist;`centroid])~asc each lnk[flip d1;`centroid;`euclidean]`
(asc each mat .ml.clust.hc[d1;`mdist;`average])~asc each lnk[flip d1;`average;`cityblock]`
.ml.clust.hc[d2;`e2dist;`single][`dist]~(lnk[flip d2;`single;`sqeuclidean]`)[;2]
value[group .ml.clust.dgram2clt[.ml.clust.hc[d2;`e2dist;`single];`k;4]]~((til 195),196;195 197;enlist 198;enlist 199)
value[group .ml.clust.dgram2clt[.ml.clust.hc[d2;`e2dist;`ward];`k;4]]~(.ml.arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(.ml.arange[1;43;2]);.ml.arange[123;200;2];(.ml.arange[128;200;2])except 132 142 146 160)
value[group .ml.clust.dgram2clt[.ml.clust.hc[d2;`edist;`centroid];`k;4]]~((til 123);.ml.arange[123;194;2];.ml.arange[124;199;2];195 197 199)
value[group .ml.clust.dgram2clt[.ml.clust.hc[d2;`edist;`complete];`k;4]]~(.ml.arange[0;43;2],(43+(til 80));(.ml.arange[1;43;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])
value[group .ml.clust.dgram2clt[.ml.clust.hc[d2;`mdist;`average];`k;4]]~(.ml.arange[0;27;2],27,.ml.arange[28;43;2],43+(til 80);(.ml.arange[1;27;2],.ml.arange[29;42;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])

// Dgram2clt

(.ml.clust.dgram2clt[tab1;`k;4]+1)~"j"$fclust[mat tab1;4;`maxclust]`
value[group .ml.clust.dgram2clt[tab2;`k;4]]~value group fclust[mat tab2;4;`maxclust]`
value[group .ml.clust.dgram2clt[tab3;`k;4]]~value group fclust[mat tab3;4;`maxclust]`
value[group .ml.clust.dgram2clt[tab4;`k;4]]~value group fclust[mat tab4;4;`maxclust]`
value[group .ml.clust.dgram2clt[tab1;`dist;.45]]~value group fclust[mat tab1;.45;`distance]`
value[group .ml.clust.dgram2clt[tab2;`dist;4]]~value group fclust[mat tab2;34;`distance]`
value[group .ml.clust.dgram2clt[tab3;`dist;500]]~value group fclust[mat tab3;500;`distance]`
value[group .ml.clust.dgram2clt[tab4;`dist;30]]~value group fclust[mat tab4;30;`distance]`


// Affinity Propagation

value[group .ml.clust.ap[d1;`e2dist;0.7;min]]~d1clt
value[group .ml.clust.ap[d1;`mdist;0.3;avg]]~((til[15] except 12),30;12,31+til 14;(15,45+til 15)except 47;(16+til[14]),47)
value[group .ml.clust.ap[d2;`mdist;0.8;avg]]~(.ml.arange[0;45;2],47 48 49 54 55 56 57 59 66 67 69 71 72 74 77 79 82 83 85,((89+til[13])except 90 95),105 106 107 108 109 112 113 114 115 116 118 121 199;(.ml.arange[1;46;2],46 50 51 52 53 58 60 61 62 63 64 65 68 70 73 75 76 78 80 81 84 86 87 88 90 95 102 103 104 110 111 117 119 120 122 123 125 127 129 131 133 198) except 11;11,.ml.arange[124;197;2];.ml.arange[135;198;2])
count[value group .ml.clust.ap[d2;`edist;0.2;max]]~ 199

