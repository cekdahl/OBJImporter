
# OBJImporter
A Wolfram Language importer for OBJ (.obj) files that preserves texture and color information. Wolfram Language has the ability to import OBJ files built in, using `Import`, but it discards color information and textures:

<img src="https://i.imgur.com/pFXEBRe.png" alt="Yoshi with colors and textures" />

OBJImporter adds a new file format setting to `Import` called `RawOBJ` which keeps the color and texture information instead of discarding it:

<img src="https://i.imgur.com/kVGwDmh.png" alt="Yoshi with colors and textures" />

## Installing OBJImporter
`OBJImporter` is distributed in the form of a paclet. Download the latest version of the paclet from [the releases page](https://github.com/cekdahl/OBJImporter/releases) and install it using the the `PacletManager` package (which you already have because it comes with Mathematica):

    Needs["PacletManager`"]
    PacletInstall["~/Downloads/OBJImporter-1.0.0.paclet"]
## Disclaimer
`OBJImporter` supports a subset of the OBJ file format. As a consequence, some models may not look exactly the way they do in other 3D programs. The important thing, though, is that it keeps information about the color of the surfaces and their textures, which is all that is needed for many models.
