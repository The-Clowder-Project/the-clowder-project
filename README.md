# The Clowder Project
<p align="center"><img src="./logo.png" width="100%"/></p>
<p>This is the repository for the <a href="https://topological-modular-forms.github.io/the-clowder-project">Clowder Project</a>, an online resource for category theory and related mathematics.</p>

## Requirements
This project requires:
- [Conda](https://anaconda.org/anaconda/conda), as Gerby needs `python3.6`.
- `inkscape`, for `make pictures` to run properly.

## Initial setup
After installing the requirements, follow the instructions below. 
1. First, clone the repository via
```
git clone https://github.com/The-Clowder-Project/the-clowder-project
```
2. Once inside the project's directory, run
```
make conda-create
```
3. Next, activate the new conda environment via
```
conda activate clowder_py36_env
```
4. Finally, run
```
make init
```
This will install all required dependencies. You can now proceed to build the website or the PDFs.

## Building the PDFs
The PDFs can be built by running `make all`.

There are individual `make` commands for the chapters, books, etc.:
1. `make all-books` will build all book PDFs.
2. `make all-tags-books` will build all book PDFs with tags.
3. `make all-chapters` will build all chapter PDFs.
4. `make all-tags-chapters` will build all chapter PDFs with tags.

In addition, there are also `make` commands for particular styles. These are formatted as follows:
1. `make [style]` will build the book PDF for the given `style`.
2. `make tags-[style]` will build the book PDF with tags for the given `style`.
3. `make chapters-[style]` will build all chapter PDFs for the given `style`.
4. `make tags-chapters-[style]` will build all chapter PDFs with tags for the given `style`.

The available styles are:
1. `cm-tcb` (Computer Modern with `tcbthm` theorem environments).
2. `alegreya-tcb` (Alegreya with `tcbthm` theorem environments).
3. `alegreya-sans-tcb` (Alegreya Sans with `tcbthm` theorem environments).
4. `crimson-pro-tcb` (Crimson Pro with `tcbthm` theorem environments).
5. `eb-garamond-tcb` (EB Garamond with `tcbthm` theorem environments).
6. `xcharter-tcb` (XCharter with `tcbthm` theorem environments).
7. `cm` (Computer Modern with `amsthm` theorem environments).
8. `alegreya` (Alegreya with `amsthm` theorem environments).
9. `alegreya-sans` (Alegreya Sans with `amsthm` theorem environments).
10. `crimson-pro` (Crimson Pro with `amsthm` theorem environments).
11. `eb-garamond` (EB Garamond with `amsthm` theorem environments).
12. `xcharter` (XCharter with `amsthm` theorem environments).

*The default style is `alegreya-sans-tcb`.*

## Building the web version
To build and serve the website on localhost (`127.0.0.1:5000`), run `make web-and-serve`.

Alternatively:
- To serve on IPv6, run `make web-and-serve-on-ipv6`.
- To render extra PDF statistics, run `make web-and-serve-with-pdf-statistics`.
