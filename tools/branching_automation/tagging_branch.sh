#!/bin/bash
#Include the path from where the files are. Find files with .bb extensions and remove the extension. Searching for SRCREV value in each repository. Put the repository name and hash value together.
a=rel/dill
pwd='/ws/melachur/ops-build/yocto/openswitch/meta-distro-openswitch/recipes-ops'
auto_rev="\${AUTOREV}"
declare -A keys
echo $1
for i in $(find $1 -name *.bb);do
# Search Each file for SRCREV string
if grep -q SRCREV "$i";then
hash=$(grep SRCREV $i | cut -d'"' -f2)
#Replace AUTOREV with HEAD, so that it will show the last commit sha value.
echo $hash
if [ "$auto_rev" = "$hash" ]; then
  hash="HEAD"
fi
#Mapping the repository value with SHA value as key-value pair in hashes.

file_name=$(basename $i .bb)
echo "$file_name,$hash"
keys[$file_name]=$hash
fi
done
#Making a directory, to clone all the repository in it.

if ! [ -d "$pwd/clones" ]; then
  mkdir $pwd/clones
fi
for j in "${!keys[@]}"
do
  echo "key :" $j
  echo "value :" ${keys[$j]}
if ! [ -d "$pwd/clones/$j" ]; then
     echo $j is not present
     git clone https://git.openswitch.net/openswitch/$j $pwd/clones/$j
fi
#Changing the path to the directory and start tagging according to the SHA value
cd $pwd/clones/$j
# git checkout $a
# git branch
# git pull --rebase origin
# git pull --rebase origin
# git reset --hard ${keys[$j]}
# git tag -a v1 -m "Creating a tag on the SHA Value"
# git push origin --tags
done
