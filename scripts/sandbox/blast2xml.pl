#!/usr/bin/perl
use Getopt::Long;
use File::Path;

my($input, $output, $nbSeqByFile, $nbHitBySeq, $nbHspByHit, $help, $queryByFile);

$help = "

- i|input 	: path of the input file (must be text blast file output)
- o|output	: path of the output file (by default, the same as the input file)
- s|sequences	: number of sequences by xml file (default inf)
- hit		: number of hit to print for each sequences (default inf)
- hsp		: number of hsp to print for each hit (default inf)
- help|h|?	: print this help and exit

";


$nbHitBySeq="inf"+0;
$nbHspByHit="inf"+0;
$queryByFile="inf"+0;

GetOptions( 

	'i|input=s'		=> \$input,
	'o|output=s'		=> \$output,
	's|sequences=s'		=> \$queryByFile,
	'hit=s'			=> \$nbHitBySeq,
	'hsp=s'			=> \$nbHspByHit,
	'help|h|?'		=> sub{print $help; exit}

);
;

if (!$input){print $help; exit}
if (!$output){$output=$input}

open (INPUT_FILE, '< '.$input) or die ("\nCannot read input file: $!\n");
open (OUTPUT_FILE, '> '.$output.'_1.xml') or die ("\nCannot create output file: $!\n");

my $compteurFile=1;
my $compteurQuery=0;
my $compteurHit=0;
my $compteurHsp=0;
my $compteurQueryTotal=0;
my $line = <INPUT_FILE>; 
$line =~ s/[\s\n\r]*$//g;
my($version, $program) = $line=~/(([^\s]+)\s.+)/;
$program=~tr/[A-Z]/[a-z]/;
my $toPrint;

my $header="<?xml version=\"1.0\"?>
<!DOCTYPE BlastOutput PUBLIC \"-//NCBI//NCBI BlastOutput/EN\" \"http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd\">
<BlastOutput>
<BlastOutput_program>$program</BlastOutput_program>
<BlastOutput_version>$version</BlastOutput_version>
<BlastOutput_reference>
Zheng Zhang, Scott Schwartz, Lukas Wagner, and Webb Miller (2000), \"A greedy algorithm for aligning DNA sequences\", J Comput Biol 2000; 7(1-2):203-14.
</BlastOutput_reference>
<BlastOutput_db>$program</BlastOutput_db>
<BlastOutput_query-ID>$output $compteurFile</BlastOutput_query-ID>
<BlastOutput_query-def>$output $compteurFile</BlastOutput_query-def>
<BlastOutput_query-len>1</BlastOutput_query-len>
<BlastOutput_param>
<Parameters>
<Parameters_expect>10</Parameters_expect>
<Parameters_sc-match>1</Parameters_sc-match>
<Parameters_sc-mismatch>-2</Parameters_sc-mismatch>
<Parameters_gap-open>0</Parameters_gap-open>
<Parameters_gap-extend>0</Parameters_gap-extend>
<Parameters_filter>L;m;</Parameters_filter>
</Parameters>
</BlastOutput_param>
<BlastOutput_iterations>";

print OUTPUT_FILE $header;

while (my $line=<INPUT_FILE>){

	$line =~ s/[\s\n\r]*$//g;

	# Bloc Iteration

	if ($line=~/Query= .*\s*/){


		$compteurHit=0;
		$compteurHsp=0;
		$compteurQuery++;
		$compteurQueryTotal++;

		my $queryLength;
		my $seqId;


		while($line && $line !~ />.*/ ){

			$line =~ s/[\s\n\r]*$//g;

			if($line=~/\(([0-9]*) letters\)/g)	{$queryLength = $1}
			elsif($line=~/Query= (.*)\s*/g)		{$seqId = $1};

			$line=<INPUT_FILE>;

		}


$toPrint = "<Iteration>
<Iteration_iter-num>$compteurQuery</Iteration_iter-num>
<Iteration_query-ID>$seqId</Iteration_query-ID>
<BlastOutput_query-def>$seqId</BlastOutput_query-def>
<Iteration_query-len>$queryLength</Iteration_query-len>
<Iteration_hits>";

		if ($compteurQuery > $queryByFile){

			print OUTPUT_FILE "</BlastOutput_iterations>\n</BlastOutput>\n";
			close (OUTPUT_FILE);
	
			$compteurQuery = 0;
			$compteurFile++;

			$toPrint = $header."\n".$toPrint;
			open (OUTPUT_FILE, '> '.$output.'_'.$compteurFile.'.xml') or die ("\nCannot create output file: $!\n");


		}

		print OUTPUT_FILE $toPrint;

	}

	# Bloc Hit

	if ($line=~/^>.*/){

		$compteurHsp=0;
		$compteurHit++;

		my $hitId;
		my $hitDef;
		my $hitAccession="NONE";
		my $length;

		while($line && $line!~/Score =\s+[0-9\.]+ bits \([0-9\.]+\), Expect = .+/){
			
			$line =~ s/[\s\n\r]*$//g;

			if($line=~/Length = (.*)/g)			{$length = $1}
			elsif($line=~/^>*([^\|]*\|*([^\|]+)\|*(.*))/g)	{if ($hitAccession eq "NONE") {$hitAccession = $2}; $hitDef.=$3; $hitId.=$1." ";}

     			$line=<INPUT_FILE>;
		}

		

		if(!$hitDef){$hitDef=$hitId}

$toPrint = "<Hit><Hit_num>$compteurHit</Hit_num>\n<Hit_id>$hitId</Hit_id>
<Hit_def>$hitDef</Hit_def>
<Hit_accession>$hitAccession</Hit_accession>
<Hit_len>$length</Hit_len>";

  		if ($compteurHit<=$nbHitBySeq) {print OUTPUT_FILE $toPrint};
     	}

  	if ($line=~/Score =\s+[0-9\.]+ bits \([0-9\.]+\), Expect = .+/){

		$compteurHsp++;

		my $bitScore;
		my $score;
		my $evalue;
		my $identities;
		my $length;
		my $positive;
		my $gap=0;
		my $qframe=1;
		my $hframe=1;
		my $debutq;
		my $finq;
		my $query;
		my $debuth;
		my $finh;
		my $hit;
		my $midline;
		my $retrait = "";

		do{

			$line =~ s/[\s\n\r]*$//g;

			if($line=~/Frame = \+?([^\+]*)/g)						{$qframe=$1;}
			elsif($line=~/Score =\s+([0-9\.]+) bits \(([0-9\.]+)\), Expect = (.+)/g)	{$bitScore = $1; $score=$2; $evalue=$3;}

			elsif($line=~/Identities = ([0-9]+)\/([0-9]+) \([0-9]+%\), Positives = ([0-9]+)\/[0-9]+ \([0-9]+%\)(, Gaps = ([0-9]+)\/[0-9]+ \([0-9]+%\))*/)		{$identities = $1; $length=$2; $positive=$3; if($5){$gap=$5;}}

			elsif($line=~/(Query:\s+([0-9]+)\s+)([^0-9]+)\s+([0-9]+)/)			{if(!$debutq){$debutq = $2} $query.=$3; $finq=$4; $retrait=length($1)}
			elsif($line=~/Sbjct:\s+([0-9]+)\s+([^0-9]+)\s+([0-9]+)/)			{if(!$debuth){$debuth = $1} $hit.=$2; $finh=$3}

			elsif($line=~/^\s{$retrait,$retrait}(.*)/)					{$midline.= $1}

			$line=<INPUT_FILE>;

		}
    while($line && ($line!~/^>.*/ && $line !~ /Query=/ && $line !~ /Score =\s+[0-9\.]+ bits \([0-9\.]+\), Expect = .+/));
		

$toPrint="<Hit_hsps>
<Hsp_num>$compteurHsp</Hsp_num>
<Hsp_score>$score</Hsp_score>
<Hsp_bit-score>$bitScore</Hsp_bit-score>
<Hsp_evalue>$evalue</Hsp_evalue>
<Hsp_query-from>$debutq</Hsp_query-from>
<Hsp_query-to>$finq</Hsp_query-to>
<Hsp_hit-from>$debuth</Hsp_hit-from>
<Hsp_hit-to>$finh</Hsp_hit-to>
<Hsp_query-frame>$qframe</Hsp_query-frame>
<Hsp_hit-frame>$hframe</Hsp_hit-frame>
<Hsp_identity>$identities</Hsp_identity>
<Hsp_positive>$positive</Hsp_positive>
<Hsp_gaps>$gap</Hsp_gaps>
<Hsp_align-len>$length</Hsp_align-len>
<Hsp_qseq>$query</Hsp_qseq>
<Hsp_hseq>$hit</Hsp_hseq>
<Hsp_midline>$midline</Hsp_midline>
</Hit_hsps>";

		if ($compteurHit <= $nbHitBySeq && $compteurHsp <= $nbHspByHit) {
  			print OUTPUT_FILE $toPrint

		}
 		if (!$line || ($line=~/^>.*/ && $compteurHit < $nbHitBySeq )|| $line=~/Query=/){print OUTPUT_FILE "\n</Hit>\n"}
    if (!$line || $line=~/Query=/ ){print OUTPUT_FILE "\n</Iteration_hits>\n</Iteration>\n"}
 		if ($line){redo} else { print OUTPUT_FILE "</BlastOutput_iterations>\n</BlastOutput>\n"}

	}
 }
  		close (OUTPUT_FILE);
