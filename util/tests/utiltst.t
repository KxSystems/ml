\l ml/ml.q
\l util/init.q

np:.p.import[`numpy]

p)import pandas as pd
t:.p.eval"pd.DataFrame({'fcol':[0.1,0.2,0.3,0.4,0.5],'jcol':[10,20,30,40,50]})"
t2:.p.eval"pd.DataFrame({'fcol':[None,None,None,None,None],'jcol':[True,False,True,False,True]})"

plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
xm:100 10#1000?100f

df :.ml.tab2df tt:([]fcol:12?1.;jcol:12?100;scol:12?`aaa`bbb`ccc)
dfj:.ml.tab2df tj:select by jcol from tt
dfs:.ml.tab2df ts:select by scol from tt
dfsj:.ml.tab2df tx:select by scol,jcol from tt
(dfsx:.ml.tab2df tx)[`:index][:;`:names;(`scol;::)]
(dfxj:.ml.tab2df tx)[`:index][:;`:names;(::;`jcol)]
(dfxx:.ml.tab2df tx)[`:index][:;`:names;(::;::)]

.ml.shape[1 2 3*/:til 10] ~ np[`:shape][1 2 3*/:til 10]`
.ml.shape[enlist 1] ~ np[`:shape][enlist 1]`
.ml.shape[1 2] ~ np[`:shape][1 2]`
.ml.shape[plaintab]~3 4
.ml.shape[xm]~100 10
.ml.shape[10 10#100?0b]~ 10 10
.ml.shape[(3#0n;3?3)]~2 3

(`int$.ml.arange[2;20;2]) ~ `int$np[`:arange][2;20;2]`
.ml.arange[2;100;2.5] ~ np[`:arange][2;100;2.5]`
.ml.arange[2.5;50.2;0.2] ~ np[`:arange][2.5;50.2;0.2]`
.ml.arange[2f;10f;1f]~2 3 4 5 6 7 8 9f

.ml.linspace[1;10;9] ~ np[`:linspace][1;10;9]`
.ml.linspace[-0.2;109;62] ~ np[`:linspace][-0.2;109;62]`
.ml.linspace[-0.2;10.4;20] ~ np[`:linspace][-0.2;10.4;20]`

.ml.eye[3] ~ "f"$(1 0 0;0 1 0;0 0 1)
first[.ml.eye[1]] ~ enlist 1f

.ml.combs[3;2]~(0 1;0 2;1 2)
.ml.combs[3;0]~enlist each (0 1 2)

.ml.df2tab[t]~([]fcol:0.1*1+til 5;jcol:10*1+til 5)
.ml.df2tab[t2]~([]fcol:5#(::);jcol:10101b)

tt~update`$scol from .ml.df2tab df
tj~update`$scol from .ml.df2tab dfj
ts~update`$scol from .ml.df2tab dfs
tx~update`$scol from .ml.df2tab dfsj
tx~update`$scol from`scol`jcol xcol .ml.df2tab dfsx
tx~update`$scol from`scol`jcol xcol .ml.df2tab dfxj
tx~update`$scol from`scol`jcol xcol .ml.df2tab dfxx

\S 43
.ml.traintestsplit[til 10;1+til 10;0.2]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5;3 4 8 2 7 5 10 6;0 8;1 9)
\S 43
.ml.traintestsplit["f"$til 10;1+"f"$til 10;0.2]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5f;3 4 8 2 7 5 10 6f;0 8f;1 9f)
\S 22
.ml.traintestsplit[1010110011b;1001100011b;0.33]~`xtrain`ytrain`xtest`ytest!(110100b;111100b;1011b;0001b)


