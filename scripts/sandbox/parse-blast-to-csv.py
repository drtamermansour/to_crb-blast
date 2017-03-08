#! /usr/bin/env python
import sys
import csv
import blastparser

# get the filename as the first argument on the command line
filename = sys.argv[1]

# open it for reading
fp = open(filename)

# send output as comma-separated values to stdout
output = csv.writer(sys.stdout)

# parse BLAST records
for record in blastparser.parse_fp(fp):
    for hit in record:
        for match in hit.matches:
            # output each match as a separate row
            #row = [record.query_name, hit.subject_name, match.score,match.expect]
            row = [record.query_name, hit.subject_name, "pident", "length", "mismatch",	"gapopen", match.query_start, match.query_end, match.subject_start, match.subject_end, match.expect, match.score, "qlen", "slen"]
            output.writerow(row)
