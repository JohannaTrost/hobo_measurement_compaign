#!/bin/bash

hobo_path="data/input/hobo"

# Manual removal of file without proper data
rm $hobo_path/2022/raw/10760769.csv

# Print all files that don't match the typical Hobo file patters
echo Non-Hobo-format filenames:
ls $hobo_path/*/raw/* | grep -v '[0-9]\{8\}\.csv$' | head -n 3
echo "( ... )"

# Get all Hobo files
files=$(ls $hobo_path/*/raw/* | grep -E '[0-9]{8}\.(csv|tsv|txt)$')

# Remove any '"'
sed -i '' 's/"//g' $files

# Replace tab with comma
sed -i '' 's/\t/,/g' $files

# Find the files that are tab separated 
# - here I only print the number of tsv files to avoid a very long output
echo "No. tsv files after pre-pro.: "$(grep -rl $'\t' $files | wc -l)

# Replace all tabs with commas
for file in $files
do 
  # Merge date and time to one timestamp column
  tstamp_col=$(awk -F',' '{print $3}' $file)
  # Number of rows without double
  n_nondouble=$(echo "$tstamp_col" | grep -oEv '\b[0-9]+\.[0-9]+\b' | wc -l)
  n_lines=$(cat $file | wc -l)
  n=$(( n_lines - (n_lines / 4) ))
  if [ $n_nondouble -gt $n ] 
  # If the 3rd column does not contain doubles (temperature)
  then 
      # Merge date and time columns
      awk 'BEGIN {FS=","; OFS=","} {print $1, $2" "$3, $4, $5}' $file > tmp.txt && mv tmp.txt $file
  fi
done

# Rename files from csv to tsv extension
rename 's/\.tsv$|\.txt$/.csv/' $hobo_path/*/raw/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].{tsv,txt}

# Show remaining files that don't match Hobo filename format
remFiles=$(ls $hobo_path/*/raw/* | grep -v '[0-9]\{8\}\.csv$')
echo Remaining non-Hobo-format filenames:
echo $remFiles

# Delete files
rm $remFiles
