## the script convert the standard text output of blast into the tabular format
## The format is matching to the blast files produced by crb-blast "6 std qlen slen"
## The only differnce is the gapopen column with represent the total no of letters in the gap not the no of gaps

import sys
import csv
import math
from Bio import SearchIO

in_file = sys.argv[1]
in_fmt = 'blast-text'
qresults = SearchIO.parse(in_file, in_fmt)

#for qresult in qresults:
#    print("Search %s has %i hits" % (qresult.id, len(qresult)))

#SearchIO.write(qresults, 'results.tab', 'blast-tab')
#SearchIO.write(qresults, 'results.xml', 'blast-xml')

#out_file = 'results.tab'
#out_fmt = 'blast-tab'
#out_kwarg = {'comments': False}
#SearchIO.convert(in_file, in_fmt, out_file, out_fmt, out_kwargs=out_kwarg)

#output = csv.writer(open("tabular.blast", 'w'))
output = csv.writer(sys.stdout)

# parse BLAST records
for qresult in qresults:
    if "\n" in qresult.id:
        cleanID = qresult.id.split('\n')[0]
    else:
        cleanID = qresult.id

    for hit in qresult:
        for hsp in hit:
            if hsp.gap_num:
                gaps=hsp.gap_num
            else:
                gaps=0
            ident = round((float(hsp.ident_num)/float(hsp.aln_span))*100,2)
            mismatch = hsp.aln_span - hsp.ident_num - gaps
            row = [cleanID, hit.id, ident, hsp.aln_span, mismatch, gaps, hsp.query_start+1, hsp.query_end, hsp.hit_start+1, hsp.hit_end, hsp.evalue, hsp.bitscore, qresult.seq_len, hit.seq_len]
            output.writerow(row)


