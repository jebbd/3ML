#!usr/bin/perl -w

my $genome = $ARGV[0] ;

open IN, "<".$genome; my @ref_test=<IN>; close IN;
$header = $ref_test[0] ;
$header =~ s/\R//g ;
my @header_ref_tests = split("", $header) ;
my $first_char_test = $header_ref_tests[0] ;
if ($first_char_test ne ">") {print "reference must be provided in fasta format\n\n" ; exit}		
elsif ($first_char_test eq ">") {print "refernce $header in fasta format, OK\n\n"}


shift @ref_test ;
foreach $seq (@ref_test){
		@lines = split(/\R/,$seq) ;
		$dna = join('',@lines) ;
		}

$end =substr($dna,0,500) ;
$front =substr($dna,-500) ;

open OUT, ">Extended_$genome" ;

print OUT $header."_extended"."\n".$front.$dna.$end."\n" ;

close OUT ;

$dict = $genome ;
$dict =~ s/fasta/dict/ ;

system "bwa index Extended_$genome" ;
system "samtools faidx Extended_$genome" ;
system "java -jar dep/CreateSequenceDictionary.jar REFERENCE=Extended_$genome OUTPUT= Extended_$dict " ;