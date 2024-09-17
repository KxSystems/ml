// nlp.q - Setup for nlp namespace
// Copyright (c) 2021 Kx Systems Inc
//
// Define version, path, and loadfile


\d .nlp
\l ml/shim.q
version:@[{NLPVERSION};0;`development]
path:{string`nlp^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
loadfile:{$[.z.q;;-1]"Loading ",x:_[":"=x 0]x:$[10=type x;;string]x;system"l ",path,"/",x;}
