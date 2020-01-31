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
plaintab:([]4 5 6.;1 2 3.;-1 -2 -3.;0.4 0.5 0.6)
nulltab:([]til 5;@[5?10f;2;:;0n];5?100;@[5?10f;0 1;:;0n];5#0;5#0n)
plainmat:value flip plaintab
tab:([]sym:`a`a`a`b`b;time:`time$til 5;@[5#0n;2 4;:;1f];@["f"$til 5;4;:;0n])
timetab:([]`timestamp$(2000.01.01+til 3);1 3 2;2 1 3)
timetabn:([]`timestamp$(2000.01.01+til 3),0n;1 3 3 2;2 1 3 3)

x:1000?40
y:1000?40
xf:1000?100f
yf:1000?100f
xb:1000#0101101011b
yb:1000#0000111000b
onehotx:`a`p`l`h`j
symtf:([]`a`b`b`a`a;"f"$til 5)
symti:([]`a`b`b`a`a;til 5)
symtb:([]`a`b`b`a`a;11001b)
symtn:([]`a`b`b``a;til 5)
symm:([] `a`b`b`a`a;til 5;`q`w`q`q`w)
xm:100 10#xb
ym:100 10#yb
ti:([]1000?500;1000#30;1000?1000;1000?1000)
tf:([]1000?500f;1000#30f;1000?1000f;1000?100f)
tb:([]1000?0b;1000#1b;1000?0b;1000?0b)
infdict:`x`x1`x2!(0 1 2 0w;0 1 2 -0w;1 2 3 0w)
nt:([]101b;000b;1 2 0n)

.ml.dropconstant[ti]~flip `x`x2`x3!ti`x`x2`x3
.ml.dropconstant[tf]~flip `x`x2`x3!tf`x`x2`x3
.ml.dropconstant[tb]~flip `x`x2`x3!tb`x`x2`x3
.ml.dropconstant[nt]~([]101b;x2:1 2 0n)
.ml.dropconstant[nulltab]~select x,x1,x2,x3 from nulltab

MinMaxScaler[`:fit][flip plainmat];
StdScaler[`:fit][flip plainmat];
.ml.minmaxscaler[plainmat] ~ flip"f"$MinMaxScaler[`:transform][flip plainmat]`
.ml.minmaxscaler[(2 3f;4 2f;5 3f)]~(0 1f;1 0f;1 0f)
.ml.minmaxscaler[3 2 5 4 1f]~0.5 0.25 1 0.75 0f
.ml.minmaxscaler[0011b]~0 0 1 1f
.ml.minmaxscaler[3 2#3 5 1 0n 4 0n]~(0 1f;2#0n;2#0n)

.ml.stdscaler[plainmat] ~ flip"f"$StdScaler[`:transform][flip plainmat]`
.ml.stdscaler[(2 3f;4 2f;5 3f)]~(-1 1f;1 -1f;1 -1f)
.ml.stdscaler[xf]~scale[xf]`
.ml.stdscaler[y]~scale[y]`
.ml.stdscaler[yb]~scale[yb]`
.ml.stdscaler[3 2#2 4 1 0n 2 0n]~(-1 1f;2#0n;2#0n)

.ml.infreplace[infdict]~`x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.infreplace[flip infdict]~flip `x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.infreplace[infdict`x]~0 1 2 2f

.ml.polytab[([] 2 4 1f;3 4 1f;3 2 3f);2]~([]x_x1:6 16 1f;x_x2:6 8 3f;x1_x2:9 8 3f)
.ml.polytab[([] 2 4 1;3 4 1;3 2 3);2]~([]x_x1:6 16 1;x_x2:6 8 3;x1_x2:9 8 3)
.ml.polytab[([]101b;110b;100b);2]~([]x_x1:1 0 0i;x_x2:1 0 0i;x1_x2:1 0 0i)
.ml.polytab[nt;2]~([]x_x1:0 0 0i;x_x2:1 0 0n;x1_x2:0 0 0n)
.ml.polytab[([] 0n 0n;2 3;1 2);2]~([]x_x1:2#0n;x_x2:2#0n;x1_x2:2 6)

.ml.filltab[tab;0#();`time;`x1`x!`linear`mean]~flip`sym`time`x`x1`x1_null`x_null!(`a`a`a`b`b;00:00:00.000 00:00:00.001 00:00:00.002 00:00:00.003 00:00:00.004;1 1 1 1 1f;0 1 2 3 4f;00001b;11010b)
.ml.filltab[tab;`sym;`time;()!()]~tab
.ml.filltab[tab;`sym;`time;::]~flip`sym`time`x`x1`x_null`x1_null!(`a`a`a`b`b;00:00:00.000 00:00:00.001 00:00:00.002 00:00:00.003 00:00:00.004;1 1 1 1 1f;0 1 2 3 3f;11010b;00001b)
(select x4,x5,x1_null,x3_null from .ml.filltab[nulltab;`x2;x;`x1`x3!`median`mean])~([]x4:5#0;x5:5#0n;x1_null:00100b;x3_null:11000b)
.ml.filltab[tab,'flip (enlist `x2)!enlist 5#0n;`sym;`time;`x1`x`x2!`median`mean`max]~flip`sym`time`x`x1`x2`x1_null`x_null`x2_null!(`a`a`a`b`b;00:00:00.000 00:00:00.001 00:00:00.002 00:00:00.003 00:00:00.004;1 1 1 1 1f;0 1 2 3 3f;5#0n;00001b;11010b;11111b)
.ml.onehot[symtf;`x] ~"f"$([] x1:til 5;x_a:1 0 0 1 1;x_b: 0 1 1 0 0)
.ml.onehot[symtf;::] ~"f"$([] x1:til 5;x_a:1 0 0 1 1;x_b: 0 1 1 0 0)
.ml.onehot[symti;`x] ~([] x1:til 5;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.onehot[symti;::] ~([] x1:til 5;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.onehot[symtb;`x]~([] x1:11001b;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.onehot[symtb;::]~([] x1:11001b;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.onehot[symtn;`x]~([]x1:til 5;x_:0 0 0 1 0f;x_a:1 0 0 0 1f;x_b:0 1 1 0 0f)
.ml.onehot[symtn;::]~([]x1:til 5;x_:0 0 0 1 0f;x_a:1 0 0 0 1f;x_b:0 1 1 0 0f)
.ml.onehot[symm;::]~([]x1:til 5;x_a:1 0 0 1 1f;x_b:0 1 1 0 0f;x2_q:1 0 1 1 0f;x2_w:0 1 0 0 1f) 
.ml.freqencode[symtf;`x]~(delete x from symtf),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symtf;::]~(delete x from symtf),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symti;`x]~(delete x from symti),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symti;::]~(delete x from symti),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symtb;`x]~(delete x from symtb),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symtb;::]~(delete x from symtb),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqencode[symtn;`x]~([] x1:til 5;x_freq:0.4 0.4 0.4 0.2 0.4)
.ml.freqencode[symtn;::]~([] x1:til 5;x_freq:0.4 0.4 0.4 0.2 0.4)
.ml.freqencode[symm;::]~([]x1:til 5;x_freq:0.6 0.4 0.4 0.6 0.6;x2_freq:0.6 0.4 0.6 0.6 0.4)
.ml.lexiencode[symtf;`x]~(delete x from symtf),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symtf;::]~(delete x from symtf),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symti;`x]~(delete x from symti),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symti;::]~(delete x from symti),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symtb;`x]~(delete x from symtb),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symtb;::]~(delete x from symtb),'([]x_lexi:0 1 1 0 0)
.ml.lexiencode[symtn;`x]~([] x1:til 5;x_lexi:1 2 2 0 1)
.ml.lexiencode[symtn;::]~([] x1:til 5;x_lexi:1 2 2 0 1)
.ml.lexiencode[symm;::]~([]x1:til 5;x_lexi: 0 1 1 0 0;x2_lexi:0 1 0 0 1)
.ml.timesplit[timetab;::]~(delete x from timetab),'flip`x_dow`x_year`x_mm`x_dd`x_qtr`x_wd`x_hh`x_uu`x_ss!(0 1 2i;2000 2000 2000i;1 1 1i;1 2 3i;1 1 1j;001b;0 0 0i;0 0 0i;0 0 0i)
.ml.timesplit[timetab;`x]~(delete x from timetab),'flip`x_dow`x_year`x_mm`x_dd`x_qtr`x_wd`x_hh`x_uu`x_ss!(0 1 2i;2000 2000 2000i;1 1 1i;1 2 3i;1 1 1j;001b;0 0 0i;0 0 0i;0 0 0i)
.ml.timesplit[timetabn;::]~(delete x from timetabn),'flip`x_dow`x_year`x_mm`x_dd`x_qtr`x_wd`x_hh`x_uu`x_ss!(`int$(0 1 2 0n);`int$(2000 2000 2000 0n);`int$(1 1 1 0n);`int$(1 2 3 0n);"j"$(1 1 1 0n);0010b;`int$(0 0 0 0n);`int$(0 0 0 0n);`int$(0 0 0 0n))
.ml.timesplit[symtf;::]~symtf
.ml.timesplit[symti;::]~symti
.ml.timesplit[symtb;::]~symtb
