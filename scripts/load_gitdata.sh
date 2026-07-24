#!/bin/bash

datadir="data/input"

# Remove directories if they already exist
if [ -d "$datadir/hobo" ] && [ -d "$datadir/GIS" ] 
then
    rm -r "$datadir/hobo"
    rm -r "$datadir/GIS"
fi

# Clone repo instead of download data because too messy with curl in MacOS and wget in Linux
git init 
git remote add -f origin https://github.com/data-hydenv/data.git

# Only clone specific directories
git config core.sparseCheckout true 
echo "GIS" >> .git/info/sparse-checkout
echo "hobo" >> .git/info/sparse-checkout
git pull origin master

# Remove repo
rm -rf *.git*
rm -rf .git

# Copy files into data dir
mv GIS $datadir
mv hobo $datadir