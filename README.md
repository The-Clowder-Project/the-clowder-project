# The Clowder Project
<p align="center"><img src="./logo.png" width="100%"/></p>
<p>This is the repository for the <a href="https://topological-modular-forms.github.io/the-clowder-project">Clowder Project</a>, an online resource for category theory and mathematics.</p>

## Requirements
This project requires:
- [Conda](https://anaconda.org/anaconda/conda), for Gerby (which needs `python3.6`).
- `inkscape`, for `make pictures`.

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

There are also individual `make` commands for the chapters, books, etc.:
1. `make all-books` will build all book PDFs.
2. `make all-tags-books` will build all book PDFs with tags.
3. `make all-chapters` will build all chapter PDFs.
4. `make all-tags-chapters` will build all chapter PDFs with tags.

In addition, there are `make` commands for particular “styles”. These are formatted as follows:
1. `make [style]` will build the book PDF for the given `style`.
2. `make tags-[style]` will build the book PDF with tags for the given `style`.
3. `make chapters-[style]` will build all chapter PDFs for the given `style`.
4. `make tags-chapters-[style]` will build all chapter PDFs with tags for the given `style`.

The available styles are the following:

| Style               |  Typeface                                                          | Theorem Environments |
| ------------------- |  ----------------------------------------------------------------- | -------------------- |
| `cm-tcb`            |  [Computer Modern](https://en.wikipedia.org/wiki/Computer_Modern)  | `tcbthm` (Boxed)     | 
| `alegreya-tcb`      |  [Alegreya](https://fonts.google.com/specimen/Alegreya)            | `tcbthm` (Boxed)     | 
| `alegreya-sans-tcb` |  [Alegreya Sans](https://fonts.google.com/specimen/Alegreya+Sans)  | `tcbthm` (Boxed)     | 
| `crimson-pro-tcb`   |  [Crimson Pro](https://fonts.google.com/specimen/Crimson+Pro)      | `tcbthm` (Boxed)     | 
| `eb-garamond-tcb`   |  [EB Garamond](https://fonts.google.com/specimen/EB+Garamond)      | `tcbthm` (Boxed)     | 
| `xcharter-tcb`      |  [XCharter](https://ctan.org/pkg/xcharter)                         | `tcbthm` (Boxed)     | 
| `cm`                |  [Computer Modern](https://en.wikipedia.org/wiki/Computer_Modern)  | `amsthm` (Standard)  | 
| `alegreya`          |  [Alegreya](https://fonts.google.com/specimen/Alegreya)            | `amsthm` (Standard)  | 
| `alegreya-sans`     |  [Alegreya Sans](https://fonts.google.com/specimen/Alegreya+Sans)  | `amsthm` (Standard)  | 
| `crimson-pro`       |  [Crimson Pro](https://fonts.google.com/specimen/Crimson+Pro)      | `amsthm` (Standard)  | 
| `eb-garamond`       |  [EB Garamond](https://fonts.google.com/specimen/EB+Garamond)      | `amsthm` (Standard)  | 
| `xcharter`          |  [XCharter](https://ctan.org/pkg/xcharter)                         | `amsthm` (Standard)  | 

**The default style is `alegreya-sans-tcb`.**

## Building the web version
To build and serve the website on localhost (`127.0.0.1:5000`), run `make web-and-serve`.

Alternatively:
- To serve on IPv6, run `make web-and-serve-on-ipv6`.
- To render extra PDF statistics, run `make web-and-serve-with-pdf-statistics` (served on localhost).
