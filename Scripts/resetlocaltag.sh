#!/bin/bash
#
# Script to reset the OSteotomy local tag on my branch to have a product name
# when building the Bodycad/Gatherfiles project
#

tagname="DesignerReflex-9.9.9.9"

# check if my tag exists

existingtag=`hg tags | grep $tagname | cut -c 1-18`

if [ -z $existingtag ]; then
  echo "Tag $tagname not found. Will just create it."
  hg tag --local $tagname
  exit
fi


if [ $existingtag == $tagname ]; then
  echo "Tag named $existingtag was found. Deleting..."
  hg tag --local --remove $tagname
  echo "Creating new tag..."
  hg tag --local $tagname  
else
  echo "Tag $tagname not found. Will just create it."
  hg tag --local $tagname
fi

exit