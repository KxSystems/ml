\l init.q

// Load the functionality and variables required when running individual performance tests
// NOTE: This is configurable and developers should modify/add functions that are needed for
//       specific benchmarks as required

// @desc Global for metric storage
.performance.metricStore:()

// @desc Function to be invoked for the generation of metrics to be published to gitlab
// @param name {string} The name of the metric which is to be published
// @param n {string} The number of datapoints being used in the evaluation
// @param duration {long} The total length of time taken to run the metric evaluation
// @param times {long} The total number of repetitions of the function being evaluated
// @return {string} The metric information that is to be publised to gitlab
.performance.metric:{[name;n;duration;times]
  enlist name,"_performance{count=",n,",times=",string[times],"} ",string duration % times
  }
