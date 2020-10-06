\l automl.q
\d .automl

loadfile`:init.q

savedefault[norm :"newnormalparams.txt";`normal]
savedefault[fresh:"newfreshparams.txt" ;`fresh ]
savedefault[nlp  :"newnlpparams.txt"   ;`nlp   ]
rdm_dict:enlist[`hp]!enlist`random
sbl_dict:enlist[`hp]!enlist`sobol

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

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;rdm_dict];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;rdm_dict];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;rdm_dict];};normtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;sbl_dict];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;sbl_dict];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`normal;`class;sbl_dict];};normtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`normal;`reg  ;`xv`gs`saveopt!((`.ml.xv.kfsplit;2);(`.ml.gs.kfsplit;2);1)];};normtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`normal;`class;`hp`trials`saveopt`seed!(`sobol;16;0;12345)];};normtab1;{[err]err;0b}];1b;0b]
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

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;rdm_dict];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;rdm_dict];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;rdm_dict];};freshtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;sbl_dict];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;sbl_dict];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;sbl_dict];};freshtab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;`saveopt`aggcols!(0;`x1)];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;`hp`trials`hld`tts!(`random;10;.3;`.ml.traintestsplit)];};freshtab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;`seed`sz!(75;.4)];};freshtab1;{[err]err;0b}];1b;0b]

0b~$[(::)~@[{.automl.run[x;tgt_f;`fresh;`reg  ;`fresh.txt];};freshtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_b;`fresh;`class;`scf`tts!((`.ml.accuracy;`.ml.mae);`.ml.ttsseed)];};freshtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_b;`fresh;`class;enlist[`gs]!enlist(`.ml.gs.kfsplit;0)];};freshtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;5000?tgt_f;`fresh;`reg;::];};freshtab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_f;`fresh;`reg;`hp`trials!(`sobol;10)];};freshtab1;{[err]err;0b}];1b;0b]

freshtab2:([]5000?100?0p;5000?0Ng;desc 5000?1f;asc 5000?1f;5000?`1)

$[(::)~@[{.automl.run[x;tgt_f  ;`fresh;`reg  ;::];};freshtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b  ;`fresh;`class;::];};freshtab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul;`fresh;`class;::];};freshtab2;{[err]err;0b}];1b;0b]


nlptab1:([]string 1000?`2;1000?0b;1000?1f)

tgt_f_nlp  :1000?1f
tgt_b_nlp  :1000?0b
tgt_mul_nlp:1000?3

$[(::)~@[{.automl.run[x;tgt_f_nlp  ;`nlp;`reg  ;::];};nlptab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b_nlp  ;`nlp;`class;::];};nlptab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul_nlp;`nlp;`class;::];};nlptab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f_nlp  ;`nlp;`reg  ;nlp];};nlptab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b_nlp  ;`nlp;`class;nlp];};nlptab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul_nlp;`nlp;`class;nlp];};nlptab1;{[err]err;0b}];1b;0b]

$[(::)~@[{.automl.run[x;tgt_f_nlp  ;`nlp;`reg  ;`xv`gs`saveopt!((`.ml.xv.kfsplit;2);(`.ml.gs.kfsplit;3);1)];};nlptab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b_nlp  ;`nlp;`class;`saveopt`seed!(1;54321)];};nlptab1;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul_nlp;`nlp;`class;`scf`saveopt`w2v!((enlist[`class]!enlist`.ml.rmsle);0;1)];};nlptab1;{[err]err;0b}];1b;0b]

0b~$[(::)~@[{.automl.run[x;tgt_f_nlp  ;`nlp;`reg  ;enlist[`gs]!enlist`.ml.gs.kfsplit];};nlptab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_b_nlp  ;`nlp;`class;`seed`scf!(1234;.ml.accuracy)];};nlptab1;{[err]err;0b}];1b;0b]
0b~$[(::)~@[{.automl.run[x;tgt_mul_nlp;`nlp;`class;`saveopt`tts!(2;`ttsnon)];};nlptab1;{[err]err;0b}];1b;0b]

nlptab2:([]string 1000?`6;string 1000?`2;1000?0Ng;1000?100f;1000?0b)

$[(::)~@[{.automl.run[x;tgt_f_nlp  ;`nlp;`reg  ;::];};nlptab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_b_nlp  ;`nlp;`class;::];};nlptab2;{[err]err;0b}];1b;0b]
$[(::)~@[{.automl.run[x;tgt_mul_nlp;`nlp;`class;::];};nlptab2;{[err]err;0b}];1b;0b]