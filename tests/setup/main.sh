. "${TESTDIR}/setup/lib.sh"

declare TOOL=vencoder.sh

declare -A GLOB_OPTKEYS=(
  [endopt]='--'
  [preset]='-p --preset'
  [conffile]='-f --conffile'
  [genconf]='--genconf'
  [help]='-h -? --help'
  [usage]='--usage'
  [opts]='--opt --opts'
  [presets]='--presets'
  [demo]='--demo'
  [version]='-v --version'
)

declare -A GLOB_PRESETS=(
  [screen]="crf=21"
  [screen720p]="width=1280 crf=21"
)

# pseudo random value, generated with:
# `cat /dev/urandom | tr -dc 'a-z' | fold -w 10 | head -n 1`
declare GLOB_RANDVAL=xqqkwtuesn
