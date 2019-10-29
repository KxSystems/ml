\l nlp.q
\l init.q
\d .nlp

sentences:("Three cheers,men--all hearts alive!";"No,no! shame upon all cowards-shame upon them!")
(`Three,(`$"cheers,men--all"),`hearts,`$"alive!";(`$"No,no!"),`shame`upon`all,(`$"cowards-shame"),`upon,(`$"them!"))~tf.tokenize[;`whitespace]each sentences
(`Three`cheers,(`$","),`men,(`$"--"),`all`hearts`alive,`$"!";`No,(`$","),`no,(`$"!"),`shame`upon`all`cowards,(`$"-"),`shame`upon`them,`$"!")~tf.tokenize[;`unicode]each sentences
(`Three`cheers`men`all`hearts`alive;`No`no`shame`upon`all`cowards`shame`upon`them)~tf.i.tokenizeSent[;`unicode]each sentences
(`Three`hearts;`shame`upon`all`upon)~tf.i.tokenizeSent[;`whitespace]each sentences
(`compound`pos`neg`neu!(0001b))~(tf.sent[;`whitespace]first sentences)>tf.sent[;`unicode]first sentences
(`compound`pos`neg`neu!(1001b))~(tf.sent[;`whitespace]last sentences)>tf.sent[;`unicode]last sentences
((`has_punc`is_punc`is_numeric`lower`tokens)!(1 3;`long$();`long$();enlist 2;`Three,(`$"cheers,men--all"),`hearts,`$"alive!"))~tf.wordshape[first sentences;`whitespace;`has_punc`is_punc`is_numeric`lower]
((`has_punc`is_punc`is_numeric`lower`tokens)!(`long$();1 3 8 12;`long$();2 4 5 6 7 9 10 11;`No,(`$","),`no,(`$"!"),`shame`upon`all`cowards,(`$"-"),`shame`upon`them,`$"!"))~tf.wordshape[last sentences;`unicode;`has_punc`is_punc`is_numeric`lower]

