def runge_kutta(t,dt,funcs,defaults,other_values=[],without_numpy=False):
    """ 
    ##  calculate system of differential equation
    ##  order of function args is (index, t, variables, other_values)
    """

    if not without_numpy:
        import numpy as np
        def k_zero(i,t,dt,func,variables,other_values):
            variables = list(variables)
            other_values = list(other_values)
            values = variables+other_values
            return dt*func(i,t,*values)
    
        def k_one(i,t,dt,func,variables,other_values,k0s):
            variables = np.array(variables)
            other_values = list(other_values)
            variables += k0s/2.0
            values = list(variables)+other_values
            return dt*func(i,t,*values)
    
        def k_two(i,t,dt,func,variables,other_values,k1s):
            variables = np.array(variables)
            other_values = list(other_values)
            variables += k1s/2.0
            values = list(variables)+other_values
            return dt*func(i,t,*values)
    
        def k_three(i,t,dt,func,variables,other_values,k2s):
            variables = np.array(variables)
            other_values = list(other_values)
            variables += k2s 
            values = list(variables)+other_values
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
        return vs
    else:
        def k_zero(i,t,dt,func,variables,other_values):
            variables = list(variables)
            other_values = list(other_values)
            values = variables+other_values
            return dt*func(i,t,*values)
    
        def k_one(i,t,dt,func,variables,other_values,k0s):
            for i in range(len(variables)):
                variables[i] += k0s[i]/2.0
            values = variables+other_values
            return dt*func(i,t,*values)

        def k_two(i,t,dt,func,variables,other_values,k1s):
            for i in range(len(variables)):
                variables[i] += k1s[i]/2.0
            values = variables+other_values
            return dt*func(i,t,*values)

        def k_three(i,t,dt,func,variables,other_values,k2s):
            for i in range(len(variables)):
                variables[i] += k2s[i]/2.0
            values = variables+other_values
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
            k0 = []
            for l in range(L):
                k0.append(k_zero(i,ti,dt,funcs[l],variables,other_values))
            k1 = []
            for l in range(L):
                k1.append(k_one(i,ti,dt,funcs[l],variables,other_values,k0))
            k2 = []
            for l in range(L):
                k2.append(k_two(i,ti,dt,funcs[l],variables,other_values,k1))
            k3 = []
            for l in range(L):
                k3.append(k_three(i,ti,dt,funcs[l],variables,other_values,k2))
    
            for l in range(L):
                dvs = (k0[l]+2*k1[l]+2*k2[l]+k3[l])/6.0
                vi = vs[l][-1]
                vs[l].append(vi+dvs)
    
        return vs

if __name__ == '__main__':
    dt = 0.0001

    try:
        import numpy as np
        import matplotlib.pyplot as plt
        t = np.arange(0,2,dt)

        # d^2y/dt^2 + 4*dy/dt + 3y = 5,
        #y0 = 2, y'0 = 1
        def y_dot(i,t,y,z):
            #dy/dt = z
            return z
        def z_dot(i,t,y,z):
            #dz/dt = -4*z-3*y+5
            return -4*z-3*y+5
        y0 = 2
        z0 = 1

        y,z = runge_kutta(t,dt,[y_dot,z_dot],[y0,z0])
        y_cal = -2./3*np.exp(-3*t)+np.exp(-1*t)+5./3
        print np.sqrt(np.sum((y-y_cal)**2)/len(y))
        plt.plot(t,y,alpha=0.5)
        plt.plot(t,y_cal,alpha=0.5)
        plt.show()

    except ImportError:
        e = 2.71828
        t = []
        t0 = range(2000)
        for i in t0:
            t.append(i*dt)

        # d^2y/dt^2 + 4*dy/dt + 3y = 5,
        #y0 = 2, y'0 = 1
        def y_dot(i,t,y,z):
            #dy/dt = z
            return z
        def z_dot(i,t,y,z):
            #dz/dt = -4*z-3*y+5
            return -4*z-3*y+5
        y0 = 2
        z0 = 1

        std = 0
        y,z = runge_kutta(t,dt,[y_dot,z_dot],[y0,z0],without_numpy=True)
        for i in t0:
            std += (y[i]-(-2./3*e**(-3*t[i])+e**(-1*t[i])+5./3))**2
        print (std/(len(t0)))**0.5

