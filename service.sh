while [[ "$(getprop sys.boot_completed)" != 1 ]]; do
    sleep 1
done
pm install "${0%/*}/xposed.apk"