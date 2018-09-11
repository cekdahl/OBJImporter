
# OBJImporter
A Wolfram Language importer for OBJ (.obj) files that preserve texture and color information. Wolfram Language has the ability to import OBJ files built in, using `Import`, but it discards color information and textures:

<img src="https://imgur.com/kVGwDmh" alt="Yoshi with colors and textures" />

OBJImporter adds a new file format setting to `Import` called `RawOBJ` which keeps the color and texture information instead of discarding it:

<img src="https://mmase.s3.amazonaws.com/yoshiWithStyling.png" alt="Yoshi with colors and textures" />

## Installing OBJImporter
`OBJImporter` is distributed in the form of a paclet. Download the latest version of the paclet from [the releases page](https://github.com/cekdahl/OBJImporter/releases) and install it using the the `PacletManager` package (which you already have because it comes with Mathematica):

    Needs["PacletManager`"]
    PacletInstall["~/Downloads/OBJImporter-1.0.0.paclet"]
