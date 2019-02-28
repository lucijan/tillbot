#!/bin/bash

join() {
    # $1 is return variable name
    # $2 is sep
    # $3... are the elements to join
    local retname=$1 sep=$2 ret=$3
    shift 3 || shift $(($#))
    printf -v "$retname" "%s" "$ret${@/#/$sep}"
}

join_titlecase() {
    # $1 is return variable name
    # $2 is sep
    # $3... are the elements to join
    local retname=$1 sep=$2 ret=$3
    shift 3 || shift $(($#))
    printf -v "$retname" "%s" "$ret${@/#/$sep}"
}

echo "// pitch, duration, amplitude, slide, end"
names=(  )
names_tc=(  )
for i in *.txt; do
	name=${i%%.txt}
	names+=($name)
	names_tc+=(${name^})
	echo "const SoundInfo ${name}[] = {"
	old_ifs=$IFS
	IFS=";, " 
	LC_NUMERIC=C
	cnt=0;
	while read idx p d a s; do
		let cnt++;
	done < $i
	line=0;
	while read idx p d a s; do
		let line++;
		#printf "\t{%2d, %6.2f, %4d, %3.2f, %d},\n" $idx $p $d $a $s
		if [ $line -lt $cnt ]; then
			printf "\t{%6.2f, %4d, %3.0f, %d, 0},\n" $p $d $( echo "$a * 255" | bc -l ) $s
		else
			printf "\t{%6.2f, %4d, %3.0f, %d, 1}};\n\n" $p $d $( echo "$a * 255" | bc -l ) $s
		fi
	done < $i
	IFS=$old_ifs
done
join names_str ", " "${names[@]}"
echo -e "const SoundInfo *sounds[] = { $names_str };\n"
join names_tc_str ", " "${names_tc[@]}"
echo -e "enum Sound { $names_tc_str };\n"
