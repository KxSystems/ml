#include "k.h"


void maint_mins_i_H(H *x,J length,H y);
void maint_imins_i_H(J *res,H *x,J length,H y,J yi);
K xmin_i_H(J x,K y);
K ximin_i_H(J x,K y);
void maint_maxs_i_H(H *x,J length,H y);
void maint_imaxs_i_H(J *res,H *x,J length,H y,J yi);
K xmax_i_H(J x,K y);
K ximax_i_H(J x,K y);
Z J binsearch_H(H* x,H y,J lw,J min,J hw);


void maint_mins_i_I(I *x,J length,I y);
void maint_imins_i_I(J *res,I *x,J length,I y,J yi);
K xmin_i_I(J x,K y);
K ximin_i_I(J x,K y);
void maint_maxs_i_I(I *x,J length,I y);
void maint_imaxs_i_I(J *res,I *x,J length,I y,J yi);
K xmax_i_I(J x,K y);
K ximax_i_I(J x,K y);
Z J binsearch_I(I* x,I y,J lw,J min,J hw);


void maint_mins_i_J(J *x,J length,J y);
void maint_imins_i_J(J *res,J *x,J length,J y,J yi);
K xmin_i_J(J x,K y);
K ximin_i_J(J x,K y);
void maint_maxs_i_J(J *x,J length,J y);
void maint_imaxs_i_J(J *res,J *x,J length,J y,J yi);
K xmax_i_J(J x,K y);
K ximax_i_J(J x,K y);
Z J binsearch_J(J* x,J y,J lw,J min,J hw);


void maint_mins_i_F(F *x,J length,F y);
void maint_imins_i_F(J *res,F *x,J length,F y,J yi);
K xmin_i_F(J x,K y);
K ximin_i_F(J x,K y);
void maint_maxs_i_F(F *x,J length,F y);
void maint_imaxs_i_F(J *res,F *x,J length,F y,J yi);
K xmax_i_F(J x,K y);
K ximax_i_F(J x,K y);
Z J binsearch_F(F* x,F y,J lw,J min,J hw);


void maint_mins_i_E(E *x,J length,E y);
void maint_imins_i_E(J *res,E *x,J length,E y,J yi);
K xmin_i_E(J x,K y);
K ximin_i_E(J x,K y);
void maint_maxs_i_E(E *x,J length,E y);
void maint_imaxs_i_E(J *res,E *x,J length,E y,J yi);
K xmax_i_E(J x,K y);
K ximax_i_E(J x,K y);
Z J binsearch_E(E* x,E y,J lw,J min,J hw);


K2(xmin);
K2(ximin);
K2(xmax);
K2(ximax);

