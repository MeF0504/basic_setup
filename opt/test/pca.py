#! /usr/bin/env python3

# import copy

import numpy as np
import matplotlib.pyplot as plt


# https://arxiv.org/abs/1404.1100v1
def main(data):
    # data_orig = copy.deepcopy(data)
    for i in range(data.shape[0]):
        data[i] -= np.mean(data[i])
    # print(data)
    C_x = np.dot(data, data.T)/len(data[0])
    eig_val, eig_vec = np.linalg.eig(C_x)
    P = eig_vec.T
    print('principal components:{}'.format(P))
    Y = np.dot(P, data)
    C_y = np.dot(Y, Y.T)/len(Y[0])
    print(C_y)

    xlim = [np.min([data[0], Y[0]])*1.1, np.max([data[0], Y[0]])*1.1]
    ylim = [np.min([data[1], Y[1]])*1.1, np.max([data[1], Y[1]])*1.1]
    fig1 = plt.figure()
    ax11 = fig1.add_subplot(221)
    ax12 = fig1.add_subplot(222)
    ax11.scatter(data[0], data[1])
    ax11.set_xlim(xlim)
    ax11.set_ylim(ylim)
    ax12.scatter(Y[0], Y[1])
    ax12.set_xlim(xlim)
    ax12.set_ylim(ylim)

    ax13 = fig1.add_subplot(223)
    im13 = ax13.imshow(C_x)
    fig1.colorbar(im13)
    ax14 = fig1.add_subplot(224)
    im14 = ax14.imshow(C_y)
    fig1.colorbar(im14)

    plt.show()


if __name__ == '__main__':
    freq = 100  # Hz
    time = np.arange(0, 10, 0.001)  # sec
    amp = 3  # ?
    noise = 1.0
    rot_angle = 30  # deg

    raw_data = amp*np.sin(time/freq*2*np.pi)
    rot_mat = np.array([
            [np.cos(rot_angle*np.pi/180), np.sin(rot_angle*np.pi/180)],
            [-np.sin(rot_angle*np.pi/180), np.cos(rot_angle*np.pi/180)],
            ])
    data = np.zeros([2, len(time)])
    data[0] = raw_data
    data = np.dot(rot_mat, data)
    data += noise*np.random.random(data.shape)
    main(data)
