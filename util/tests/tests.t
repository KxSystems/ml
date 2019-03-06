\l ml.q
\l util/init.q

np:.p.import[`numpy]
skmetric:.p.import[`sklearn.metrics]
skpreproc:.p.import[`sklearn.preprocessing]
stats:.p.import[`scipy.stats]
MinMaxScaler:skpreproc[`:MinMaxScaler][]
StdScaler:skpreproc[`:StandardScaler][]

tabtest:([]10?`4;10?100;10?100;10?00:00:02.000;10?10f)
smalltab:([]1000?1000;1000?1000;1000?1000)
plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
nulltab:([]til 5;@[5?10f;2;:;0n];5?100;@[5?10f;0 1;:;0n];5#0;5#0n)
plainmat:value flip plaintab
tab:([]sym:`a`a`a`b`b;time:`time$til 5;@[5#0n;2 4;:;1f];@["f"$til 5;4;:;0n])
timetab:([]`timestamp$(2000.01.01+til 3);3?3;3?3)

x:1000?40
y:1000?40
xf:1000?100f
yf:1000?100f
xb:010010101011111010110111b
yb:000000000001000000111000b
onehotx:`a`p`l`h`j
symt:([]`a`b`b`a`a;"f"$til 5)



.ml.util.traintestsplitseed[til 10;1+til 10;0.2;43]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5;3 4 8 2 7 5 10 6;0 8;1 9)


.ml.util.onehot[onehotx] ~ "f"$(1 0 0 0 0;0 0 0 0 1;0 0 0 1 0;0 1 0 0 0;0 0 1 0 0)
.ml.util.onehot[symt] ~"f"$([] x1:til 5;x_a:1 0 0 1 1;x_b: 0 1 1 0 0) 

MinMaxScaler[`:fit][flip plainmat];
StdScaler[`:fit][flip plainmat];
.ml.util.minmaxscaler[plainmat] ~ flip"f"$MinMaxScaler[`:transform][flip plainmat]`
.ml.util.stdscaler[plainmat] ~ flip"f"$StdScaler[`:transform][flip plainmat]`

(cols .ml.util.polytab[plaintab;3]) ~`x2_x1_x`x3_x1_x`x3_x2_x`x3_x2_x1
(cols .ml.util.dropconstant[nulltab]) ~ `x`x1`x2`x3


infdict:`x`x1`x2!(0 1 2 0w;0 1 2 -0w;1 2 3 0w)
.ml.util.infreplace[infdict]~`x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.util.infreplace[flip infdict]~flip `x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.util.infreplace[infdict`x]~0 1 2 2f

.ml.util.filltab[delete sym from tab;0#();`time;`linear`mean!(`x1;`x)] ~ ([]time:`time$til 5;5#1f;"f"$til 5)
.ml.util.filltab[tab;`sym;`time;()!()]~([]sym:`a`a`a`b`b;time:`time$til 5;5#1f;@["f"$til 5;4;:;3f])

.ml.util.freqencode[symt]~([] x1:"f"$til 5;freq_x:0.6 0.4 0.4 0.6 0.6)
.ml.util.lexiencode[symt]~([]x1:symt`x1;lexi_label_x:0 1 1 0 0)

(cols .ml.util.timespantransform[timetab])~`yr_x`qtr_x`mm_x`dom_x`dow_x`wd_x`hr_x`mn_x`sec_x`x1`x2
(cols .ml.util.classreport[xb;yb])~`class`precision`recall`f1_score`support

nt:delete x5 from nulltab
.ml.util.nullencode[nt;avg]~([]"f"$til 5;@[nt`x1;2;:;avg nt`x1];"f"$nt`x2;@[nt`x3;0 1;:;avg nt`x3];"f"$nt`x4;null_x1:00100b;null_x3:11000b)

