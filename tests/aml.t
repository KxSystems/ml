\l automl.q
\d .automl

loadfile`:init.q

savedefault[norm :"newnormalparams.txt";`normal]
savedefault[fresh:"newfreshparams.txt" ;`fresh ]

tgt_f:asc 100?1f
tgt_b:100?0b
tgt_mul:100?3

normtab1:([]100?1f;100?0b;asc 100?`1;100?100)

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;::];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;::];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;::];};normtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;norm];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;norm];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;norm];};normtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;`xv`gs`saveopt!((`.ml.xv.kfsplit;2);(`.ml.gs.kfsplit;2);1)];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;`saveopt`seed!(0;12345)];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;`scf`saveopt`sz!((`class`reg!(`.ml.mae;`.ml.rmsle));2;.6)];};normtab1;{[err]err;0b}];1b;0b]

0b~$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;enlist[`tst]!enlist 1];};normtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;`saveopt`tts!(2;`.ml.tst)];};normtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;`seed`xv!(`aml;`.ml.xv.kfshuffle)];};normtab1;{[err]err;0b}];1b;0b]

normtab2:([]100?0Ng;100?1f;asc 100?1000;100?`1)

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;::];};normtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;::];};normtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;::];};normtab2;{[err]err;0b}];1b;0b]

normtab3:([]100?0p;desc 100?1f;100?1f;100?`a`b`c)

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;::];};normtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;::];};normtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;::];};normtab2;{[err]err;0b}];1b;0b]

freshtab1:([]5000?100?0p;asc 5000?100?1f;5000?1f;desc 5000?10f;5000?0b)

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;::];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;::];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;::];};freshtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;fresh];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;fresh];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;fresh];};freshtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;`saveopt`aggcols!(0;`x1)];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;`hld`tts!(.3;`.ml.traintestsplit)];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;`seed`sz!(75;.4)];};freshtab1;{[err]err;0b}];1b;0b]

0b~$[(::)~@[{.automl.run[x;tgt_f;`fresh;`reg  ;`fresh.txt];};freshtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_b;`fresh;`class;`scf`tts!((`.ml.accuracy;`.ml.mae);`.ml.ttsseed)];};freshtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_b;`fresh;`class;enlist[`gs]!enlist(`.ml.gs.kfsplit;0)];};freshtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;5000?tgt_f;`fresh;`reg;::];};freshtab1;{[err]err;0b}];1b;0b]

freshtab2:([]5000?100?0p;5000?0Ng;desc 5000?1f;asc 5000?1f;5000?`1)

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;::];};freshtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;::];};freshtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;::];};freshtab2;{[err]err;0b}];1b;0b]
