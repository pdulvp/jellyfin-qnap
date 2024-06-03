#!/bin/bash

VERSION="$1"
BUILD_DEB="$2"
ARCH=$3

mkdir -p .tmp/lib;
if [ -d ".cache/$VERSION-$ARCH/deb" ]; then
  echo -e "\033[0;32mPrefetch dependencies $BUILD_DEB from cache \033[0m"
  cp .cache/$VERSION-$ARCH/deb/* .tmp/lib
  exit 0
fi

echo "Prefetch dependencies $BUILD_DEB"
mkdir -p .tmp/lib-unary;
cp "$BUILD_DEB" .tmp/lib-unary
cd .tmp/lib-unary
ls *.deb | cat > root.txt

getDependencies() {
    DEPENDENCIES=$(dpkg-deb -I "$1" | grep "^ Depends:" | cut -c 11- | sed "s/[ ]//g" | sed "s/[(][^)]*[)]//g" )
    echo "$DEPENDENCIES" | sed -E "s/[|]([a-zA-Z0-9\.\-]+,)/,/g" | tr -s "," "\n" | sort | uniq
}

getInnerLibs() {
    FILE=$(basename $1) 
    mkdir "f_$FILE"
    cd "f_$FILE"
    ar x "../$1" data.tar.xz
    tar xf data.tar.xz ./usr/lib/x86_64-linux-gnu/ 2>/dev/null
    tar xf data.tar.xz ./lib/x86_64-linux-gnu/ 2>/dev/null
    LIBS=$(find . -name "lib*.so*" -exec basename {} \; | grep -v "libLLVM")
    cd ..
    rm -rf "f_$FILE"
    echo "$LIBS" | sort | uniq
}

#for all .deb recursively in the current folder, we fetch dependencies
echo "" > done.txt
while true; do
    cat currentDependencies.txt > dependencies.txt
    rm -f currentDependencies.txt
    echo "       #########################     "
    cat dependencies.txt
    while read line; do
        ISDONE=$(cat done.txt | grep -q $line; echo $?)
        if [ $ISDONE -ne 0 ]; then
            LIBS=$(getInnerLibs $line)
            HASLIBS=$(echo $LIBS | grep -q .so; echo $?)
            LIBFILE=$(basename "$line")
            ISROOT=$(cat root.txt | grep -q "${LIBFILE}$"; echo $?)
            if [ $ISROOT -eq 0 ]; then
                for var in $(getDependencies $line); do
                    apt-get download "$var" -o APT::Architecture=$ARCH
                done

            elif [ $HASLIBS -ne 0 ]; then
                rm -f "$line"
            else
                for var in $(getDependencies $line); do
                    apt-get download "$var" -o APT::Architecture=$ARCH
                done
            fi
            echo "$line" >> done.txt
        fi
    done < dependencies.txt

    find . -type f -name "*.deb" > currentDependencies.txt
     
    F1=$(md5sum dependencies.txt | cut -d" " -f1)
    F2=$(md5sum currentDependencies.txt | cut -d" " -f1)
    echo $F1 $F2
    [[ "$F1" != "$F2" ]] || break;
done

cd ../..
rm .tmp/lib-unary/$BUILD_DEB
mkdir -p .cache/$VERSION-$ARCH/deb;
cp .tmp/lib-unary/* ".cache/$VERSION-$ARCH/deb"
cp .tmp/lib-unary/* ".tmp/lib"
rm -rf .tmp/lib-unary
exit 0
