while read line
do
	char1=`echo "$line" | cut -c 1`
	
	if [ $char1 == "G" ]
	then
		trans=`fgrep $line maize_v3.len | sort -k2 -r | head -n 1 | cut -f 1`
		echo "$trans"
	else
		prot=`echo $line | sed 's/FG/FGP/g'`
		trans=`fgrep $prot maize_v3.len | sort -k2 -r | head -n 1 | cut -f 1`
		echo "$trans"
	fi
done < $1
