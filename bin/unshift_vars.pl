#!/user/bin/perl/

my $variants = $ARGV[0] ;
my $ref = $ARGV[1] ;
open IN, "<".$ref; my @reference=<IN>; close IN ;  
open IN, "<".$variants; my @vars=<IN>; close IN ;  
my $header = $reference[0] ;
my $mito = $reference[1];
my $shift = 7999 ;

			 my $mtlength = length($mito);
			 my $cutoff = $mtlength - $shift;
			
			foreach (@vars) {
						if($_=~m/CHROM/){ 
							@headers=split(/,/,$_) ;							
							print "$headers[0],$headers[1],$headers[3],$headers[4],FREQ,DEPTH\n" ;
												}
						else{ 
						$line=$_;
						@array=split(/,/,$line);
							my $pos = $array[1];
							if ($pos<$cutoff) {
							$oripos = $pos + $shift; }
							elsif ($pos>=$cutoff){ 
								$oripos = $pos + $shift - $mtlength ; }
								$array[1]=$oripos ;
								print "$array[0],$array[1],$array[2],$array[3],$array[4],$array[5]" ;
								}
						}