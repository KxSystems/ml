\l tests/performance/load.q

// @desc All data required for running the expected analytic, this should
//   be structured such that each dictionary key has the same count
//   and each 'vertical slice' describes an individual set of parameters to
//   be passed to the function
data:`X`y!(til 5;2+til 5)

// @desc Number of unique evaluations being completed
idxs:count first data

// @desc Function to be invoked when generating metrics
// @param iter {long} Number of iterations of the function to be completed
// @param idx {long} Index of the dictionary 'data' to use 
.performance.func:{[iter;idx]
  n:string count data[;idx]`X;
  timing:first system "ts:",string[iter]," .template.example . value data[;",string[idx],"]";
  .performance.metricStore,:.performance.metric[".template.example";n;timing;iter]
  }

// Execute the performance function
.performance.func[100] each til idxs

// Publish the metrics in accordance with requirements for prometheus
-1 "===METRICS===";
-1 @'.performance.metricStore;
-1 "===END METRICS===";

// Exit execution
exit 0;
