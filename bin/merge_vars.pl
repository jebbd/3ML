#!/user/bin/perl/

$in1 = "$ARGV[0]" ;
$in2 = "$ARGV[1]" ;
open IN, "<".$in1 ; my @in_fir=<IN> ; close IN ;
open IN, "<".$in2 ; my @in_sec=<IN> ; close IN ;
$header_fir = shift @in_fir ;
shift @in_sec ;
$len_sec = scalar(@in_sec) ;
$len_fir = scalar(@in_fir) ; 

print $header_fir ;


foreach $infir (@in_fir) {
	@het1 = split(/,/,$infir) ;
	$pos1 = $het1[1] ;
	$alt1 = $het1[3] ;
	$freq1 = $het1[4] ;
	$dep1 = $het1[5] ; 
	$mismatch_check1 = 0 ;
	
	 foreach $insec (@in_sec) {
	 @het2 = split(/,/,$insec) ;
	$pos2 = $het2[1] ;
	$alt2 = $het2[3] ;
	$freq2 = $het2[4] ;
	$dep2 = $het2[5] ;
	$match_count1 = 0;
	$mismatch_count1 = 0;
	if ($pos1 ne $pos2) { $mismatch_count1 ++ }
	if ($pos1 eq $pos2 && $alt1 eq $alt2) {
			$match_count1 ++ }

	if ($mismatch_count1 == 1 ) { $mismatch_check1 ++ ;}
	if ($match_count1 == 1) { $av_freq = ($freq1 + $freq2) /2 ;
							$av_dep = ($dep1 + $dep2) /2 ;
							print "$het1[0],$pos1,$het1[2],$alt1,$av_freq,$av_dep\n" ;}
	if ($mismatch_check1 == $len_sec) { print "$infir"} 						
		}
}

 
foreach $insec (@in_sec) {
@het2 = split(/,/,$insec) ;
$pos2 = $het2[1] ;
$alt2 = $het2[3] ;
$freq2 = $het2[4] ;
$dep2 = $het2[5] ;
$mismatch_check2 = 0 ;

	foreach $infir (@in_fir) {
	@het1 = split(/,/,$infir) ;
	$pos1 = $het1[1] ;
	$alt1 = $het1[3] ;
	$freq1 = $het1[4] ;
	$dep1 = $het1[5] ;
	$match_count2 = 0;
	$mismatch_count2 = 0;
	if ($pos1 ne $pos2) { $mismatch_count2 ++ }
	if ($pos1 eq $pos2 && $alt1 eq $alt2) {
			$match_count2 ++ }
	if ($mismatch_count2 == 1 ) { $mismatch_check2 ++ ;}
	if ($mismatch_check2 == $len_fir) { print "$insec"} 
		}
}