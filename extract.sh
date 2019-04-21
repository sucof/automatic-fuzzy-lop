binwalk -e $1

THEDIR="$(find _*/ -name 'bin' | head -1)"

THISDIR="$(echo $PWD)"

THEARCH="$(file -b -e elf $THEDIR/* | grep -o ','.*',' | tr -d ' ' | tr -d ',' | uniq | tr '[:upper:]' '[:lower:]')"

NEWDIR="$(echo 'firmware-library/'$THEARCH$(echo _*/))"

mkdir $NEWDIR
mkdir $NEWDIR/in/
mkdir $NEWDIR/out/

cp $(afl/testcases/ - type f) in/
cp auto-fuzz.sh $NEWDIR/auto-fuzz.sh

mv $1 $NEWDIR/

cp -r _*/* $NEWDIR/

rm -rf _*/

export CPU_TARGET="$(echo $THEARCH)"

cd afl/qemu_mode/

ORIG_CPU_TARGET="$CPU_TARGET"

test "$CPU_TARGET" = "" && CPU_TARGET="`uname -m`"
test "$CPU_TARGET" = "i686" && CPU_TARGET="i386"

cd qemu-*/

CFLAGS="-O3 -ggdb" ./configure --disable-system \
  --enable-linux-user --disable-gtk --disable-sdl --disable-vnc \
  --target-list="${CPU_TARGET}-linux-user" --enable-pie --enable-kvm || exit 1

echo "[+] Configuration complete."

echo "[*] Attempting to build QEMU (fingers crossed!)..."

make || exit 1

echo "[+] Build process successful!"

echo "[*] Copying binary..."

cp -f "${CPU_TARGET}-linux-user/qemu-${CPU_TARGET}" "../../afl-qemu-trace" || exit 1

cd ..
ls -l ../afl-qemu-trace || exit 1

echo "[+] Successfully created '../afl-qemu-trace'."

if [ "$ORIG_CPU_TARGET" = "" ]; then

  echo "[*] Testing the build..."

  cd ..

  make >/dev/null || exit 1

  gcc test-instr.c -o test-instr || exit 1

  unset AFL_INST_RATIO

  echo 0 | ./afl-showmap -m none -Q -q -o .test-instr0 ./test-instr || exit 1
  echo 1 | ./afl-showmap -m none -Q -q -o .test-instr1 ./test-instr || exit 1

  rm -f test-instr

  cmp -s .test-instr0 .test-instr1
  DR="$?"

  rm -f .test-instr0 .test-instr1

  if [ "$DR" = "0" ]; then

    echo "[-] Error: afl-qemu-trace instrumentation doesn't seem to work!"
    exit 1

  fi

  echo "[+] Instrumentation tests passed. "
  echo "[+] All set, you can now use the -Q mode in afl-fuzz!"

else

  echo "[!] Note: can't test instrumentation when CPU_TARGET set."
  echo "[+] All set, you can now (hopefully) use the -Q mode in afl-fuzz!"

fi

cd ..

sudo make install

cd $THISDIR

echo '###################################################'
echo '#      You only need to run this file again       #'
echo '# if you change the architecture you are fuzzing. #'
echo '###################################################'

exit 0
