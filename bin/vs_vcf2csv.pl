#!/user/bin/perl/

$genome=$ARGV[0] ;
open IN, "<".$genome; my @ref_test=<IN>; close IN;
shift @ref_test ;
foreach $seq (@ref_test){
		@lines = split(/\R/,$seq) ;
		$dna = join('',@lines) ;
		}
$length = length($dna) ;
$limit = $length - 1000 ;

$file=$ARGV[1] ;
open(IN, "<$file");
$out = $file ;
$out =~ s/vcf/csv/g ;
open (OUT,">$out") ;
while(<IN>){
    if($_=~m/CHROM/){
	@headers = split(/\t/, $_) ;	 
	print OUT "$headers[0],$headers[1],$headers[3],$headers[4],FREQ,DEPTH\n" ;   
    }
    elsif ($_=~m/##/){
	$_ = $infofield ;
	}
	$line=$_;
	@array=split(/\t/,$line);
	$pos = $array[1] ;	
	$truepos = $pos -500 ;
	my $info= $array[9]	;
	$info =~ s/%//g ;
	@info_fields=split(/:/,$info) ;
	my $calc = $info_fields[6] / 100 ;
	my $depth= $info_fields[3] ;
	if ($truepos < 0 || $truepos > $limit){
		#print "removing overhang var\n"
		}
	else{
	if ($calc gt 0.5){
		$freq = 1-$calc ;
		if ($freq gt $maf){
		print OUT "$array[0],$truepos,$array[4],$array[3],$freq,$depth\n" ;
		}
	}	
	else {
		$freq = $calc ;
		print OUT "$array[0],$truepos,$array[3],$array[4],$freq,$depth\n" ;
		}
	}
	}
	