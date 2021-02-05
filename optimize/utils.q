\d .ml

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Optimize a function until gradient tolerance is reached or
//   maximum number of allowed iterations is met. The following outlines a
//   python equivalent
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/optimize.py#L1131
// @param func {func} Function to be minimized
// @param optimDict {dict} Variables to be updated at each iteration of
//   optimization
// @param args {any} Arguments to the optimization function that do not 
//   change per iteration 
// @param params {dict} Parameters controlling non default optimization 
//   behaviour
// @return {dict} Variables, gradients, matrices and indices at the end of 
//   each iteration
i.BFGSFunction:{[func;optimDict;args;params] 
  // Calculate search direction
  pk:neg mmu[optimDict`hess;optimDict`gk];
  // Line search func to be inserted to get alpha
  wolfe:i.wolfeSearch[;;;pk;func;;args;params]. optimDict`fk`fkPrev`gk`xk;
  // Old fk goes to previous val
  optimDict[`fkPrev]:optimDict`fk;
  // Update values based on wolfe line search
  alpha:wolfe 0;
  optimDict[`fk]:wolfe 1;
  gNew:wolfe 2;
  // Redefine the x value at k-1 to the current x value
  optimDict[`xkPrev]:optimDict`xk;
  // Calculate the step distance for moving from x(k-1) -> x(k)
  sk:alpha*pk;
  // Update values of x at the new position k
  optimDict[`xk]:optimDict[`xkPrev]+sk;
  // If null gNew, then get gradient of new x value
  if[any null gNew;gNew:i.grad[func;optimDict`xk;args;params`geps]];
  // Subtract new gradients
  yk:gNew-optimDict`gk;
  optimDict[`gk]:gNew;
  // Get new norm of gradient
  optimDict[`gnorm]:i.vecNorm[optimDict`gk;params`norm];
  // Calculate new hessian matrix for next iteration 
  rhok:1%mmu[yk;sk];
  if[0w=rhok;
    rhok:1000f;
    -1"Division by zero in calculation of rhok, assuming rhok large";
    ];
  A1:optimDict[`I]-sk*\:yk*rhok;
  A2:optimDict[`I]-yk*\:sk*rhok;
  hessMul:mmu[A1;mmu[optimDict`hess;A2]];
  optimDict[`hess]:hessMul+rhok*(sk*/:sk);
  // if x(k) returns infinite value update gnorm and fk
  if[0w in abs optimDict`xk;optimDict[`gnorm`fk]:(0n;0w)];
  optimDict[`idx]+:1;
  if[params`display;show optimDict;-1"";];
  optimDict
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Complete a line search across an unconstrained minimization
//   problem making use of wolfe conditions to constrain the search. The naming
//   convention for dictionary keys in this implementation is based on the 
//   python implementation of the same functionality here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L193 // noqa
// @param fk {float} Function return evaluated at position k
// @param fkPrev {float} Function return evaluated at position k-1
// @param gk {float} Gradient at position k
// @param pk {float} Search direction
// @param func {func} Function being optimized 
// @param xk {num[]} Parameter values at position k
// @param args {dict;num[]} Function arguments that do not change per iteration
// @param params {dict} Parameters controlling non default optimization
//   behaviour
// @return {num[]} New alpha, fk and derivative values
i.wolfeSearch:{[fk;fkPrev;gk;pk;func;xk;args;params]
  phiFunc   :i.phi[func;pk;;xk;args];
  derPhiFunc:i.derPhi[func;params`geps;pk;;xk;args];
  // Initial Wolfe conditions
  wolfeKeys:`idx`alpha0`phi0`phia0;
  wolfeVals:(0;0;fk;fk);
  wolfeDict:wolfeKeys!wolfeVals;
  // Calculate the derivative at that phi0
  derPhi0:gk mmu pk;
  wolfeDict[`derPhia0`derPhi0]:2#derPhi0;
  // Calculate step size this should be 0 < x < 1 
  // with min(x;maxstepsize) or 1f otherwise
  alpha:1.01*2*(fk-fkPrev)%derPhi0;
  alphaVal:$[alpha within 0 1f;min(alpha;params`stepSize);1f];
  wolfeDict[`alpha1]:alphaVal;
  // function value at alpha1
  wolfeDict[`phia1]:phiFunc wolfeDict`alpha1;
  // Repeat until wolfe criteria is reached or max iterations have been done
  // to get new alpha, phi and derPhi values
  wolfeDict:i.stopWolfe[;params]
    i.scalarWolfe[derPhiFunc;phiFunc;pk;params]/wolfeDict;
  // if the line search did not converge, use last alpha , phi and derPhi
  $[not any null raze wolfeDict`alphaStar`phiStar`derPhiStar;
    wolfeDict`alphaStar`phiStar`derPhiStar;
    wolfeDict`alpha1`phia1`derPhia0Fin
    ]
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Apply a scalar search to find an alpha value that satisfies
//   strong Wolfe conditions, a python implementation of this is outlined here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L338  // noqa
//   This functions defines the bounds between which the step function can 
//   be found. When the optimal bound is found, the area is zoomed recursively
//   until the optimal value is found
// @param derPhiFunc {func} Function to calculate the value of the objective
//   function derivative at alpha
// @param phiFunc {func} Function to calculate the value of the objective
//   function at alpha
// @param pk {float} Search direction
// @param params {dict} Parameters controlling non default optimization
//   behaviour
// @param wolfeDict {dict} All data relevant to the calculation of the optimal
//   alpha values 
// @returns {dict} New alpha, fk and derivative values
i.scalarWolfe:{[derPhiFunc;phiFunc;pk;params;wolfeDict]
  // Set up zoom function constant params
  zoomSetup:i.zoomFunc[derPhiFunc;phiFunc;;;params]. wolfeDict`phi0`derPhi0;
  // If criteria 1 is met, zoom and break loop
  if[i.wolfeCriteria1[wolfeDict;params];
    wolfeDict[`idx]:0w;
    wolfeVals:wolfeDict`alpha0`alpha1`phia0`phia1`derPhia0;
    updZoom:zoomSetup wolfeVals;
    wolfeDict[i.zoomReturn]:updZoom;
    :wolfeDict
    ];
  // Calculate the derivative of the function at the new position
  derPhiCalc:derPhiFunc wolfeDict`alpha1;
  // Update the new derivative function
  wolfeDict[`derPhia1]:derPhiCalc`derval;
  $[i.wolfeCriteria2[wolfeDict;params];
    [wolfeDict[`alphaStar]:wolfeDict`alpha1;
     wolfeDict[`phiStar]:wolfeDict`phia1;
     wolfeDict[`derPhiStar]:derPhiCalc`grad;
     wolfeDict[`idx]:0w;
     wolfeDict
    ];
    0<=wolfeDict`derPhia1;
    [wolfeDict[`idx]:0w;
     updZoom:zoomSetup wolfeDict`alpha1`alpha0`phia1`phia0`derPhia1;
     wolfeDict[i.zoomReturn]:updZoom   
    ];
    // Update dictionary and repeat process until criteria is met
    [wolfeDict[`alpha0]:wolfeDict`alpha1;
     wolfeDict[`alpha1]:2*wolfeDict`alpha1;
     wolfeDict[`phia0]:wolfeDict`phia1;
     wolfeDict[`phia1]:phiFunc wolfeDict`alpha1;
     wolfeDict[`derPhia0]:wolfeDict`derPhia1;
     wolfeDict[`derPhia0Fin]:derPhiCalc`grad;
     wolfeDict[`idx]+:1
    ]
    ];
  wolfeDict
  }

// @private
// @kind function
// @category optimizeUtility
// @fileoverview Function to apply 'zoom' iteratively during linesearch to find
//   optimal alpha value satisfying strong Wolfe conditions
// @param derPhiFunc {func} Function to calculate the value of the objective
//   function derivative at alpha
// @param phiFunc {func} Function to calculate the value of the objective
//   function at alpha
// @param phi0 {float} Value of function evaluation at x(k-1)
// @param derPhi0 {float} Value of objective function derivative at x(k-1)
// @param params {dict} Parameters controlling non default optimization 
//   behaviour
// @param cond {num[]} Bounding conditions for alpha, phi and derPhi used in 
//   zoom algorithm
// @returns {num[]} New alpha, fk and derivative values
i.zoomFunc:{[derPhiFunc;phiFunc;phi0;derPhi0;params;cond]
  zoomDict:i.zoomKeys!cond,phi0;
  zoomDict[`idx`aRec]:2#0f;
  zoomDict:i.stopZoom[;params]
    i.zoom[derPhiFunc;phiFunc;phi0;derPhi0;params]/zoomDict;
  // If zoom did not converge, set to null
  $[count star:zoomDict[i.zoomReturn];star;3#0N]
  }

// @private
// @kind function
// @category optimizeUtility
// @fileoverview Function to apply an individual step in 'zoom' during 
//   linesearch to find optimal alpha value satisfying strong Wolfe conditions.
//   An outline of the python implementation of this section of the algorithm 
//   can be found here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L556   // noqa
// @param derPhiFunc {func} Function to calculate the value of the objective 
//   function derivative at alpha
// @param phiFunc {func} Function to calculate the value of the objective 
//   function at alpha
// @param phi0 {float} Value of function evaluation at x(k-1)
// @param derPhi0 {float} Value of objective function derivative at x(k-1)
// @param params {dict} Parameters controlling non default optimization 
//   behaviour
// @param zoomDict {dict} Parameters to be updated as 'zoom' procedure is
//   applied to find the optimal value of alpha
// @returns {dict} Parameters calculated for an individual step in line search
//   procedure to find optimal alpha value satisfying strong Wolfe conditions
i.zoom:{[derPhiFunc;phiFunc;phi0;derPhi0;params;zoomDict]
  alphaDiff:zoomDict[`aHi]-zoomDict`aLo;
  // define high and low values
  highLowVal:$[alphaDiff>0;zoomDict`aHi`aLo;zoomDict`aLo`aHi];
  highLow:`high`low!highLowVal;
  if["i"$zoomDict`idx;
    cubicCheck:alphaDiff*0.2;
    findMin:i.cubicMin . zoomDict`aLo`phiLo`derPhiLo`aHi`phiHi`aRec`phiRec
    ];
  if[i.quadCriteria[findMin;highLow;cubicCheck;zoomDict];
    quadCheck:0.1*alphaDiff;
    findMin:i.quadMin . zoomDict`aLo`phiLo`derPhiLo`aHi`phiHi;
    lowerCheck:findMin<highLow[`high]+quadCheck;
    upperCheck:findMin>highLow[`low]-quadCheck;
    if[upperCheck|lowerCheck;
      findMin:zoomDict[`aLo]+0.5*alphaDiff
      ]
    ];
  // Update new values depending on findMin
  phiMin:phiFunc[findMin];
  // First condition, update and continue loop
  if[i.zoomCriteria1[phi0;derPhi0;phiMin;findMin;zoomDict;params];
    zoomDict[`idx]+:1;
    zoomDict[i.zoomKeys1]:zoomDict[`phiHi`aHi],findMin,phiMin;
    :zoomDict
    ];
  // Calculate the derivative at the cubic minimum
  derPhiMin:derPhiFunc findMin;
  // Second scenario, create new features and end the loop
  $[i.zoomCriteria2[derPhi0;derPhiMin;params];
    [zoomDict[`idx]:0w;
     zoomDict:zoomDict,i.zoomReturn!findMin,phiMin,enlist derPhiMin`grad
    ];
    i.zoomCriteria3[derPhiMin;alphaDiff];
    [zoomDict[`idx]+:1;
     zoomDict[i.zoomKeys1,i.zoomKeys2]:zoomDict[`phiHi`aHi`aLo`phiLo],
       findMin,phiMin,derPhiMin`derval
    ];
    [zoomDict[`idx]+:1;
     zoomDict[i.zoomKeys3,i.zoomKeys2]:zoomDict[`phiLo`aLo],
       findMin,phiMin,derPhiMin`derval
    ]
    ];
  zoomDict
  }

// Vector norm calculation

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Calculate the vector norm, used in calculation of the gradient
//   norm at position k. Default behaviour is to use the maximum value of the
//   gradient, this can be overwritten by a user, this is in line with the 
//   default python implementation.
// @param gradVals {num[]} Vector of calculated gradient values
// @param ord {long} Order of norm (0W = max; -0W = min)
// @return {float} Gradient norm based on the input gradient
i.vecNorm:{[gradVals;ord]
  if[-7h<>type ord;'"ord must be +/- infinity or a long atom"];
  $[0W~ord;max abs gradVals;
    -0W~ord;min abs gradVals;
    sum[abs[gradVals]xexp ord]xexp 1%ord
   ]
  }

// Stopping conditions

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Evaluate if the optimization function has reached a condition
//   which should result in the optimization algorithm being stopped
// @param dict {dict} Optimization function returns
// @param params {dict} Parameters controlling non default optimization
//   behaviour
// @return {bool} Indication as to if the optimization has met one of it's
//   stopping conditions
i.stopOptimize:{[dict;params]
  // Is the function evaluation at k an improvement on k-1?
  check1:dict[`fk]<dict`fkPrev;
  // Has x[k] returned a non valid return?
  check2:not any null dict`xk;
  // Have the maximum number of iterations been met?
  check3:params[`optimIter]>dict`idx;
  // Is the gradient at position k below the accepted tolerance
  check4:params[`gtol]<dict`gnorm;
  check1&check2&check3&check4
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Evaluate if the wolfe condition search has reached a condition
//   which should result in the optimization algorithm being stopped
// @param dict {dict} Optimization function returns
// @param params {dict} Parameters controlling non default optimization
//   behaviour
// @return {bool} Indication as to if the optimization has met one of it's 
//   stopping conditions
i.stopWolfe:{[dict;params]
  dict[`idx]<params`wolfeIter
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Evaluate if the alpha condition 'zoom' has reached a condition
//   which should result in the optimization algorithm being stopped
// @param dict {dict} Optimization function returns
// @param params {dict} Parameters controlling non default optimization
//   behaviour
// @return {bool} Indication as to if the optimization has met one of it's 
//   stopping conditions
i.stopZoom:{[dict;params]
  dict[`idx]<params`zoomIter
  }

// Function + derivative evaluation at x[k]+p[k]*alpha[k]

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Evaluate the objective function at the position x[k]+step size
// @param func {func} The objective function to be minimized
// @param pk {float} Step direction
// @param alpha {float} Size of the step to be applied
// @param xk {num[]} Parameter values at position k
// @param args {dict;num[]} Function arguments that do not change per iteration
// @returns {float} Function evaluated at at the position x[k] + step size
i.phi:{[func;pk;alpha;xk;args]
  xk+:alpha*pk;
  i.funcEval[func;xk;args]
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Evaluate the derivative of the objective function at
//   the position x[k] + step size
// @param func {func} The objective function to be minimized
// @param eps {float} The absolute step size used for numerical approximation
//   of the jacobian via forward differences
// @param pk {float} Step direction
// @param alpha {float} Size of the step to be applied
// @param xk {num[]} Parameter values at position k
// @param args {dict;num[]} Function arguments that do not change per iteration
// @returns {dict} Gradient and value of scalar derivative
i.derPhi:{[func;eps;pk;alpha;xk;args]
  // Increment xk by a small step size
  xk+:alpha*pk;
  // Get gradient at the new position
  gval:i.grad[func;xk;args;eps];
  derval:gval mmu pk;
  `grad`derval!(gval;derval)
  }

// Minimization functions

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Find the minimizing solution for a cubic polynomial which
//   passes through the points (a,fa), (b,fb) and (c,fc) with a derivative of
//   the objective function calculated as fpa. This follows the python 
//   implementation outlined here 
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L482  // noqa
// @param a {float} Position a
// @param fa {float} Objective function evaluated at a
// @param fpa {float} Derivative of the objective function evaluated at 'a'
// @param b {float} Position b
// @param fb {float} Objective function evaluated at b
// @param c {float} Position c
// @param fc {float} Objective function evaluated at c
// @returns {num[]} Minimized parameter set as a solution for the cubic 
//   polynomial
i.cubicMin:{[a;fa;fpa;b;fb;c;fc]
  bDiff:b-a;
  cDiff:c-a;
  denom:(bDiff*cDiff)xexp 2*(bDiff-cDiff);
  d1:2 2#0f;
  d1[0]:(1 -1)*xexp[;2]each(bDiff;cDiff);
  d1[1]:(-1 1)*xexp[;3]each(cDiff;bDiff);
  AB:d1 mmu(fb-fa-fpa*bDiff;fc-fa-fpa*cDiff);
  AB%:denom;
  radical:AB[1]*AB[1]-3*AB[0]*fpa;
  a+(neg[AB[1]]+sqrt(radical))%(3*AB[0])
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Find the minimizing solution for a quadratic polynomial which
//   passes through the points (a,fa) and (b,fb) with a derivative of the 
//   objective function calculated as fpa. This follows the python 
//   implementation outlined here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L516 // noqa
// @param a {float} Position a
// @param fa {float} Objective function evaluated at a
// @param fpa {float} Derivative of the objective function evaluated at a
// @param b {float} Position b
// @param fb {float} Objective function evaluated at b
// @returns {num[]} Minimized parameter set as a solution for the quadratic
//   polynomial
i.quadMin:{[a;fa;fpa;b;fb]
  bDiff:b-a;
  B:(fb-fa-fpa*bDiff)%(bDiff*bDiff);
  a-fpa%(2*B)
  }

// Gradient + function evaluation

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Calculation of the gradient of the objective function for all 
//   parameters of x incremented individually by epsilon
// @param func {func} The objective function to be minimized
// @param xk {num[]} Parameter values at position k
// @param args {dict;num[]} Function arguments that do not change per iteration
// @param eps {float} The absolute step size used for numerical approximation
//   of the jacobian via forward differences
// @returns {dict} Gradient of function at position k
i.grad:{[func;xk;args;eps]
  fk:i.funcEval[func;xk;args];
  i.gradEval[fk;func;xk;args;eps]each til count xk
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Calculation of the gradient of the objective function for a
//   single parameter set x where one of the indices has been incremented by
//   epsilon
// @param func {func} The objective function to be minimized
// @param xk {num[]} Parameter values at position k
// @param args {dict;num[]} Function arguments that do not change per iteration
// @param eps {float} The absolute step size used for numerical approximation
//   of the jacobian via forward differences
// @returns {dict} Gradient of function at position k with an individual
//   variable x incremented by epsilon
i.gradEval:{[fk;func;xk;args;eps;idx]
  if[(::)~fk;fk:i.funcEval[func;xk;args]];
  // Increment function optimisation values by epsilon
  xk[idx]+:eps;
  // Evaluate the gradient
  (i.funcEval[func;xk;args]-fk)%eps
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Evaluate the objective function at position x[k] with relevant
//   additional arguments accounted for
// @param {func} The objective function to be minimized
// @param xk {num[]} Parameter values at position k
// @param args {dict;num[]} Function arguments that do not change per iteration
// @returns {float} The objective function evaluated at the appropriate
//   location
i.funcEval:{[func;xk;args]
  $[any args~/:((::);());func xk;func[xk;args]]
  }

// Parameter dictionary

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Update the default behaviour of the model optimization 
//   procedure to account for increased sensitivity to tolerance, the number 
//   of iterations, how the gradient norm is calculated and various numerical 
//   updates including changes to the Armijo rule and curvature for calculation
//   of the strong Wolfe conditions
// @param dict {dict;(::);()} If dict isn't empty,update the default dictionary
//   to include the user defined updates, otherwise use the default dictionary
// @returns {dict} Updated or default parameter set depending on user input
i.updDefault:{[dict]
  dictKeys:`norm`optimIter`gtol`geps`stepSize`c1`c2`wolfeIter`zoomIter`display;
  dictVals:(0W;0W;1e-4;1.49e-8;0w;1e-4;0.9;10;10;0b);
  returnDict:dictKeys!dictVals;
  if[99h<>type dict;dict:()!()];
  i.wolfeParamCheck[returnDict,dict]
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Ensure that the Armijo and curvature parameters are consistent
//   with the expected values for calculation of the strong Wolfe conditions
// @param dict {dict} Updated parameter dictionary containing default
//   information and any updated parameter information
// @returns {dict;err} The original input dictionary or an error suggesting
//   that the Armijo and curvature parameters are unsuitable
i.wolfeParamCheck:{[dict]
  check1:dict[`c1]>dict`c2;
  check2:any not dict[`c1`c2]within 0 1;
  $[check1 or check2;
    '"When evaluating Wolfe conditions the following must hold 0 < c1 < c2 < 1";
    dict
    ]
  }

// Data Formatting

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Ensure that the input parameter x at position 0 which 
//   will be updated is in a format that is suitable for use with this 
//   optimization procedure i.e. the data is a list of values.
// @param x0 {dict;num;num[]} Initial values of x to be optimized
// @returns {num[]} The initial values of x converted into a suitable
//   numerical list format
i.dataFormat:{[x0]
  "f"$$[99h=type x0;raze value x0;0h>type x0;enlist x0;x0]
  }

// Conditional checks for Wolfe, zoom and quadratic condition evaluation

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Ensure new values lead to improvements over the older values
// @param wolfeDict {dict} The current iterations values for the objective
//   function and the derivative of the objective function evaluated
// @param params {dict} Parameter dictionary containing the updated/default 
//   information used to modify the behaviour of the system as a whole
// @returns {bool} Indication as to if a further zoom is required
i.wolfeCriteria1:{[wolfeDict;params]
  prdVal:prd wolfeDict`alpha1`derPhi0;
  check1:wolfeDict[`phia1]>wolfeDict[`phi0]+params[`c1]*prdVal;
  prevPhi:wolfeDict[`phia1]>=wolfeDict`phia0;
  wolfeIdx:1<wolfeDict`idx;
  check2:prevPhi and wolfeIdx;
  check1 or check2
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Ensure new values lead to improvements over the older values
// @param wolfeDict {dict} The current iterations values for the objective 
//   function and the derivative of the objective function evaluated
// @param params {dict} Parameter dictionary containing the updated/default
//   information used to modify the behaviour of the system as a whole
// @returns {bool} Indication as to if a further zoom is required 
i.wolfeCriteria2:{[wolfeDict;params]
  neg[params[`c2]*wolfeDict[`derPhi0]]>=abs wolfeDict`derPhia1
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Check if there is need to apply quadratic minimum calculation
// @param findMin {num[]} The currently calculated minimum values
// @param highLow {dict} Upper and lower bounds of the search space
// @param cubicCheck {float} Interpolation check parameter
// @param zoomDict {dict} Parameters to be updated as 'zoom' procedure is 
//   applied to find the optimal value of alpha
// @returns {bool} Indication as to if the value of findMin needs to be updated 
i.quadCriteria:{[findMin;highLow;cubicCheck;zoomDict]
  // On first iteration the initial minimum has not been calculated
  // as such criteria should exit early to complete the quadratic calculation
  if[findMin~();:1b];
  check1:0=zoomDict`idx;
  check2:findMin>highLow[`low] -cubicCheck;
  check3:findMin<highLow[`high]+cubicCheck;
  check1 or check2 or check3
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Check if the zoom conditions are sufficient
// @param phi0 {float} Objective function evaluation at index 0
// @param derPhi0 {float} Derivative of objective function evaluated at index 0
// @param phiMin {float} 0bjective function evaluated at the current minimum
// @param findMin {float} The currently calculated minimum value
// @param zoomDict {dict} Parameters to be updated as 'zoom' procedure is
//   applied to find the optimal value of alpha
// @param params {dict} Parameter dictionary containing the updated/default
//   information used to modify the behaviour of the system as a whole
// @returns {bool} Indication as to if further zooming is required
i.zoomCriteria1:{[phi0;derPhi0;phiMin;findMin;zoomDict;params]
  calc:phi0+findMin*derPhi0*params`c1;
  check1:phiMin>calc;
  check2:phiMin>=zoomDict`phiLo;
  check1 or check2
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Check if the zoom conditions are sufficient
// @param derPhi0 {float} Derivative of the objective function evaluated at
//   index 0
// @param derPhiMin {float} Derivative of the objective function evaluated at
//   the current minimum
// @param params {dict} Parameter dictionary containing the updated/default
//   information used to modify the behaviour of the system as a whole
// @returns {bool} Indication as to if further zooming is required
i.zoomCriteria2:{[derPhi0;derPhiMin;params]
  abs[derPhiMin`derval]<=neg derPhi0*params`c2
  }

// @private
// @kind function
// @category optimizationUtility
// @fileoverview Check if the zoom conditions are sufficient
// @param derPhiMin {float} Derivative of the objective function evaluated at 
//   the current minimum
// @param alphaDiff {float} Difference between the upper and lower bound of the 
//   zoom bracket
// @returns {bool} Indication as to if further zooming is required
i.zoomCriteria3:{[derPhiMin;alphaDiff]
  0<=derPhiMin[`derval]*alphaDiff
  }
	   
// Zoom dictionary 

// @private
// @kind dictionary
// @category optimizationUtility
// @fileoverview Input keys of zoom dictionary
i.zoomKeys:`aLo`aHi`phiLo`phiHi`derPhiLo`phiRec;

// @private
// @kind dictionary
// @category optimizationUtility
// @fileoverview Keys to be updated in zoom each iteration
i.zoomKeys1:`phiRec`aRec`aHi`phiHi;

// @private
// @kind dictionary
// @category optimizationUtility
// @fileoverview Extra keys that have to be updated in some scenarios
i.zoomKeys2:`aLo`phiLo`derPhiLo;

// @private
// @kind dictionary
// @category optimizationUtility
// @fileoverview Extra keys that have to be updated in some scenarios
i.zoomKeys3:`phiRec`aRec

// @private
// @kind dictionary
// @category optimizationUtility
// @fileoverview Final updated keys to be used
i.zoomReturn:`alphaStar`phiStar`derPhiStar;
