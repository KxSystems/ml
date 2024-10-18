\d .ml

@[system"l ",;"p.q";{::}]

// @desc Retrieve initial command line configuration
mlops.init:.Q.opt .z.x

// @desc Define root path from which scripts are to be loaded
mlops.path:{
  module:`$"mlops-tools";
  string module^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]
  }`

// @kind function
// @desc Load an individual file
// @param x {symbol} '.q/.p/.k' file which is to be loaded into the current
//   process. Failure to load the file at location 'path,x' or 'x' will
//   result in an error message
// @return {null}
mlops.loadfile:{
  filePath:_[":"=x 0]x:$[10=type x;;string]x;
  @[system"l ",;
    mlops.path,"/",filePath;
    {@[system"l ",;y;{'"Library load failed with error :",x}]}[;filePath]
    ];
    }

mlops.loadfile`:src/q/init.q
