\l ../clust.q

arange:{x+z*til ceiling(y-x)%z}
d1:(60#"F";",")0:`:../data/ss5.csv
d2:flip@[;`Income`SpendingScore]("SSFFF";(),",")0:`:../data/cust.csv

/dbscan

(value exec idx by clt from .ml.clust.dbscan[d1;5;5])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.dbscan[d2;4;300])~((til 197),198;enlist 197;enlist 199)

/kmeans
/(value exec idx by clt from .ml.clust.kmeans[d1;4;2;1b;`e2dist])~((til 15);15+(til 15);30+(til 15);45+(til 15))

/(value exec idx by clt from .ml.clust.kmeans[d1;4;2;1b;`mdist])~((til 15);15+(til 15);30+(til 15);45+(til 15))

/cure
(value exec idx by clt from .ml.clust.cure[d1;4;`e2dist;5;0;0b;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;`e2dist;5;0;1b;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d2;4;`mdist;10;0;0b;0b])~((til 195),196;195 197;enlist 198;enlist 199)

/hierarchial

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`single])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`ward])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`centroid])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`average])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`e2dist;`complete])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`single])~((til 195),196;195 197;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`centroid])~((til 123);arange[123;194;2];arange[124;199;2];195 197 199)

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`average])~(arange[0;45;2];(arange[1;46;2]),(46+(til 77));arange[123;200;2];arange[124;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`complete])~(arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(arange[1;43;2]);arange[123;200;2];(arange[128;200;2])except 132 142 146 160)

(value exec idx by clt from .ml.clust.hc[d2;4;`e2dist;`ward])~(arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(arange[1;43;2]);arange[123;200;2];(arange[128;200;2])except 132 142 146 160)

(value exec idx by clt from .ml.clust.cure[d2;4;`e2dist;20;0;0b;0b])~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.cure[d2;4;`e2dist;20;0;1b;0b])~((til 192),193 195 197;192 194 196;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.hc[d1;4;`mdist;`single])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`mdist;`ward])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`mdist;`centroid])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d1;4;`mdist;`average])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;`mdist;5;0;0b;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.cure[d1;4;`mdist;5;0;1b;0b])~((til 15);15+(til 15);30+(til 15);45+(til 15))

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`single])~((til 195),196;195 197;enlist 198;enlist 199)

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`centroid])~(arange[0;43;2],43+(til 80);arange[1;43;2];arange[123;200;2];arange[124;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`average])~(arange[0;27;2],27,arange[28;43;2],43+(til 80);(arange[1;27;2],arange[29;42;2]);arange[123;200;2];arange[124;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`complete])~(arange[0;45;2];(arange[1;46;2]),(46+til 45),92 95 96 97 99 101 102 103 104 106 107 109 110 
 111 113 114 115 117 119 120 122;91 93 94 98 100 105 108 112 116 118 121,arange[124;200;2];arange[123;200;2])

(value exec idx by clt from .ml.clust.hc[d2;4;`mdist;`ward])~((til 46),51 53;46 47 48 49 50 52,54+til 69;arange[123;200;2];(arange[124;200;2]))

