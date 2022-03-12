# -*- sh -*-
#
# Sanity tests for the table-producing scripts.  Should succeed and produce
# nothing on stdout/stderr
# 

cd ~/local/sarif-cli/data/treeio/2021-12-09
sarif-extract-tables results.sarif test-tables

cd ~/local/sarif-cli/data/treeio
sarif-extract-multi multi-sarif-01.json test-multi-table
