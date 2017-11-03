

##   3ML - Mammalian Mitochondrial Mutational Load 


### 3ML can currently only handle paired-end reads
### Dependencies - 3ML requires GNU parallel v 20160422 or higher 
### and BWA version supporting the mem algorithm

USAGE: ./3ML.sh -f [REFERENCE in fasta] [OPTIONAL FLAGS]

Required Flags: 
*	-f : *FILE* Reference Sequence in FASTA format

Optional Flags:
*	-c : _STR_ Variants caller of choice		
				lf = LoFreq(default); vs = VarScan		
*	-a : *FILE* Annotations in tab delimited format		
				Example given in "example/" directory
*	-m : *FLOAT* Minor Allele Frequency cut-off		
				Deafult 0.01 (1%) 
* -p : *DIR* Path to reads		
				Default is current directory
* -j : *INT* Number of processes to start simultaneously

Additional Flags:
* -h : Print this kinda helpful menu


### CITATION		
If you use 3ML please cite...		

"Jebb D. et al (2017) Dynamic heteroplasmy revealed by targeted, deep sequencing in a population of the long-lived Greater mouse-eared bats, Myotis myotis. (In Press)"

### 3ML is a wrapper script used to call and annotate heteroplasmic variants in mammalian mitogenomes

The heavy lifting is performed by the programmes included as binary and jar files in the dep folder.		
Additional file handling and processing is done by custom Perl scripts in the bin folder.		
*These two folders should be kept in the same directory as 3ML.sh wrapper.*		

GNU Parallel is used to parallelise and so greatly increase the speed of 3ML.  
GNU Parallel v 20170122 is should work with 3ML once correctly installed.  
The link below contains the parallel v 20170122. However, we recommend getting the latest version  
http://ftp.gnu.org/gnu/parallel/parallel-20170222.tar.bz2

Bug reports and any questions are welcome,  
David  
Laboratory of Molecular Evolution and Phylogenetics  
University College Dublin  
Ireland

