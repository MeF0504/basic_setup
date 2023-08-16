#! /usr/bin/env python3
import sys

import numpy as np
import matplotlib.pyplot as plt
import plotly.graph_objects as go


def main():
    if len(sys.argv) < 2:
        print('image file not specified')
        return
    img_file = sys.argv[1]
    img_data = plt.imread(img_file)
    counts_r, bins_r = np.histogram(img_data[:, :, 0].flatten(),
                                    bins=range(0, 255, 1))
    bins_r = 0.5 * (bins_r[:-1] + bins_r[1:])
    counts_g, bins_g = np.histogram(img_data[:, :, 1].flatten(),
                                    bins=range(0, 255, 1))
    bins_g = 0.5 * (bins_g[:-1] + bins_g[1:])
    counts_b, bins_b = np.histogram(img_data[:, :, 2].flatten(),
                                    bins=range(0, 255, 1))
    bins_b = 0.5 * (bins_b[:-1] + bins_b[1:])

    fig = go.Figure()
    fig.add_trace(go.Bar(x=bins_r, y=counts_r, name='red',
                         opacity=0.5, marker=dict(color='Red'),
                         ))
    fig.add_trace(go.Bar(x=bins_g, y=counts_g, name='green',
                         opacity=0.5, marker=dict(color='Green'),
                         ))
    fig.add_trace(go.Bar(x=bins_b, y=counts_b, name='blue',
                         opacity=0.5, marker=dict(color='Blue'),
                         ))
    fig.update_layout(barmode='overlay',  # stack, group, overlay, relative
                      xaxis=dict(title='RGB values'),
                      yaxis=dict(title='counts'))
    print(f'shape: {img_data.shape}')
    fig.show()


if __name__ == '__main__':
    main()
