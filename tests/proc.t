\l automl.q
\d .automl

loadfile`:init.q

xtrn:flip(til 5;01010b;asc til 5;7.6 1.2 9.5 8.3 2.4;11001b)
ytrn:10101b
xtst:flip(3 2 1 9 0;10101b;9 8 2 3 4;8.4 3.2 7.9 0.1 2.2;10110b)
ytst:11001b
data:(xtrn;ytrn;xtst;ytst)

mdl:flip`model`lib`fnc`seed`typ!flip key[d],'value d:proc.i.txtparse[`class;"/code/models/"]
scf:.ml.accuracy
p:i.normaldefault[]

rfclf:proc.i.mdlfunc[`sklearn;`ensemble;`RandomForestClassifier]
gshp:enlist[`random_state]!enlist 123;
rshp:`typ`random_state`n`p!(`random;123;8;`n_estimators`max_depth!((`uniform;1;100;"j");(`uniform;1;50;"j")))
sbhp:`typ`random_state`n`p!(`sobol ;123;8;`n_estimators`max_depth!((`uniform;1;100;"j");(`uniform;1;50;"j")))

raze[first value get[`.ml.gs.kfsplit][5;1;data 0;data 1;p[`prf]rfclf;gshp;enlist[`val]!enlist 0]]~enlist each 0110011001b

$[(::)~@[{get[`.ml.gs.kfsplit][5;1;data 0;data 1;p[`prf]rfclf;x;enlist[`val]!enlist 0];};gshp;{[err]err;0b}];1b;0b]
$[(::)~@[{get[`.ml.rs.kfsplit][5;1;data 0;data 1;p[`prf]rfclf;x;enlist[`val]!enlist 0];};rshp;{[err]err;0b}];1b;0b]
$[(::)~@[{get[`.ml.rs.kfsplit][5;1;data 0;data 1;p[`prf]rfclf;x;enlist[`val]!enlist 0];};sbhp;{[err]err;0b}];1b;0b]

/ scoring

proc.i.ord[`.ml.accuracy]~desc
proc.i.ord[`.ml.rmse]~asc
proc.i.ord[`.ml.r2score]~desc