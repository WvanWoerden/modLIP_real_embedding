\\  This Pari/GP script generates data for Figure 4, which focuses on
\\  the timed recovery of the ideal zO_{L_1} from the matrix B^tB.
\\
\\  How to run:
\\  Use the helper script: bash run_idealrecovery.sh p nbtrials
\\    p: prime degree
\\    nbtrials: number of trials
\\
\\  Example:
\\  bash run_idealrecovery.sh 43 16
\\
\\  Output format:
\\  The output file (data/idealrecovery_[p]) contains nbtrials lines,
\\  each with the format: p a b c time
\\    p: prime degree
\\    a, b: indicators (should be 1) for the equation from Lemma 5
\\    c: indicator (should be 1) for successful ideal recovery
\\    time: total runtime for ideal recovery

default(parisize,"4G");
default(parisizemax, "16G");
setrand(extern("date +%s"));

p = eval(getenv("P")); \\ assume p%4=3 so far

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
