\l ml.q
\l util/init.q
\l xval/utils.q
\l xval/xval.q
\l xval/tests/test.p

xf:flip(1000?100f;asc 1000?100f)
yf:asc 1000?100f
xi:flip(1000?10000;asc 1000?10000)
yi:asc 1000?10000
xb:flip(1000?0101101011b;asc 1000?0101101011b)
yb:1000#110011001100b
xc:flip(1000?100f;asc 1000?100f)
yc:1000#`A`B`A`C`B`C

df:(2;0N)#value .ml.trainTestSplit[xf;yf;.2]
di:(2;0N)#value .ml.trainTestSplit[xi;yi;.2]
db:(2;0N)#value .ml.trainTestSplit[xb;yb;.2]
dc:(2;0N)#value .ml.trainTestSplit[xc;yc;.2]

net:{.p.import[`sklearn.linear_model]`:ElasticNet}
lin:{.p.import[`sklearn.linear_model]`:LinearRegression}
dtc:{.p.import[`sklearn.tree]`:DecisionTreeClassifier}

fs:.ml.xv.fitScore
rnd:{.01*"j"$100*x}
bp:{first where a=max a:avg each x}

k:3
p:.2
seed:42
trials:8
gs_pr:`alpha`max_iter!(0.1 0.2;100 200 1000)
gs_pc:enlist[`max_depth]!enlist(::;1;2;3;4;5)
rs_pr_rdm:`typ`random_state`n`p!(`random;seed;trials;`alpha`max_iter!((`uniform;.1;1.;"f");(`loguniform;1;4;"j")))
rs_pc_rdm:`typ`random_state`n`p!(`random;seed;trials;enlist[`max_depth]!enlist(`uniform;1;30;"j"))
rs_pr_sbl:`typ`random_state`n`p!(`sobol;seed;trials;`alpha`max_iter!((`uniform;.1;1.;"f");(`loguniform;1;4;"j")))
rs_pc_sbl:`typ`random_state`n`p!(`sobol;seed;trials;enlist[`max_depth]!enlist(`uniform;1;30;"j"))
rs_pr_err:`typ`random_state`n`p!(`sobol;seed;10;`alpha`max_iter!((`uniform;.1;1.;"f");(`loguniform;1;4;"j")))
rs_pc_err:`typ`random_state`n`p!(`sobol;seed;10;enlist[`max_depth]!enlist(`uniform;1;30;"j"))

ms:enlist(2 800 2;2 200 2)
ridx:1_(1 xprev l),'l:enlist each(3,0N)#t:til count yf
cidx:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each(3,0N)#t;
fr:first each ridx
fc:first each cidx
lr:last each ridx
lc:last each cidx

/ utils

not(count[s]~count[yf])&(s:.ml.xv.i.shuffle[yf])~yf
not(count[s]~count[yi])&(s:.ml.xv.i.shuffle[yi])~yi
not(count[s]~count[yb])&(s:.ml.xv.i.shuffle[yb])~yb
not(count[s]~count[yc])&(s:.ml.xv.i.shuffle[yc])~yc

(`int$.ml.xv.i.splitIdx[2;yf])~`int$reverse first(.p.list kfsplit[yf;2])`
(`int$.ml.xv.i.splitIdx[2;yi])~`int$reverse first(.p.list kfsplit[yi;2])`
(`int$.ml.xv.i.splitIdx[2;yb])~`int$reverse first(.p.list kfsplit[yb;2])`
(`int$.ml.xv.i.splitIdx[2;yc])~`int$reverse first(.p.list kfsplit[yc;2])`

(.ml.shape .ml.xv.i.shuffIdx[k;yf])~3 333
(.ml.shape .ml.xv.i.shuffIdx[5;yi])~5 200
(.ml.shape .ml.xv.i.shuffIdx[2;yb])~2 500
(.ml.shape .ml.xv.i.shuffIdx[0;yc])~`long$()

(count each .ml.xv.i.stratIdx[k;yf])~0 0 1000
({count@'value group x}each yb .ml.xv.i.stratIdx[k;yb])~(166 166;167 167;167 167)
(.ml.shape .ml.xv.i.stratIdx[0;yb])~`long$()

.ml.xv.i.groupIdx[1]~enlist(`long$();0,())
.ml.xv.i.groupIdx[2]~enlist@''((0;1);(1;0))
.ml.xv.i.groupIdx[k]~((0 1;2,());(2 0;1,());(1 2;0,()))

/ xval

(avg[.ml.xv.kfSplit[k;1;xf;yf;fs[net][]]]-avg kfoldr[xf;yf])<.05
(avg[.ml.xv.kfSplit[k;1;xi;yi;fs[net][]]]-avg kfoldr[xi;yi])<.05
(avg[.ml.xv.kfSplit[k;1;xb;yb;fs[dtc][]]]-avg kfoldc[xb;yb])<.05
(avg[.ml.xv.kfSplit[k;1;xc;yc;fs[dtc][]]]-avg kfoldc[xc;yc])<.05

count[.ml.xv.kfShuff[k;1;xf;yf;fs[net][]]]~3
count[.ml.xv.kfShuff[k;1;xi;yi;fs[net][]]]~3
count[.ml.xv.kfShuff[k;1;xb;yb;fs[dtc][]]]~3
count[.ml.xv.kfShuff[k;1;xc;yc;fs[dtc][]]]~3

count[.ml.xv.kfStrat[k;1;xb;yb;fs[dtc][]]]~3
count[.ml.xv.kfStrat[k;1;xc;yc;fs[dtc][]]]~3

.ml.xv.tsRolls[k;1;xf;yf;fs[lin][]]~crossvalr[xf;yf;fr;lr;3]
.ml.xv.tsRolls[k;1;xi;yi;fs[lin][]]~crossvalr[xi;yi;fr;lr;3]
(avg[.ml.xv.tsRolls[k;1;xb;yb;fs[dtc][]]]-avg crossvalc[xb;yb;fr;lr;3])<.05
(avg[.ml.xv.tsRolls[k;1;xc;yc;fs[dtc][]]]-avg crossvalc[xc;yc;fr;lr;3])<.05

.ml.xv.tsChain[k;1;xf;yf;fs[lin][]]~crossvalr[xf;yf;fc;lc;3]
.ml.xv.tsChain[k;1;xi;yi;fs[lin][]]~crossvalr[xi;yi;fc;lc;3]
(avg[.ml.xv.tsChain[k;1;xb;yb;fs[dtc][]]]-avg crossvalc[xb;yb;fc;lc;3])<.05
(avg[.ml.xv.tsChain[k;1;xc;yc;fs[dtc][]]]-avg crossvalc[xc;yc;fc;lc;3])<.05

(.ml.xv.pcSplit[p;1;xf;yf]{[d].ml.shape each d})~ms
(.ml.xv.pcSplit[p;1;xi;yi]{[d].ml.shape each d})~ms
(.ml.xv.pcSplit[p;1;xb;yb]{[d].ml.shape each d})~ms
(.ml.xv.pcSplit[p;1;xc;yc]{[d].ml.shape each d})~ms
(.ml.xv.pcSplit[p;1;xf;yf]{count@''x})~enlist(800 800;200 200)
(.ml.xv.pcSplit[.1;3;xf;yf]{count@''x})~3#enlist(900 900;100 100)
(.ml.xv.pcSplit[.3;5;xf;yf]{count@''x})~5#enlist(700 700;300 300)

(.ml.xv.mcSplit[p;1;xf;yf]{[d].ml.shape each d})~ms
(.ml.xv.mcSplit[p;1;xi;yi]{[d].ml.shape each d})~ms
(.ml.xv.mcSplit[p;1;xb;yb]{[d].ml.shape each d})~ms
(.ml.xv.mcSplit[p;1;xc;yc]{[d].ml.shape each d})~ms
(.ml.xv.mcSplit[p;1;xf;yf]{count@''x})~enlist(800 800;200 200)
(.ml.xv.mcSplit[.1;3;xf;yf]{count@''x})~3#enlist(900 900;100 100)
(.ml.xv.mcSplit[.3;5;xf;yf]{count@''x})~5#enlist(700 700;300 300)

/ grid search

(bp .ml.gs.kfSplit[k;1;xf;yf;fs net;gs_pr;0])~@[;1]gridsearchr[xf;yf]
(bp .ml.gs.kfSplit[k;1;xi;yi;fs net;gs_pr;0])~@[;1]gridsearchr[xi;yi]
(rnd[(avg/).ml.gs.kfSplit[k;1;xf;yf;fs net;gs_pr;0]]-rnd@[;0]gridsearchr[xf;yf])<.05
(rnd[(avg/).ml.gs.kfSplit[k;1;xi;yi;fs net;gs_pr;0]]-rnd@[;0]gridsearchr[xi;yi])<.05
(rnd[(avg/).ml.gs.kfSplit[k;1;xb;yb;fs dtc;gs_pc;0]]-rnd@[;0]gridsearchc[xb;yb])<.05
(rnd[(avg/).ml.gs.kfSplit[k;1;xc;yc;fs dtc;gs_pc;0]]-rnd@[;0]gridsearchc[xc;yc])<.05

((@[;2].ml.gs.kfSplit[k;1;xf;yf;fs net;gs_pr;.2])-@[;0]gridsearchr[xf;yf])<.05
((@[;2].ml.gs.kfSplit[k;1;xi;yi;fs net;gs_pr;.2])-@[;0]gridsearchr[xi;yi])<.06
((@[;2].ml.gs.kfSplit[k;1;xb;yb;fs dtc;gs_pc;.2])-@[;0]gridsearchc[xb;yb])<.05
((@[;2].ml.gs.kfSplit[k;1;xc;yc;fs dtc;gs_pc;.2])-@[;0]gridsearchc[xc;yc])<.05

(key@[;1].ml.gs.kfSplit[k;1;xf;yf;fs net;gs_pr;.2])~`alpha`max_iter
(key@[;1].ml.gs.kfSplit[k;1;xi;yi;fs net;gs_pr;.2])~`alpha`max_iter
(key@[;1].ml.gs.kfSplit[k;1;xb;yb;fs dtc;gs_pc;.2])~enlist`max_depth
(key@[;1].ml.gs.kfSplit[k;1;xc;yc;fs dtc;gs_pc;.2])~enlist`max_depth

.ml.shape[.ml.gs.kfSplit[ 4;2;xf;yf;.ml.xv.fitScore net;gs_pr; .2]]~3 6 8
.ml.shape[.ml.gs.kfShuff[ 4;2;xf;yf;.ml.xv.fitScore net;gs_pr;-.2]]~3 6 8
.ml.shape[.ml.gs.kfStrat[ 4;2;xb;yb;.ml.xv.fitScore dtc;gs_pc;-.2]]~3 6 8
.ml.shape[.ml.gs.tsRolls[ 2;5;xb;yb;.ml.xv.fitScore dtc;gs_pc; .2]]~3 6 5
.ml.shape[.ml.gs.tsChain[ 2;5;xb;yb;.ml.xv.fitScore dtc;gs_pc; .2]]~3 6 5
.ml.shape[.ml.gs.pcSplit[.3;5;xf;yf;.ml.xv.fitScore net;gs_pr; .2]]~3 6 5
.ml.shape[.ml.gs.mcSplit[.3;5;xf;yf;.ml.xv.fitScore net;gs_pr;-.2]]~3 6 5

/ random search

(key@[;1].ml.rs.kfSplit[k;1;xf;yf;fs net;rs_pr_rdm;.2])~`alpha`max_iter
(key@[;1].ml.rs.kfSplit[k;1;xi;yi;fs net;rs_pr_rdm;.2])~`alpha`max_iter
(key@[;1].ml.rs.kfSplit[k;1;xb;yb;fs dtc;rs_pc_rdm;.2])~enlist`max_depth
(key@[;1].ml.rs.kfSplit[k;1;xc;yc;fs dtc;rs_pc_rdm;.2])~enlist`max_depth

.ml.shape[.ml.rs.kfSplit[ 4;2;xf;yf;.ml.xv.fitScore net;rs_pr_rdm; .2]]~3 8 8
.ml.shape[.ml.rs.kfShuff[ 4;2;xf;yf;.ml.xv.fitScore net;rs_pr_rdm;-.2]]~3 8 8
.ml.shape[.ml.rs.kfStrat[ 4;2;xb;yb;.ml.xv.fitScore dtc;rs_pc_rdm;-.2]]~3 7 8
.ml.shape[.ml.rs.tsRolls[ 2;5;xb;yb;.ml.xv.fitScore dtc;rs_pc_rdm; .2]]~3 7 5
.ml.shape[.ml.rs.tsChain[ 2;5;xb;yb;.ml.xv.fitScore dtc;rs_pc_rdm; .2]]~3 7 5
.ml.shape[.ml.rs.pcSplit[.3;5;xf;yf;.ml.xv.fitScore net;rs_pr_rdm; .2]]~3 8 5
.ml.shape[.ml.rs.mcSplit[.3;5;xf;yf;.ml.xv.fitScore net;rs_pr_rdm;-.2]]~3 8 5

/ sobol search

(key@[;1].ml.rs.kfSplit[k;1;xf;yf;fs net;rs_pr_sbl;.2])~`alpha`max_iter
(key@[;1].ml.rs.kfSplit[k;1;xi;yi;fs net;rs_pr_sbl;.2])~`alpha`max_iter
(key@[;1].ml.rs.kfSplit[k;1;xb;yb;fs dtc;rs_pc_sbl;.2])~enlist`max_depth
(key@[;1].ml.rs.kfSplit[k;1;xc;yc;fs dtc;rs_pc_sbl;.2])~enlist`max_depth

.ml.shape[.ml.rs.kfSplit[ 4;2;xf;yf;.ml.xv.fitScore net;rs_pr_sbl; .2]]~3 8 8
.ml.shape[.ml.rs.kfShuff[ 4;2;xf;yf;.ml.xv.fitScore net;rs_pr_sbl;-.2]]~3 8 8
.ml.shape[.ml.rs.kfStrat[ 4;2;xb;yb;.ml.xv.fitScore dtc;rs_pc_sbl;-.2]]~3 8 8
.ml.shape[.ml.rs.tsRolls[ 2;5;xb;yb;.ml.xv.fitScore dtc;rs_pc_sbl; .2]]~3 8 5
.ml.shape[.ml.rs.tsChain[ 2;5;xb;yb;.ml.xv.fitScore dtc;rs_pc_sbl; .2]]~3 8 5
.ml.shape[.ml.rs.pcSplit[.3;5;xf;yf;.ml.xv.fitScore net;rs_pr_sbl; .2]]~3 8 5
.ml.shape[.ml.rs.mcSplit[.3;5;xf;yf;.ml.xv.fitScore net;rs_pr_sbl;-.2]]~3 8 5

$[0b=@[{.ml.rs.kfSplit[ 4;2;xf;yf;.ml.xv.fitScore dtc;x;-.2];};rs_pr_err;{[err]err;0b}];1b;0b]
$[0b=@[{.ml.rs.kfShuff[ 4;2;xf;yf;.ml.xv.fitScore dtc;x;-.2];};rs_pr_err;{[err]err;0b}];1b;0b]
$[0b=@[{.ml.rs.kfStrat[ 4;2;xb;yb;.ml.xv.fitScore dtc;x;-.2];};rs_pc_err;{[err]err;0b}];1b;0b]
$[0b=@[{.ml.rs.tsRolls[ 4;2;xb;yb;.ml.xv.fitScore dtc;x;-.2];};rs_pc_err;{[err]err;0b}];1b;0b]
$[0b=@[{.ml.rs.tsChain[ 4;2;xb;yb;.ml.xv.fitScore dtc;x;-.2];};rs_pc_err;{[err]err;0b}];1b;0b]
$[0b=@[{.ml.rs.pcSplit[ 4;2;xf;yf;.ml.xv.fitScore dtc;x;-.2];};rs_pr_err;{[err]err;0b}];1b;0b]
$[0b=@[{.ml.rs.mcSplit[ 4;2;xf;yf;.ml.xv.fitScore dtc;x;-.2];};rs_pr_err;{[err]err;0b}];1b;0b]

/ scoring

fs[net;::;df]~fitscore[df[0]0;df[0]1;df[1]0;df[1]1]
fs[net;::;di]~fitscore[di[0]0;di[0]1;di[1]0;di[1]1]
fs[net;::;db]~fitscore[db[0]0;db[0]1;db[1]0;db[1]1]
