#!/bin/sh
id=$1
wkd=/public/home/cxwu/sswu/RNA_seq/00_data/kernal/${id}
cd ${wkd}

hisat2=/public/home/sswu/software/hisat2-2.1.0
samtools=/public/home/sswu/software/new_software/samtools-1.9/samtools
stringtie=/public/home/sswu/software/stringtie-1.3.5.Linux_x86_64/stringtie
ref=/public/home/sswu/RNA_seq/MT/00_ref

#<<'COMMENT'
#####
### 1.trim the raw reads
for s in *_1.fq.gz
	do
		prx=$(basename $s | sed "s/_1.fq.gz//g")
		bsub -K -J fap.$id -n 3 -o %J.out -e %J.err -R span[hosts=1] \
			"/public/home/sswu/software/Anaconda3/bin/fastp -g -w 3 -l 76 --adapter_fasta /public/home/sswu/RNA_seq/raw_data/adapters.fa -i ${wkd}/${prx}_1.fq.gz -I ${wkd}/${prx}_2.fq.gz -o ${wkd}/${id}_1.alltrimed.fq.gz -O ${wkd}/${id}_2.alltrimed.fq.gz -h ${wkd}/${id}.html"
	done
#COMMENT
#####
### 2.map the reads for each sample to the reference genome
bsub -K -J hit2.$id -n 8 -o %J.out -e %J.err -R span[hosts=1] \
	"${hisat2}/hisat2 -p 8 --dta -x ${ref}/Zea_mays.B73_RefGen_v4.dna.toplevel_tran -1 ${wkd}/${id}_1.alltrimed.fq.gz -2 ${wkd}/${id}_2.alltrimed.fq.gz -S ${wkd}/${id}_hisat2.sam --max-intronlen 50000 2>${wkd}/${id}_hisat2.log"

#####
### 3.extra uniq mapped reads and reform sam file to bam file

bsub -K -J samtls.$id -n 1 -o %J.out -e %J.err -R span[hosts=1] \
	"grep -E '@|NH:i:1' ${wkd}/${id}_hisat2.sam >${wkd}/${id}_hisat2_uniq.sam ;${samtools} sort -o ${wkd}/${id}_hisat2.bam ${wkd}/${id}_hisat2.sam ; ${samtools} sort -o ${wkd}/${id}_hisat2_uniq.bam ${wkd}/${id}_hisat2_uniq.sam ;rm ${wkd}/${id}_hisat2.sam ;rm ${wkd}/${id}_hisat2_uniq.sam"

#####
### 4.htseq count raw reads number
bsub -K -J htseq.$id -n 1 -o %J.out -e %J.err -R span[hosts=1] \
	"/public/home/sswu/software/Anaconda3/bin/htseq-count -f bam -s no ${wkd}/${id}_hisat2_uniq.bam -t gene ${ref}/Zea_mays.B73_RefGen_v4.45.gtf >${wkd}/${id}.Genecounts 2>${wkd}/${id}.htseq.log"

#####
### 5.stringtie assmebly transcription
bsub -K -J str.$id -n 8 -o %J.out -e %J.err -R span[hosts=1] \
	"${stringtie} -p 8 -G ${ref}/Zea_mays.B73_RefGen_v4.45.gtf -o ${wkd}/${id}_stringtie.gtf -l ${id} ${wkd}/${id}_hisat2_uniq.bam 1>${id}_str_assm.log 2>&1"

#####
### 6.
