#!usr/bin/perl -w

my $genome = $ARGV[0] ;

open IN, "<".$genome; my @ref_test=<IN>; close IN;
$header = $ref_test[0] ;
$header =~ s/\R//g ;
my @header_ref_tests = split("", $header) ;
my $first_char_test = $header_ref_tests[0] ;
if ($first_char_test ne ">") {print "reference must be provided in fasta format\n\n" ; exit}		
elsif ($first_char_test eq ">") {print "refernce $header in fasta format, OK\n\n"}

system "bwa index $genome" ;
system "samtools faidx $genome" ;
$dname = $genome ;
$dname =~ s/.fasta//g ;
system "java -jar dep/CreateSequenceDictionary.jar REFERENCE= $genome OUTPUT= $dname.dict " ;
		
##produce shifted genome		
open IN, "<".$genome; my @mito=<IN>; close IN;
$header = $mito[0] ;
$header =~ s/\R//g ;
my @header_tests = split("", $header) ;
my $first_char = $header_tests[0] ;
if ($first_char ne ">") {print "reference must be provided in fasta format\n" ; exit}
elsif ($first_char eq ">") {print "reference $header in fasta format.
Mitogenome will be shifted 7999bp, position 8000 will become position 1\n\n"}
$seq = $mito[1] ;
my $shift_factor = 7999 ;


my $sub_seq = substr($seq, 0, $shift_factor);
#print "SUB_SEQ: $sub_seq\n\n" ;

my $remainder = substr ($seq, $shift_factor, -1) ;
#print "REMAINING SEQ: $remainder\n\n" ;
$remainder =~ s/\R//g ;
open OUT, ">$dname.shifted.fasta" ;
print OUT "$header-shift_factor-$shift_factor
$remainder$sub_seq" ;
close OUT ;
system "bwa index $dname.shifted.fasta" ;
system "samtools faidx $dname.shifted.fasta" ;
system "java -jar dep/CreateSequenceDictionary.jar REFERENCE= $dname.shifted.fasta OUTPUT= $dname.shifted.dict " ;

