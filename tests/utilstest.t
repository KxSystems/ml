\l nlp.q
\l init.q
\d .nlp
all(i.findRuns[where 000000000b]~();i.findRuns[where 100000000b]~();i.findRuns[where 100000001b]~();i.findRuns[where 101010101b]~();i.findRuns[where 100100100b]~())
i.findRuns[where 111111111b]~enlist 0 1 2 3 4 5 6 7 8
i.findRuns[where 11110000b]~enlist 0 1 2 3
all(i.findRuns[where 00011110b]~enlist 3 4 5 6;i.findRuns[where 01111000b] ~ enlist 1 2 3 4)
i.findRuns[where 10011100b] ~ enlist 3 4 5
all(i.findRuns[where 110111011b]~(0 1;3 4 5;7 8);i.findRuns[where 0001110110b]~(3 4 5;7 8);i.findRuns[where 11011101100011b]~(0 1;3 4 5;7 8;12 13))
