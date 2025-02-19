#! /usr/bin/env python3

from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
import plotly.graph_objects as go


def main():
    wave_num_x = 2.0
    wave_num_y = 2.5
    Ax = 0.7
    Ay = 1.0
    delta_p = 0.0  # deg
    N = 256

    t = np.linspace(0, 2*np.pi, N)
    x1 = Ax*np.cos(t)
    y1 = Ay*np.cos(t-np.deg2rad(delta_p))
    p12_x = t[-1]
    p12_y = t[-1]-np.deg2rad(delta_p)
    x2 = Ax*np.cos(wave_num_x*t-p12_x)
    y2 = Ay*np.cos(wave_num_y*t-p12_y)
    p23_x = wave_num_x*t[-1]-p12_x
    p23_y = wave_num_y*t[-1]-p12_y
    x3 = Ax*np.cos(t-p23_x)
    y3 = Ay*np.cos(t-p23_y)

    if False:
        fig1 = plt.figure()
        ax11 = fig1.add_subplot(2, 1, 1)
        ax12 = fig1.add_subplot(2, 1, 2)
        ax11.plot(np.rad2deg(t), x1, 'r')
        ax12.plot(np.rad2deg(t), y1, 'r')
        ax11.plot(np.rad2deg(t+2*np.pi), x2, 'g')
        ax12.plot(np.rad2deg(t+2*np.pi), y2, 'g')
        ax11.plot(np.rad2deg(t+4*np.pi), x3, 'b')
        ax12.plot(np.rad2deg(t+4*np.pi), y3, 'b')
        plt.show()
        return

    fig1 = go.Figure()
    xcolor = "green"
    ycolor = "blue"
    fig1.add_trace(go.Scatter3d(x=t, y=x1, z=np.zeros_like(x1),
                                mode='lines',
                                line=dict(color=xcolor,
                                          width=4, dash="solid")))
    fig1.add_trace(go.Scatter3d(x=t, y=np.zeros_like(y1), z=y1,
                                mode='lines',
                                line=dict(color=ycolor,
                                          width=4, dash="solid")))

    fig1.add_trace(go.Scatter3d(x=t+2*np.pi, y=x2, z=np.zeros_like(x2),
                                mode='lines',
                                line=dict(color=xcolor,
                                          width=4, dash="dashdot")))
    fig1.add_trace(go.Scatter3d(x=t+2*np.pi, y=np.zeros_like(y2), z=y2,
                                mode='lines',
                                line=dict(color=ycolor,
                                          width=4, dash="dashdot")))

    fig1.add_trace(go.Scatter3d(x=t+4*np.pi, y=x3, z=np.zeros_like(x3),
                                mode='lines', name=None,
                                line=dict(color=xcolor,
                                          width=4, dash="solid")))
    fig1.add_trace(go.Scatter3d(x=t+4*np.pi, y=np.zeros_like(y3), z=y3,
                                mode='lines',
                                line=dict(color=ycolor,
                                          width=4, dash="solid")))

    fig1.add_trace(go.Scatter3d(x=np.ones_like(t)*2*np.pi, y=x1, z=y1,
                                name='incident polarization', mode='lines',
                                line=dict(color='red', width=4)))
    fig1.add_trace(go.Scatter3d(x=np.ones_like(t)*4*np.pi, y=x3, z=y3,
                                name='output polarization', mode='lines',
                                line=dict(color='red', width=4)))

    # Plate threshold
    yin = [-1, 1, 1, -1, -1, -1, 1, 1, -1]
    zin = [-1, -1, 1, 1, 1, -1, -1, 1, 1]
    xin1 = np.concatenate([np.ones(4)*2*np.pi, [2*np.pi], np.ones(4)*2*np.pi])
    fig1.add_trace(go.Mesh3d(x=xin1, y=yin, z=zin,
                             i=[0, 2, 5, 7, 7, 2, 7, 2],
                             j=[1, 3, 6, 8, 3, 3, 6, 1],
                             k=[3, 1, 8, 6, 4, 7, 2, 6],
                             color='gray', opacity=0.3,
                             name='Wave Plate'))

    xin2 = np.concatenate([np.ones(4)*4*np.pi, [4*np.pi], np.ones(4)*4*np.pi])
    fig1.add_trace(go.Mesh3d(x=xin2, y=yin, z=zin,
                             i=[0, 2, 5, 7, 7, 2, 7, 2],
                             j=[1, 3, 6, 8, 3, 3, 6, 1],
                             k=[3, 1, 8, 6, 4, 7, 2, 6],
                             color='gray', opacity=0.3,
                             name='Wave Plate'))

    # Axes
    fig1.add_trace(go.Scatter3d(x=np.concatenate([t, t, t]),
                                y=np.zeros(3*len(t)), z=np.zeros(3*len(t)),
                                mode='lines',
                                line=dict(color='black', width=2,)))
    fig1.add_trace(go.Scatter3d(x=np.ones(10)*2*np.pi,
                                y=np.linspace(-1, 1, 10), z=np.zeros(10),
                                mode='lines',
                                line=dict(color='black', width=2,)))
    fig1.add_trace(go.Scatter3d(x=np.ones(10)*2*np.pi,
                                y=np.zeros(10), z=np.linspace(-1, 1, 10),
                                mode='lines',
                                line=dict(color='black', width=2,)))
    fig1.add_trace(go.Scatter3d(x=np.ones(10)*4*np.pi,
                                y=np.linspace(-1, 1, 10), z=np.zeros(10),
                                mode='lines',
                                line=dict(color='black', width=2,)))
    fig1.add_trace(go.Scatter3d(x=np.ones(10)*4*np.pi,
                                y=np.zeros(10), z=np.linspace(-1, 1, 10),
                                mode='lines',
                                line=dict(color='black', width=2,)))

    fig1.update_layout(
            scene_aspectmode='manual',
            scene_aspectratio=dict(x=2, y=1, z=1),
            # title=dict(text='<b>Wave Plate',
            #            font=dict(size=24)),
            legend=dict(xanchor='left', yanchor='bottom',
                        x=0.3, y=0.93,
                        font=dict(size=20)),
            scene=dict(
                xaxis_title='',
                yaxis_title='',
                zaxis_title='',
                xaxis=dict(tickvals=[],
                           range=np.deg2rad([360-120, 720+120]),
                           backgroundcolor='white',
                           ),
                yaxis=dict(tickvals=[],
                           backgroundcolor='white',
                           ),
                zaxis=dict(tickvals=[],
                           backgroundcolor='white',
                           ),
                ),
            showlegend=False,
            )
    # default camera position
    fig1.update_scenes(camera_eye=dict(x=0.95, y=-1.60, z=0.92))

    savedir = Path(__file__).parent.parent/'tmp'
    if not savedir.is_dir():
        savedir.mkdir(parents=True)
    fig1.write_html(savedir/'WavePlate.html')
    fig1.show()


if __name__ == '__main__':
    main()
