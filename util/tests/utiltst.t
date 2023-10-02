\l ml.q
\l util/init.q

np:.p.import[`numpy]
p)import pandas as pd
p)import numpy as np
p)import datetime
t:.p.eval"pd.DataFrame({'fcol':[0.1,0.2,0.3,0.4,0.5],'jcol':[10,20,30,40,50]})"
t2:.p.eval"pd.DataFrame({'fcol':[None,None,None,None,None],'jcol':[True,False,True,False,True]})"
t3:.p.eval"pd.DataFrame({'date':[datetime.date(2005, 7, 14),datetime.date(2005, 7, 15)],'time':[datetime.time(12, 10, 30,500)
   ,datetime.time(12, 13, 30,200)],'str':['h','i'],'ind':[1.3,2.5],'bool':[True,False]})"
t4:.p.eval"pd.DataFrame({'bool':[True,False],'date':[np.datetime64('2005-02-25'),np.datetime64('2015-12-22')],'timed':[datetime.timedelta(hours=-5),
   datetime.timedelta(seconds=1000)]})"
p)dtT = pd.Series(pd.date_range('2019-01-01 1:30',periods=2)).to_frame(name='dt')
p)dtT['dt_with_tz']=dtT.dt.dt.tz_localize('CET')
t5: .p.eval "dtT"
dt1:2019.01.01D01:30:00.000000000 2019.01.02D01:30:00.000000000

plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
xm:100 10#1000?100f
x:1000?1000
xf:1000?100f

.ml.range[til 63] ~ 62
.ml.range[5] ~ 0
.ml.range[0 1 3 2f]~3f
.ml.range[0 1 0n 2]~2f

df :.ml.tab2df tt:([]fcol:12?1.;jcol:12?100;scol:12?`aaa`bbb`ccc)
dfj:.ml.tab2df tj:select by jcol from tt
dfs:.ml.tab2df ts:select by scol from tt
dfsj:.ml.tab2df tx:select by scol,jcol from tt
dfc:.ml.tab2df ([]s:`a`b`c;j:1 2 3;c:"ABC")
(dfsx:.ml.tab2df tx)[`:index][:;`:names;(`scol;::)]
(dfxj:.ml.tab2df tx)[`:index][:;`:names;(::;`jcol)]
(dfxx:.ml.tab2df tx)[`:index][:;`:names;(::;::)]
tt2:([]date:2005.07.14 2005.07.15;timesp:("N"$"12:10:30.000500000";"N"$"12:13:30.000200007");time:20:30:00.001 19:23:20.201;str:enlist each ("h";"i");ind:1.3 2.5;bool:10b)
col_types:$[.pykx.loaded;-12 112 112 -10 -9 -1h;112 112 112 10 -9 -1h];
col_types~type each first (.ml.tab2df tt2)[`:values]`
ret_value:$[.pykx.loaded;"ABC";enlist each "ABC"]
ret_value~dfc[`:c.values]`;

.ml.shape[1 2 3*/:til 10] ~ np[`:shape][.p.toraw 1 2 3*/:til 10]`
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

.ml.linearSpace[1;10;9] ~ np[`:linspace][1;10;9]`
.ml.linearSpace[-0.2;109;62] ~ np[`:linspace][-0.2;109;62]`
.ml.linearSpace[-0.2;10.4;20] ~ np[`:linspace][-0.2;10.4;20]`

.ml.eye[3] ~ "f"$(1 0 0;0 1 0;0 0 1)
first[.ml.eye[1]] ~ enlist 1f

.ml.combs[3;2]~(0 1;0 2;1 2)
.ml.combs[3;0]~enlist each (0 1 2)

.ml.df2tab[t]~([]fcol:0.1*1+til 5;jcol:10*1+til 5)
.ml.df2tab[t2]~([]fcol:5#(::);jcol:10101b)
.ml.df2tabTimezone[t3;0b;1b]~([]date:2005.07.14 2005.07.15;time:("N"$"12:10:30.000500000";"N"$"12:13:30.000200000");str:enlist each ("h";"i");ind:1.3 2.5;bool:10b)
.ml.df2tabTimezone[t4;0b;1b]~([]bool:10b;date:"p"$(2005.02.25;2015.12.22);timed:(neg "N"$"05:00:00";"N"$"00:16:40"))
.ml.df2tabTimezone[t5;1b;0b]~([]dt:dt1;dt_with_tz:dt1)
.ml.df2tabTimezone[t5;0b;0b]~([]dt:dt1;dt_with_tz:dt1-"T"$"01:00:00")

@[{.ml.df2tab x;1b};.ml.tab2df ([]10?1f;"p"$0N,9?1000);0b]

convertScol:{$[.pykx.loaded;x;update `$scol from x]}
convertSJcol:{$[.pykx.loaded;;{update`$scol from x}]`scol`jcol xcol x}
tt~convertScol .ml.df2tab df
tj~convertScol .ml.df2tab dfj
ts~convertScol .ml.df2tab dfs
tx~convertScol .ml.df2tab dfsj
tx~convertSJcol .ml.df2tab dfsx
tx~convertSJcol .ml.df2tab dfxj
tx~convertSJcol .ml.df2tab dfxx

\S 43
.ml.trainTestSplit[til 10;1+til 10;0.2]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5;3 4 8 2 7 5 10 6;0 8;1 9)
\S 43
.ml.trainTestSplit["f"$til 10;1+"f"$til 10;0.2]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5f;3 4 8 2 7 5 10 6f;0 8f;1 9f)
\S 22
.ml.trainTestSplit[1010110011b;1001100011b;0.33]~`xtrain`ytrain`xtest`ytest!(110100b;111100b;1011b;0001b)
