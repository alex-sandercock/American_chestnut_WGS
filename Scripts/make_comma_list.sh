# use this to turn a multiline string file into comma separated list
#Use this for SMC++

cat data.txt | xargs | sed -e 's/ /,/g'