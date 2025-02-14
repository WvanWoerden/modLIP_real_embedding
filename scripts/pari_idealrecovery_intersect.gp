// pari/gp script to generate data for Figure 4.
// run by: sh run_idealrecover.sh p t
// where p is a prime and t is the number of trials

default(parisize,"4G");
default(parisizemax, "16G");
setrand(extern("date +%s"))

p = eval(getenv("P")) \\ assume p%4=3 so far

PK = x^p-x-1;
PL = if(p%4==1, x^(2*p)-2*x^(p+1)+x^2+1 ,x^(2*p)+2*x^(p+1)+x^2+1);

y_rep = if(p%4==1, Mod(x^2 - x^(p+1), PL), Mod(x^2 + x^(p+1), PL));
r_rep = if(p%4==1, Mod(-x + x^p, PL), Mod(-x + -x^p, PL));

\\ print("Setting up number fields")
K = nfinit([PK, 10^6],4);
L = nfinit([PL, 10^6],4);

f = sum(i=0, p-1, (random(3)-1)*x^i);
g = sum(i=0, p-1, (random(3)-1)*x^i);
F = sum(i=0, p-1, (random(3)-1)*x^i);
G = sum(i=0, p-1, (random(3)-1)*x^i);

f_abs = subst(f.pol, x, y_rep);
g_abs = subst(g.pol, x, y_rep);
F_abs = subst(F.pol, x, y_rep);
G_abs = subst(G.pol, x, y_rep);

z1_abs = f_abs + r_rep * g_abs;
z2_abs = F_abs + r_rep * G_abs;

q1_abs = f_abs * f_abs + g_abs * g_abs;
q2_abs = f_abs * F_abs + g_abs * G_abs;
detB_abs = f_abs * G_abs - g_abs * F_abs;

print(z1_abs * (detB_abs * r_rep + q2_abs ) == q1_abs * z2_abs);
print(z1_abs * z2_abs^(-1) == q1_abs * (detB_abs * r_rep + q2_abs )^(-1));

Im = idealhnf(L,z1_abs, z2_abs);
zzI_gen = q1_abs * (detB_abs * r_rep + q2_abs )^(-1);
zzI = idealmul(L, zzI_gen, Im);
intI = idealintersect(L, Im, zzI);

print(intI == idealhnf(L, z1_abs))
\q
