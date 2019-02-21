\d .nlp
text: first (enlist "*";",";1) 0: `:./data/miniJeff.txt
p:newParser[`en; enlist`keywords]
corpus:p text
emptyDoc:([] keywords:enlist ()!())
truncate:{[precision; x]coefficient: 10 xexp precision;reciprocal[coefficient]*`long$coefficient*x}
mseTest:{[corpus;cluster] cluster.MSE each (corpus cluster)@\:`keywords}
cluster04:cluster.MCL[corpus;0.04;0b]
cluster25:cluster.MCL[corpus;0.25;0b]
cluster50:cluster.MCL[corpus;0.5;0b]
cluster75:cluster.MCL[corpus;0.75;0b]
cluster95:cluster.MCL[corpus;0.95;0b]
clusterlist:(cluster04;cluster25;cluster50;cluster75;cluster95)
()~cluster.MCL[emptyDoc;0.5;0b]
()~cluster.MCL[1#emptyDoc;0.5;0b]
()~cluster.MCL[1#corpus;0.5;0b]
all (til 5) in raze cluster.MCL[5#corpus; .5; 0b]
cluster.MCL[corpus;0.5;0b]~cluster.MCL[corpus,emptyDoc;0.5;0b]
cluster.MCL[corpus;0.5;0b]~cluster.MCL[corpus,5#emptyDoc;0.5;0b]
all {x[0]~/:x} {cluster.MCL[corpus;0.25;0b]} each til 5
cs:{avg count each x} each clusterlist
cs~desc cs
avgMSE:avg each mseTest[corpus] each clusterlist
truncate[2; avgMSE]~ 0.49 0.81 0.87 0.87 0.88
minMSE:min each mseTest[corpus] each clusterlist
truncate[2;minMSE]~ 0.19 0.65 0.65 0.65 0.67
()~cluster.bisectingKMeans[0#emptyDoc;10;2]
(100 101 102 103 104) in cluster.bisectingKMeans[corpus,5#emptyDoc;10;2];
(enlist til 100) ~cluster.bisectingKMeans[corpus;1;2]         
(til 100) ~ asc raze cluster.bisectingKMeans[corpus;10;2];
MSEs: asc mseTest[corpus;cluster.bisectingKMeans[corpus;10;2]]
(avg 1 _ MSEs) > .20
all {0.20<avg 1_asc mseTest[corpus;x]}each cluster.bisectingKMeans[corpus;10]each 1+til 5
not all {x[0]~/:x}{cluster.bisectingKMeans[corpus;10;2]}each til 5
enlist [100] in cluster.bisectingKMeans[corpus,emptyDoc;10;2] 
(100 101 102 103 104) in cluster.bisectingKMeans[corpus,5#emptyDoc;10;2] /modified this func to work
()~cluster.fastRadix[0#emptyDoc;10]
()~cluster.fastRadix[1#emptyDoc;10]
()~cluster.fastRadix[1#corpus;10]
(enlist 0 1 2 3 4) ~ cluster.fastRadix[5#corpus; 10]
cluster.fastRadix[corpus;10] ~ cluster.fastRadix[corpus,emptyDoc;10]
cluster.fastRadix[corpus;10] ~ cluster.fastRadix[corpus, 5#emptyDoc; 10];
(enlist 63 64 65 66 67 68 69) ~ cluster.fastRadix[corpus; 1]
clusters:cluster.fastRadix[corpus;100]
all (count each clusters) > 1
.30 < min mseTest[corpus; clusters]
88 = count raze clusters  
all 1={count distinct key each .nlp.i.takeTop[1] each x`keywords}each corpus clusters
(enlist 100) in cluster.kmeans[corpus,emptyDoc;10;2]
(100 101 102 103 104) in cluster.kmeans[corpus,5#emptyDoc;10;2]
(enlist til 100) ~ cluster.kmeans[corpus;1;2]   
(til 100) ~ asc raze cluster.kmeans[corpus;10;2]
MSEs: asc mseTest[corpus;cluster.kmeans[corpus;10;2]];
(avg MSEs)>.20
all {.20<avg 1_asc mseTest[corpus; x]} each cluster.kmeans[corpus;10]each 1+til 5
not all {x[0]~/:x}{cluster.kmeans[corpus;10;2]} each til 5
()~cluster.radix[0#emptyDoc;10]
()~cluster.radix[1#emptyDoc;10]
()~cluster.radix[1#corpus;10] 
(enlist 0 1 2 3 4 5)~cluster.radix[6#corpus;10]
.nlp.cluster.radix[corpus;10]~cluster.radix[corpus,emptyDoc;10]
.nlp.cluster.radix[corpus;10]~cluster.radix[corpus,5#emptyDoc;10]
(enlist 7)~count each cluster.radix[corpus; 1]
clusters:cluster.radix[corpus;10]
all (count each clusters)>1
.28<min mseTest[corpus;clusters]
60>count raze clusters
corpus:p ("In Brittany, the Bretons play the bombard";"The Bretons of Brittany enjoy bombard music";"I enjoy medieval music";"The lute common medieval instrument";"Wire strings are common on medieval harps";"Lutes have too many strings";"Medieval wind instruments are also abundant";"No medieval wind instruments had strings"; "The modern harp has mostly nylon strings";"Modern music is much less shrill");
orthogonalDocs:(`a`b!1 1f;`c`d!1 1f;`e`f!1 1f)
0n ~cluster.MSE documents:0#emptyDoc
1f ~cluster.MSE documents:1#emptyDoc
1f ~cluster.MSE documents:1#corpus
0f ~cluster.MSE orthogonalDocs
.4~ cluster.MSE(corpus[0 0],3#emptyDoc)`keywords
(cluster.MSE corpus[0 1;`keywords])>cluster.MSE corpus[2 3;`keywords]
1f ~ cluster.MSE corpus[0 0 0; `keywords]
.2 ~ truncate[2] cluster.MSE corpus[1 3 5 7 9; `keywords]
corpus:p ("beep beep beep";"In Brittany, the Bretons play the bombard";"The Bretons of Brittany enjoy bombard music";"A special hand tool is needed to adjust a bike chain to the right length";"A chain whip is a tool used by a bike mechanic";"Chain oil is recommeneded instead of WD-40"; "A bike mechanic frequently gets chain oil on their hands"; "I enjoy medieval music";"The lute is a common medieval instrument";"Wire strings are common on medieval harps";"Lutes have too many strings";"Medieval wind instruments are also abundant";"No medieval wind instruments had strings";"The modern harp has mostly nylon strings";"Modern music is much less shrill");
centroids:sum each corpus[`keywords] (enlist 0;1 + til 2;3 + til 4;7 + til 8)
cluster.i.groupByCentroids[centroids; 1 _ corpus `keywords] ~ -1 + (1 2;3 4 5 6;7 8 9 10 11 12 13 14)
cluster.i.groupByCentroids[centroids enlist 0; 1 _ corpus `keywords]~ enlist til 14
cluster.i.groupByCentroids[centroids 1 2; corpus `keywords]~ (0 8 9 10 11 12 13;1 2 7 14;3 4 5 6)
cluster.i.groupByCentroids[centroids; corpus `keywords]~(enlist 0;1 2;3 4 5 6;7 8 9 10 11 12 13 14)
cluster.i.groupByCentroids[centroids 0 1 2;()] ~ ()
cluster.i.groupByCentroids[centroids enlist 2; corpus `keywords] ~ (0 1 2 7 8 9 10 11 12 13 14; 3 4 5 6)
cluster.i.groupByCentroids[centroids; corpus[enlist 0] `keywords]~ enlist enlist 0           
(til 15) ~ asc raze cluster.i.groupByCentroids[1_centroids;corpus`keywords]
\d .
text: first (enlist "*";",";1) 0: `:./data/miniJeff.txt
p:.nlp.newParser[`en; enlist`keywords]
corpus:p text
emptyDoc:([] keywords:enlist ()!())
cluster:.nlp.cluster.summarize[corpus;10]
()~.nlp.cluster.summarize[0#emptyDoc;10]
(enlist enlist 0)~.nlp.cluster.summarize[1#emptyDoc; 10]
(enlist enlist 0)~.nlp.cluster.summarize[1#corpus; 10]
(0 1 3 4; enlist 2)~.nlp.cluster.summarize[5#corpus; 10]
((til 100) except l; l:63 64 65 66 67 68 69) ~ .nlp.cluster.summarize[corpus; 1]
0 in first .nlp.cluster.summarize[emptyDoc, corpus; 10]
all 0 1 2 3 4 in first .nlp.cluster.summarize[(5#emptyDoc), corpus; 10]
11 ~ count .nlp.cluster.summarize[corpus; 10]
(til 100) ~ asc raze cluster
