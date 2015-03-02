# vim:syntax=apparmor

#include <tunables/global>

# Specified profile variables
###VAR###

###PROFILEATTACH### (attach_disconnected) {
  #include <abstractions/base>
  #include <abstractions/consoles>
  #include <abstractions/openssl>

  # for python apps/services
  #include <abstractions/python>
  /usr/bin/python{,2,2.[0-9]*,3,3.[0-9]*} ixr,

  # for perl apps/services
  #include <abstractions/perl>
  /usr/bin/perl{,5*} ixr,

  # for bash 'binaries' (do *not* use abstractions/bash)
  # user-specific bash files
  /bin/bash ixr,
  /bin/dash ixr,
  /etc/bash.bashrc r,
  /usr/share/terminfo/** r,
  /etc/inputrc r,
  deny @{HOME}/.inputrc r,
  # Common utilities for shell scripts
  /{,usr/}bin/{,g,m}awk ixr,
  /{,usr/}bin/basename ixr,
  /{,usr/}bin/bunzip2 ixr,
  /{,usr/}bin/bzcat ixr,
  /{,usr/}bin/bzdiff ixr,
  /{,usr/}bin/bzgrep ixr,
  /{,usr/}bin/bzip2 ixr,
  /{,usr/}bin/cat ixr,
  /{,usr/}bin/chmod ixr,
  /{,usr/}bin/cmp ixr,
  /{,usr/}bin/cp ixr,
  /{,usr/}bin/cpio ixr,
  /{,usr/}bin/cut ixr,
  /{,usr/}bin/date ixr,
  /{,usr/}bin/dd ixr,
  /{,usr/}bin/diff{,3} ixr,
  /{,usr/}bin/dir ixr,
  /{,usr/}bin/dirname ixr,
  /{,usr/}bin/echo ixr,
  /{,usr/}bin/{,e,f,r}grep ixr,
  /{,usr/}bin/env ixr,
  /{,usr/}bin/expr ixr,
  /{,usr/}bin/find ixr,
  /{,usr/}bin/fmt ixr,
  /{,usr/}bin/getopt ixr,
  /{,usr/}bin/false ixr,
  /{,usr/}bin/head ixr,
  /{,usr/}bin/id ixr,
  /{,usr/}bin/igawk ixr,
  /{,usr/}bin/kill ixr,
  /{,usr/}bin/ln ixr,
  /{,usr/}bin/line ixr,
  /{,usr/}bin/link ixr,
  /{,usr/}bin/ls ixr,
  /{,usr/}bin/md5sum ixr,
  /{,usr/}bin/mkdir ixr,
  /{,usr/}bin/mktemp ixr,
  /{,usr/}bin/mv ixr,
  /{,usr/}bin/pgrep ixr,
  /{,usr/}bin/printenv ixr,
  /{,usr/}bin/printf ixr,
  /{,usr/}bin/ps ixr,
  /{,usr/}bin/pwd ixr,
  /{,usr/}bin/readlink ixr,
  /{,usr/}bin/realpath ixr,
  /{,usr/}bin/rev ixr,
  /{,usr/}bin/rm ixr,
  /{,usr/}bin/rmdir ixr,
  /{,usr/}bin/sed ixr,
  /{,usr/}bin/seq ixr,
  /{,usr/}bin/sleep ixr,
  /{,usr/}bin/sort ixr,
  /{,usr/}bin/stat ixr,
  /{,usr/}bin/tac ixr,
  /{,usr/}bin/tail ixr,
  /{,usr/}bin/tar ixr,
  /{,usr/}bin/tee ixr,
  /{,usr/}bin/test ixr,
  /{,usr/}bin/tempfile ixr,
  /{,usr/}bin/touch ixr,
  /{,usr/}bin/tr ixr,
  /{,usr/}bin/true ixr,
  /{,usr/}bin/uname ixr,
  /{,usr/}bin/uniq ixr,
  /{,usr/}bin/unlink ixr,
  /{,usr/}bin/unxz ixr,
  /{,usr/}bin/unzip ixr,
  /{,usr/}bin/vdir ixr,
  /{,usr/}bin/wc ixr,
  /{,usr/}bin/which ixr,
  /{,usr/}bin/xz ixr,
  /{,usr/}bin/yes ixr,
  /{,usr/}bin/zcat ixr,
  /{,usr/}bin/z{,e,f}grep ixr,
  /{,usr/}bin/zip ixr,
  /{,usr/}bin/zipgrep ixr,

  # uptime
  /{,usr/}bin/uptime ixr,
  @{PROC}/uptime r,
  @{PROC}/loadavg r,
  # this is an information leak
  deny /{,var/}run/utmp r,

  # Miscellaneous accesses
  /etc/mime.types r,
  @{PROC}/sys/kernel/hostname r,
  @{PROC}/sys/kernel/osrelease r,

  # Read-only for the install directory
  @{CLICK_DIR}/@{APP_PKGNAME}/                   r,
  @{CLICK_DIR}/@{APP_PKGNAME}/@{APP_VERSION}/    r,
  @{CLICK_DIR}/@{APP_PKGNAME}/@{APP_VERSION}/**  mrklix,

  # Read-only home area for other versions
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/                  r,
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/   r,
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/** mrkix,

  # Writable home area for this version.
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/   w,
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/@{APP_VERSION}/** wl,

  # Read-only system area for other versions
  /var/lib/apps/@{APP_PKGNAME}/   r,
  /var/lib/apps/@{APP_PKGNAME}/** mrkix,

  # TODO: the write on these is needed in case they doesn't exist, but means an
  # app could adjust inode data and affect rollbacks.
  owner @{HOMEDIRS}/*/apps/@{APP_PKGNAME}/         w,
  /var/lib/apps/@{APP_PKGNAME}/                  w,

  # Writable system area only for this version
  /var/lib/apps/@{APP_PKGNAME}/@{APP_VERSION}/   w,
  /var/lib/apps/@{APP_PKGNAME}/@{APP_VERSION}/** wl,

  # Writable temp area only for this version (launcher will create this
  # directory on our behalf so only allow readonly on parent)
  /tmp/snapps/@{APP_PKGNAME}/                  r,
  /tmp/snapps/@{APP_PKGNAME}/**                rk,
  /tmp/snapps/@{APP_PKGNAME}/@{APP_VERSION}/   rw,
  /tmp/snapps/@{APP_PKGNAME}/@{APP_VERSION}/** mrwlkix,

  # No abstractions specified

  # Rules specified via policy groups
  # Description: Can access the network
  # Usage: common
  #include <abstractions/nameservice>
  #include <abstractions/ssl_certs>

  @{PROC}/sys/net/core/somaxconn r,

  # We want to explicitly deny access to NetworkManager because its DBus API
  # gives away too much
  deny dbus (receive, send)
       bus=system
       path=/org/freedesktop/NetworkManager,
  deny dbus (receive, send)
       bus=system
       peer=(name=org.freedesktop.NetworkManager),

  # Do the same for ofono (LP: #1226844)
  deny dbus (receive, send)
       bus=system
       interface="org.ofono.Manager",

  # Specified read permissions
  /etc/hosts.allow rk,
  /etc/hosts.deny rk,
  /etc/passwd rk,
  /proc/cmdline rk,
  /sys/bus/i2c/devices/0-0050/eeprom rk,
  /sys/devices/ocp/44e0b000.i2c/i2c-0/0-0050/eeprom rk,
  @{PROC}/ rk,
  @{PROC}/** rk,
  @{PROC}/[0-9]*/stat rk,

  # Specified write permissions
  /sys/bus/i2c/devices/i2c-0/new_device rwk,

  # Ninja
  /{,usr/}bin/xxd ixr,
  /sys/class/net/[a-z0-9]*/address rk,
  /sys/devices/*/*/net/[a-z0-9]*/address rk,
  /proc/cmdline rk,
  /bin/ip ixr,
  /dev/zigbee rwk,
  /dev/ttyO4 rwk,
  /sys/class/gpio rwk,
  /sys/class/gpio/** rwk,
  /sys/devices/virtual/gpio/** rwk,

  # And REALLY hax, allowing insmod for now (yes yes, this defeats AppArmor completely, TODO move to base system, device part or framework :-)
  /bin/kmod ixr,
  capability sys_module,
}
