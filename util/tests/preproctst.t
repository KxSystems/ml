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

\S 42

x:1000?40
y:1000?40
xf:1000?100f
yf:1000?100f
xb:1000#0101101011b
yb:1000#0000111000b
scale1:(2 3f;4 2f;5 3f)
scale2:3 2 5 4 1f
scale3:0011b
scale4:3 2#3 5 1 0n 4 0n
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

.ml.dropConstant[ti]~flip `x`x2`x3!ti`x`x2`x3
.ml.dropConstant[tf]~flip `x`x2`x3!tf`x`x2`x3
.ml.dropConstant[tb]~flip `x`x2`x3!tb`x`x2`x3
.ml.dropConstant[nt]~([]101b;x2:1 2 0n)
.ml.dropConstant[nulltab]~select x,x1,x2,x3 from nulltab

MinMaxScaler[`:fit][flip plainmat];
minMaxKeys:`minData`maxData
minMax1:.ml.minMaxScaler.fit[plainmat]
minMax2:.ml.minMaxScaler.fit[scale1]
minMax3:.ml.minMaxScaler.fit[scale2]
minMax4:.ml.minMaxScaler.fit[scale3]
minMax5:.ml.minMaxScaler.fit[scale4]

minMax1[`modelInfo]~minMaxKeys!(4 1 -3 0.4f;6 3 -1 0.6f)
minMax2[`modelInfo]~minMaxKeys!(2 2 3f;3 4 5f)
minMax3[`modelInfo]~minMaxKeys!1 5f
minMax4[`modelInfo]~minMaxKeys!01b
minMax5[`modelInfo]~minMaxKeys!(3 1 4f;5 1 4f)

.ml.minMaxScaler.fitPredict[plainmat]~flip"f"$MinMaxScaler[`:transform][flip plainmat]`
.ml.minMaxScaler.fitPredict[scale1]~(0 1f;1 0f;1 0f)
.ml.minMaxScaler.fitPredict[scale2]~0.5 0.25 1 0.75 0f
.ml.minMaxScaler.fitPredict[scale3]~0 0 1 1f
.ml.minMaxScaler.fitPredict[scale4]~(0 1f;2#0n;2#0n)
minMax2.predict[scale4]~(1 3f;-0.5 0n;0.5 0n)
minMax3.predict[5#y]~5.75 1.75 9.5 5.5 4.25

StdScaler[`:fit][flip plainmat];
stdScaleKeys:`avgData`devData
stdScale1:.ml.stdScaler.fit[plainmat]
stdScale2:.ml.stdScaler.fit[scale1]
stdScale3:.ml.stdScaler.fit[xf]
stdScale4:.ml.stdScaler.fit[y]
stdScale5:.ml.stdScaler.fit[yb]
stdScale6:.ml.stdScaler.fit[scale4]

key[stdScale1[`modelInfo]]~stdScaleKeys
key[stdScale2[`modelInfo]]~stdScaleKeys
key[stdScale3[`modelInfo]]~stdScaleKeys
key[stdScale4[`modelInfo]]~stdScaleKeys
key[stdScale5[`modelInfo]]~stdScaleKeys
key[stdScale6[`modelInfo]]~stdScaleKeys

stdScale1.predict[plainmat]~flip"f"$StdScaler[`:transform][flip plainmat]`
stdScale2.predict[scale1]~(-1 1f;1 -1f;1 -1f)
stdScale3.predict[xf]~scale[xf]`
stdScale4.predict[y]~scale[y]`
stdScale5.predict[yb]~scale[yb]`
stdScale6.predict[scale4]~(-1 1f;2#0n;2#0n)
stdScale2.predict[scale4]~(1 5f;-2 0n;0 0n)

.ml.infReplace[infdict]~`x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.infReplace[flip infdict]~flip `x`x1`x2!"f"$(0 1 2 2;0 1 2 0;1 2 3 3)
.ml.infReplace[infdict`x]~0 1 2 2f

.ml.polyTab[([] 2 4 1f;3 4 1f;3 2 3f);2]~([]x_x1:6 16 1f;x_x2:6 8 3f;x1_x2:9 8 3f)
.ml.polyTab[([] 2 4 1;3 4 1;3 2 3);2]~([]x_x1:6 16 1;x_x2:6 8 3;x1_x2:9 8 3)
.ml.polyTab[([]101b;110b;100b);2]~([]x_x1:1 0 0i;x_x2:1 0 0i;x1_x2:1 0 0i)
.ml.polyTab[nt;2]~([]x_x1:0 0 0i;x_x2:1 0 0n;x1_x2:0 0 0n)
.ml.polyTab[([] 0n 0n;2 3;1 2);2]~([]x_x1:2#0n;x_x2:2#0n;x1_x2:2 6)

.ml.fillTab[tab;0#();`time;`x1`x!`linear`mean]~flip`sym`time`x`x1`x1_null`x_null!(`a`a`a`b`b;00:00:00.000 00:00:00.001 00:00:00.002 00:00:00.003 00:00:00.004;1 1 1 1 1f;0 1 2 3 4f;00001b;11010b)
.ml.fillTab[tab;`sym;`time;()!()]~tab
.ml.fillTab[tab;`sym;`time;::]~flip`sym`time`x`x1`x_null`x1_null!(`a`a`a`b`b;00:00:00.000 00:00:00.001 00:00:00.002 00:00:00.003 00:00:00.004;1 1 1 1 1f;0 1 2 3 3f;11010b;00001b)
(select x4,x5,x1_null,x3_null from .ml.fillTab[nulltab;`x2;x;`x1`x3!`median`mean])~([]x4:5#0;x5:5#0n;x1_null:00100b;x3_null:11000b)
.ml.fillTab[tab,'flip (enlist `x2)!enlist 5#0n;`sym;`time;`x1`x`x2!`median`mean`max]~flip`sym`time`x`x1`x2`x1_null`x_null`x2_null!(`a`a`a`b`b;00:00:00.000 00:00:00.001 00:00:00.002 00:00:00.003 00:00:00.004;1 1 1 1 1f;0 1 2 3 3f;5#0n;00001b;11010b;11111b)

.ml.oneHot.fitPredict[symtf;`x] ~"f"$([] x1:til 5;x_a:1 0 0 1 1;x_b: 0 1 1 0 0)
.ml.oneHot.fitPredict[symtf;::] ~"f"$([] x1:til 5;x_a:1 0 0 1 1;x_b: 0 1 1 0 0)
.ml.oneHot.fitPredict[symti;`x] ~([] x1:til 5;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.oneHot.fitPredict[symti;::] ~([] x1:til 5;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.oneHot.fitPredict[symtb;`x]~([] x1:11001b;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.oneHot.fitPredict[symtb;::]~([] x1:11001b;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
.ml.oneHot.fitPredict[symtn;`x]~([]x1:til 5;x_:0 0 0 1 0f;x_a:1 0 0 0 1f;x_b:0 1 1 0 0f)
.ml.oneHot.fitPredict[symtn;::]~([]x1:til 5;x_:0 0 0 1 0f;x_a:1 0 0 0 1f;x_b:0 1 1 0 0f)
.ml.oneHot.fitPredict[symm;::]~([]x1:til 5;x_a:1 0 0 1 1f;x_b:0 1 1 0 0f;x2_q:1 0 1 1 0f;x2_w:0 1 0 0 1f) 

oneHot1:.ml.oneHot.fit[symtf;::]
oneHot1.predict[symtb;::]~([] x1:11001b;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
oneHot1.predict[symti;::]~([] x1:til 5;x_a:1 0 0 1 1f;x_b: 0 1 1 0 0f)
oneHot1.predict[symm;`x`x2!`x`x]~([]x1:til 5;x_a:1 0 0 1 1f;x_b:0 1 1 0 0f;x2_a:5#0f;x2_b:5#0f)

.ml.freqEncode[symtf;`x]~(delete x from symtf),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqEncode[symtf;::]~(delete x from symtf),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqEncode[symti;`x]~(delete x from symti),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqEncode[symti;::]~(delete x from symti),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqEncode[symtb;`x]~(delete x from symtb),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqEncode[symtb;::]~(delete x from symtb),'([]x_freq:0.6 0.4 0.4 0.6 0.6)
.ml.freqEncode[symtn;`x]~([] x1:til 5;x_freq:0.4 0.4 0.4 0.2 0.4)
.ml.freqEncode[symtn;::]~([] x1:til 5;x_freq:0.4 0.4 0.4 0.2 0.4)
.ml.freqEncode[symm;::]~([]x1:til 5;x_freq:0.6 0.4 0.4 0.6 0.6;x2_freq:0.6 0.4 0.6 0.6 0.4)

.ml.lexiEncode.fitPredict[symtf;`x]~(delete x from symtf),'([]x_lexi:0 1 1 0 0)
.ml.lexiEncode.fitPredict[symtf;::]~(delete x from symtf),'([]x_lexi:0 1 1 0 0)
.ml.lexiEncode.fitPredict[symti;`x]~(delete x from symti),'([]x_lexi:0 1 1 0 0)
.ml.lexiEncode.fitPredict[symti;::]~(delete x from symti),'([]x_lexi:0 1 1 0 0)
.ml.lexiEncode.fitPredict[symtb;`x]~(delete x from symtb),'([]x_lexi:0 1 1 0 0)
.ml.lexiEncode.fitPredict[symtb;::]~(delete x from symtb),'([]x_lexi:0 1 1 0 0)
.ml.lexiEncode.fitPredict[symtn;`x]~([] x1:til 5;x_lexi:1 2 2 0 1)
.ml.lexiEncode.fitPredict[symtn;::]~([] x1:til 5;x_lexi:1 2 2 0 1)
.ml.lexiEncode.fitPredict[symm;::]~([]x1:til 5;x_lexi: 0 1 1 0 0;x2_lexi:0 1 0 0 1)

lexi1:.ml.lexiEncode.fit[symtf;::]
lexi1.predict[symtb;::]~(delete x from symtb),'([]x_lexi:0 1 1 0 0)
lexi1.predict[symti;::]~(delete x from symti),'([]x_lexi:0 1 1 0 0)
lexi1.predict[symm;`x`x2!`x`x]~([]x1:til 5;x_lexi: 0 1 1 0 0;x2_lexi:5#-1)

guidList :asc 5?0Ng
symList1 :`b`a`d`c
symList2 :`e`a`d`d
floatList:1.2 2 2.5 0.1

.ml.labelEncode.fit[guidList][`modelInfo] ~(asc distinct guidList)!til count distinct guidList
.ml.labelEncode.fit[symList1][`modelInfo]  ~`a`b`c`d!til 4
.ml.labelEncode.fit[floatList][`modelInfo]~0.1 1.2 2 2.5!til 4

label1:.ml.labelEncode.fit[symList1]
label1.predict[symList1]~1 0 3 2
label1.predict[symList2]~-1 0 3 3

.ml.applyLabelEncode[0 0 2 3 4  ;.ml.labelEncode.fit floatList]~(0.1;0.1;2f;2.5;0n)
.ml.applyLabelEncode[1 1 2 5 3 0;.ml.labelEncode.fit symList1  ]~`b`b`c``d`a
.ml.applyLabelEncode[0 0 0 1 6  ;.ml.labelEncode.fit guidList ]~(3#guidList 0),(guidList 1),`guid$0Ng
.ml.applyLabelEncode[0 0 2 3 4  ;.ml.labelEncode.fit [floatList]`modelInfo]~(0.1;0.1;2f;2.5;0n)
.ml.applyLabelEncode[1 1 2 5 3 0;.ml.labelEncode.fit [symList1]`modelInfo]~`b`b`c``d`a
.ml.applyLabelEncode[0 0 0 1 6  ;.ml.labelEncode.fit [guidList]`modelInfo]~(3#guidList 0),(guidList 1),`guid$0Ng

timesplitKeys:`x_dayOfWeek`x_year`x_month`x_day`x_quarter`x_weekday`x_hour`x_minute`x_second
.ml.timeSplit[timetab;::]~(delete x from timetab),'flip  timesplitKeys!(0 1 2i;2000 2000 2000i;1 1 1i;1 2 3i;1 1 1j;001b;0 0 0i;0 0 0i;0 0 0i)
.ml.timeSplit[timetab;`x]~(delete x from timetab),'flip timesplitKeys!(0 1 2i;2000 2000 2000i;1 1 1i;1 2 3i;1 1 1j;001b;0 0 0i;0 0 0i;0 0 0i)
.ml.timeSplit[timetabn;::]~(delete x from timetabn),'flip timesplitKeys!(`int$(0 1 2 0n);`int$(2000 2000 2000 0n);`int$(1 1 1 0n);`int$(1 2 3 0n);"j"$(1 1 1 0n);0010b;`int$(0 0 0 0n);`int$(0 0 0 0n);`int$(0 0 0 0n))
.ml.timeSplit[symtf;::]~symtf
.ml.timeSplit[symti;::]~symti
.ml.timeSplit[symtb;::]~symtb
