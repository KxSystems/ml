\d .ml
/ bootstrap load ml library
system"l ",{$[count u:@[{1_string first` vs hsym`$u -3+count u:get .z.s};`;""];u;"ml"]}[],"/ml.q"
/load in all the .q scripts within the ml library
loadfile`:util/init.q
loadfile`:fresh/init.q
