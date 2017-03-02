#!/user/bin/perl

$maf = $ARGV[0] ;
$genome=$ARGV[1] ;
open IN, "<".$genome; my @ref_test=<IN>; close IN;
shift @ref_test ;
foreach $seq (@ref_test){
		@lines = split(/\R/,$seq) ;
		$dna = join('',@lines) ;
		}
$length = length($dna) ;
$limit = $length - 1000 ;

$file = $ARGV[2] ;
open IN, "<$file";
#$out = $file ;
#$out =~ s/vcf/csv/g ;
#open OUT,">$out" ;
while(<IN>){
    if($_=~m/CHROM/){
	my $header = $_ ;
	@headers = split(/\t/, $header) ;	 
	print "$headers[0],$headers[1],$headers[3],$headers[4],FREQ,DEPTH\n" ;
    }
    elsif ($_=~m/##/){
	$_ = $infofield ;
	#print "converting to CSV\n" ;
	}
	else{
	$line=$_;
	@array=split(/\t/,$line);
	$pos = $array[1] ;
	
	$truepos = $pos -500 ;
	$info=$array[7] ;
	@inform = split(/;/,$info) ;
	$depth = $inform[0] ;
	$freq_raw = $inform[1] ;
	$depth =~ s/\D//g ;
	$calc = substr($freq_raw, 3) ;
	if ($truepos < 0 || $truepos > $limit){
		#print "removing overhang var\n"
		}
	else{	
	
	if ($calc gt 0.5){
		$freq = 1-$calc ;
		if ($freq gt $maf){
		print "$array[0],$truepos,$array[4],$array[3],$freq,$depth\n" ;
		}
	}	
	else {
		$freq = $calc ;
		if ($freq >= $maf) {
			print "$array[0],$truepos,$array[3],$array[4],$freq,$depth\n" ;		
		}
		}	
	
	}
	}
}
