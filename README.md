# The Clowder Project
<p align="center"><img src="./logo.png" width="100%"/></p>
<p>This is the repository for the <a href="https://topological-modular-forms.github.io/the-clowder-project">Clowder Project</a>, an online resource for category theory and related mathematics.</p>

## Requirements
This project uses [Conda](https://anaconda.org/anaconda/conda) as Gerby requires `python3.6`. It also requires `inkscape` for `make pictures` to run properly.

## Initial setup
First, clone the repository via
```
git clone https://github.com/The-Clowder-Project/the-clowder-project
```
Then, run
```
make conda-create
```
activate the new conda environment via
```
conda activate clowder_py36_env
```
and then run
```
make init
```
which will install all required dependencies.

## Building the PDFs
The PDFs can be built by running `make all`. There are also `make` commands for particular styles, which are formatted as follows:
1. `make [style]` to build the book PDFs.
2. `make tags-[style]` to build the tagged book PDFs.
3. `make chapters-[style]` to build all chapters individually.
4. `make tags-chapters-[style]` to build all tagged chapters individually.

The available styles are:
1. `cm` (Computer Modern).
2. `alegreya` (Alegreya).
3. `alegreya-sans` (Alegreya Sans).
4. `alegreya-sans-tcb` (Alegreya Sans with `tcbthm` replacing `amsthm`)
5. `crimson-pro` (Crimson Pro).
6. `eb-garamond` (EB Garamond).
7. `xcharter` (XCharter).

The default style in the [Clowder website](https://www.clowderproject.com) is `alegreya-sans-tcb`.
## Building the web version
To build and serve the website on localhost (`127.0.0.1:5000`), run `make web-and-serve`.

Alternatively, you may run `make web-and-serve-with-pdf-statistics` instead, which will render a few additional statistics on Clowder's main output PDF. These will then be displayed in the website.
