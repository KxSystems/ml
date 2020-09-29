// Namespace appropriately
\d .ml

// @kind function
// @category optimization
// @fileoverview Optimize a function using the 
//   Broyden-Fletcher-Goldfarb-Shanno (BFGS) algorithm. This implementation
//   is based on https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/optimize.py#L1058
//   and is a quasi-Newton hill-climbing optimization technique used to find
//   a preferebly twice continuously differentiable stationary point of a function.
//   An outline of the algorithm mathematically is provided here:
//   https://en.wikipedia.org/wiki/Broyden-Fletcher-Goldfarb-Shanno_algorithm#Algorithm
// @param func {lambda} the function to be optimized. This function should take
//   as its arguments a list/dictionary of parameters to be optimized and a list/dictionary
//   of additional unchanging arguments
// @param x0 {num[]/dict} the first guess at the parameters to be optimized as 
//   a list or dictionary of numeric values
// @param args {list/dict/(::)} any unchanging parameters to required for evaluation 
//   of the function, these should be in the order that they are to be applied
//   to the function
// @param params {dict} any modifications to be applied to the optimization procedure e.g.
//   - display   {bool} are the results at each optimization iteration to be printed
//   - optimIter {integer} maximum number of iterations in optimization procedure
//   - zoomIter  {integer} maximum number of iterations when finding optimal zoom
//   - wolfeIter {integer} maximum number of iterations in 
//   - norm      {integer} order of norm (0W = max; -0W = min), otherwise calculated via
//      sum[abs[vec]xexp norm]xexp 1%norm
//   - gtol      {float} gradient norm must be less than gtol before successful termination
//   - geps      {float} the absolute step size used for numerical approximation
//      of the jacobian via forward differences.
//   - stepSize  {float} maximum allowable 'alpha' step size between calculations
//   - c1        {float} armijo rule condition 
//   - c2        {integer} curvature conditions rule 
// @returns {dict} a dictionary containing the estimated optimal parameters, number of iterations 
//   and the evaluated return of the function being optimized. 
optimize.BFGS:{[func;x0;args;params]
  // update the default behaviour of the parameters
  params:i.updDefault[params];
  // format x0 based on input type
  x0:i.dataFormat[x0];
  // Evaluate the function at the starting point
  f0:i.funcEval[func;x0;args];
  // Calculate the starting gradient
  gk:i.grad[func;x0;args;params`geps];
  // Initialize Hessian matrix as identity matrix
  hess:.ml.eye count x0;
  // set initial step guess i.e. the step before f0
  prev_fk:f0+sqrt[sum gk*gk]%2;
  gradNorm:i.vecNorm[gk;params`norm];
  optimKeys:`xk`fk`prev_fk`gk`prev_xk`hess`gnorm`I`idx;
  optimVals:(x0;f0;prev_fk;gk;0n;hess;gradNorm;hess;0);
  optimDict:optimKeys!optimVals;
  // Run optimization until one of the stopping conditions is met
  optimDict:i.stopOptimize[;params]i.BFGSFunction[func;;args;params]/optimDict;
  returnKeys:`xVals`funcRet`numIter;
  // if function returned due to a null xVal or the new value being worse than the previous
  //  value then return the k-1 value
  returnVals:$[(optimDict[`fk]<optimDict`prev_fk) & (not any null optimDict`xk);
    optimDict`xk`fk`idx;
    optimDict`prev_xk`prev_fk`idx
    ];
  returnKeys!returnVals
  }

// @private
// @kind function
// @category optimization
// @fileoverview optimize a function until gradient tolerance is reached or 
//   maximum number of allowed iterations is met. The following outlines a python equivalent
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/optimize.py#L1131
// @param func      {lambda} the function to be minimized
// @param optimDict {dict} variables to be updated at each iteration of optimization
// @param args      {any} arguments to the optimization function that do not change per iteration 
// @param params    {dict} parameters controlling non default optimization behaviour
// @return {dict} variables, gradients, matrices and indices at the end of each iteration
i.BFGSFunction:{[func;optimDict;args;params] 
  // calculate search direction
  pk:neg mmu[optimDict`hess;optimDict`gk];
  // line search func to be inserted to get alpha
  wolfe:i.wolfeSearch[;;;pk;func;;args;params]. optimDict`fk`prev_fk`gk`xk;
  // old fk goes to previous val
  optimDict[`prev_fk]:optimDict`fk;
  // update values based on wolfe line search
  alpha:wolfe 0;
  optimDict[`fk]:wolfe 1;
  gnew:wolfe 2;
  // redefine the x value at k-1 to the current x value
  optimDict[`prev_xk]:optimDict`xk;
  // Calculate the step distance for moving from x(k-1) -> x(k)
  sk:alpha*pk;
  // update values of x at the new position k
  optimDict[`xk]:optimDict[`prev_xk]+sk;
  // if null gnew, then get gradient of new x value
  if[any null gnew;gnew:i.grad[func;optimDict`xk;args;params`geps]];
  // subtract new gradients
  yk:gnew-optimDict`gk;;
  optimDict[`gk]:gnew;
  // get new norm of gradient
  optimDict[`gnorm]:i.vecNorm[optimDict`gk;params`norm];
  // calculate new hessian matrix for next iteration 
  rhok:1%mmu[yk;sk];
  if[0w=rhok;
    rhok:1000f;
    -1"Division by zero in calculation of rhok, assuming rhok large";];
  A1:optimDict[`I] - sk*\:yk*rhok;
  A2:optimDict[`I] - yk*\:sk*rhok;
  optimDict[`hess]:mmu[A1;mmu[optimDict`hess;A2]]+rhok*(sk*/:sk);
  // if x(k) returns infinite value update gnorm and fk
  if[0w in abs optimDict`xk;optimDict[`gnorm`fk]:(0n;0w)];
  optimDict[`idx]+:1;
  if[params`display;show optimDict;-1"";];
  optimDict
  }

// @private
// @kind function
// @category optimization
// @fileoverview complete a line search across an unconstrained minimization problem making
//   use of wolfe conditions to constrain the search the naming convention for dictionary keys 
//   in this implementation is based on the python implementation of the same functionality here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L193
// @param fk      {float} function return evaluated at position k
// @param prev_fk {float} function return evaluated at position k-1
// @param gk      {float} gradient at position k
// @param pk      {float} search direction
// @param func    {lambda} function being optimized 
// @param xk      {num[]} parameter values at position k
// @param args    {dict/num[]} function arguments that do not change per iteration
// @param params  {dict} parameters controlling non default optimization behaviour
// @return {num[]} new alpha, fk and derivative values
i.wolfeSearch:{[fk;prev_fk;gk;pk;func;xk;args;params]
  phiFunc   :i.phi[func;pk;;xk;args];
  derphiFunc:i.derphi[func;params`geps;pk;;xk;args];
  // initial Wolfe conditions
  wolfeDict:`idx`alpha0`phi0`phi_a0!(0;0;fk;fk);
  // calculate the derivative at that phi0
  derphi0:gk mmu pk;
  wolfeDict[`derphi_a0`derphi0]:2#derphi0;
  // calculate step size this should be 0 < x < 1 
  // with min(x;maxstepsize) or 1f otherwise
  alpha:1.01*2*(fk - prev_fk)%derphi0;
  alphaVal:$[alpha within 0 1f;min(alpha;params`stepSize);1f];
  wolfeDict[`alpha1]:alphaVal;
  // function value at alpha1
  wolfeDict[`phi_a1]:phiFunc wolfeDict`alpha1;
  // repeat until wolfe criteria is reached or max iterations have been done
  // to get new alpha, phi and derphi values
  wolfeDict:i.stopWolfe[;params]i.scalarWolfe[derphiFunc;phiFunc;pk;params]/wolfeDict;
  // if the line search did not converge, use last alpha , phi and derphi
  $[not any null raze wolfeDict`alpha_star`phi_star`derphi_star;
    wolfeDict`alpha_star`phi_star`derphi_star;
    wolfeDict`alpha1`phi_a1`derphi_a0_fin
  ]
  }

// @private
// @kind function
// @category optimization
// @fileoverview apply a scalar search to find an alpha value that satisfies
//   strong Wolfe conditions, a python implementation of this is outlined here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L338
//   This functions defines the bounds between which the step function can be found.
//   When the optimal bound is found, the area is zoomed in on and optimal value find
// @param derphiFunc {proj} function to calculate the value of the objective function
//   derivative at alpha
// @param phiFunc {proj} function to calculate the value of the objective function at alpha
// @param pk {float} search direction
// @param params {dict} parameters controlling non default optimization behaviour
// @param wolfeDict {dict} all data relevant to the calculation of the optimal
//   alpha values 
// @returns {dict} new alpha, fk and derivative values
i.scalarWolfe:{[derphiFunc;phiFunc;pk;params;wolfeDict]
  // set up zoom function constant params
  zoomSetup:i.zoomFunc[derphiFunc;phiFunc;;;params]. wolfeDict`phi0`derphi0;
  // if criteria 1, zoom and break loop
  if[i.wolfeCriteria1[wolfeDict;params];
    wolfeDict[`idx]:0w;
    wolfeDict[i.zoomReturn]:zoomSetup wolfeDict`alpha0`alpha1`phi_a0`phi_a1`derphi_a0;
    :wolfeDict
  ];
  // calculate the derivative of the function at the new position
  derphiCalc:derphiFunc wolfeDict`alpha1;
  // update the new derivative fnc
  wolfeDict[`derphi_a1]:derphiCalc`derval;
  $[i.wolfeCriteria2[wolfeDict;params];
    [wolfeDict[`alpha_star] :wolfeDict`alpha1;
     wolfeDict[`phi_star]   :wolfeDict`phi_a1;
     wolfeDict[`derphi_star]:derphiCalc`grad;
     wolfeDict[`idx]:0w;
     wolfeDict
    ];
    0<=wolfeDict`derphi_a1;
    [wolfeDict[`idx]:0w;
     wolfeDict[i.zoomReturn]:zoomSetup wolfeDict`alpha1`alpha0`phi_a1`phi_a0`derphi_a1
    ];
    // update dictionary and repeat process until criteria is met
    [wolfeDict[`alpha0]:wolfeDict`alpha1;
     wolfeDict[`alpha1]:2*wolfeDict`alpha1;
     wolfeDict[`phi_a0]:wolfeDict`phi_a1;
     wolfeDict[`phi_a1]:phiFunc wolfeDict`alpha1;
     wolfeDict[`derphi_a0]:wolfeDict`derphi_a1;
     wolfeDict[`derphi_a0_fin]:derphiCalc`grad;
     wolfeDict[`idx]+:1
    ]
  ];
  wolfeDict
  }

// @private
// @kind function
// @category optimize
// @fileoverview function to apply 'zoom' iteratively during linesearch to find optimal alpha
//   value satisfying strong Wolfe conditions
// @param derphiFunc {proj} function to calculate the value of the objective function
//   derivative at alpha
// @param phiFunc {proj} function to calculate the value of the objective function at alpha
// @param phi0 {float} value of function evaluation at x(k-1)
// @param derphi0 {float} value of objective function derivative at x(k-1)
// @param params {dict} parameters controlling non default optimization behaviour
// @param lst {num[]} bounding conditions for alpha, phi and derphi used in zoom algorithm
// @returns {num[]} new alpha, fk and derivative values
i.zoomFunc:{[derphiFunc;phiFunc;phi0;derphi0;params;lst]
  zoomDict:i.zoomKeys!lst,phi0;
  zoomDict[`idx`a_rec]:2#0f;
  zoomDict:i.stopZoom[;params]i.zoom[derphiFunc;phiFunc;phi0;derphi0;params]/zoomDict;
  // if zoom did not converge, set to null
  $[count star:zoomDict[i.zoomReturn];star;3#0N]
  }

// @private
// @kind function
// @category optimize
// @fileoverview function to apply an individual step in 'zoom' during linesearch 
//   to find optimal alpha value satisfying strong Wolfe conditions. An outline of
//   the python implementation of this section of the algorithm can be found here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L556
// @param derphiFunc {proj} function to calculate the value of the objective function
//   derivative at alpha
// @param phiFunc {proj} function to calculate the value of the objective function at alpha
// @param phi0 {float} value of function evaluation at x(k-1)
// @param derphi0 {float} value of objective function derivative at x(k-1)
// @param params {dict} parameters controlling non default optimization behaviour
// @param zoomDict {dict} parameters to be updated as 'zoom' procedure is applied to find
//   the optimal value of alpha
// @returns {dict} parameters calculated for an individual step in line search procedure
//   to find optimal alpha value satisfying strong Wolfe conditions
i.zoom:{[derphiFunc;phiFunc;phi0;derphi0;params;zoomDict]
  // define high and low values
  dalpha:zoomDict[`a_hi]-zoomDict`a_lo;
  // These should probably be named a and b since mapping doesn't work properly?
  highLow:`high`low!$[dalpha>0;zoomDict`a_hi`a_lo;zoomDict`a_lo`a_hi];
  if["i"$zoomDict`idx;
    cubicCheck:dalpha*0.2;
    findMin:i.cubicMin . zoomDict`a_lo`phi_lo`derphi_lo`a_hi`phi_hi`a_rec`phi_rec
  ];
  if[i.quadCriteria[findMin;highLow;cubicCheck;zoomDict];
    quadCheck:0.1*dalpha;
    findMin:i.quadMin . zoomDict`a_lo`phi_lo`derphi_lo`a_hi`phi_hi;
    if[(findMin > highLow[`low]-quadCheck) | findMin < highLow[`high]+quadCheck;
      findMin:zoomDict[`a_lo]+0.5*dalpha
    ]
  ];
  // update new values depending on fnd_min
  phiMin:phiFunc[findMin];
  //first condition, update and continue loop
  if[i.zoomCriteria1[phi0;derphi0;phiMin;findMin;zoomDict;params];
    zoomDict[`idx]+:1;
    zoomDict[i.zoomKeys1]:zoomDict[`phi_hi`a_hi],findMin,phiMin;
    :zoomDict
  ];
  // calculate the derivative at the cubic minimum
  derphiMin:derphiFunc findMin;
  // second scenario, create new features and end the loop
  $[i.zoomCriteria2[derphi0;derphiMin;params];
    [zoomDict[`idx]:0w;
     zoomDict:zoomDict,i.zoomReturn!findMin,phiMin,enlist derphiMin`grad];
    i.zoomCriteria3[derphiMin;dalpha];
    [zoomDict[`idx]+:1;
     zoomDict[i.zoomKeys1,i.zoomKeys2]:zoomDict[`phi_hi`a_hi`a_lo`phi_lo],
                                   findMin,phiMin,derphiMin`derval];
    [zoomDict[`idx]+:1;
     zoomDict[i.zoomKeys3,i.zoomKeys2]:zoomDict[`phi_lo`a_lo],
                                   findMin,phiMin,derphiMin`derval]
  ];
  zoomDict
  }


// Vector norm calculation

// @private
// @kind function
// @category optimization
// @fileoverview calculate the vector norm, used in calculation of the gradient norm at position k.
//   Default behaviour is to use the maximum value of the gradient, this can be overwritten by
//   a user, this is in line with the default python implementation.
// @param vec {num[]} calculated gradient values
// @param ord {long} order of norm (0W = max; -0W = min)
// @return the gradient norm based on the input gradient
i.vecNorm:{[vec;ord]
  if[-7h<>type ord;'"ord must be +/- infinity or a long atom"];
  $[ 0W~ord;max abs vec;
    -0W~ord;min abs vec;
    sum[abs[vec]xexp ord]xexp 1%ord
  ]
  }


// Stopping conditions

// @private
// @kind function
// @category optimization
// @fileoverview evaluate if the optimization function has reached a condition which is
//   should result in the optimization algorithm being stopped. 
// @param dict {dict} optimization function returns
// @param params {dict} parameters controlling non default optimization behaviour
// @return {bool} indication as to if the optimization has met one of it's stopping conditions
i.stopOptimize:{[dict;params]
  // is the function evaluation at k an improvement on k-1?
  check1:dict[`fk] < dict`prev_fk;
  // has x[k] returned a non valid return?
  check2:not any null dict`xk;
  // have the maximum number of iterations been met?
  check3:params[`optimIter] > dict`idx;
  // is the gradient at position k below the accepted tolerance
  check4:params[`gtol] < dict`gnorm;
  check1 & check2 & check3 & check4
  }

// @private
// @kind function
// @category optimization
// @fileoverview evaluate if the wolfe condition search has reached a condition which is
//   should result in the optimization algorithm being stopped.
// @param dict {dict} optimization function returns
// @param params {dict} parameters controlling non default optimization behaviour
// @return {bool} indication as to if the optimization has met one of it's stopping conditions
i.stopWolfe:{[dict;params]
  dict[`idx] < params`wolfeIter
  }

// @private
// @kind function
// @category optimization
// @fileoverview evaluate if the alpha condition 'zoom' has reached a condition which is
//   should result in the optimization algorithm being stopped.
// @param dict {dict} optimization function returns
// @param params {dict} parameters controlling non default optimization behaviour
// @return {bool} indication as to if the optimization has met one of it's stopping conditions
i.stopZoom:{[dict;params]
  dict[`idx] < params`zoomIter
  }


// Function + derivative evaluation at x[k]+ p[k]*alpha[k]

// @private
// @kind function
// @category optimization
// @fileoverview evaluate the objective function at the position x[k] + step size
// @param func {lambda} the objective function to be minimized
// @param pk {float} step direction
// @param alpha {float} size of the step to be applied
// @param xk {num[]} parameter values at position k
// @param args {dict/num[]} function arguments that do not change per iteration
// @param xk {num[]} 
// @returns {float} function evaluated at at the position x[k] + step size
i.phi:{[func;pk;alpha;xk;args]
  xk+:alpha*pk;
  i.funcEval[func;xk;args]
  }

// @private
// @kind function
// @category optimization
// @fileoverview evaluate the derivative of the objective function at 
//   the position x[k] + step size
// @param func {lambda} the objective function to be minimized
// @param eps {float} the absolute step size used for numerical approximation
//   of the jacobian via forward differences.
// @param pk {float} step direction
// @param alpha {float} size of the step to be applied
// @param xk {num[]} parameter values at position k
// @param args {dict/num[]} function arguments that do not change per iteration
// @returns {dict} gradient and value of scalar derivative
i.derphi:{[func;eps;pk;alpha;xk;args]
  // increment xk by a small step size
  xk+:alpha*pk;
  // get gradient at the new position
  gval:i.grad[func;xk;args;eps];
  derval:gval mmu pk;
  `grad`derval!(gval;derval)
  }


// Minimization functions

// @private
// @kind function
// @category optimization
// @fileoverview find the minimizing solution for a cubic polynomial which
//   passes through the points (a,fa), (b,fb) and (c,fc) with a derivative of the 
//   objective function calculated as fpa. This follows the python implementation 
//   outlined here https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L482
// @param a {float} position a
// @param b {float} position b
// @param c {float} position c
// @param fa {float} objective function evaluated at a
// @param fb {float} objective function evaluated at b
// @param fc {float} objective function evaluated at c
// @param fpa {float} derivative of the objective function evaluated at a
// @returns {num[]} minimized parameter set as a solution for the cubic polynomial
i.cubicMin:{[a;fa;fpa;b;fb;c;fc]
  db:b-a;
  dc:c-a;
  denom:(db*dc)xexp 2*(db-dc);
  d1:2 2#0f;
  d1[0]:(1 -1)*xexp[;2]each(db;dc);
  d1[1]:(-1 1)*xexp[;3]each(dc;db);
  AB:d1 mmu(fb-fa-fpa*db;fc-fa-fpa*dc);
  AB%:denom;
  radical:AB[1]*AB[1]-3*AB[0]*fpa;
  a+(neg[AB[1]]+sqrt(radical))%(3*AB[0])
  }

// @private
// @kind function
// @category optimization
// @fileoverview find the minimizing solution for a quadratic polynomial which
//   passes through the points (a,fa) and (b,fb) with a derivative of the objective function
//   calculated as fpa. This follows the python implementation outlined here
//   https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/linesearch.py#L516
// @param a {float} position a
// @param b {float} position b
// @param fa {float} objective function evaluated at a
// @param fb {float} objective function evaluated at b
// @param fpa {float} derivative of the objective function evaluated at a
// @returns {num[]} minimized parameter set as a solution for the quadratic polynomial
i.quadMin:{[a;fa;fpa;b;fb]
  db:b-a;
  B:(fb-fa-fpa*db)%(db*db);
  a-fpa%(2*B)
  }


// Gradient + function evaluation

// @private
// @kind function
// @category optimization
// @fileoverview calculation of the gradient of the objective function for all parameters of x
//   incremented individually by epsilon
// @param func {lambda} the objective function to be minimized
// @param xk {num[]} parameter values at position k
// @param args {dict/num[]} function arguments that do not change per iteration
// @param eps {float} the absolute step size used for numerical approximation
//   of the jacobian via forward differences.
// @returns {dict} gradient of function at position k
i.grad:{[func;xk;args;eps]
  fk:i.funcEval[func;xk;args];
  i.gradEval[fk;func;xk;args;eps]each til count xk
  }

// @private
// @kind function
// @category optimization
// @fileoverview calculation of the gradient of the objective function for a single
//   parameter set x where one of the indices has been incremented by epsilon
// @param func {lambda} the objective function to be minimized
// @param xk {num[]} parameter values at position k
// @param args {dict/num[]} function arguments that do not change per iteration
// @param eps {float} the absolute step size used for numerical approximation
//   of the jacobian via forward differences.
// @returns {dict} gradient of function at position k with an individual
//   variable x incremented by epsilon
i.gradEval:{[fk;func;xk;args;eps;idx]
  if[(::)~fk;fk:i.funcEval[func;xk;args]];
  // increment function optimisation values by epsilon
  xk[idx]+:eps;
  // Evaluate the gradient
  (i.funcEval[func;xk;args]-fk)%eps
  }

// @private
// @kind function
// @category optimization
// @fileoverview evaluate the objective function at position x[k] with relevant
//   additional arguments accounted for
// @param {lambda} the objective function to be minimized
// @param xk {num[]} parameter values at position k
// @param args {dict/num[]} function arguments that do not change per iteration
// @returns {float} the objective function evaluated at the appropriate location
i.funcEval:{[func;xk;args]
  $[any args~/:((::);());func xk;func[xk;args]]
  }


// Paramter dictionary

// @private
// @kind function
// @category
// @fileoverview update the default behaviour of the model optimization procedure
//   to account for increased sensitivity to tolerance, the number of iterations,
//   how the gradient norm is calculated and various numerical updates including changes
//   to the Armijo rule and curvature for calculation of the strong Wolfe conditions.
// @param dict {dict/(::)/()} if a dictionary update the default dictionary to include
//   the user defined updates, otherwise use the default dictionary 
// @returns {dict} updated or default parameter set depending on user input
i.updDefault:{[dict]
  returnKeys:`norm`optimIter`gtol`geps`stepSize`c1`c2`wolfeIter`zoomIter`display;
  returnVals:(0W;0W;1e-4;1.49e-8;0w;1e-4;0.9;10;10;0b);
  returnDict:returnKeys!returnVals;
  if[99h<>type dict;dict:()!()];
  i.wolfeParamCheck[returnDict,dict]
  }

// @private
// @kind function
// @category optimization
// @fileoverview Ensure that the armijo and curvature parameters are consistent 
//   with the expected values for calculation of the strong Wolfe conditions.
//   Return an error on unsuitable conditions otherwise return the input dictionary
// @param dict {dict} updated parameter dictionary containing default information and
//   any updated parameter information
// @returns {dict/err} the original input dictionary or an error suggesting that the 
//   Armijo and curvature parameters are unsuitable
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
// @category optimization
// @fileoverview Ensure that the input parameter x at position 0 which will
//   be updated is in a format that is suitable for use with this optimization
//   procedure i.e. the data is a list of values.
// @param x0 {dict/num/num[]} initial values of x to be optimized
// @returns {num[]} the initial values of x converted into a suitable numerical list format
i.dataFormat:{[x0]
  "f"$$[99h=type x0;raze value x0;0h >type x0;enlist x0; x0]
  }


// Conditional checks for Wolfe, zoom and quadratic condition evaluation

// @private
// @kind function
// @category optimization
// @fileoverview ensure new values lead to improvements over the older values
// @param wolfeDict {dict} the current iterations values for the objective function and the 
//   derivative of the objective function evaluated 
// @param params {dict} parameter dictionary containing the updated/default information
//   used to modify the behaviour of the system as a whole
// @returns {bool} indication as to if a further zoom is required 
i.wolfeCriteria1:{[wolfeDict;params]
  check1:wolfeDict[`phi_a1]>wolfeDict[`phi0]+params[`c1]*prd wolfeDict`alpha1`derphi0;
  check2:(wolfeDict[`phi_a1]>=wolfeDict`phi_a0) and (1<wolfeDict`idx);
  check1 or check2
  }

// @private
// @kind function
// @category optimization
// @fileoverview ensure new values lead to improvements over the older values
// @param wolfeDict {dict} the current iterations values for the objective function and the
//   derivative of the objective function evaluated
// @param params {dict} parameter dictionary containing the updated/default information
//   used to modify the behaviour of the system as a whole
// @returns {bool} indication as to if a further zoom is required 
i.wolfeCriteria2:{[wolfeDict;params]
  neg[params[`c2]*wolfeDict[`derphi0]]>=abs wolfeDict`derphi_a1
  }

// @private
// @kind function
// @category optimization
// @fileoverview check if there is need to apply quadratic minimum calculation
// @param findMin {num[]} the currently calculated minimum values
// @param highLow {dict} upper and lower bounds of the search space
// @param cubicCheck {float} interpolation check parameter
// @param zoomDict {dict} parameters to be updated as 'zoom' procedure is applied to find
//   the optimal value of alpha
// @returns {bool} indication as to if the value of findMin needs to be updated 
i.quadCriteria:{[findMin;highLow;cubicCheck;zoomDict]
  // On initial iteration the minimum has not been calculated
  // as such criteria should exit early to complete the quadratic calculation
  if[findMin~();:1b];
  check1:0=zoomDict`idx;
  check2:findMin>highLow[`low] -cubicCheck;
  check3:findMin<highLow[`high]+cubicCheck;
  check1 or check2 or check3
  }


// @private
// @kind function
// @category optimization
// @fileoverview check if the zoom conditions are sufficient
// @param phi0 {float} objective function evaluation at index 0 
// @param derphi0 {float} derivative of objective function evaluated at index 0
// @param phiMin {float} objective function evaluated at the current minimum
// @param findMin {float} the currently calculated minimum value
// @param zoomDict {dict} parameters to be updated as 'zoom' procedure is applied to find
//   the optimal value of alpha
// @param params {dict} parameter dictionary containing the updated/default information
//   used to modify the behaviour of the system as a whole
// @returns indication as to if further zooming is required
i.zoomCriteria1:{[phi0;derphi0;phiMin;findMin;zoomDict;params]
  check1:phiMin> phi0+findMin*derphi0*params`c1;
  check2:phiMin>=zoomDict`phi_lo;
  check1 or check2
  }

// @private
// @kind function
// @category optimization
// @fileoverview check if the zoom conditions are sufficient
// @param derphi0 {float} derivative of the objective function evaluated at index 0
// @param derphiMin {float} derivative of the objective function evaluated at the current minimum
// @param params {dict} parameter dictionary containing the updated/default information
//   used to modify the behaviour of the system as a whole
// @returns indication as to if further zooming is required
i.zoomCriteria2:{[derphi0;derphiMin;params]
  abs[derphiMin`derval]<=neg derphi0*params`c2
  }

// @private
// @kind function
// @category optimization
// @fileoverview check if the zoom conditions are sufficient
// @param derphiMin {float} derivative of the objective function evaluated at the current minimum
// @param dalpha {float} difference between the upper and lower bound of the zoom bracket
// @returns indication as to if further zooming is required
i.zoomCriteria3:{[derphiMin;dalpha]
  0<=derphiMin[`derval]*dalpha
  }
	   
	   
// Zoom dictionary 

//input keys of zoom dictionary
i.zoomKeys:`a_lo`a_hi`phi_lo`phi_hi`derphi_lo`phi_rec;
// keys to be updated in zoom each iteration
i.zoomKeys1:`phi_rec`a_rec`a_hi`phi_hi;
// extra keys that have to be updated in some scenarios
i.zoomKeys2:`a_lo`phi_lo`derphi_lo;
i.zoomKeys3:`phi_rec`a_rec
// final updated keys to be used
i.zoomReturn:`alpha_star`phi_star`derphi_star;
