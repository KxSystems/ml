/random point generation
dsc:{(y+x?z-y)*/:(cos;sin)@\:4*x?acos 0}
genpts:{
 n:x div 2;
 d :flip(-5 1)+(1 1.5)*dsc[n;0;1.8],'dsc[n;3.1;4.2],'dsc[n;5.2;6.5];
 d,:flip(4 -1)+(1 8)*dsc[n;0;1.];
 d,:flip(-12 -10)+(17 20)*2 0N#(2*x)?1.;    
 d@neg[x]?count d}

/classify new points
.z.ts:{h(`classify;genpts 1+rand 100;0b)}

/open connection and set timer
h:hopen 5001;
system"t 5000"
