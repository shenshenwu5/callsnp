#!/bin/sh


for file in F17FTSCCKF2847_LIBqkgR 
   do
      cd /public/home/sswu/sequence/${file}/Clean
      for ss in W*
         do
		echo ${file}_${ss}
		qsub -N snpcalling_${ss} -l nodes=1:ppn=8 -q batch -V -d ./ -F "$file $ss" /public/home/sswu/sequence/graduation/SK/snpcalling_SK.sh
         done
   done
