path:{string`nlp^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
system"l ",path,"/","nlp.q"

\d .nlp

loadfile`:code/checkimport.p
loadfile`:code/utils.q
loadfile`:code/regex.q
loadfile`:code/sent.q
loadfile`:code/parser.q
loadfile`:code/date_time.q
loadfile`:code/email.q
loadfile`:code/cluster.q
loadfile`:code/nlp_code.q
if[0~checkimport`tensorflow;loadfile`:code/tensorflow.q]

