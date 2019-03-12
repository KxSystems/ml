\l init.q
\d .nlp
sent.amplifyEP[""]~0f
sent.amplifyEP[enlist "!"]~.292
0 .292 .584 .876 1.168 1.168 ~sent.amplifyEP each ("ok"; "bad!"; "no!worse!"; "terrible!!!"; "ghastly!!!! eew"; "!!!!!!!!!!")
sent.amplifyQM[""]~0f
sent.amplifyQM[enlist "?"]~0f
0 0 0.36 0.54 0.96 0.96~sent.amplifyQM each ("yes"; "oh?"; "oh? really?"; "you don't say???"; "forsooth????"; "????????????")
all (sent.findSequence[`a`b`c`d;enlist`c]~enlist 2;sent.findSequence[`c`b`c`d; enlist `c] ~ 0 2)
all (sent.findSequence[`a`b`c`d`e`f;`c`d]~enlist 2;sent.findSequence[`a`b`c`d`e`f`c`d; `c`d] ~ 2 6;sent.findSequence[`a`b`c`d`e`f`a`b`c`d`e`g`a`b`c`d; `a`b`c`d] ~ 0 6 12)
sent.findSequence[`a`b`c`d;`c]~enlist 2;
sent.findSequence[`$();`a`b`c]~`long$()
all(sent.findSequence[enlist`a;`a]~enlist 0;sent.findSequence[enlist`a;`b]~`long$())
sent.findSequence[`a`b`c`d`e`a;`a]~0 5
sent.findSequence[0 0 4 5 1 2 4 5;4 5]~2 6
sent.findSequence["Facebook,Tim Cook";"oo"]~5 14
sent.butCheck[`$(); `float$()] ~ `float$()
all(sent.butCheck[enlist `good; enlist 2f] ~ enlist 2f;sent.butCheck[enlist`but;enlist 0f]~enlist 0f)
all(sent.butCheck[`that`was`good`but; 0 0 1 0f] ~ 0 0 .5 0f;sent.butCheck[`that`was`good`but`it; 0 0 1 0 0f] ~ 0 0 .5 0 0f;sent.butCheck[`but`it`was`ok; 0 0 0 1f] ~ 0 0 0 1.5f;sent.butCheck[`tasty`but`it`smelled`bad; 2 0 0 -1.5 -2f] ~ 1 0 0 -2.25 -3f)
sent.butCheck[`it`was`good`and`useful`but`boring`and`gross;0 0 1 0 1.5 0 -1 0 -2]~0 0 .5 0 .75 0 -1.5 0 -3
compare:{value (floor 1000* sent.score x) % 1000}
all(compare[""]~0 0 0 0f;compare["\t\t\r\n\n"]~0 0 0 0f;compare["a  b  c 1"]~0 0 0 0f)
all(compare["bad"]~-.543 0 1 0f;compare["racist"]~-.613 0 1 0f;compare["good"]~.44 1 0 0f;compare["free"] ~.51 1 0 0f;compare["those"]~0 0 0 1f;compare["123"]~0 0 0 1f)
all(compare["ugly smile"]~-0.203 0.431 0.568 0;compare["free sadness"]~0.102 0.532 0.467 0)
all(compare["sad"]~-0.477 0 1 0;compare["marginally sad"]~-0.423 0 0.737 0.262;compare["very sad"]~-0.526 0 0.772 0.227)
all(compare["suave"]~0.458 1 0 0;compare["partly suave"]~0.403 0.73 0 0.269;compare["uber suave"]~0.509 0.767 0 0.232)
all(compare["some very free"]~0.556 0.642 0 0.357;compare["some very free candy"]~0.556 0.544 0 0.455;compare["some very free candy awards"]~0.781 0.695 0 0.304)
all(compare["very delicious"]~0.611 0.799 0 0.2;compare["very super delicious"]~0.847 0.89 0 0.109;compare["very very super delicious"]~.866 .813 0 .186;compare["very very very super delicious"]~.874 .749 0 .25)
compare["That bad ass typgraphy vlog is the shit"]~.757 0.619 0 0.38
compare["Paul Anka doesn't cut the mustard"]~-.357 0 0.452 0.547
all(compare["Paul Anka is cool"]~0.318 0.433 0 0.566;compare["Paul Anka is cool, but..."]~0.165 0.292 0 0.707)
all(compare["Jethro Tull is dorkier"]~-0.274 0 0.411 0.588;compare["But Jethro Tull is dorkier"]~-0.392 0 0.398 0.601)
all(compare["Paul Anka is a dork"]~-0.34 0 0.444 0.555;compare["Paul Anka isn't a dork"]~.258 .404 0 0.595)
all(compare["Paul Anka is a nerd"]~-0.296 0 0.423 0.576;compare["Paul Anka is kind of a nerd"]~-0.229 0 0.322 0.677)
all(sent.score["Paul Anka is the GREATEST"][`compound`pos])>sent.score["Paul Anka is thegreatest"][`compound`pos]
(sent.score["PAUL ANKA IS THE GREATEST"])~sent.score["Paul Anka is the greatest"]
all(compare["中国 is beautiful"]~0.599 0.661 0 0.338;compare["Best φαλάφελ in Greece"]~0.636 0.583 0 0.416;compare["Paul Anka…king of the dorks"]~-0.129 0 0.23 0.769)
compare["Paul Anka's singing is beautiful- especially Black Hole Sun"]~compare["Paul Anka's singing is beautiful especially Black Hole Sun"]
\d .
