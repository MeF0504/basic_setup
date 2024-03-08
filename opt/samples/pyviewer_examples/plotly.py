import os
from typing import Any

import numpy as np
from PIL import Image
import plotly.graph_objects as go


def show_image_file(img_file: str) -> None:
    name = os.path.basename(img_file)
    img_data = Image.open(img_file)
    if 'RGB' not in img_data.mode:
        img_data = img_data.convert('RGBA')
    img_data = np.asarray(img_data)
    show_image_ndarray(img_data, name)


def show_image_ndarray(data: Any, name: str) -> None:
    fig = go.Figure()
    fig.add_trace(go.Image(z=data))
    fig.update_layout(title=dict(text=name))
    fig.show()
