#include "k.h"
qtemplate({
 "names":["maint_mins_i","maint_imins_i","xmin_i","ximin_i","maint_maxs_i","maint_imaxs_i","xmax_i","ximax_i","binsearch"],
 "types":["QT1"],
 "ptypes":{"QT1":["H","I","J","F","E"]}}|

void maint_mins_i(QT1 *x,J length,QT1 y);
void maint_imins_i(J *res,QT1 *x,J length,QT1 y,J yi);
K xmin_i(J x,K y);
K ximin_i(J x,K y);
void maint_maxs_i(QT1 *x,J length,QT1 y);
void maint_imaxs_i(J *res,QT1 *x,J length,QT1 y,J yi);
K xmax_i(J x,K y);
K ximax_i(J x,K y);
Z J binsearch(QT1* x,QT1 y,J lw,J min,J hw);
)

K2(xmin);
K2(ximin);
K2(xmax);
K2(ximax);
