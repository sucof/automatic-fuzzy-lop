echo 'core' | sudo tee /proc/sys/kernel/core_pattern

THISDIR="$(echo $PWD)"

TARGETDIR="$(find ./ -name 'bin' | head -1)/"

cd $TARGETDIR
cd ..

export QEMU_LD_PREFIX="$(echo $PWD)"

cd $THISDIR

#COUNTER=0
#
#BINARIES="
#$(for BIN in $TARGETDIR*; do
#  TYPE="$(file $BIN)"
#  TEST="$(echo $TYPE | grep -E 'ARM|busybox')"
#  if [ ! "$TEST" = "" ]; then
#    COUNTER="$(expr $COUNTER + 1)"
#
#    echo "[$COUNTER] $(basename "$BIN")"
#  fi
#done)"

# echo $BINARIES

# printf "\nEnter the name of the program you want to fuzz: "
# read FUZZ

# You MUST pass a value in for '-m'
# '4G' seems to work most of the time
# If you are fuzzing a binary that takes input
# directly from stdin, then use the third
# parameter by adding '@@' to the end of your
# call. Like this:
# ./auto-fuzz.sh /path/to/binary 4G @@
afl-fuzz -Q -m $2 -i in/ -o out/ $1 $3

# afl-fuzz -Q -m 4G -i in/ -o out/ $TARGETDIR/$FUZZ
