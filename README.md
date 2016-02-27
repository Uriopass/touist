TouIST, the IDE for propositional logic
=======================================

![The Travis build state: says if the java project can be built of not](https://travis-ci.org/FredMaris/touist.svg?branch=master)

TouIST is a user-friendly tool for solving propositionnal logic problems using a high-level logic language (known as the _bigand_ format or syntax or language). This language allows complex expressions like _big and_, _sets_... 

We can for example solve the problem "Wolf, Sheep, Cabbage", or a sudoku, or any problem that can be expressed in propositionnal logic.

The TouIST has been initialized by Frederic Maris and Olivier Gasquet, associate professors at the _Institut de Recherche en Informatique de Toulouse_ (IRIT). It is a "second" or "new" version of a previous program, [SAToulouse](http://www.irit.fr/satoulouse/).

The development is done by a team of five students in first year of master's degree at the _Université Toulouse III — Paul Sabatier_. This project is a part of their work at school. See [CONTRIBUTORS](https://github.com/FredMaris/touist/blob/master/CONTRIBUTORS.md).

![Formulas](https://cloud.githubusercontent.com/assets/2195781/7631376/8b0a1e66-fa41-11e4-9d14-5fd39da7c494.png)

## Download it  
[Get the latest release](https://github.com/FredMaris/touist/releases). For now, Touist is compatible with:

- Mac OS X Intel 64 bits
- Linux 64 bits

Touist is platform-specific because of the ocaml `touist` translator that translates the high-level `.touistl` (touist language files) into `SAT_DIMACS` or `SMT2` is compiled into an architecture-specific binary (for performances).

We have some issues with compiling the ocaml translator for Windows. Some of the first releases have been compiled for Windows, but the tool we used has been discontinued ([see corresponding issue](https://github.com/FredMaris/touist/issues/5)).


## What is Touist made of?
Touist uses Java (>= jre6) and embeds an architecture-specific binary, [touistc](https://github.com/FredMaris/touist/tree/master/touist-translator) (we coded it in ocaml), which translates touistl language to dimacs. The dimacs files are then given to another binary, the SAT (or SMT) solver, and then displayed to the user.

_touistc_ can also be used in command-line.


## Rebuilding-it
See the [./INSTALL.md](https://github.com/FredMaris/touist/blob/master/INSTALL.md) file.

------------
Here is a small figure showing the architecture of the whole program:   
![Architecture of touist](https://cloud.githubusercontent.com/assets/2195781/7631517/94c276e0-fa43-11e4-9a5c-351b84c2d1e1.png)

## Bugs and feature requests
You can report bugs by creating a new Github issue. Feature requests can also be submitted using the issue system.  

You can contribute to the project by forking/pull-requesting.

