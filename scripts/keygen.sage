
def HermiteSolve(OK, f, g):
	y = OK.gen(1)
	p = OK.rank()
	f_rot = Matrix(ZZ, [list(f*y^i) for i in range(p)])
	g_rot = Matrix(ZZ, [list(g*y^i) for i in range(p)])
	X = matrix.block(2,1, [f_rot, g_rot])
	H, U = X.hermite_form(transformation=True)
	if( H[:p] != matrix.identity(p) or H[p:] != 0 ):
		return False
	G = U[0][:p]
	F = -U[0][p:]

	return sum([F[l] * y^l for l in range(p)]), sum([G[l] * y^l for l in range(p)])

def keygen(p=17):
	P = x^p-x-1
	K.<y> = NumberField(P)
	OK = K.order(y)

	f = sum([randint(-1,1) * y^l for l in range(p)])
	g = sum([randint(-1,1) * y^l for l in range(p)])
	# return f,g
	res = HermiteSolve(OK, f,g)
	while not res:
		f = sum([randint(-1,1) * y^l for l in range(p)])
		g = sum([randint(-1,1) * y^l for l in range(p)])
		res = HermiteSolve(OK, f,g)
	F, G = res

	F,G = reduce(OK, f,g,F,G)
	return OK, f,g,F,G

# simple basis rounding reduction algorithm
def reduce(OK, f,g,F,G):
	y = OK.gen(1)
	p = OK.rank()

	f_rot = Matrix(ZZ, [list(f*y^i) for i in range(p)])
	g_rot = Matrix(ZZ, [list(g*y^i) for i in range(p)])
	F_vec = list(F)
	G_vec = list(G)
	X = matrix.block(1,2, [f_rot, g_rot])
	Xinv = X.pseudoinverse()
	v = vector(F_vec + G_vec) * Xinv
	for i in range(p):
		F -= round(v[i]) * f*y^i
		G -= round(v[i]) * g*y^i
	return F,G
