#include <string.h> 
#include <stdio.h>
#include "xminmax.h"
#define we wf

qtemplate({
 "names":["maint_mins_i","maint_imins_i","xmin_i","ximin_i","maint_maxs_i","maint_imaxs_i","xmax_i","ximax_i","binsearch"],
 "types":["QT1"],
 "ptypes":{"QT1":["H","I","J","F","E"]}}|
K xmin_i(J x,K y){
  if(x>y->n)x=y->n;
  K res=ktn(KQT1,x);
  J i;
  for(i=0;i<x;i++)
    kQT1(res)[i]=wqt1;
  for(i=0;i<y->n;i++)
    maint_mins_i_QT1(kQT1(res),res->n,kQT1(y)[i]);
  R res;
  }

K ximin_i(J x,K y){
  if(x>y->n)x=y->n;
  K res=ktn(KJ,x);
  K tmp=ktn(KQT1,x);
  J i;
  for(i=0;i<x;i++){
    kJ(res)[i]=-1;
    kQT1(tmp)[i]=wqt1;
  }
  for(i=0;i<y->n;i++)
    maint_imins_i_QT1(kJ(res),kQT1(tmp),res->n,kQT1(y)[i],i);
  r0(tmp);
  R res;
  }

V maint_mins_i(QT1 *x,J length,QT1 y){
  J i=0;
  if(length>8) // TODO, find a good way to approximate a good limit for this problemA
    i=i+binsearch_QT1(x,y,0,0,length-1);
  else{
    for(;i<length;i++)
      if(y<x[i])break;
  }
  if(i<length){
    if(i<length-1)
      memmove(&x[i+1],&x[i],sizeof(QT1)*(length-(i+1)));
    x[i]=y;
  }
  }

V maint_imins_i(J *res,QT1 *x,J length,QT1 y,J yi){
  J i=0;
  if(length>8) // TODO, find a good way to approximate a good limit for this problem
    i=1+binsearch_QT1(x,y,0,0,length-1);
  else{
    for(;i<length;i++)
      if(y<x[i])break;
  }
  if(i<length){
    if(i<length-1){
      memmove(&x[i+1],&x[i],sizeof(QT1)*(length-(i+1)));
      memmove(&res[i+1],&res[i],sizeof(J)*(length-(i+1)));
    }
    x[i]=y;
    res[i]=yi;
  }
  }

K xmax_i(J x,K y){
  if(x>y->n)x=y->n;
  K res=ktn(KQT1,x);
  J i;
  for(i=0;i<x;i++)
    kQT1(res)[i]=-wqt1;
  for(i=0;i<y->n;i++)
    maint_maxs_i_QT1(kQT1(res),res->n,kQT1(y)[i]);
  R res;
  }

K ximax_i(J x,K y){
  if(x>y->n)x=y->n;
  K res=ktn(KJ,x);
  K tmp=ktn(KQT1,x);
  J i;
  for(i=0;i<x;i++){
    kJ(res)[i]=-1;
    kQT1(tmp)[i]=-wqt1;
  }
  for(i=0;i<y->n;i++)
    maint_imaxs_i_QT1(kJ(res),kQT1(tmp),res->n,kQT1(y)[i],i);
  r0(tmp);
  R res;
  }

V maint_maxs_i(QT1 *x,J length,QT1 y){
  J i=length-1;
  if(length>8) // TODO, find a good way to approximate a good limit for this problemA
    i=i+binsearch_QT1(x,y,0,(length-1)/2,length-1);
  else{
    for(;i>-1;i--)
      if(y>=x[i])break;
  }
  if(i>-1){
    if(i>0)
      memmove(x,&x[1],sizeof(QT1)*i);
    x[i]=y;
  }
  }

V maint_imaxs_i(J *res,QT1 *x,J length,QT1 y,J yi){
  J i=length-1;
  if(length>8) // TODO, find a good way to approximate a good limit for this problem
    i=1+binsearch_QT1(x,y,0,(length-1)/2,length-1);
  else{
    for(;i>length;i++)
      if(y>=x[i])break;
  }
  if(i>-1){
    if(i>0){
      memmove(x,&x[i],sizeof(QT1)*i);
      memmove(res,&res[i],sizeof(J)*i);
    }
    x[i]=y;
    res[i]=yi;
  }
  }

Z J binsearch(QT1* x,QT1 y,J lw,J mid,J hw){
  while(hw>lw){
  if(x[mid]<y)      // right
    lw=mid+1;
  else if(x[mid]>y) // left
    hw=mid-1;
  else              // equal, break and find last index
    break;
  mid=(hw+lw)/2;
  }
  if(x[mid]>y)mid--;
  while((x[mid+1]==x[mid])&&mid<hw)mid++;
  R mid;
}
)

// functions exposed to q
K2(xmin){
  K res;
  if(-KJ!=xt)R krr("x argument must be number of results as default integer for kdb+ version");
  SW(y->t){
		CS(KH,R xmin_i_H(xj,y))
		CS(KI,R xmin_i_I(xj,y))
		CS(KJ,R xmin_i_J(xj,y))
		CS(KE,R xmin_i_E(xj,y))
		CS(KF,R xmin_i_F(xj,y))
		CS(KP,res=xmin_i_J(xj,y);res->t=KP;R res)
		CS(KM,res=xmin_i_I(xj,y);res->t=KM;R res)
		CS(KD,res=xmin_i_I(xj,y);res->t=KD;R res)
		CS(KN,res=xmin_i_J(xj,y);res->t=KN;R res)
		CS(KU,res=xmin_i_I(xj,y);res->t=KU;R res)
		CS(KV,res=xmin_i_I(xj,y);res->t=KV;R res)
		CS(KT,res=xmin_i_I(xj,y);res->t=KT;R res)
		CD:R krr("unsupported type");}
	}
K2(ximin){
  K res;
  if(-KJ!=xt)R krr("x argument must be number of results as default integer for kdb+ version");
  SW(y->t){
		CS(KH,R ximin_i_H(xj,y))
		CS(KI,R ximin_i_I(xj,y))
		CS(KJ,R ximin_i_J(xj,y))
		CS(KE,R ximin_i_E(xj,y))
		CS(KF,R ximin_i_F(xj,y))
		CS(KP,res=ximin_i_J(xj,y);res->t=KP;R res)
		CS(KM,res=ximin_i_I(xj,y);res->t=KM;R res)
		CS(KD,res=ximin_i_I(xj,y);res->t=KD;R res)
		CS(KN,res=ximin_i_J(xj,y);res->t=KN;R res)
		CS(KU,res=ximin_i_I(xj,y);res->t=KU;R res)
		CS(KV,res=ximin_i_I(xj,y);res->t=KV;R res)
		CS(KT,res=ximin_i_I(xj,y);res->t=KT;R res)
		CD:R krr("unsupported type");}
	}
K2(xmax){
  K res;
  if(-KJ!=xt)R krr("x argument must be number of results as default integer for kdb+ version");
  SW(y->t){
		CS(KH,R xmax_i_H(xj,y))
		CS(KI,R xmax_i_I(xj,y))
		CS(KJ,R xmax_i_J(xj,y))
		CS(KE,R xmax_i_E(xj,y))
		CS(KF,R xmax_i_F(xj,y))
		CS(KP,res=xmax_i_J(xj,y);res->t=KP;R res)
		CS(KM,res=xmax_i_I(xj,y);res->t=KM;R res)
		CS(KD,res=xmax_i_I(xj,y);res->t=KD;R res)
		CS(KN,res=xmax_i_J(xj,y);res->t=KN;R res)
		CS(KU,res=xmax_i_I(xj,y);res->t=KU;R res)
		CS(KV,res=xmax_i_I(xj,y);res->t=KV;R res)
		CS(KT,res=xmax_i_I(xj,y);res->t=KT;R res)
		CD:R krr("unsupported type");}
	}

