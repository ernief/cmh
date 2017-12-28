for i in version0/*
do
	ff=`basename $i`
	echo $ff
	diff version0/$ff version0.1/$ff
done
