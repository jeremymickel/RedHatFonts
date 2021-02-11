#!/bin/sh
set -e

# Only use this when necesdsary, are currently not all instances are defined in the VF designspace files.
# generate static designspace referencing csv and variable designspace file
# later, this might not be done dynamically
# python mastering/scripts/generate_fonts_designspace.py

## -------------------------------------------------------------
## Static TTF

echo "Cleaning out old static TTF fonts"

rm -rf fonts/static/ttf

echo "Generating Static TTF fonts"

mkdir -p fonts/static/ttf
fontmake -m source/Mono/RedHatMono_static.designspace -i -o ttf --no-production-names --output-dir fonts/static/ttf/
fontmake -m source/Mono/RedHatMonoItalic_static.designspace -i -o ttf --no-production-names --output-dir fonts/static/ttf/
fontmake -m source/Proportional/RedHatText_static.designspace -i -o ttf --no-production-names --output-dir fonts/static/ttf/
fontmake -m source/Proportional/RedHatTextItalic_static.designspace -i -o ttf --no-production-names --output-dir fonts/static/ttf/
fontmake -m source/Proportional/RedHatDisplay_static.designspace -i -o ttf --no-production-names --output-dir fonts/static/ttf/
fontmake -m source/Proportional/RedHatDisplayItalic_static.designspace -i -o ttf --no-production-names --output-dir fonts/static/ttf/

echo "Post processing TTFs"
ttfs=$(ls fonts/static/ttf/*.ttf)
for ttf in $ttfs
do
    gftools fix-dsig -f $ttf;
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    ttfautohint $ttf "$ttf.fix";
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    gftools fix-hinting $ttf;
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    gftools fix-nonhinting $ttf $ttf.fix
    mv  $ttf.fix $ttf                                    
    python mastering/scripts/fixNameTable.py $ttf
done

rm -f fonts/static/ttf/*gasp.ttf 

## -------------------------------------------------------------
## Static OTF

echo "Cleaning out old static OTF fonts"
rm -rf fonts/static/otf


echo "Generating Static OTF fonts"
mkdir -p fonts/static/otf
fontmake -m source/Mono/RedHatMono_static.designspace -i -o otf --no-production-names --output-dir fonts/static/otf/
fontmake -m source/Mono/RedHatMonoItalic_static.designspace -i -o otf --no-production-names --output-dir fonts/static/otf/
fontmake -m source/Proportional/RedHatText_static.designspace -i -o otf --no-production-names --output-dir fonts/static/otf/
fontmake -m source/Proportional/RedHatTextItalic_static.designspace -i -o otf --no-production-names --output-dir fonts/static/otf/
fontmake -m source/Proportional/RedHatDisplay_static.designspace -i -o otf --no-production-names --output-dir fonts/static/otf/
fontmake -m source/Proportional/RedHatDisplayItalic_static.designspace -i -o otf --no-production-names --output-dir fonts/static/otf/

echo "Post processing OTFs"
otfs=$(ls fonts/static/otf/*.otf)
for otf in $otfs
do
    gftools fix-dsig -f $otf;
    if [ -f "$otf.fix" ]; then mv "$otf.fix" $otf; fi
    gftools fix-nonhinting $otf $otf.fix
    mv  $otf.fix $otf                                    # TODO: add back hinting?
    python mastering/scripts/fixNameTable.py $otf
done

rm -f fonts/static/otf/*gasp.otf 

## -------------------------------------------------------------
## Improving version string detail

echo "----------------------------------------------------------------------------------"
echo "Adding the current commit hash to static font version strings"
allStaticFonts=$(find fonts/static -type f -name "*.ttf"  -o -name "*.otf")
for font in $allStaticFonts; do
    font-v write --sha1 "$font"
done
