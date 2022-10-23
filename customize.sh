
SKIPUNZIP=1

do_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" "$API/$ARCH/*" XposedBridge.90.jar XposedBridge.89.jar -d $TMPDIR >&2

  XPOSEDDIR=$TMPDIR/$API/$ARCH
  [ -d $XPOSEDDIR ] || abort "! Unsupported device"

  if [ $API -ge 26 ]; then
    XVERSION="90-beta3"
    XPOSEDBRIDGE="XposedBridge.90.jar"
  else
    XVERSION="89"
    XPOSEDBRIDGE="XposedBridge.89.jar"
  fi

  ui_print "- Xposed version: $XVERSION"
  ui_print "- Device platform: $ARCH"

  ui_print "- Copying files"
  mkdir -p $MODPATH/system/framework
  mv $TMPDIR/$XPOSEDBRIDGE $MODPATH/system/framework/XposedBridge.jar
  cp -af $XPOSEDDIR/system/. $MODPATH/system
  cat << EOF > $MODPATH/xposed.prop
version=${XVERSION}
arch=${ARCH}
minsdk=${API}
maxsdk=${API}
EOF
  [ $API -ge 26 ] && echo "requires:fbe_aware=1" >> $MODPATH/xposed.prop
  unzip -o "$ZIPFILE" post-fs-data.sh service.sh xposed.apk module.prop -d $MODPATH >&2
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  set_perm_recursive  $MODPATH/system/bin           0   2000    0755    0755
  set_perm_check  $MODPATH/system/bin/app_process32       0   2000    0755    u:object_r:zygote_exec:s0
  set_perm_check  $MODPATH/system/bin/app_process64       0   2000    0755    u:object_r:zygote_exec:s0
  set_perm_check  $MODPATH/system/bin/dex2oat             0   2000    0755    u:object_r:dex2oat_exec:s0
  set_perm_check  $MODPATH/system/bin/patchoat            0   2000    0755    u:object_r:zygote_exec:s0
  set_perm_check  $MODPATH/system/bin/dexoptanalyzer      0   2000    0755    u:object_r:dexoptanalyzer_exec:s0
  set_perm_check  $MODPATH/system/bin/profman             0   2000    0755    u:object_r:profman_exec:s0
}

# You can add more functions to assist your custom script code

set_perm_check() {
  [ -f "$1" ] || return
  set_perm "$@"
}

do_install
set_permissions