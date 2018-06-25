.nlp.loadfile:{$[.z.q;;-1]"Loading ",x;system"l ",.nlp.path,"/",x;} /nlp/",x;}
/ attempt to find the path of this file, default to nlp if any problem
.nlp.path:{$[count u:@[{1_string first` vs hsym`$u -3+count u:get .nlp.loadfile};`;""];u;"nlp"]}[]
.nlp.hpath:hsym`$.nlp.path
.nlp.loadfile"utils.q"
.nlp.loadfile"regex.q"
.nlp.loadfile"sent.q"
.nlp.loadfile"parser.q"
.nlp.loadfile"time.q"
.nlp.loadfile"date.q"
.nlp.loadfile"email.q"
.nlp.loadfile"cluster.q"
.nlp.loadfile"nlp.q"
