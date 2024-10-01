# maw-incompletes

## incompletes checker

This script aims to reduce the amount of things that get nuked for being incomplete by rather trying to go for completion and pointing out what's missing where.

The supplied dist config is hopefully enough to get the gist of what needs to be configured.

### Requirements

- Python 3
- SQLite3

### Installation

- copy `config.yaml.dist` to `config.yaml`
- adjust `config.yaml` to match your environment regarding paths and settings
- adjust `incompletes.tcl` if you want to use the eggdrop counterpart to match your paths
- make sure your eggdrop loads `incompletes.tcl` if you choose to use it
- set up a cronjob to run the incompletes checker regularly

```bash
# update incomplete symlinks every 5 minutes
*/5 * * * *     /opt/scripts/maw-incompletes/incompletes.py --silent /opt/scripts/maw-incompletes/config.yaml SYSOP
# update incomplete symlinks and post about the status of the incompletes to IRC by abusing the TURGEN chain already configured in pzs-ng
0 */6 * * *     /opt/scripts/maw-incompletes/incompletes.py /opt/scripts/maw-incompletes/config.yaml TURGEN
```

### Usage

```bash
usage: incompletes.py [-h] [--silent] config chain

positional arguments:
  config      path to config file
  chain       the output destination of this announce

optional arguments:
  -h, --help  show this help message and exit
  --silent    no output to glftpd.log
  ```

When using `--silent` the script will only print to stdout.
Without using `--silent` the script will write all output to the specified `chain` in `glftpd.log` to make `pzs-ng` pick it up and print to IRC.

### Example

```
Please complete the following releases:
    /recent/movies-1080/Some.cool.Movie.2022.1080p.WEB.x264-GROUP lacks sample, was sent by someuser/somegroup.
    /recent/movies-1080/Some.other.decent.Movie.2022.1080p.WEB.x264-GROUP lacks nfo/completeness, was sent by someuser/somegroup.
```

### Changelog

#### 2024-10-01
- Extra loops for DATED dirs, ghetto workaround, sue me.

#### 2024-07-25

- Add .wmv as valid extension for sample

#### 2023-11-30

- Add cleanup of dead symlinks in incompletes folder

#### 2023-07-23

- Add support for diz/zip releases

#### 2022-01-19

- Only write to log/irc if there is anything to complete, reduce noise

#### 2022-01-18

- Consider dirs and files for complete check
- Add `skip_paths` option to exclude paths from being checked

#### 2022-01-17

- Initial release
