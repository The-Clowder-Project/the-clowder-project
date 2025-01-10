#/bin/bash
cd pictures/light-mode/monoidal-left-unity-of-id-otimes-sets/
./make.sh
cd pictures/light-mode/monoidal-left-unity-of-id-otimes-sets-star/
./make.sh
cd ../monoidal-right-unity-of-id-otimes-sets/
./make.sh
cd pictures/light-mode/monoidal-right-unity-of-id-otimes-sets-star/
./make.sh
cd ../symmetric-difference/associativity/
lualatex A.tex
lualatex A_sdiff_B.tex
lualatex A_sdiff_B_sdiff_C.tex
lualatex B_sdiff_C.tex
lualatex C.tex
cd ../via-unions-and-intersections/
lualatex Venn0001.tex
lualatex Venn0110.tex
lualatex Venn0111.tex
cd ../../../../
cd pictures/dark-mode/monoidal-left-unity-of-id-otimes-sets/
./make.sh
cd ../monoidal-left-unity-of-id-otimes-sets-star/
./make.sh
cd ../monoidal-right-unity-of-id-otimes-sets/
./make.sh
cd ../monoidal-right-unity-of-id-otimes-sets-star/
./make.sh
cd ../symmetric-difference/associativity/
lualatex A.tex
lualatex A_sdiff_B.tex
lualatex A_sdiff_B_sdiff_C.tex
lualatex B_sdiff_C.tex
lualatex C.tex
cd ../via-unions-and-intersections/
lualatex Venn0001.tex
lualatex Venn0110.tex
lualatex Venn0111.tex
