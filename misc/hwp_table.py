#! /usr/bin/env python3

from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def main():
    row_num = 7
    col_num = 17
    rot_angle = np.arange(col_num)*np.pi/8
    row_label = ['HWP \nrotation',
                 'linear\npolarization\ninput',
                 'linear\npolarization\noutput',
                 'linear\npolarization\ndetected',
                 'circular\npolarization\ninput',
                 'circular\npolarization\noutput',
                 'circular\npolarization\ndetected']
    col_label = [r'${:.1f}^\circ$'.format(ang) for ang in rot_angle*180/np.pi]
    data_str = np.full([row_num, col_num], ' ', dtype=str)

    plt.rcParams['font.family'] = 'Times New Roman'
    plt.rcParams['font.size'] = 14
    fig_x = 15
    fig_y = 8
    asp = fig_y/fig_x
    fig1 = plt.figure(figsize=(fig_x, fig_y))
    ax11 = fig1.add_axes((0.09, 0.08, 0.90, 0.83))

    ax11.axis('off')
    table = ax11.table(cellText=data_str,
                       colLabels=col_label, rowLabels=row_label,
                       loc='center', colLoc='center', rowLoc='right')

    for pos, cell in table.get_celld().items():
        cell.set_height(1/row_num)

    left_bias = 0.03
    top_bias = 0.15
    R = 0.75/col_num
    cs = []
    cs2 = []
    for i in range(col_num):
        # HWP plate
        cs.append(patches.Ellipse(xy=(i/col_num+left_bias,1-top_bias),
                                  width=2*R*asp, height=2*R,
                                  fill=False, ec='k'))
        ax11.add_patch(cs[-1])
        # circular pol
        cs2.append(patches.Ellipse(xy=(i/col_num+left_bias,1-top_bias-4./row_num),
                                   width=2*R*asp, height=2*R,
                                   fill=False, ec='r'))
        ax11.add_patch(cs2[-1])

    for i in range(col_num):
        # HWP angle
        arr_dic = dict(arrowstyle='-|>', color='black')
        ax11.annotate(text='',
                      xy=(i/col_num+left_bias+R*asp*np.sin(rot_angle[i]),
                          1-top_bias+R*np.cos(rot_angle[i])),
                      xytext=(i/col_num+left_bias-R*asp*np.sin(rot_angle[i]),
                              1-top_bias-R*np.cos(rot_angle[i])),
                      arrowprops=arr_dic)
        # linear pol
        arr_dic = dict(arrowstyle='<->', color='blue')
        ax11.annotate(text='',
                      xy=(i/col_num+left_bias, 1-top_bias-1./row_num+R),
                      xytext=(i/col_num+left_bias, 1-top_bias-1./row_num-R),
                      arrowprops=arr_dic)
        # rotated linerar pol
        ax11.annotate(text='',
                      xy=(i/col_num+left_bias+R*asp*np.sin(2*rot_angle[i]),
                          1-top_bias-2./row_num+R*np.cos(2*rot_angle[i])),
                      xytext=(i/col_num+left_bias-R*asp*np.sin(2*rot_angle[i]),
                              1-top_bias-2./row_num-R*np.cos(2*rot_angle[i])),
                      arrowprops=arr_dic)
        # detected linear pol
        arr_dic = dict(arrowstyle='-', color='blue')
        ax11.annotate(text='',
                      xy=(i/col_num+left_bias,
                          1-top_bias-3./row_num+R*np.cos(2*rot_angle[i])),
                      xytext=(i/col_num+left_bias,
                              1-top_bias-3./row_num-R*np.cos(2*rot_angle[i])),
                      arrowprops=arr_dic)
        # circular polarization arrow
        arr_dic = dict(arrowstyle='-|>', color='red')
        ax11.annotate(text='',
                      xy=(i/col_num+left_bias-0.01,
                          1-top_bias-4./row_num+R),
                      xytext=(i/col_num+left_bias,
                              1-top_bias-4./row_num+R),
                      arrowprops=arr_dic)
        # linear pol from circular pol
        arr_dic = dict(arrowstyle='<->', color='red')
        ax11.annotate(text='',
                      xy=(i/col_num+left_bias+R*asp*np.sin(np.pi/4+rot_angle[i]),
                          1-top_bias-5./row_num+R*np.cos(np.pi/4+rot_angle[i])),
                      xytext=(i/col_num+left_bias-R*asp*np.sin(np.pi/4+rot_angle[i]),
                              1-top_bias-5./row_num-R*np.cos(np.pi/4+rot_angle[i])),
                      arrowprops=arr_dic)
        # detected circular pol
        arr_dic = dict(arrowstyle='-', color='red')
        ax11.annotate(text='',
                      xy=(i/col_num+left_bias,
                          1-top_bias-6./row_num+R*abs(np.cos(np.pi/4+rot_angle[i]))),
                      xytext=(i/col_num+left_bias,
                              1-top_bias-6./row_num-R*abs(np.cos(np.pi/4+rot_angle[i]))),
                      arrowprops=arr_dic)

    savedir = Path(__file__).parent.parent/'tmp'
    if not savedir.is_dir():
        savedir.mkdir(parents=True)
    fig1.savefig(savedir/'halfwaveplate_modulate.pdf')
    plt.show()


if __name__ == '__main__':
    main()
