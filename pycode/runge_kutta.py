import numpy as np

def runge_kutta(t,dt,funcs,defaults,other_values=[]):
    """ 
    ##  calculate system of differential equation
    ##  order of function args is (index, t, variables, other_values)
    """

    def k_zero(i,t,dt,func,variables,other_values):
        variables = list(variables)
        other_values = list(other_values)
        values = variables+other_values
        return dt*func(i,t,*values)

    def k_one(i,t,dt,func,variables,other_values,k0s):
        variables = np.array(variables)
        other_values = np.array(other_values)
        #for l,v in enumerate(variables):
            #variables[l] += k0[l]/2.0
        variables += k0s/2.0
        values = np.r_[variables,other_values]
        return dt*func(i,t,*values)

    def k_two(i,t,dt,func,variables,other_values,k1s):
        variables = np.array(variables)
        other_values = np.array(other_values)
        variables += k1s/2.0
        values = np.r_[variables,other_values]
        return dt*func(i,t,*values)

    def k_three(i,t,dt,func,variables,other_values,k2s):
        variables = np.array(variables)
        other_values = np.array(other_values)
        variables += k2s 
        values = np.r_[variables,other_values]
        return dt*func(i,t,*values)

    if callable(funcs):
        funcs = [funcs]
        L = 1 
    else:
        L = len(funcs)
    vs = []
    for l in range(L):
        vs.append([defaults[l]])

    for i,ti in enumerate(t[:-1]):
        variables = []
        for l in range(L):
            variables.append(vs[l][-1])
        variables = np.array(variables)
        k0 = []
        for l in range(L):
            k0.append(k_zero(i,ti,dt,funcs[l],variables,other_values))
        k0 = np.array(k0)
        k1 = []
        for l in range(L):
            k1.append(k_one(i,ti,dt,funcs[l],variables,other_values,k0))
        k1 = np.array(k1)
        k2 = []
        for l in range(L):
            k2.append(k_two(i,ti,dt,funcs[l],variables,other_values,k1))
        k2 = np.array(k2)
        k3 = []
        for l in range(L):
            k3.append(k_three(i,ti,dt,funcs[l],variables,other_values,k2))
        k3 = np.array(k3)

        dvs = (k0+2*k1+2*k2+k3)/6.0
        for l in range(L):
            vi = vs[l][-1]
            vs[l].append(vi+dvs[l])

    vs = np.array(vs)
    #print vs.shape
    return vs

