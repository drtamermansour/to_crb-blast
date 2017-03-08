## Start spot instance to test software install and prepare data volumes
#1. select m3.medium
#2. Maximum price= 0.02
sudo apt-get update
sudo apt-get install python2.7-dev python-virtualenv python-pip gcc g++
sudo apt-get install unzip

#sudo pip install --upgrade pip
#virtualenv ENV
#source ENV/bin/activate
wget https://repo.continuum.io/archive/Anaconda2-4.3.0-Linux-x86_64.sh
bash Anaconda2-4.3.0-Linux-x86_64.sh
#sudo pip install biopython
#sudo pip install NumPy
conda install numpy
conda install biopython

## crb-blast
## https://github.com/cboursnell/crb-blast

## install ruby
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/ubuntu/.rvm/scripts/rvm

## https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download
## https://www.ncbi.nlm.nih.gov/books/NBK52640/
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.6.0+-x64-linux.tar.gz
tar zxvpf ncbi-blast-2.6.0+-x64-linux.tar.gz
export PATH=$PATH:$HOME/ncbi-blast-2.6.0+/bin
## first run of crb-blast installed blastplus (2.2.29)...

gem install crb-blast

mkdir workdir && cd workdir
#scp jrosenthal@evol5.mbl.edu:/users/jrosenthal/enrico/assembly/EN3/annotation/EN3.transcriptome.renamed.fasta .
#scp jrosenthal@evol5.mbl.edu:/users/jrosenthal/enrico/assembly/EN3/annotation/uniprot_sprot.fasta .
touch query.fasta query.nin query.nhr query.nsq
touch target.fasta target.psq target.pin target.phr

scp jrosenthal@evol5.mbl.edu:/users/jrosenthal/enrico/assembly/EN3/annotation/EN3.x.uniprot .
scp jrosenthal@evol5.mbl.edu:/users/jrosenthal/enrico/assembly/EN3/annotation/uniprot.x.EN3 .

## conversion of blastall output into tabular format ## target format: outfmt \"6 std qlen slen\"
## Titus parser
#python $HOME/scripts/parse-blast-to-csv.py EN3.x.uniprot > query_into_target.1.blast_comma
#python $HOME/scripts/parse-blast-to-csv.py uniprot.x.EN3 > target_into_query.2.blast_comma
#tr ',' '\t' < query_into_target.1.blast_comma > query_into_target.1.blast
#tr ',' '\t' < target_into_query.2.blast_comma > target_into_query.2.blast

## convert to xml then tab
##https://groups.google.com/forum/#!topic/blast2go/zJJCN-timCg
#cd $HOME/scripts/
#wget https://groups.google.com/group/blast2go/attach/ed2c446e1b1852a9/blast2xml.pl?part=0.1&authuser=0
#mv blast2xml.pl?part=0.1 blast2xml.pl
#cd $HOME/workdir
#perl $HOME/scripts/blast2xml.pl -i EN3.x.uniprot
#cd $HOME/
#git clone https://github.com/knadh/xmlutils.py.git
#cd xmlutils.py
#sudo python setup.py install
##source ~/env/bin/activate
##python setup.py install
#cd $HOME/workdir/
#xml2csv --input EN3.x.uniprot_1.xml --output EN3.x.uniprot.Hit.csv --tag Hit
#xml2csv --input EN3.x.uniprot_1.xml --output EN3.x.uniprot.Iteration.csv --tag Iteration
## another tool to convert xml to tab
##https://github.com/peterjc/galaxy_blast/blob/master/tools/ncbi_blast_plus/blastxml_to_tabular.py

## my parser
cd $HOME/workdir
python $HOME/scripts/textToTabular.py EN3.x.uniprot | tr ',' '\t' > query_into_target.1.blast
python $HOME/scripts/textToTabular.py uniprot.x.EN3 | tr ',' '\t' > target_into_query.2.blast


crb-blast --query query.fasta --target target.fasta --threads 4 --output annotation.tsv


## test module 
mkdir test && cd test
wget https://raw.githubusercontent.com/cboursnell/crb-blast/master/test/query.fasta
wget https://raw.githubusercontent.com/cboursnell/crb-blast/master/test/target.fasta
## generate tabular format using crb-blast run
crb-blast --query query.fasta --target target.fasta --threads 1 --output annotation.tsv
## generate tabular format using direct blast run
blastx -query query.fasta -db target -out quary.x.target_crb -evalue 1e-5 -max_target_seqs 50 -seg no -outfmt "6 std qlen slen"
tblastn -query target.fasta -db query -out target.x.quary_crb -evalue 1e-5 -max_target_seqs 50 -seg no -outfmt "6 std qlen slen"
## generate text format using direct blast run then convert to tabular using my parser
blastx -query query.fasta -db target -out quary.x.target -evalue 1e-5 -max_target_seqs 50 -seg no
tblastn -query target.fasta -db query -out target.x.quary -evalue 1e-5 -max_target_seqs 50 -seg no
python $HOME/scripts/textToTabular.py quary.x.target | tr ',' '\t' > query_into_target.1TM.blast
python $HOME/scripts/textToTabular.py target.x.quary | tr ',' '\t' > target_into_query.2TM.blast

