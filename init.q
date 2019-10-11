\l p.q
\d .nlp
version:@[{NLPVERSION};0;`development]
path:{string`nlp^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
loadfile:{$[.z.q;;-1]"Loading ",x:_[":"=x 0]x:$[10=type x;;string]x;system"l ",path,"/",x;}

loadfile`:code/utils.q
loadfile`:code/regex.q
loadfile`:code/sent.q
loadfile`:code/parser.q
loadfile`:code/date_time.q
loadfile`:code/email.q
loadfile`:code/cluster.q
loadfile`:code/nlp_code.q
