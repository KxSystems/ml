\l ml.q
\l util/init.q

np:.p.import[`numpy]
skmetric:.p.import[`sklearn.metrics]
skpreproc:.p.import[`sklearn.preprocessing]
stats:.p.import[`scipy.stats]
MinMaxScaler:skpreproc[`:MinMaxScaler][]
StdScaler:skpreproc[`:StandardScaler][]
scale:.p.import[`sklearn.preprocessing]`:scale

tabtest:([]10?`4;10?100;10?100;10?00:00:02.000;10?10f)
smalltab:([]1000?1000;1000?1000;1000?1000)
plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
nulltab:([]til 5;@[5?10f;2;:;0n];5?100;@[5?10f;0 1;:;0n];5#0;5#0n)
plainmat:value flip plaintab
tab:([]sym:`a`a`a`b`b;time:`time$til 5;@[5#0n;2 4;:;1f];@["f"$til 5;4;:;0n])
timetab:([]`timestamp$(2000.01.01+til 3);1 3 2;2 1 3)

x:1000?40
y:1000?40
xf:1000?100f
yf:1000?100f
xb:010010101011111010110111b
yb:000000000001000000111000b
onehotx:`a`p`l`h`j
symtf:([]`a`b`b`a`a;"f"$til 5)
symti:([]`a`b`b`a`a;til 5)
symtb:([]`a`b`b`a`a;11001b)
xm:100 10#1000?100f
ym:100 10#1000?100f
ti:([]1000?500;1000#30;1000?1000;1000?1000)
tf:([]1000?500f;1000#30f;1000?1000f;1000?100f)
tb:([]1000?0b;1000#1b;1000?0b;1000?0b)


.ml.util.traintestsplitseed[til 10;1+til 10;0.2;43]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5;3 4 8 2 7 5 10 6;0 8;1 9)
.ml.util.traintestsplitseed["f"$til 10;1+"f"$til 10;0.2;43]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5f;3 4 8 2 7 5 10 6f;0 8f;1 9f)
.ml.util.traintestsplitseed[1010110011b;1001100011b;0.33;22]~`xtrain`ytrain`xtest`ytest!(110100b;111100b;1011b;0001b)

.ml.util.onehot[onehotx] ~ "f"$(1 0 0 0 0;0 0 0 0 1;0 0 0 1 0;0 1 0 0 0;0 0 1 0 0)
.ml.util.onehot[symtf] ~"f"$([] x1:til 5;x_a:1 0 0 1 1;x_b: 0 1 1 0 0) 
.ml.util.onehot[symti] ~([] x1:til 5;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.util.onehot[symtb]~([] x1:11001b;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)

MinMaxScaler[`:fit][flip plainmat];
StdScaler[`:fit][flip plainmat];
.ml.util.minmaxscaler[plainmat] ~ flip"f"$MinMaxScaler[`:transform][flip plainmat]`
.ml.util.minmaxscaler[(2 3f;4 2f;5 3f)]~(0 1f;1 0f;1 0f)
.ml.util.minmaxscaler[3 2 5 4 1f]~0.5 0.25 1 0.75 0f
.ml.util.minmaxscaler[0011b]~0 0 1 1f

.ml.util.stdscaler[plainmat] ~ flip"f"$StdScaler[`:transform][flip plainmat]`
.ml.util.stdscaler[(2 3f;4 2f;5 3f)]~(-1 1f;1 -1f;1 -1f)
.ml.util.stdscaler[xf]~scale[xf]`
.ml.util.stdscaler[y]~scale[y]`
.ml.util.stdscaler[yb]~scale[yb]`

.ml.util.polytab[([] 2 4 1f;3 4 1f;3 2 3f);2]~([]x1_x:6 16 1f;x2_x:6 8 3f;x2_x1:9 8 3f)
.ml.util.polytab[([] 2 4 1;3 4 1;3 2 3);2]~([]x1_x:6 16 1;x2_x:6 8 3;x2_x1:9 8 3)
.ml.util.polytab[([]101b;110b;100b);2]~([]x1_x:1 0 0i;x2_x:1 0 0i;x2_x1:1 0 0i)
.ml.util.polytab[nt:([]101b;000b;1 2 0n);2]~([]x1_x:0 0 0i;x2_x:1 0 0n;x2_x1:0 0 0n)

.ml.util.dropconstant[ti]~flip `x`x2`x3!ti`x`x2`x3
.ml.util.dropconstant[tf]~flip `x`x2`x3!tf`x`x2`x3
.ml.util.dropconstant[tb]~flip `x`x2`x3!tb`x`x2`x3
.ml.util.dropconstant[nt]~([]101b;x2:1 2 0n)


infdict:`x`x1`x2!(0 1 2 0w;0 1 2 -0w;1 2 3 0w)
.ml.util.infreplace[infdict]~`x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.util.infreplace[flip infdict]~flip `x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.util.infreplace[infdict`x]~0 1 2 2f

.ml.util.filltab[delete sym from tab;0#();`time;`linear`mean!(`x1;`x)] ~ ([]time:`time$til 5;5#1f;"f"$til 5)
.ml.util.filltab[tab;`sym;`time;()!()]~([]sym:`a`a`a`b`b;time:`time$til 5;5#1f;@["f"$til 5;4;:;3f])

.ml.util.freqencode[symtf]~([] x1:symtf`x1;freq_x:0.6 0.4 0.4 0.6 0.6)
.ml.util.freqencode[symti]~([] x1:symti`x1;freq_x:0.6 0.4 0.4 0.6 0.6)
.ml.util.freqencode[symtb]~([] x1:symtb`x1;freq_x:0.6 0.4 0.4 0.6 0.6)
.ml.util.lexiencode[symtf]~([]x1:symtf`x1;lexi_label_x:0 1 1 0 0)
.ml.util.lexiencode[symti]~([]x1:symti`x1;lexi_label_x:0 1 1 0 0)
.ml.util.lexiencode[symtb]~([]x1:symtb`x1;lexi_label_x:0 1 1 0 0)

(.ml.util.timespantransform[timetab])~flip `yr_x`qtr_x`mm_x`dom_x`dow_x`wd_x`hr_x`mn_x`sec_x`x1`x2!(3#2000i;3#1;3#1i;"i"$1+til 3;"i"$til 3i;001b;0 0 0i;0 0 0i;0 0 0i;1 3 2;2 1 3)
.ml.util.timespantransform[symtf]~symtf
.ml.util.timespantransform[symti]~symti
.ml.util.timespantransform[symtb]~symtb


.ml.util.classreport[110b;101b]~flip `class`precision`recall`f1_score`support!((`$string each 0 1),`$"avg/total";0 0.5 0.25; 0 0.5 0.25;0n 0.5 0.5;1 2 3i)
.ml.util.classreport[3 3 5 2 5 1;3 5 2 3 5 1]~ flip `class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0n 0.5 0.5f, 2%3;1 1 2 2 6i)
.ml.util.classreport[3 3 5 2 5 1f;3 5 2 3 5 1f]~ flip `class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0n 0.5 0.5f, 2%3;1 1 2 2 6i)


nt2:delete x5 from nulltab

.ml.util.nullencode[nt2;avg]~([]"f"$til 5;@[nt2`x1;2;:;avg nt2`x1];"f"$nt2`x2;@[nt2`x3;0 1;:;avg nt2`x3];"f"$nt2`x4;null_x1:00100b;null_x3:11000b)
.ml.util.nullencode[nt;max]~([]101b;000b;1 2 2f;null_x2:001b)
