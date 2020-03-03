// Fix for windows argv matplotlib conflict
\l p.q
.p.import[`sys;:;`:argv;enlist""]

\d .automl
version:@[{AUTOMLVERSION};`;`development]
path:{string`automl^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
loadfile:{$[.z.q;;-1]"Loading ",x:_[":"=x 0]x:$[10=type x;;string]x;system"l ",path,"/",x;}
