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
   
  
CITATION -- 
If you use 3ML please cite...

"Jebb D. et al (2016) Dynamic heteroplasmy revealed by targeted, deep sequencing in a population
of the long-lived Greater mouse-eared bats, Myotis myotis. (In Press)"
	
3ML is a wrapper script used to call and annotate heteroplasmic variants in mammalian mitogenomes

The heavy lifting is performed by the programmes included as binary and jar files in the dep folder
Additional file handling and processing is done by custom Perl scripts in the bin folder.
These two folders should be kept in the same directory as 3ML.sh wrapper.

GNU Parallel is used to parallelise and so greatly increase the speed of 3ML.
GNU Parallel v 20170122 is should work with 3ML once correctly installed.
The link below contains the parallel v 20170122. However, we recommend getting the latest version.

http://ftp.gnu.org/gnu/parallel/parallel-20170222.tar.bz2


Bug reports and any questions are welcome
David
david.jebb@ucdconnect.ie
Laboratory of Molecular Evolution and Mammalian Phylogenetics                                
University College Dublin                                                                                     
Ireland
