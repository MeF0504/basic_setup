# pyviewer extensions

An extension for PyViewer to open fits file.

* fits_healpy.py  
    open .fits file using astropy  
    (copy into pyviewer/pyviewerlib/core)
* fits_healpy.py  
    open .fits file using healpy  
    (copy into pyviewer/pyviewerlib/core)

A new image viewer.

* plotly.py  
    Image Viewer which opens an image by plotly.  
    (copy into pyviewer/pyviewerlib/core/image_viewer)


# Required

Please append following settings.
``` json
{
    "additional_types": {
        "fits_astropy": "fits fit",
        "fits_healpy": ""
    },
    "fits_healpy": {
        "projection": "mollweide",
        "norm": "None",
        "coord": [],
    }
}
```
