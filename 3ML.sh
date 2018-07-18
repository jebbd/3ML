#!/bin/bash
shopt -s nullglob
anno=""
ref=""
caller="lf"
maf=0.01
path="."
njob=2
hlp=$(cat <<EOF
################################################################
#                                                              #  
#  3ML - Mammalian Mitochondrial Mutational Load               #
#                                                              #
################################################################
 
 3ML is currently only able to handle paired end reads
 
 Dependencies - GNU Parallel v 20160422 or higher 
                BWA version supporting the mem algorithm
 
 USAGE: ./3ML.sh -f [REFERENCE in fasta] [OPTIONAL FLAGS]
 
 Required Flags:                                              
   -f : Reference Sequence in fasta format                
      
 Optional Flags:
   -p : Path to paired-end reads. 
        Deafult is current directory
        Paired files must have same identifier
   -c : Caller of choice - Lofreq or Varscan
        LoFreq is default caller
   -a : Annotation File in tab delimitted format
   	    Example provided in "example" directory
   -m : Minor Allele Frequency cut-off
   	    Alleles below this cut-off will be filtered out
   	    Default is 0.01 (1%)
   -j : Number of parallel processes to run simultaneously
   	    Defualt is 2
   	
 Additional Flags:
   -h : Print this kinda helpful menu
		
EOF
)		

while getopts ":j::p::f::c::a::m:h" opt; do
 case $opt in 
 f)
  ref=$OPTARG
  echo "$ref to be used as reference, must be in fasta format" >&2
  ;;
 c) 
  caller=$OPTARG
  if [ "$caller" = "vs" ]; then
   echo "Caller assigned as Varscan" >&2
  elif [ "$caller" = "lf" ]; then
   echo "Caller assigned as Lofreq" >&2
  else 
   echo "Caller not recognised, vs = Varscan, lf = Lofreq" ;
   exit 1;
  fi
  ;;
 a) 
  anno=$OPTARG
  echo "$anno to be used as annotations, must be tab separated" 
  ;;
 m)
  maf=$OPTARG
  echo "Minor Allele Frequency set to $maf"
  ;;
 j)
  njob=$OPTARG
  echo "Maximum number of processes to be spawned is $njob"
  ;;
 p)
  input=$OPTARG
  path=${input%/}
  echo "$path designated directory for read data"
  ;;
 h)
  echo "$hlp"
  exit 0
  ;;
 \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;; 
 :) 
   echo "Invalid: -a [annotation file], -c [caller: lf or vs] and -f [mitogenome reference in fasta] must take arguments" 
   exit 1
   ;;
 esac 
done

shift $(( OPTIND - 1 ))

if [ "$ref" = "" ]; then
	echo -e "\n\n****A reference in fasta format must be provided****\n\n"
	echo "$hlp" 
	exit 1
else
perl bin/extend_ref.pl $ref
ext="Extended_$ref"	
fi

vs_call () {
local maf=$1
local ref=$2
local for=$3
local rev=$4
sample=`echo $for | perl -ne '/.?[A-Za-z0-9_\/]+/;print $&'`
	bwa mem $ref $for $rev > $sample.sam
	java -jar dep/SortSam.jar INPUT= $sample.sam OUTPUT= $sample.sorted.sam SORT_ORDER=coordinate
	java -jar dep/AddOrReplaceReadGroups.jar INPUT= $sample.sorted.sam OUTPUT= $sample.headers.sam RGSM=$sample RGLB=library RGPL=illumina RGPU=mito
	java -jar dep/SamFormatConverter.jar INPUT= $sample.headers.sam OUTPUT= $sample.convert.bam
	java -jar dep/BuildBamIndex.jar INPUT= $sample.convert.bam
	java -jar dep/GenomeAnalysisTK.jar \-T RealignerTargetCreator \-R $ref \-I $sample.convert.bam \-o $sample.targets.intervals
	java -jar dep/GenomeAnalysisTK.jar \-T IndelRealigner \-R $ref \-I $sample.convert.bam \-targetIntervals $sample.targets.intervals \-o $sample.realigned.bam
	samtools mpileup -B -f $ref $sample.realigned.bam | java -jar dep/VarScan.v2.3.9.jar mpileup2snp --min-var-freq $maf --output-vcf 1 >> $sample.raw.vcf
	java -jar dep/GenomeAnalysisTK.jar \ -T BaseRecalibrator \ -I $sample.realigned.bam \ -R $ref \ -knownSites $sample.raw.vcf \ -o $sample.recal.table
	java -jar dep/GenomeAnalysisTK.jar \ -T PrintReads \ -I $sample.realigned.bam \ -R $ref \ -BQSR $sample.recal.table \ -o $sample.recal.bam
	samtools mpileup -B -f $ref $sample.recal.bam | java -jar dep/VarScan.v2.3.9.jar mpileup2snp --min-var-freq $maf --output-vcf 1 >> $sample.final.vcf
	perl bin/vs_vcf2csv.pl $ref $sample.final.vcf
}
export -f vs_call
	
lf_call () {
local maf=$1
local ref=$2
local for=$3
local rev=$4
sample=`echo $for | perl -ne '/.?[A-Za-z0-9_\/]+/;print $&'`
	bwa mem $ref $for $rev > $sample.sam
	java -jar dep/SortSam.jar INPUT= $sample.sam OUTPUT= $sample.sorted.sam SORT_ORDER=coordinate
	java -jar dep/AddOrReplaceReadGroups.jar INPUT= $sample.sorted.sam OUTPUT= $sample.headers.sam RGSM=$sample RGLB=library RGPL=illumina RGPU=mito
	java -jar dep/SamFormatConverter.jar INPUT= $sample.headers.sam OUTPUT= $sample.convert.bam
	java -jar dep/BuildBamIndex.jar INPUT= $sample.convert.bam	
	java -jar dep/GenomeAnalysisTK.jar \-T RealignerTargetCreator \-R $ref \-I $sample.convert.bam \-o $sample.targets.intervals 2>$sample.targ.log
	java -jar dep/GenomeAnalysisTK.jar \-T IndelRealigner \-R $ref \-I $sample.convert.bam \-targetIntervals $sample.targets.intervals \-o $sample.realigned.bam 2>$sample.realn.log
	./dep/lofreq call -f $ref $sample.realigned.bam -o $sample.raw.vcf
	java -jar dep/GenomeAnalysisTK.jar \ -T BaseRecalibrator \ -I $sample.realigned.bam \ -R $ref \ -knownSites $sample.raw.vcf \ -o $sample.recal.table 2>$sample.recal.log
	java -jar dep/GenomeAnalysisTK.jar \ -T PrintReads \ -I $sample.realigned.bam \ -R $ref \ -BQSR $sample.recal.table \ -o $sample.recal.bam 2>$sample.recal.log
	./dep/lofreq call -f $ref $sample.recal.bam -o $sample.final.vcf
	perl bin/lf_vcf2csv.pl $maf $ref $sample.final.vcf > $sample.final.csv
}
export -f lf_call


r1_reads=($path/*R1*fastq*)
r2_reads=($path/*R2*fastq*)

if [ "$caller" = "vs" ]; then
parallel --link -j $njob vs_call $maf $ext ::: ${r1_reads[@]}  ::: ${r2_reads[@]}
elif [ "$caller" = "lf" ]; then
parallel --link -j $njob lf_call $maf $ext ::: ${r1_reads[@]}  ::: ${r2_reads[@]}
else 
echo "No caller detected, exiting.....";exit 1 ;
fi
wait 

if [ $anno != "" ];then
files=($path/*final.csv)
for f in ${files[@]}
do
name=`echo $f | perl -ne '/[A-Za-z0-9_\/]+/;print $&'`
perl bin/mito_anno.pl $ref $anno $name.final.csv > $name.annotated.csv
done
else
echo "No annotations provided...exiting"; exit 0
fi


echo "Sample,hetCount" > heteroplasmy.$path.csv
arr=($path/*annotated.csv)

for file in ${arr[@]}; do
        count=`grep -c -v '#CHROM' $file` ;
        echo "$file,$count" >> heteroplasmy.$path.csv
done
