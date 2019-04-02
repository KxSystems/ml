\l ml.q
.ml.loadfile`:util/init.q

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

\S 43
.ml.traintestsplit[til 10;1+til 10;0.2]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5;3 4 8 2 7 5 10 6;0 8;1 9)
\S 43
.ml.traintestsplit["f"$til 10;1+"f"$til 10;0.2]~`xtrain`ytrain`xtest`ytest!(2 3 7 1 6 4 9 5f;3 4 8 2 7 5 10 6f;0 8f;1 9f)
\S 22
.ml.traintestsplit[1010110011b;1001100011b;0.33]~`xtrain`ytrain`xtest`ytest!(110100b;111100b;1011b;0001b)

.ml.onehot[symtf;`x] ~"f"$([] x1:til 5;x_a:1 0 0 1 1;x_b: 0 1 1 0 0) 
.ml.onehot[symti;`x] ~([] x1:til 5;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.onehot[symtb;`x]~([] x1:11001b;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)

MinMaxScaler[`:fit][flip plainmat];
StdScaler[`:fit][flip plainmat];
.ml.minmaxscaler[plainmat] ~ flip"f"$MinMaxScaler[`:transform][flip plainmat]`
.ml.minmaxscaler[(2 3f;4 2f;5 3f)]~(0 1f;1 0f;1 0f)
.ml.minmaxscaler[3 2 5 4 1f]~0.5 0.25 1 0.75 0f
.ml.minmaxscaler[0011b]~0 0 1 1f

.ml.stdscaler[plainmat] ~ flip"f"$StdScaler[`:transform][flip plainmat]`
.ml.stdscaler[(2 3f;4 2f;5 3f)]~(-1 1f;1 -1f;1 -1f)
.ml.stdscaler[xf]~scale[xf]`
.ml.stdscaler[y]~scale[y]`
.ml.stdscaler[yb]~scale[yb]`

.ml.polytab[([] 2 4 1f;3 4 1f;3 2 3f);2]~([]x_x1:6 16 1f;x_x2:6 8 3f;x1_x2:9 8 3f)
.ml.polytab[([] 2 4 1;3 4 1;3 2 3);2]~([]x_x1:6 16 1;x_x2:6 8 3;x1_x2:9 8 3)
.ml.polytab[([]101b;110b;100b);2]~([]x_x1:1 0 0i;x_x2:1 0 0i;x1_x2:1 0 0i)
.ml.polytab[nt:([]101b;000b;1 2 0n);2]~([]x_x1:0 0 0i;x_x2:1 0 0n;x1_x2:0 0 0n)

.ml.dropconstant[ti]~flip `x`x2`x3!ti`x`x2`x3
.ml.dropconstant[tf]~flip `x`x2`x3!tf`x`x2`x3
.ml.dropconstant[tb]~flip `x`x2`x3!tb`x`x2`x3
.ml.dropconstant[nt]~([]101b;x2:1 2 0n)


infdict:`x`x1`x2!(0 1 2 0w;0 1 2 -0w;1 2 3 0w)
.ml.infreplace[infdict]~`x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.infreplace[flip infdict]~flip `x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.infreplace[infdict`x]~0 1 2 2f

.ml.filltab[delete sym from tab;0#();`time;`x1`x!`linear`mean]~flip`time`x`x1`x1_null`x_null!(00:00:00.000 00:00:00.001 00:00:00.002 00:00:00.003 00:00:00.004;1 1 1 1 1f;0 1 2 3 4f;00001b;11010b)
.ml.filltab[tab;`sym;`time;()!()]~tab

.ml.freqencode[symtf;`x]~(delete x from symtf),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symti;`x]~(delete x from symti),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symtb;`x]~(delete x from symtb),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.lexiencode[symtf;`x]~(delete x from symtf),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symti;`x]~(delete x from symti),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symtb;`x]~(delete x from symtb),'([]x_lexi:0 1 1 0 0)

.ml.timesplit[timetab;()]~(delete x from timetab),'flip`x_dow`x_year`x_mm`x_dd`x_qtr`x_wd`x_hh`x_uu`x_ss!(0 1 2i;2000 2000 2000i;1 1 1i;1 2 3i;1 1 1j;001b;0 0 0i;0 0 0i;0 0 0i)
.ml.timesplit[symtf;()]~symtf
.ml.timesplit[symti;()]~symti
.ml.timesplit[symtb;()]~symtb

.ml.classreport[110b;101b]~1!flip`class`precision`recall`f1_score`support!((`$string each 0 1),`$"avg/total";0 0.5 0.25; 0 0.5 0.25;0.0 0.5 0.25;1 2 3i)
.ml.classreport[3 3 5 2 5 1;3 5 2 3 5 1]~1!flip`class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 1 2 2 6i)
.ml.classreport[3 3 5 2 5 1f;3 5 2 3 5 1f]~1!flip`class`precision`recall`f1_score`support!((`$string each 1 2 3 5),`$"avg/total";1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 0 0.5 0.5 0.5;1 1 2 2 6i)
