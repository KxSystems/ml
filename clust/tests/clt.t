\l ml.q
.ml.loadfile`:clust/tests/passfail.q
.ml.loadfile`:clust/init.q
.ml.loadfile`:util/init.q

// Initialize datasets

\S 42

// Python imports
lnk   :.p.import[`scipy.cluster.hierarchy]`:linkage
fclust:.p.import[`scipy.cluster.hierarchy]`:fcluster

// q Utilities
mat        :{"f"$flip value flip x}
clusterIdxs:{value group(x . y)[`modelInfo;`clust]}
clusterKeys:{key   group(x . y)[`modelInfo;`clust]}
clusterIdxsDendro:{value group(x . y)`clust}
clusterIdxsUpd:{value group(x . y)[`modelInfo;`clust]}
clusterAdd1:{1+(x . y)`clust}
qDendrogram:{asc each x(y . z)[`modelInfo;`dgram]}
algoOutputs:{asc key x . y}
algoOutputsFit:{asc key first x . y}
countOutput:{count x y}
pythonRes  :{[fclust;mat;t;clust;param]value group fclust[.p.toraw mat t[`modelInfo;`dgram];clust;param]`}[fclust;mat]
pythonDgram:{[lnk;d;lf;df]asc each lnk[.p.toraw flip d;lf;df]`}[lnk]
qDgramDists:{(x . y)[`modelInfo;`dgram]`dist}

// Datasets
d1:flip(60#"F";",")0:`:clust/tests/data/ss5.csv
d1tts:flip each(0;45)_flip d1
d2:@[;`AnnualIncome`SpendingScore]("SSIII";(),",")0:`:clust/tests/data/Mall_Customers.csv

// Configurations
kMeansCfg:enlist[`iter]!enlist 2

// Affinity Propagation

// Expected Results
d1clt:(15*til 4)+\:til 15
APclt:2 2 2 2 2 2 0 2 0 0 0 2 2 2 2

// Fit
passingTest[clusterIdxs[.ml.clust.ap.fit];(d1;`nege2dist;0.7;min;(::));1b;d1clt]
passingTest[clusterIdxs[.ml.clust.ap.fit];(d1;`nege2dist;0.9;med;(::));1b;d1clt]
passingTest[clusterIdxs[.ml.clust.ap.fit];(d2;`nege2dist;0.01;{[x] -10.};(::));1b;enlist til 200]
passingTest[clusterIdxs[.ml.clust.ap.fit];(d1tts 0;`nege2dist;0.3;min;`maxrun`maxmatch!100 10);1b;enlist til 45]
passingTest[clusterKeys[.ml.clust.ap.fit];(d2;`nege2dist;0.95;{[x] -20000.};enlist[`maxsame]!enlist 150);1b;til 5]
passingTest[clusterKeys[.ml.clust.ap.fit];(d2;`nege2dist;0.5;min;(::));1b;til 5]
passingTest[algoOutputsFit[.ml.clust.ap.fit];(d2;`nege2dist;0.5;min;(::));1b;`clust`data`exemplars`inputs]
failingTest[.ml.clust.ap.fit;(d1;`e2dist;0.7;min;(::));0b;"AP must be used with nege2dist"]
failingTest[.ml.clust.ap.fit;(d1;`nege2dist;0.7;min;100);0b;"iter must be (::) or a dictionary"]
failingTest[.ml.clust.ap.fit;(d1;`nege2dist;0.7;min;([]total:10,();nochange:5,()));0b;"iter must be (::) or a dictionary"]
failingTest[.ml.clust.ap.fit;(100?`8;`nege2dist;0.7;min;(::));0b;"Dataset not suitable for clustering. Must be convertible to floats."]


// Predict
passingTest[.ml.clust.ap.fit[d1tts 0;`nege2dist;0.7;min;(::)]`predict;d1tts 1;1b;APclt]
passingTest[.ml.clust.ap.fit[d1tts 0;`nege2dist;0.7;med;`maxrun`maxmatch!100 10]`predict;d1tts 1;1b;APclt]
failingTest[.ml.clust.ap.fit[d1tts 0;`nege2dist;0.7;min;(::)]`predict;100?`7;1b;"Dataset not suitable for clustering. Must be convertible to floats."]
failingTest[.ml.clust.ap.predict;(enlist[`modelInfo]!enlist enlist[`clust]!enlist -1;d1tts 1);
            0b;"'.ml.clust.ap.fit' did not converge, all clusters returned -1. Cannot predict new data."]

// K-Means

// Fit
passingTest[clusterIdxs[.ml.clust.kmeans.fit];(d1;`e2dist;4;kMeansCfg);1b;d1clt]
passingTest[clusterIdxs[.ml.clust.kmeans.fit];(d1;`e2dist;4;kMeansCfg,enlist[`iter]!enlist 3);1b;d1clt]
passingTest[clusterIdxs[.ml.clust.kmeans.fit];(d1;`e2dist;4;kMeansCfg,enlist[`init]!enlist 0b);1b;d1clt]
passingTest[clusterIdxs[.ml.clust.kmeans.fit];(d1;`e2dist;4;kMeansCfg,enlist[`thresh]!enlist 1e-3);1b;d1clt]
passingTest[clusterIdxs[.ml.clust.kmeans.fit];(d1;`edist;4;kMeansCfg);1b;d1clt]
passingTest[clusterKeys[.ml.clust.kmeans.fit];(d1;`edist;4;kMeansCfg);1b;til 4]
passingTest[clusterKeys[.ml.clust.kmeans.fit];(d1;`e2dist;7;kMeansCfg);1b;til 7]
passingTest[algoOutputsFit[.ml.clust.kmeans.fit];(d2;`edist;4;kMeansCfg);1b;`clust`data`inputs`repPts]
failingTest[.ml.clust.kmeans.fit;(d1;`mdist;4;kMeansCfg);0b;"kmeans must be used with edist/e2dist"]
failingTest[.ml.clust.kmeans.fit;(d1;`nege2dist;4;74);0b;"config must be (::) or a dictionary"]
failingTest[.ml.clust.kmeans.fit;(d1;`nege2dist;4;([]total:28,();nochange:100,()));0b;"config must be (::) or a dictionary"]
failingTest[.ml.clust.kmeans.fit;(1000?`a`b`c;`edist;4;kMeansCfg);0b;"Dataset not suitable for clustering. Must be convertible to floats."]

// Predict
passingTest[countOutput[.ml.clust.kmeans.fit[d1tts 0;`e2dist;4;kMeansCfg]`predict];d1tts 1;1b;15]
passingTest[countOutput[.ml.clust.kmeans.fit[d1tts 0;`edist;4;kMeansCfg]`predict];d1tts 1;1b;15]
failingTest[.ml.clust.kmeans.fit[d1tts 0;`e2dist;4;kMeansCfg]`predict;100?`4;1b;"Dataset not suitable for clustering. Must be convertible to floats."]

// Update
passingTest[algoOutputs[.ml.clust.kmeans.fit[d1tts 0;`edist;4;kMeansCfg]`update];enlist d1tts 1;1b;`modelInfo`predict`update]
passingTest[clusterIdxsUpd[.ml.clust.kmeans.fit[d1tts 0;`e2dist;4;kMeansCfg]`update];enlist d1tts 1;1b;d1clt]
failingTest[.ml.clust.kmeans.update;(()!();1000?`2);0b;"Dataset not suitable for clustering. Must be convertible to floats."]


// DBSCAN

// Fit
passingTest[clusterIdxs[.ml.clust.dbscan.fit];(d1;`e2dist;5;5);1b;d1clt]
passingTest[clusterIdxs[.ml.clust.dbscan.fit];(d1;`edist;5;5);1b;d1clt]
passingTest[clusterIdxs[.ml.clust.dbscan.fit];(d1;`mdist;5;5);1b;d1clt]
passingTest[clusterIdxs[.ml.clust.dbscan.fit];(d2;`e2dist;4;300);1b;(til[197],198;197 199)]
passingTest[clusterIdxs[.ml.clust.dbscan.fit];(d2;`edist;4;17.2);1b;(til[197],198;197 199)]
passingTest[clusterIdxs[.ml.clust.dbscan.fit];(d2;`mdist;7;24);1b;(til 196;196 197 198 199)]
failingTest[.ml.clust.dbscan.fit;(50?`x`y;`edist;4;300);0b;"Dataset not suitable for clustering. Must be convertible to floats."]
failingTest[.ml.clust.dbscan.fit;(d1;`euclidean;5;5);0b;"invalid distance metric"]

// Predict
passingTest[.ml.clust.dbscan.fit[d1tts 0;`e2dist;5;5]`predict;d1tts 1;1b;15#-1]
passingTest[.ml.clust.dbscan.fit[d1tts 0;`edist;5;5]`predict;d1tts 1;1b;15#-1]
passingTest[.ml.clust.dbscan.fit[d1tts 0;`mdist;5;5]`predict;d1tts 1;1b;15#-1]
failingTest[.ml.clust.dbscan.fit[d1tts 0;`e2dist;5;5]`predict;(50?`x`y);1b;"Dataset not suitable for clustering. Must be convertible to floats."]

// Update
passingTest[clusterIdxsUpd[.ml.clust.dbscan.fit[d1tts 0;`e2dist;5;5]`update];enlist d1tts 1;1b;d1clt]
passingTest[clusterIdxsUpd[.ml.clust.dbscan.fit[d1tts 0;`edist;5;5]`update];enlist d1tts 1;1b;d1clt]
passingTest[clusterIdxsUpd[.ml.clust.dbscan.fit[d1tts 0;`mdist;5;5]`update];enlist d1tts 1;1b;d1clt]
passingTest[algoOutputs[.ml.clust.dbscan.fit[d1tts 0;`mdist;5;5]`update];enlist d1tts 1;1b;`modelInfo`predict`update]
failingTest[.ml.clust.dbscan.update;(()!();50?`x`y);0b;"Dataset not suitable for clustering. Must be convertible to floats."]

// CURE

// Expected Results
cured2clt1:((til 192),193 195 197;192 194 196;enlist 198;enlist 199)
cured2clt2:(0 1 3 4,.ml.arange[5;16;2],16 17 18 19 20 21 23 25 26 27 28 29 31 33 35,(37+til 86),124 126 132 142 146 160;2 6 8 10 12 14 22 24 30 32 34 36;.ml.arange[123;200;2];128 130 134 136 138 140 144,.ml.arange[148;199;2]except 160)
cured2clt3:(til[122],.ml.arange[122;191;2];.ml.arange[123;194;2];192 194 196 198;195 197 199)
cured1pred1:1 2 1 1 2 2 1 1 1 1 1 2 1 2 2
cured1pred2:0 3 0 0 3 3 0 0 0 0 0 3 0 3 3
cured1pred3:1 3 1 3 3 3 1 1 1 1 1 3 1 3 3

// Fit
passingTest[clusterIdxsDendro[.ml.clust.cure.cutK];(.ml.clust.cure.fit[d1;`e2dist;5;0];4);1b;d1clt]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutK];(.ml.clust.cure.fit[d1;`edist;10;0.2];4);1b;d1clt]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutK];(.ml.clust.cure.fit[d1;`mdist;3;0.15];4);1b;d1clt]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutK];(.ml.clust.cure.fit[d2;`e2dist;20;0];4);1b;cured2clt1]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutK];(.ml.clust.cure.fit[d2;`edist;20;0.2];4);1b;cured2clt2]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutK];(.ml.clust.cure.fit[d2;`mdist;10;0.1];4);1b;cured2clt3]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutDist];(.ml.clust.cure.fit[d1;`e2dist;5;0];2.);1b;d1clt]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutDist];(.ml.clust.cure.fit[d1;`edist;10;0.2];2.);1b;d1clt]
passingTest[clusterIdxsDendro[.ml.clust.cure.cutDist];(.ml.clust.cure.fit[d1;`mdist;3;0.15];2.);1b;d1clt]
passingTest[algoOutputsFit[.ml.clust.cure.fit];(d1;`e2dist;5;0);1b;`data`dgram`inputs]
failingTest[.ml.clust.cure.fit;(821?`2;`e2dist;5;0);0b;"Dataset not suitable for clustering. Must be convertible to floats."]
failingTest[.ml.clust.cure.fit;(d1;`newmetric;5;0);0b;"invalid distance metric"]

// FitPredict
passingTest[clusterIdxsDendro[.ml.clust.cure.fitPredict];(d1;`e2dist;5;0;enlist[`k]!enlist 4);1b;d1clt]
passingTest[clusterIdxsDendro[.ml.clust.cure.fitPredict];(d1;`edist;10;0.2;enlist[`k]!enlist 4);1b;d1clt]
passingTest[clusterIdxsDendro[.ml.clust.cure.fitPredict];(d1;`mdist;3;0.15;enlist[`k]!enlist 4);1b;d1clt]

// Predict
passingTest[.ml.clust.cure.fit[d1tts 0;`e2dist;5;0]`predict;(d1tts 1;enlist[`k]!enlist 4);0b;cured1pred1]
passingTest[.ml.clust.cure.fit[d1tts 0;`edist;10;0.2]`predict;(d1tts 1;enlist[`k]!enlist 4);0b;cured1pred2]
passingTest[.ml.clust.cure.fit[d1tts 0;`mdist;3;0.15]`predict;(d1tts 1;enlist[`k]!enlist 4);0b;cured1pred3]
failingTest[.ml.clust.cure.fit[d1tts 0;`e2dist;5;0]`predict;(182?`5;enlist[`k]!enlist 3);0b;"Dataset not suitable for clustering. Must be convertible to floats."]

// Hierarchical

// Expected Results
hcResSingle:((til 195),196;195 197;enlist 198;enlist 199)
hcResWard:(.ml.arange[0;43;2],(43+(til 80)),124 126 132 142 146 160;(.ml.arange[1;43;2]);.ml.arange[123;200;2];(.ml.arange[128;200;2])except 132 142 146 160)
hcResCentroid:((til 123);.ml.arange[123;194;2];.ml.arange[124;199;2];195 197 199)
hcResComplete:(.ml.arange[0;43;2],(43+(til 80));(.ml.arange[1;43;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])
hcResAverage:(.ml.arange[0;27;2],27,.ml.arange[28;43;2],43+(til 80);(.ml.arange[1;27;2],.ml.arange[29;42;2]);.ml.arange[123;200;2];.ml.arange[124;200;2])
tab1:.ml.clust.hc.fit[d1;`mdist ;`single]
tab2:.ml.clust.hc.fit[d1;`e2dist;`average]
tab3:.ml.clust.hc.fit[d2;`e2dist;`centroid]
tab4:.ml.clust.hc.fit[d2;`edist ;`complete]
hct1fit:"j"$fclust[.p.toraw mat tab1[`modelInfo;`dgram];4;`maxclust]`
hcd1pred1:1 2 1 1 2 2 1 1 1 1 1 2 1 2 2
hcd1pred2:1 3 1 1 3 3 1 1 1 1 1 3 1 3 3
hcd1pred3:1 3 1 1 3 3 1 1 1 1 1 3 1 3 3
pyDgramDists:(lnk[.p.toraw flip d2;`single;`sqeuclidean]`)[;2]

// Fit
passingTest[clusterAdd1[.ml.clust.hc.cutK   ];(tab1;4);1b;hct1fit]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(.ml.clust.hc.fit[d2;`e2dist;`single];4);1b;hcResSingle]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(.ml.clust.hc.fit[d2;`e2dist;`ward];4);1b;hcResWard]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(.ml.clust.hc.fit[d2;`edist;`centroid];4);1b;hcResCentroid]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(.ml.clust.hc.fit[d2;`edist;`complete];4);1b;hcResComplete]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(.ml.clust.hc.fit[d2;`mdist;`average];4);1b;hcResAverage]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(tab2;4);1b;pythonRes[tab2;4;`maxclust]]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(tab3;4);1b;pythonRes[tab3;4;`maxclust]]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutK];(tab4;4);1b;pythonRes[tab4;4;`maxclust]]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutDist];(tab1;.45);1b;pythonRes[tab1;.45;`distance]]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutDist];(tab2;4);1b;pythonRes[tab2;34;`distance]]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutDist];(tab3;500);1b;pythonRes[tab3;500;`distance]]
passingTest[clusterIdxsDendro[.ml.clust.hc.cutDist];(tab4;30);1b;pythonRes[tab4;30;`distance]]
passingTest[qDendrogram[mat;.ml.clust.hc.fit];(d1;`e2dist;`single);1b;pythonDgram[d1;`single;`sqeuclidean]]
passingTest[qDendrogram[mat;.ml.clust.hc.fit];(d1;`mdist;`complete);1b;pythonDgram[d1;`complete;`cityblock]]
passingTest[qDendrogram[mat;.ml.clust.hc.fit];(d1;`edist;`centroid);1b;pythonDgram[d1;`centroid;`euclidean]]
passingTest[qDendrogram[mat;.ml.clust.hc.fit];(d1;`mdist;`average);1b;pythonDgram[d1;`average;`cityblock]]
passingTest[qDgramDists[.ml.clust.hc.fit];(d2;`e2dist;`single);1b;pyDgramDists]
failingTest[.ml.clust.hc.fit;(821?`2;`e2dist;`ward);0b;"Dataset not suitable for clustering. Must be convertible to floats."]
failingTest[.ml.clust.hc.fit;(d1;`mdist;`ward);0b;"ward must be used with e2dist"]
failingTest[.ml.clust.hc.fit;(d1;`mdist;`linkage);0b;"invalid linkage"]

// FitPredict
passingTest[clusterIdxsDendro[.ml.clust.hc.fitPredict];(d2;`e2dist;`single;enlist[`k]!enlist 4);1b;hcResSingle]
passingTest[clusterIdxsDendro[.ml.clust.hc.fitPredict];(d2;`e2dist;`ward;enlist[`k]!enlist 4);1b;hcResWard]
passingTest[clusterIdxsDendro[.ml.clust.hc.fitPredict];(d2;`edist;`centroid;enlist[`k]!enlist 4);1b;hcResCentroid]

// Predict
passingTest[.ml.clust.hc.fit[d1tts 0;`e2dist;`single]`predict;(d1tts 1;enlist[`k]!enlist 4);0b;hcd1pred1]
passingTest[.ml.clust.hc.fit[d1tts 0;`e2dist;`ward]`predict;(d1tts 1;enlist[`k]!enlist 4);0b;hcd1pred2]
passingTest[.ml.clust.hc.fit[d1tts 0;`edist;`centroid]`predict;(d1tts 1;enlist[`k]!enlist 4);0b;hcd1pred3]

