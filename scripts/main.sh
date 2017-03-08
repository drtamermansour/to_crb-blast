## Start m3.medium Amazon instance

## software installation: Please run one line at a time and responde to the prompt (always accept).
sudo apt-get update
wget https://repo.continuum.io/archive/Anaconda2-4.3.0-Linux-x86_64.sh
bash Anaconda2-4.3.0-Linux-x86_64.sh
source ~/.bashrc
conda install numpy
conda install biopython
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/ubuntu/.rvm/scripts/rvm
gem install crb-blast

git clone https://github.com/drtamermansour/to_crb-blast.git
cd to_crb-blast
workPath=$(pwd)

cd $workPath/workdir
## download blast output files
scp jrosenthal@evol5.mbl.edu:/users/jrosenthal/enrico/assembly/EN3/annotation/EN3.x.uniprot .
scp jrosenthal@evol5.mbl.edu:/users/jrosenthal/enrico/assembly/EN3/annotation/uniprot.x.EN3 .

## run the parser
python $workPath/scripts/textToTabular.py EN3.x.uniprot | tr ',' '\t' > query_into_target.1.blast
python $workPath/scripts/textToTabular.py uniprot.x.EN3 | tr ',' '\t' > target_into_query.2.blast

## create the Conditional Reciprocal blast report
crb-blast --query query.fasta --target target.fasta --threads 4 --output annotation.tsv


