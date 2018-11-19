\p 0W /set random port
f:{system"q jworker.q ",x," > worker.log.",x," 2>&1 "}
f each string 4#system"p" /start workers, change the number of workers here

/tracking workers
regt:(0#0)!0#.z.P
regworker:{regt[.z.w]:.z.P} 
.z.pc:{regt::regt _ x}
/ split a list into chunks for each available worker
chunk:{(count[regt],0N)#x}
/ execute function on arg split into func, resf on list of results for chunks
weach:{[func;arg;resf]
 neg[wh:key regt]@'({neg[.z.w]x y};func;)each chunk arg; / chunk and send jobs
 neg[wh]@\:(::);  / async flush
 resf wh@\:(::)} / collect results and handle them

/can specify functions in this script

/ parse documents on workers
/parsedocs:{weach[{parse1 x};x;raze]};
