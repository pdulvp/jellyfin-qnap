#!/bin/bash


rm -rf .tmp; mkdir .tmp;
mkdir -p "$2"
cp "$1" .tmp
cd .tmp
ls *.deb | cat > root.txt

ssh 192.168.1.18 -l admin 'ldconfig -p | while read -r i; do TOTO=`echo $i | cut -d= -f2 | cut -d\> -f2`; readlink ${TOTO}; done;' | sort | uniq > existing.txt


getDependencies() {
    DEPENDENCIES=`dpkg-deb -I "$1" | grep "^ Depends:" | cut -c 11- | sed "s/[ ]//g" | sed "s/[(][^)]*[)]//g" `
    echo "$DEPENDENCIES" | sed -E "s/[|]([a-zA-Z0-9\.\-]+,)/,/g" | tr -s "," "\n" | sort | uniq
}

getInnerLibs() {
    FILE=`basename $1` 
    mkdir "f_$FILE"
    cd "f_$FILE"
    ar x "../$1" data.tar.xz
    tar xf data.tar.xz ./usr/lib/x86_64-linux-gnu/
    tar xf data.tar.xz ./lib/x86_64-linux-gnu/
    LIBS=`find . -name "lib*.so*" -exec basename {} \; | grep -v "libLLVM"`
    cd ..
    rm -rf "f_$FILE"
    echo "$LIBS" | sort | uniq
}

#for all .deb recursively in the current folder, we fetch dependencies
echo "" > done.txt
while true; do
    cat dependencies2.txt > dependencies.txt
    rm -f dependencies2.txt
    echo "       #########################     "
    cat dependencies.txt
    while read line; do
        ISDONE=`cat done.txt | grep -q $line; echo $?`
        if [ $ISDONE -ne 0 ]; then
            LIBS=`getInnerLibs $line`
            HASLIBS=`echo $LIBS | grep -q .so; echo $?`
            echo "  Root: $1  : $line  "
            LIBFILE=`basename "$line"`
            ISROOT=`cat root.txt | grep -q "${LIBFILE}$"; echo $?`
            if [ $ISROOT -eq 0 ]; then
                echo "  Is Root"
                echo "=> $line: FETCH"
                for var in `getDependencies $line`; do
                    apt-get download "$var" 
                done

            elif [ $HASLIBS -ne 0 ]; then
                echo "   No FoundLibs  : USELESS  "
                rm -f "$line"
            else
                echo "  FoundLibs   "
                echo "$line"
                FETCH=0
                for var in $LIBS; do
                    LIBEXIST=`cat existing.txt | grep -q "${var}$"; echo $?`
                    echo "-> $var: $LIBEXIST"
                    if [ $LIBEXIST -ne 0 ]; then
                        FETCH=1
                    fi
                done

                if [ $FETCH -eq 1 ]; then
                    echo "=> $line: FETCH"
                    for var in `getDependencies $line`; do
                        apt-get download "$var" 
                    done
                else
                    rm -f "$line"
                fi
            fi
            echo "$line" >> done.txt
        fi
    done < dependencies.txt

    find . -type f -name "*.deb" > dependencies2.txt
     
    F1=`md5sum dependencies.txt | cut -d" " -f1`
    F2=`md5sum dependencies2.txt | cut -d" " -f1`
    echo $F1 $F2
    [[ "$F1" != "$F2" ]] || break;
done

echo "       #########################     "
for file in `find . -type f -name "*.deb"`; do
    echo "--- $file"
    ar x $file data.tar.xz
    tar xvf data.tar.xz ./usr/lib/x86_64-linux-gnu/
    tar xvf data.tar.xz ./lib/x86_64-linux-gnu/
    rm -f *.tar.xz
done

cd ..
mv .tmp/usr/lib/x86_64-linux-gnu/* "$2"
mv .tmp/lib/x86_64-linux-gnu/* "$2"
