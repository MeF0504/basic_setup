#! /usr/bin/env python3
import sys

import numpy as np
import matplotlib.pyplot as plt
import plotly.graph_objects as go

from pymeflib import plot2


def main():
    if len(sys.argv) < 2:
        print('image file not specified')
        return
    img_file = sys.argv[1]
    img_data = plt.imread(img_file)

    fig = go.Figure().set_subplots(rows=2, cols=1)
    # add_trace? append_trace?
    fig.append_trace(go.Image(z=img_data), row=1, col=1)
    plot2.hist_np(fig, img_data[:, :, 0].flatten(),
                  xmin=0, xmax=255, bins=256,
                  row=2, col=1,
                  name='Red', opacity=0.5, marker=dict(color='Red'),
                  )
    plot2.hist_np(fig, img_data[:, :, 1].flatten(),
                  xmin=0, xmax=255, bins=256,
                  row=2, col=1,
                  name='Green', opacity=0.5, marker=dict(color='Green'),
                  )
    plot2.hist_np(fig, img_data[:, :, 2].flatten(),
                  xmin=0, xmax=255, bins=256,
                  row=2, col=1,
                  name='Blue', opacity=0.5, marker=dict(color='Blue'),
                  )
    fig.update_layout(barmode='overlay',  # stack, group, overlay, relative
                      xaxis2=dict(title='RGB values'),
                      yaxis2=dict(title='counts'))

    print(f'shape: {img_data.shape}')
    fig.show()


if __name__ == '__main__':
    main()
