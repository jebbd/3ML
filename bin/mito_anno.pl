#!usr/bin/perl -w

my %aminoacids =(TTT => "F", TTC => "F", TTA => "L", TTG => "L",
  TCT => "S", TCC => "S", TCA => "S", TCG => "S",
  TAT => "Y", TAC => "Y", TAA => "STOP", TAG => "STOP",
  TGT => "C", TGC => "C", TGA => "W", TGG => "W",
  CTT => "L", CTC => "L", CTA => "L", CTG => "L",
  CCT => "P", CCC => "P", CCA => "P", CCG => "P",
  CAT => "H", CAC => "H", CAA => "Q", CAG => "Q",
  CGT => "R", CGC => "R", CGA => "R", CGG => "R",
  ATT => "I", ATC => "I", ATA => "M", ATG => "M",
  ACT => "T", ACC => "T", ACA => "T", ACG => "T",
  AAT => "N", AAC => "N", AAA => "K", AAG => "K",
  AGT => "S", AGC => "S", AGA => "STOP", AGG => "STOP",
  GTT => "V", GTC => "V", GTA => "V", GTG => "V",
  GCT => "A", GCC => "A", GCA => "A", GCG => "A",
  GAT => "D", GAC => "D", GAA => "E", GAG => "E",
  GGT => "G", GGC => "G", GGA => "G", GGG => "G", );
  
 my $mitogenome = $ARGV[0] ;
open IN, "<".$mitogenome ; my @ref=<IN> ; close IN;
$genome = $ref[1] ;

my $anno_file = $ARGV[1] ;
open IN, "<".$anno_file; my @annotations=<IN> ; close IN;
$feat_count=0 ;
foreach $annotation(@annotations) {
if($annotation =~ m/Primer/){
	$annotation =~ s/\R//g;
	push (@primers, $annotation) ;
	$primer_count ++ ;
	}
else{
	$annotation =~ s/\R//g;
	push (@features, $annotation) ;
	$feat_count ++ ;
	}
	}
foreach $primer (@primers) {
@array = split(/\t/, $primer);
$start = $array [1] ;
$end = $array [2] ;
push (@primer_starts, $start);
push (@primer_ends, $end);
}
foreach $feature (@features) {
@foo = split(/\t/, $feature);
$name = $foo[0] ;
$start = $foo[1] ;
$end = $foo[2] ;
push (@feat_names, $name) ;
push (@feat_starts, $start);
push (@feat_ends, $end)
} 

my $var_file = $ARGV[2] ;	
$var_file =~ /[A-Za-z0-9_\/]+/ ;
$sample = $& ;
open IN, "<".$var_file ; my @unfil_vars=<IN> ; close IN;	
foreach $entry (@unfil_vars) {
if ($entry =~ m/CHROM/) { $entry =~ s/\R//g ;
							push (@unanno_vars, $entry) }
else{
	my @vals=split(/,/,$entry) ;
	$pos = $vals[1] ;
	my $check = 0 ;
	for ($j = 0 ; $j < $primer_count ; $j ++) {
		if ($pos >= $primer_starts[$j] && $pos <= $primer_ends[$j]){
			$check++ ;
			last ;
			}
		else {
			next ;
			}
		}
	if ($check == 0){$entry =~ s/\R//g ;
							push (@unanno_vars, $entry) }
}
}
							
foreach $entry (@unanno_vars){
	if ($entry =~ m/CHROM/) { $entry =~ s/\R//g ;						
							print "$entry,FEATURE,CODON,Ref_codon,Ref_AA,Alt_codon,Alt_AA,Syn/Nonsyn\n" ;
							}
	else{
		$entry =~ s/\R//g ;
		@values = split (/,/,$entry) ;
		$posv = $values[1] ;
		$posc = $posv-1 ;
		$alt = $values[3] ;
		$values[0] = $sample ;
		$entry = join(",",@values) ;	
		for ($m = 0 ; $m < $feat_count ; $m ++) { 
		if ($posv >= $feat_starts[$m] && $posv <= $feat_ends[$m]) {
		
		$locus = $feat_names[$m] ;
		
	
	if ($locus =~ m/RNA/ or $locus =~ m/loop/i or $locus =~ m/region/i) {
														print "$entry,$locus,N/A,N/A,N/A,N/A,N/A,N/A\n" ;
														 }	
	elsif ($locus =~ m/ND6/i){
			
			if ( ($feat_ends[$m] - $posv +1) %3 == 0 ) {$codon = "3rd"} 
			elsif ( ($feat_ends[$m] - $posv +2) %3 == 0 ) {$codon = "2nd"} 
			elsif ( ($feat_ends[$m] - $posv) %3 == 0 ) {$codon = "1st"} 
			
								
		if ($codon =~ m/3/) { $refcodon = substr($genome,$posc,3) ;
								$codends = substr($refcodon,1,2) ;
								$newcodon = "$alt$codends" ;
								$revrefcod = reverse($refcodon) ;		
								$revnewcod = reverse($newcodon) ;
								$revrefcod =~ tr/ATCGatcg/TAGCtagc/ ; 
								$revnewcod =~ tr/ATCGatcg/TAGCtagc/ ;	
								$ref_aa = $aminoacids{$revrefcod} ;
								$alt_aa = $aminoacids {$revnewcod} ;
								if ($ref_aa ne $alt_aa) {$nsy = "Nonsynonomous" }
								elsif ($ref_aa eq $alt_aa) {$nsy = "Synonomous" } 								
								print "$entry,$locus,$codon,$revrefcod,$ref_aa,$revnewcod,$alt_aa,$nsy\n"}
		elsif ($codon =~ m/2/) {$firpos = $posc -1 ;
							 $refcodon = substr($genome,$firpos,3) ;
							 $firbase = substr($refcodon,0,1) ;
							 $thrbase = substr($refcodon,2,1) ;
							 $newcodon = "$firbase$alt$thrbase" ;
							 $revrefcod = reverse($refcodon) ;		
								$revnewcod = reverse($newcodon) ;
								$revrefcod =~ tr/ATCGatcg/TAGCtagc/ ; 
								$revnewcod =~ tr/ATCGatcg/TAGCtagc/ ;	
								$ref_aa = $aminoacids{$revrefcod} ;
								$alt_aa = $aminoacids {$revnewcod} ;
							 if ($ref_aa ne $alt_aa) {$nsy = "Nonsynonomous" }
							 elsif ($ref_aa eq $alt_aa) {$nsy = "Synonomous" } 							 
							 print "$entry,$locus,$codon,$revrefcod,$ref_aa,$revnewcod,$alt_aa,$nsy\n"}
		elsif ($codon =~ m/1/)	{$firpos = $posc -2 ;
							 $refcodon = substr($genome,$firpos,3) ;
							 $firbase = substr($refcodon,0,1) ;
							 $secbase = substr($refcodon,1,1) ;
							 $newcodon = "$firbase$secbase$alt" ;
							 $revrefcod = reverse($refcodon) ;		
								$revnewcod = reverse($newcodon) ;
								$revrefcod =~ tr/ATCGatcg/TAGCtagc/ ; 
								$revnewcod =~ tr/ATCGatcg/TAGCtagc/ ;	
								$ref_aa = $aminoacids{$revrefcod} ;
								$alt_aa = $aminoacids {$revnewcod} ;
							 if ($ref_aa ne $alt_aa) {$nsy = "Nonsynonomous" }
							 elsif ($ref_aa eq $alt_aa) {$nsy = "Synonomous" }							 
							 print "$entry,$locus,$codon,$revrefcod,$ref_aa,$revnewcod,$alt_aa,$nsy\n" }

		else {
			}
	} 

else{

		if ( ($posv - $feat_starts[$m]) %3 == 0 ) {$codon = "1st"} 
		elsif ( ($posv - $feat_starts[$m] -1) %3 == 0 ) {$codon = "2nd"} 
		elsif ( ($posv - $feat_starts[$m] -2) %3 == 0 ) {$codon = "3rd"} 
	
	if ($codon =~ m/1/) { $refcodon = substr($genome,$posc,3) ;
								$codends = substr($refcodon,1,2) ;
								$newcodon = "$alt$codends" ;	
								$ref_aa = $aminoacids{$refcodon} ;
								$alt_aa = $aminoacids{$newcodon} ;
								if ($ref_aa ne $alt_aa) {$nsy = "Nonsynonomous" }
								elsif ($ref_aa eq $alt_aa) {$nsy = "Synonomous" } 								
								print "$entry,$locus,$codon,$refcodon,$ref_aa,$newcodon,$alt_aa,$nsy\n"}
	elsif ($codon =~ m/2/) {$firpos = $posc -1 ;
							 $refcodon = substr($genome,$firpos,3) ;
							 $firbase = substr($refcodon,0,1) ;
							 $thrbase = substr($refcodon,2,1) ;
							 $newcodon = "$firbase$alt$thrbase" ;
							 $ref_aa = $aminoacids{$refcodon} ;
							 $alt_aa = $aminoacids {$newcodon} ;
							 if ($ref_aa ne $alt_aa) {$nsy = "Nonsynonomous" }
							 elsif ($ref_aa eq $alt_aa) {$nsy = "Synonomous" } 							 
							 print "$entry,$locus,$codon,$refcodon,$ref_aa,$newcodon,$alt_aa,$nsy\n"}
	elsif ($codon =~ m/3/)	{$firpos = $posc -2 ;
							 $refcodon = substr($genome,$firpos,3) ;
							 $firbase = substr($refcodon,0,1) ;
							 $secbase = substr($refcodon,1,1) ;
							 $newcodon = "$firbase$secbase$alt" ;
							 $ref_aa = $aminoacids{$refcodon} ;
							 $alt_aa = $aminoacids {$newcodon} ;
							 if ($ref_aa ne $alt_aa) {$nsy = "Nonsynonomous" }
							 elsif ($ref_aa eq $alt_aa) {$nsy = "Synonomous" }							 
							 print "$entry,$locus,$codon,$refcodon,$ref_aa,$newcodon,$alt_aa,$nsy\n" }

	else {
		}

}

		}	
}
}

}