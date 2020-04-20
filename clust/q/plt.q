/plots for affinity propagration
plt:.p.import`matplotlib.pyplot;

/plot clusters at each iteration
pltex:{[d;e]
 c:(!).(l;count[l:distinct e]#"bgrcmyk");
 i:(d,'d[e],'cl:c e)til[count d]except l;
 fig:plt[`:figure][`figsize pykw 12 6];
 {plt[`:plot][(x 0;x 2);(x 1;x 3);`c pykw x 4]}each i;
 plt[`:scatter][;;`c pykw cl]. flip d;
 plt[`:show][];}
