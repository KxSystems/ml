// init.q - Load nlp libraries
// Copyright (c) 2021 Kx Systems Inc

path:{string`nlp^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
system"l ",path,"/","nlp.q"

\d .nlp

loadfile`:code/utils.q
loadfile`:code/regex.q
loadfile`:code/sent.q
loadfile`:code/parser.p
loadfile`:code/parser.q
loadfile`:code/dateTime.q
loadfile`:code/extractRtf.p
loadfile`:code/email.q
loadfile`:code/cluster.q
loadfile`:code/nlpCode.q

