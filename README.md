# CLI tools for SARIF processing 

  Each of these tools present a high-level command-line interface to extract a
  specific subset of information from a SARIF file. The main tools are: `sarif-extract-scans-runner`,`sarif-aggregate-scans`,`sarif-create-aggregate-report`. 
  
  Each tool can print its options and description like: `sarif-extract-scans-runner --help`.

  The tool was implemented using Python 3.9.

# Sarif format information

  The tool operates on sarif generated by LGTM 1.27.0 (by default) or by the CodeQL CLI (enabled with the -f flag given a value of `CLI`). The supported sarif is [SARIF v2.1.0](https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html).

  The values that the -f flag accepts are: `LGTM` and `CLI`.

  The CLI versions used against development of the CLI support were: 2.6.3, 2.9.4, and 2.11.4.

  The CLI sarif **MUST** contain one additional property `versionControlProvenance` - which needs to look like:
  ```
  "versionControlProvenance": [
        {
          "repositoryUri": "https://github.com/testorg/testrepo.git",
          "revisionId": "testsha"
        }
      ]
  ```

# Test Setup
  This repository includes some test data (in `data`) and uses =git lfs= for storing those test files; installation steps are at
  [[https://git-lfs.github.com][git-lfs]]; on a mac with homebrew, install it via
  #+BEGIN_SRC sh
    brew install git-lfs
    git lfs install
  #+END_SRC

# Tool Setup
Set up the virtual environment and install the packages:
 ```
   python3.9 -m venv .venv
  . .venv/bin/activate
  ```

  ### For development
 ```
  # Use requirementsDEV.txt 
  python -m pip install -r requirementsDEV.txt
  ```

  ### For distribution
  ```
    # Use requirements.txt 
    python -m pip install -r requirements.txt
   ```

  Then install:
  ```
  pip install -e .
  ```

# Tool Use

## sarif-extract-scans-runner
   Parses the SARIF results into a result set of 4 csvs located under a directory structure like: 
  ```
  ├── results-log.scanlog
  ├── results-log.csv
  ├── results.sarif.scanspec
    ├── results.sarif.scantables
        ├── codeflows.csv
        ├── projects.csv
        ├── results.csv
        └── scans.csv
  ```

  where `codeflows.csv`,`projects.csv`, `results.csv`, `scans.csv` are the consumable parsed output of the analysis. 
  
  `results-log.scanlog` contains a raw log of any errors encountered while parsing the sarif and `results-log.csv` contains a summary of the scanlog contents.

  ### sample usage:
  ```
  python bin/sarif-extract-scans-runner sarif-files.txt -o <outer-level-results-directory>
  ```

  where `cat sarif-files.txt` contains sarif files to process, each entry of the form `<org>/<project>` and separated by newline, like:
  ```
  data/wxWidgets_wxWidgets__2021-11-21_16_06_30__export.sarif
  data/torvalds_linux__2021-10-21_10_07_00__export.sarif
  ```

## sarif-aggregate-scans
  Parses the `codeflows.csv`,`projects.csv`, `results.csv`, `scans.csv` files generated for some batch of input sarifs and creates a final set of `codeflows.csv`,`projects.csv`, `results.csv`, `scans.csv` files aggregating all of the contents across those sarif files.

  ### sample usage:
  ```
  python bin/sarif-aggregate-scans sarif-files.txt <combined-tables-output directory>
  ```

## sarif-pad-aggregate
  **Optional** Post-fills the `scans.csv` file with more realisitic (but still fake) values for the following columns: `db_create_start`,`db_create_stop`,`scan_start_date`,`scan_stop_date`. These values are not in the input sarif and it may be beneficial to have date values near the present. Otherwise `sarif-extract-scans-runner` will have populated these columns with the value `1970-01-01`.

  ### sample usage:
  ```
  python bin/sarif-pad-aggregate <combined-tables-output directory> <padded-combined-tables-output directory>
  ```

## sarif-create-aggregate-report
  Parses the `results-log.csv` files generated for some batch of input sarifs and creates a final summary report in `summary-report.csv` (unless otherwise specified).

  ### sample usage:
  ```
  python bin/sarif-create-aggregate-report sarif-files.txt -in <outer-level-results-directory-to-summarize>
  ```

# Sample Data Information
  The query results in =data/= are taken from lgtm.com, which ran the
  : ql/$LANG/ql/src/codeql-suites/$LANG-lgtm.qls
  queries.

  The linux kernel has both single-location results (="kind": "problem"=) and path
  results (="kind": "path-problem"=).  It also has results for multiple source
  languages.

  The subset of files referenced by the sarif results is in =data/linux-small/=
  and is taken from 
  ```
    "versionControlProvenance": [
        {
            "repositoryUri": "https://github.com/torvalds/linux.git",
            "revisionId": "d9abdee5fd5abffd0e763e52fbfa3116de167822"
        }
    ]
  ```

  The wxWidgets library has both single-location results (="kind": "problem"=) and path
  results (="kind": "path-problem"=). 

  The subset of files referenced by the sarif results is in =data/wxWidgets-small/=
  and is taken from 

```
    "repositoryUri": "https://github.com/wxWidgets/wxWidgets.git",
    "revisionId": "7a03d5fe9bca2d2a2cd81fc0620bcbd2cbc4c7b0"
 ```

