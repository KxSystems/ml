#include "binsearch.h"
qtemplate({"names":["binsearch"],"types":["QT1"],"ptypes":{"QT1":["H","I","J","F","E"]}}|
J binsearch(QT1* x,QT1 y,J lw,J mid,J hw){
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
