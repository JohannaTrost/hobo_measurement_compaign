#!/bin/bash

hobo_path="data/input/hobo"

# Print all files that don't match the typical Hobo file patters
echo Non-Hobo-format filenames:
ls $hobo_path/*/hourly/* | grep -v '[0-9]\{8\}\_Th.csv$' | head -n 3
echo "( ... )"

# Rename file by removing whitespace from the filename
dir="$hobo_path/2019/hourly" # Define the directory path
mv "$dir/10347320_Th .tsv" "$dir/10347320_Th.tsv"

# Remove first column from one hobo file
file="$hobo_path/2021/hourly/10350090_Th.csv"
awk 'BEGIN {FS=","; OFS=","} {print $2, $3, $4}' $file > tmp.txt && mv tmp.txt $file

# Get all Hobo files
files=$(ls $hobo_path/*/hourly/* | grep -E '[0-9]{8}_[Tt]h\.(csv|tsv|txt)$')

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
  tstamp_col=$(awk -F',' '{print $2}' $file)
  # Number of rows without double
  n_nondouble=$(echo "$tstamp_col" | grep -oEv '\b[0-9]+\.[0-9]+\b' | wc -l)
  n_lines=$(cat $file | wc -l)
  n=$(( n_lines - (n_lines / 4) ))
  if [ $n_nondouble -gt $n ] 
  # If the 3rd column does not contain doubles (temperature)
  then 
      # Merge date and time columns
      awk 'BEGIN {FS=","; OFS=","} {print $1" "$2, $3, $4}' $file > tmp.txt && mv tmp.txt $file
  fi
done

# Rename files from csv to tsv extension
rename 's/\.tsv$|\.txt$/.csv/' $hobo_path/*/hourly/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[Tt]h.{tsv,txt}

# Show remaining files that don't match Hobo filename format
remFiles=$(ls $hobo_path/*/hourly/* | grep -v '[0-9]\{8\}\_Th.csv$')
echo Remaining non-Hobo-format filenames:
echo $remFiles

# Delete files
rm $remFiles