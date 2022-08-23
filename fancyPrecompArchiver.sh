calc() {
  echo "scale=2;$@" | bc -l
}

tam() {
    du -B1 -cs "$1" | tail -1 | cut -f1
}

cbs_wim_Precomp_fazip_srep_fxz() {
    echo Creating Archive...

    SECONDS=0
    BYTES=$(tam "$1")
    FOLDER=$PWD

    wimlib-imagex capture "$1" - --compress=none --unix-data --pipable 2>/dev/null \
    | pv -ptebac -s "$BYTES" -N " WIM image " >$1.wim

    echo -e "\nPre-processing with precomp..."
        sleep 1 && (pushd /dev/shm && precomp -e -cn -intense $FOLDER/$1.wim ; popd ) \
        | grep -i --color=never streams >/dev/shm/$1.wim.pcf.log \
        | pv -pteba -d $(sleep 1 && echo $(pidof precomp)):3 -N " Progress  " &&
        bat --color=always /dev/shm/$1.wim.pcf.log | grep -v File
    echo Done! $((($BYTES/1000)/($SECONDS))) kbps, $(calc 100*$(tam "$1.wim.pcf")/$(tam "$1.wim")) \%
    rm $1.wim /dev/shm/$1.wim.pcf.log

    echo -e "\nCompressing:"
        PREBYTES=$(du -bs "$1.wim.pcf" | tail -1 | cut -f1)
        cat $1.wim.pcf \
        | pv -ptebac -s $(sleep 0.1 && echo $PREBYTES) -N  " Reading    " \
        | wine fazip rep+dispack+delta 2>/dev/null \
        | pv -ptebacW -s $(sleep 0.3 && echo $PREBYTES) -N " filters    " \
        | srep -m3f -s$PREBYTES 2>/dev/null \
        | pv -ptebacW -s $(sleep 0.6 && echo $PREBYTES) -N " srep dedupe" \
        | fxz -z -9 -e -v -T0 --lzma2=dict=1073741824 2>/dev/null \
        | pv -ptebacW -s $(sleep 0.9 && echo    $BYTES) -N " fast-lzma2 " >"$1.wPfsf" &&
        rm "$1.wim.pcf"

    duration=$SECONDS
    echo -e "\nDone! Total $((($BYTES/1000)/($duration))) kbps, $(calc 100*$(tam "$1.wPfsf")/$BYTES) %"
}
