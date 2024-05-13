# aftviewer extensions

An extension for aftviewer to open fits file.

* fits_healpy.py  
    open .fits file using healpy  
    (copy into ~/.config/aftviewer/additional_types)

A new image viewer.

* plotly.py  
    Image Viewer which opens an image by plotly.  
    (copy into ~/.config/aftviewer/additional_ivs)


# Required

Please append following settings.
``` json
{
    "fits_healpy": {
        "projection": "mollweide",
        "norm": "None",
        "coord": [],
    }
}
```
