#!/bin/sh
set -e

if [ -z "$1" ]
then
	echo "No version number supplied. If you wish to update the version number in UFOs & built fonts, add one as a build argument:"
	echo "sources/build-vf.sh 1.000"
else
	version=$1
	python mastering/scripts/edit-ufo-info/set-ufo-version.py sources/Mono $version --save
fi

## ------------------------------------------------------------------
## Variable Fonts Build - Static build is at sources/build-statics.sh

echo "Generating VFs"
mkdir -p fonts
fontmake -m source/Mono/RedHatMono.designspace -o variable --no-production-names --output-path fonts/RedHatMono[wght].ttf
fontmake -m source/Mono/RedHatMonoItalic.designspace -o variable --no-production-names --output-path fonts/RedHatMono-Italic[wght].ttf
fontmake -m source/Proportional/RedHatText.designspace -o variable --no-production-names --output-path fonts/RedHatText[wght].ttf
fontmake -m source/Proportional/RedHatTextItalic.designspace -o variable --no-production-names --output-path fonts/RedHatText-Italic[wght].ttf
fontmake -m source/Proportional/RedHatDisplay.designspace -o variable --no-production-names --output-path fonts/RedHatDisplay[wght].ttf
fontmake -m source/Proportional/RedHatDisplayItalic.designspace -o variable --no-production-names --output-path fonts/RedHatDisplay-Italic[wght].ttf



vfs=$(ls fonts/*.ttf)
echo vfs
echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	#python mastering/scripts/fix_naming.py $vf;
	#ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
	#mv "$vf.fix" $vf;
done

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-nonhinting $vf "$vf.fix";
	if [ -f "$vf.fix" ]; then mv "$vf.fix" $vf; fi
done

echo "Add STAT table"
python mastering/scripts/add_STAT-improved.py "fonts/RedHatMono[wght].ttf"
python mastering/scripts/add_STAT-improved.py "fonts/RedHatMono-Italic[wght].ttf"
python mastering/scripts/add_STAT-improved.py "fonts/RedHatText[wght].ttf"
python mastering/scripts/add_STAT-improved.py "fonts/RedHatText-Italic[wght].ttf"
python mastering/scripts/add_STAT-improved.py "fonts/RedHatDisplay[wght].ttf"
python mastering/scripts/add_STAT-improved.py "fonts/RedHatDisplay-Italic[wght].ttf"

rm -rf fonts/*gasp*

echo "Remove unwanted fvar instances"
for vf in $vfs
do
	python mastering/scripts/removeUnwantedVFInstances.py $vf
done

echo "Dropping MVAR"
for vf in $vfs
do
	# mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=fonts/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fix name table"
for vf in $vfs
do
    python mastering/scripts/fixNameTable.py $vf
done


### Cleanup


rm -rf ./*/instances/

rm -f fonts/*.ttx
rm -f fonts/static/ttf/*.ttx
rm -f fonts/*gasp.ttf
rm -f fonts/static/ttf/*gasp.ttf

# ## -------------------------------------------------------------
# ## Improving version string detail

# echo "----------------------------------------------------------------------------------"
# echo "Adding the current commit hash to variable font version strings"
# font-v write --sha1 "fonts/RedHatMono[wght].ttf"
# font-v write --sha1 "fonts/RedHatMono-Italic[wght].ttf"

echo "Done Generating"

# # # You should check the fonts now with fontbakery, and generate a markdown file. 
