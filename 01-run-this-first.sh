#!/bin/bash
#
# Dependencies for afl and auto-fuzz
sudo apt-get install -y git binwalk qemu-user libtool wget python autoconf libtool-bin automake bison libglib2.0-dev

# Dependencies specifically for sasquatch
sudo apt-get install -y build-essential liblzma-dev liblzo2-dev zlib1g-dev

THISDIR="$(echo $PWD)"

# Commented this out, as I decided to host my own tweaked AFL, 
# but if you want default AFL, get it here
# Grab latest version of AFL
#wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
# Unpack it
#tar -xvf afl-latest.tgz

# This is to future proof the script (in case the latest version changes)
#rm afl-latest.tgz
#mv afl* afl/
cd afl/ #clever, huh?

# We have to make it before we do anything else 
# (for reasons we can talk about, but are outside the scope
# of these comments...).
sudo make

cd qemu_mode

# Decided to host my own version of QEMU
# So I've commented out the lines to grab a new copy
#VERSION="2.10.0"
#QEMU_URL="http://download.qemu-project.org/qemu-${VERSION}.tar.xz"
#QEMU_SHA384="68216c935487bc8c0596ac309e1e3ee75c2c4ce898aab796faa321db5740609ced365fedda025678d072d09ac8928105"

# Dealing with QEMU now
if [ ! "`uname -s`" = "Linux" ]; then

  echo "[-] Error: QEMU instrumentation is supported only on Linux."
  exit 1

fi

if [ ! -f "patches/afl-qemu-cpu-inl.h" -o ! -f "../config.h" ]; then

  echo "[-] Error: key files not found - wrong working directory?"
  exit 1

fi

if [ ! -f "../afl-showmap" ]; then

  echo "[-] Error: ../afl-showmap not found - compile AFL first!"
  exit 1

fi

for i in libtool wget python automake autoconf sha384sum bison iconv; do

  T=`which "$i" 2>/dev/null`

  if [ "$T" = "" ]; then

    echo "[-] Error: '$i' not found, please install first."
    exit 1

  fi

done

#ARCHIVE="`basename -- "$QEMU_URL"`"
#CKSUM=`sha384sum -- "$ARCHIVE" 2>/dev/null | cut -d' ' -f1`

#if [ ! "$CKSUM" = "$QEMU_SHA384" ]; then
#
#  echo "[*] Downloading QEMU ${VERSION} from the web..."
#  rm -f "$ARCHIVE"
#  wget -O "$ARCHIVE" -- "$QEMU_URL" || exit 1
#
#  CKSUM=`sha384sum -- "$ARCHIVE" 2>/dev/null | cut -d' ' -f1`
#
#fi

#if [ "$CKSUM" = "$QEMU_SHA384" ]; then
#
#  echo "[+] Cryptographic signature on $ARCHIVE checks out."
#
#else
#
#  echo "[-] Error: signature mismatch on $ARCHIVE (perhaps download error?)."
#  exit 1
#
#fi

#echo "[*] Uncompressing archive (this will take a while)..."

#rm -rf "qemu-${VERSION}" || exit 1
#tar xf "$ARCHIVE" || exit 1

#cd qemu-*/ || exit 1

#echo "[*] Applying patches..."

#patch -p1 <../patches/elfload.diff || exit 1
#patch -p1 <../patches/cpu-exec.diff || exit 1
#patch -p1 <../patches/syscall.diff || exit 1

#echo "[+] Patching done."

cd $THISDIR

mkdir firmware-library/

echo '################################################'
echo '#   All done with Dependencies and AFL make.   #'
echo '#         Find a target and auto-fuzz!         #'
echo '################################################'
