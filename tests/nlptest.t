\l nlp.q
\l init.q
\d .nlp
charPosParser:newParser[`en; `sentChars`starts`tokens]
doc:first charPosParser enlist text:"Le café noir était pour André Benoît. Mes aïeux été vieux."
all(doc[`tokens]~`$("le";"café";"noir";"était";"pour";"andré";"benoît";"mes";"aïeux";"été";"vieux");(doc[`starts] cut text)~("Le ";"café ";"noir ";"était ";"pour ";"André ";"Benoît. ";"Mes ";"aïeux ";"été ";"vieux.");(doc[`sentChars;;0] cut text)~("Le café noir était pour André Benoît. ";"Mes aïeux été vieux.");((0,doc[`sentChars;;1]) cut text)~("Le café noir était pour André Benoît.";" Mes aïeux été vieux.";""))
text: first (enlist "*";",";1) 0: `:tests/data/miniJeff.txt
p:newParser[`en; `tokens`isStop];
corpus:p text;
keywords:TFIDF corpus;
0n~keywords[0;`please]
keywords[0;`billion]~keywords[0;`counterparties]
keywords[0; `billion] > keywords[0; `transacting]
()~TFIDF 0#corpus
enlist[(`u#`$())!()]~TFIDF([]tokens:enlist `$(); isStop:enlist `boolean$());
keywords:TFIDF enlist corpus 1;
98h~type keywords
keywords_tot:TFIDF_tot corpus
keywords_tot[`erv]~keywords_tot[`published]
keywords_tot[`mpr] > keywords_tot[`attached]
p:newParser[`en;`keywords];
corpus:p text;
1f~compareDocs . corpus[`keywords]0 0
0f~compareDocs[(enlist`a)!enlist 1;(enlist `b)!enlist 1]
all(0n~compareDocs[`a`b!0 0; `b`c!.6 .5];0n ~ compareDocs[`a`b!0 0; `c`d!0 0])
(compareDocs . corpus[`keywords] 0 2)>compareDocs . corpus[`keywords] 0 20
truncate:{[precision; x]coefficient: 10 xexp precision;reciprocal[coefficient] * `long$coefficient * x}
.64~truncate[3] cosineSimilarity[47 74 14; 97 11 26]
.64~truncate[3] cosineSimilarity[.47 .74 .14; .97 .11 .26]
.872~truncate[3] cosineSimilarity[.33 .96 .39 .61 .59; .51 .81 .11 .09 .83]
0f~truncate[3] cosineSimilarity[0 1; 1 0]
1f~truncate[3] cosineSimilarity[0 1; 0 1]
1f~truncate[3] cosineSimilarity[1; 1]
centroid:sum corpus`keywords
1 1f~2#desc compareDocToCentroid[centroid]each corpus`keywords
1 1 1 1f~4#desc compareDocToCorpus[corpus`keywords;0]
0 0 0f~3#asc compareDocToCorpus[corpus`keywords;0]
explainSimilarity[(`a`b`c)!(.1 .2 .3);(`e`f`g)!(.1 .2 .3)]~(`$())!`float$()
all(explainSimilarity[(`a`b`c)!(.1 .2 .3); (`$())!(`float$())]~(`$())!(`float$());explainSimilarity[(`$())!(`float$());(`a`b`c)!(.1 .2 .3)]~(`$())!(`float$());explainSimilarity[(`$())!(`float$());(`$())!(`float$())]~(`$())!(`float$()))        
all(explainSimilarity[(enlist `a)!enlist .1;(enlist `a)!enlist .1]~(enlist `a)!enlist 1f;explainSimilarity[(enlist `a)!enlist .1;(enlist `a)!enlist .5]~(enlist `a)!enlist 1f;explainSimilarity[(enlist `a)!enlist .1;(enlist `b)!enlist .5]~(`$())!(`float$()))       
all(`a`b`c`d~ key explainSimilarity[(`a`b`c`d)!(.1 .1 .1 .1);(`a`b`c`d)!(.1 .1 .1 .1)];(`$())~key explainSimilarity[(`a`b`c`d)!(.1 .1 .1 .1);(`e`f`g`h)!(.1 .1 .1 .1)];(enlist `a)~key explainSimilarity[(`a`b`c`d)!(.1 .1 .1 .1);(`a`e`f`g)!(.1 .1 .1 .1)];`c`b~key explainSimilarity[(`a`c`b`e)!(.1 .1 .1 .1); (`f`b`c`g)!(.1 .1 .1 .1)])
all(explainSimilarity[(`a`b`c`d)!(.1 .1 .2 .2);(`a`b`c`d)!(.1 .1 .2 .2)][`a`b`c`d]~.1 .1 .4 .4;explainSimilarity[(`a`b`c`d`e`f)!(.1 .1 .2 .2 .3 .4);(`a`b`c`d`g)!(.1 .1 .2 .2 .7)][`a`b`c`d]~.1 .1 .4 .4)
p:newParser[`en;`tokens`isStop`sentIndices];
corpus:p text
extractPhrases[corpus;`antidisestablishmentarianism]~()!()
all `report in/: key extractPhrases[corpus;`report]
all 1<value extractPhrases[corpus;`enron]
phrases:(!) . flip ((`notre`dame`executive`education;7);(`chief`executive`reuters;7);(`sandy`leitch`chief`executive`zurich;7));
phrases~(key phrases)#extractPhrases[corpus;`executive]
all(extractPhrases[p enlist "hydrogren."; `helium] ~ ()!();extractPhrases[p enlist "helium."; `helium] ~()!())
all(()~findDates"";()~findDates"not a date";()~findDates"Oct 33rd 2001";()~findDates"Feb 29st 2001")
/checks ranges- are changed now ()~findDates "2291"
()~findDates"1700"
()~findDates"2291"
(first(findDates "Jan 1800")[;0 1])~1800.01.01 1800.01.31
(first(findDates "Jan 2281")[;0 1])~2281.01.01 2281.01.31
(first(findDates "Jan 1st 1800")[;0 1])~1800.01.01 1800.01.01
(first(findDates "Jan 1st 2281")[;0 1])~2281.01.01 2281.01.01
all(2001.02.01 2001.02.28~first(findDates"Feb 2001")[;0 1];2004.02.01 2004.02.29~first(findDates"Feb 2004")[;0 1];2004.12.01 2004.12.31~first(findDates"Dec 2004")[;0 1];2004.12.01 2004.12.31~first(findDates"2004 Dec")[;0 1])
all((2#2001.02.11)~first(findDates"Feb 11 2001")[;0 1];(2#2001.02.11)~first(findDates"Feb 2001 11")[;0 1];(2#2001.02.11)~first(findDates"11 Feb 2001")[;0 1];(2#2001.02.11)~first(findDates"11 2001 Feb")[;0 1];(2#2001.02.11)~first(findDates"2001 Feb 11")[;0 1];(2#2001.02.11)~first(findDates"2001 11 Feb")[;0 1];(2#2001.02.11)~first(findDates"Feb 11th 01")[;0 1];(2#2001.02.11)~first(findDates"Feb 01 11th")[;0 1];(2#2001.02.11)~first(findDates"11th Feb 01")[;0 1];(2#2001.02.11)~first(findDates"11th 01 Feb")[;0 1];(2#2001.02.11)~first(findDates"01 Feb 11th")[;0 1];(2#2001.02.11)~first(findDates"01 11th Feb")[;0 1];(2#2001.10.11)~first(findDates"10 11th 2001")[;0 1];(2#2001.10.11)~first(findDates"10 2001 11th")[;0 1];(2#2001.10.11)~first(findDates"11th 10 2001")[;0 1];(2#2001.10.11)~first(findDates"11th 2001 10")[;0 1];(2#2001.10.11)~first(findDates"2001 10 11th")[;0 1];(2#2001.10.11)~first(findDates"2001 11th 10")[;0 1])
all((2#1999.02.01)~first(findDates"01/02/1999")[;0 1];(2#1999.02.01)~first(findDates"01/1999/02")[;0 1];(2#1999.02.01)~first(findDates"1999/02/01")[;0 1];(2#2001.02.02)~first(findDates"01/02/Feb")[;0 1];(2#2002.02.01)~first(findDates"01/Feb/02")[;0 1];(2#2001.02.02)~first(findDates"Feb/02/01")[;0 1];(2#2001.02.03)~first(findDates"01/02/3rd")[;0 1];(2#2002.01.03)~first(findDates"01/3rd/02")[;0 1];(2#2001.02.03)~first(findDates "3rd/02/01")[;0 1])
(2#2001.02.03)~first(findDates"03/02/01")[;0 1]
all((2#2035.02.03)~first(findDates"35 3 Feb")[;0 1];(2#2010.02.03)~first(findDates"10 3 Feb")[;0 1];(2#1987.02.03)~first(findDates"87 3rd Feb.")[;0 1];(2#1936.02.03)~first(findDates"36 3rd Feb.")[;0 1])        
all((2#2001.02.03)~first(findDates"3rd. Feb/2001")[;0 1];(2#2001.02.03)~first(findDates"3-Feb.- 2001")[;0 1])
all((2#1965.01.02)~first(findDates"65/01/02")[;0 1];(2#1965.01.02)~first(findDates"02/01/65")[;0 1];(2#2011.12.13)~first(findDates"13/12/11")[;0 1];(2#2013.12.11)~first(findDates"11/12/13")[;0 1])
all(()~findDates"65/13/02";()~findDates"12/13/12")
posParser:newParser[`en; `uniPOS`pennPOS`tokens]
findPOSRuns[`uniPOS; `ADV`VERB;first posParser enlist". ."]~()
findPOSRuns[`uniPOS; `DET;first posParser enlist "The"]~enlist(`the; enlist 0)
findPOSRuns[`uniPOS; `VERB;first posParser enlist"The train from nowhere"]~()
findPOSRuns[`uniPOS; `VERB;first posParser enlist"has been gone dancing"]~enlist(`$"gone dancing";2 3)
doc:first posParser enlist"Wade Hemsworth famously surveyed the Abitibi Waterways in North Ontario.";
all(findPOSRuns[`uniPOS;`DET`PROPN;doc];findPOSRuns[`pennPOS;`DT`NNP`NNPS; doc])~\:((`$"wade hemsworth"; 0 1);(`$"the abitibi waterways"; 4 5 6);(`$"north ontario"; 8 9))
p:newParser[`en;`tokens`isStop`sentIndices];
corpus:p text;
((`$())!())~findRelatedTerms[corpus; `jollof]
chief:findRelatedTerms[corpus; `chief];
chief[`chairman]>chief[`executive]
findTimes["At 11:61am, or 31h00 or 29:59"]~()
findTimes["I eat breakfast at 7:20"]~enlist(07:20:00.000;"7:20";19;23)
(findTimes each("7:45 is good";"7:46 is better"))~(enlist(07:45:00.000; "7:45 ";0;5);enlist(07:46:00.000;"7:46 ";0;5))
findTimes["At 11:00?"]~enlist(11:00:00.000;"11:00";3;8) 
findTimes["At 11:00am, or 11:00pm"]~((11:00:00.000; "11:00am";3;10);(23:00:00.000;"11:00pm";15;22))
findTimes["At 11:00a.m., or 11:00 p.m."]~((11:00:00.000;"11:00a.m";3;11);(23:00:00.000;"11:00 p.m";17;26))
findTimes["I'm leaving at 09:00:07 on the dot"]~enlist(09:00:07.000;"09:00:07 ";15;24)      
findTimes["At 312312:12am 100h555"]~()
findTimes["At 06:00AM, or 4:30 P.M."]~((06:00:00.000;"06:00AM";3;10);(16:30:00.000;"4:30 P.M";15;23))
all(findTimes["12:05 a.m., 1:05 a.m., 2:05 a.m., 3:05 a.m., 4:05 a.m., 5:05 a.m., 6:05 a.m., 7:05 a.m., 8:05 a.m., 9:05 a.m., 10:05 a.m., 11:05 a.m."][;0]~ 00:05:00.000 01:05:00.000 02:05:00.000 03:05:00.000 04:05:00.000 05:05:00.000 06:05:00.000 07:05:00.000 08:05:00.000 09:05:00.000 10:05:00.000 11:05:00.000;findTimes["12:05 pm, 1:05 p.m., 2:05 p.m., 3:05 p.m., 4:05 p.m., 5:05 p.m., 6:05 p.m., 7:05 p.m., 8:05 p.m., 9:05 p.m., 10:05 p.m., 11:05 p.m."][;0] ~ 12:05:00.000 13:05:00.000 14:05:00.000 15:05:00.000 16:05:00.000 17:05:00.000 18:05:00.000 19:05:00.000 20:05:00.000 21:05:00.000 22:05:00.000 23:05:00.000)
sentenceParser:newParser[`en;`text`sentChars]
getSentences[first sentenceParser enlist""]~()
all(getSentences[first sentenceParser enlist "aa."]~enlist "aa.";getSentences[first sentenceParser enlist " ."]~enlist " .")
getSentences[first sentenceParser enlist"This is my sentence"]~enlist "This is my sentence"
(getSentences first sentenceParser enlist "There's no train to Guysborough. Though I know there'll be one in time")~("There's no train to Guysborough."; "Though I know there'll be one in time")
truncate:{[precision; x]coefficient: 10 xexp precision;reciprocal[coefficient]*`long$coefficient*x}
/jaroWinkler
all(.961~truncate[3] i.jaroWinkler["martha";"marhta"];.840~truncate[3] i.jaroWinkler["dwayne"; "duane"];.813~truncate[3] i.jaroWinkler["dixon";"dicksonx"];.743~truncate[3] i.jaroWinkler["johnson"; "jannsen"];.562~truncate[3] i.jaroWinkler["johnson";"jannsenberg"];.906~truncate[3] i.jaroWinkler["aahahahahahahhaahah"; "ahahahahhahahahahaha"])   
all(0f~i.jaroWinkler["benjamin";enlist"z"];0f~i.jaroWinkler["benjamin";enlist"a"])
all(0f~i.jaroWinkler["";enlist"a"];0f~i.jaroWinkler["ben";""])
.75~i.jaroWinkler["abcd"; enlist "b"]
p:newParser[`en; `tokens`isStop];
corpus:p text;       
(()!())~keywordsContinuous 0#corpus  
((`$())!())~keywordsContinuous ([]tokens:enlist`$();isStop:enlist`boolean$())
doc:corpus 1;
keywords:keywordsContinuous enlist doc;
99h ~ type keywords
keywords:keywordsContinuous corpus;
{x~desc x} keywords `chairman`chief`group`enron`thanks`mountains
(1 1f,(2%3),(1%3),0.5 0.5 0.5 0.5 0.5 0.5)~value 10#ngram[enlist first corpus;2]
1 1 .5 .5 1 1 1 1 1 1f~value 10#ngram[enlist first corpus;3]
((`enrononline`management`report);(`management`report`june);(`report`june`attached))~key 3#ngram[enlist first corpus;3]
emails:email.loadEmails["tests/data/test.mbox"]
`sender`to`date`subject`contentType`payload`text~cols emails
(last emails`text)~"Your email client does not support HTML mails."
("multipart/alternative";"multipart/alternative";"multipart/alternative";"multipart/alternative";"multipart/alternative";"multipart/alternative";"text/html";"multipart/alternative";"multipart/alternative")~emails`contentType
`sender`to`volume~cols email.getGraph emails
1~(last email.getGraph emails)`volume
parseURLs["http://www.google.com"]~`scheme`domainName`path`parameters`query`fragment!("http";"www.google.com";"";"";"";"")
parseURLs["ssh://samsquanch@mx4.hotmail.com"][`scheme`domainName]~("ssh";"samsquanch@mx4.hotmail.com")
parseURLs["https://www.google.ca:1234/test/index.html;myParam?foo=bar&quux=blort#abc=123&def=456"]~(!) . flip ((`scheme;"https");(`domainName;"www.google.ca:1234");(`path;"/test/index.html");(`parameters;   "myParam");(`query;"foo=bar&quux=blort");(`fragment;"abc=123&def=456"))
all(parseURLs["google.ca/test/index.html"][`scheme`domainName`path]~("http";"google.ca";"/test/index.html");parseURLs["www.google.co.uk"][`scheme`domainName`path]~("http";"www.google.co.uk";""))
parseURLs["https://网站.中国.com"]~`scheme`domainName`path`parameters`query`fragment!("https";"网站.中国.com";"";"";"";"")
(parseURLs each ("https://travel.gc.ca/";"https://www.canada.ca/en/revenue-agency.html"))~([]scheme:("https"; "https");domainName:("travel.gc.ca"; "www.canada.ca");path:(enlist "/";"/en/revenue-agency.html");parameters: (""; "");query:(""; "");fragment:(""; ""))
seq:bi_gram[corpus]
seq[`enrononline`management]~1f
seq[`management`report]>seq[`report`june]
`en~detectLang["This is a sentence"]
`de~detectLang["Das ist ein Satz"]
`fr~detectLang["C'est une phrase"]
ascii["This is ä senteñcê"]~"This is  sentec"
rmv_list   :("http*";"*,";"*&*";"*[0-9]*")
rmv_custom["https//:google.com & https//:bing.com are 2 search engines!";rmv_list]~"are search engines!"
rmv_master["https//:google.com & https//:bing.com are 2 search engines!";",.:?!/@'\n";""]~"httpsgooglecom & httpsbingcom are 2 search engines"
loadDir:loadTextFromDir["tests/data/test.mbox"]
`fileName`path`text~cols loadDir
loadDir[`fileName]~enlist `test.mbox
text: first (enlist "*";",";1) 0: `:tests/data/miniJeff.txt
p:newParser[`en;`tokens`isStop`text]
corpus:p text
phonecall:corpus n:where corpus[`text] like "*Telephone Call*"
remaining:corpus til[count corpus]except n
(`message`murdock`erica`error`jerry;`enron`know`let,`meeting`company)~key each 5#/:compareCorpora[phonecall;remaining]
txt:"You can call the number 123 456 7890 or email us on name@email.com in book an appoinment for January,February and March for £30.00"
findRegex[txt;`phoneNumber`emailAddress`yearmonthList`money]~`phoneNumber`emailAddress`yearmonthList`money!(enlist (" 123 456 7890";23;36);enlist("name@email.com";52;66);(("January";93;100);("February";101;109);("March";114;119);("30";125;127);("00";128;130));enlist("\302\24330.00";124;130))
\d .

