#!usr/bin/perl -w
  
  foreach $file (@ARGV){
	open IN, "<".$file ; my @seqs = <IN>; close IN;
	
	@seqs = split(/\>/,join('',@seqs)) ;
	if ($seqs[0] =~ m/^[A-Z]/){
		}
	else{shift @seqs }
	
	foreach $seq (@seqs){
		@lines = split(/\R/,$seq) ;
		$header = $lines[0]  ;
		shift @lines ;
		$seq = $header."\n".join('',@lines)."\n" ;
		
		if ($seq =~ m/>/){
				print $seq ;
				}
			else {
				print ">".$seq ;
			}
		}
	
}	