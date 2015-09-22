Summary: __TAG_SUMMARY__
Name: __TAG_NAME__
Version: __TAG_VERSION__
Release: 1
License: Commercial
Group: Applications
Source: __TAG_NAME__
Prefix: __TAG_LOCATION__
Requires: adobeair >= __TAG_MIN_RUNTIME_VERSION__

URL: http://www.adobe.com
Vendor: __TAG_VENDOR__
Packager: __TAG_VENDOR__
AutoReqProv: no

%define _use_internal_dependency_generator 0
%define __check_files %{nil}
%define _unpackaged_files_terminate_build  0
%define _missing_doc_files_terminate_build 0

%description
__TAG_DESCRIPTION__

%prep

%build

%install

%pre

%post

InstallDir="$RPM_INSTALL_PREFIX"/__TAG_QUOTED_FILENAME__
AIRInstallDir="/opt/Adobe AIR"
ResourceDir="${AIRInstallDir}/Versions/1.0/Resources"
PATH="${ResourceDir}/xdg-utils:$PATH"
XDG_UTILS_INSTALL_MODE="system"

if which kde-config >/dev/null 2>&1; then
   :
else
   PATH="$PATH:/opt/kde3/bin:/opt/kde/bin"
fi

if which kde4-config >/dev/null 2>&1; then
   :
else
   PATH="$PATH:/opt/kde4/bin:/usr/lib/kde4/bin"
fi

if [ -z "$XDG_DATA_DIRS" ]; then
    XDG_DATA_DIRS="/usr/share/:/usr/local/share/"

    if xdg_data_dir=`kde-config --prefix 2>/dev/null`; then
        XDG_DATA_DIRS="${XDG_DATA_DIRS}:${xdg_data_dir}/share/"
    fi

    if xdg_data_dir=`kde4-config --prefix 2>/dev/null`; then
        XDG_DATA_DIRS="${XDG_DATA_DIRS}:${xdg_data_dir}/share/"
    fi

    if [ -x /opt/gnome/bin/gnome-open ]; then
        XDG_DATA_DIRS="${XDG_DATA_DIRS}:/opt/gnome/share/"
    fi

    export XDG_DATA_DIRS
fi

export PATH
export XDG_UTILS_INSTALL_MODE

InstallMimeType()
{
    xdg-mime install --novendor "__TAG_NAME__.xml" >/dev/null 2>&1
}


InstallMimeIcon()
{
    icon_size="$1"
    icon_path="$2"
    mimetype="`echo "$3" | tr '//' '-'`"

    xdg-icon-resource install --noupdate --novendor --context mimetypes --mode system --size "$icon_size" "$icon_path" "$mimetype" >/dev/null 2>&1
    xdg-icon-resource install --noupdate --novendor --theme gnome --context mimetypes --mode system --size "$icon_size" "$icon_path" "$mimetype" >/dev/null 2>&1
}


InstallAppIcon()
{
    icon_size="$1"
    icon_path="$2"

    xdg-icon-resource install --noupdate --novendor --context apps --mode system --size "$icon_size" "$icon_path" >/dev/null 2>&1
    xdg-icon-resource install --noupdate --novendor --theme gnome --context apps --mode system --size "$icon_size" "$icon_path" >/dev/null 2>&1
}


SetAsDefaultApplication()
{
    mimetype="$1"

    xdg-mime default "__TAG_NAME__.desktop" "$mimetype" >/dev/null 2>&1
}


cd "$InstallDir/share/META-INF/AIR"

if [ -n __TAG_QUOTED_PROGRAM_MENU_FOLDER__ ]; then
    xdg-desktop-menu install --novendor "__TAG_NAME__.directory" "__TAG_NAME__.desktop"
else
    xdg-desktop-menu install --novendor "__TAG_NAME__.desktop"
fi >/dev/null 2>&1


__TAG_MIME_ICON_CMD__


if __TAG_SHORTCUT__; then
    if script="`mktemp -t air.XXXXXX`"; then
        chmod 755 "$script"
        cat > "$script" <<EOF
export PATH="$PATH"
xdg-desktop-icon install --novendor "__TAG_NAME__.desktop"
EOF
        ( sudo -H -S -u __TAG_USER__ "$script" || su __TAG_USER__ -c "$script" ) < /dev/null
        rm -f "$script"
    fi
fi >/dev/null 2>&1

rm -f /usr/share/applications/__TAG_NAME__.desktop 2>/dev/null
ln -s "$PWD/__TAG_NAME__.desktop" /usr/share/applications/__TAG_NAME__.desktop 2>/dev/null

#OLD_IFS="$IFS"
#IFS=':'

#xdg_gnome_dirs="`echo $XDG_DATA_DIRS:/usr/share:/usr/local/share | sed -e 's#//*#/#g' -e 's#//*:#:#g' -e 's#//*$##g'`"

#xdg_kde_dirs=`kde-config --install xdgdata-apps --expandvars 2>/dev/null`:`kde-config --install apps --expandvars 2>/dev/null`:`kde4-config --install xdgdata-apps --expandvars 2>/dev/null`:`kde4-config --install apps --expandvars 2>/dev/null`
#xdg_kde_dirs="`echo $xdg_kde_dirs | sed -e 's#//*#/#g' -e 's#//*:#:#g' -e 's#//*$##g'`"

#for xdg_dir in $xdg_gnome_dirs
#do
#    if [ -d "$xdg_dir/applications" ]; then
#        rm -f "$xdg_dir/__TAG_NAME__.desktop"
#        ( grep -v "^OnlyShowIn=" "__TAG_NAME__.desktop"
#
#        if [ -n __TAG_QUOTED_PROGRAM_MENU_FOLDER__ ]; then
#            echo "OnlyShowIn="
#        else
#            echo "OnlyShowIn=GNOME;XFCE;"
#        fi ) > "$xdg_dir/applications/__TAG_NAME__.desktop"
#    fi
#done >/dev/null 2>&1

#xdg_kde_dirs=`kde-config --install xdgdata-apps --expandvars 2>/dev/null`:`kde-config --install apps --expandvars 2>/dev/null`:`kde4-config --install xdgdata-apps --expandvars 2>/dev/null`:`kde4-config --install apps --expandvars 2>/dev/null`

## The OnlyShowIn entries are removed for files installed to the directory if it is common between GNOME and KDE.

#for xdg_dir in $xdg_kde_dirs
#do
#    if [ -d "$xdg_dir" -a -z __TAG_QUOTED_PROGRAM_MENU_FOLDER__ ]
#    then
#         ( grep -v "^OnlyShowIn=" "__TAG_NAME__.desktop"; echo "OnlyShowIn=KDE;" ) | tee "$xdg_dir/.hidden/__TAG_NAME__.desktop" > "$xdg_dir/__TAG_NAME__.desktop"
#        for x in $xdg_gnome_dirs
#        do
#            if [ "$xdg_dir" = "$x/applications" ]
#            then
#                grep -v "^OnlyShowIn=" "__TAG_NAME__.desktop" > "$xdg_dir/__TAG_NAME__.desktop"
#                break
#            fi
#        done
#    fi
#done >/dev/null 2>&1

#IFS="$OLD_IFS"

xdg-icon-resource forceupdate 2>/dev/null
#update-app-install >/dev/null 2>&1

if grep -qi "midinux" /etc/issue >/dev/null 2>&1; then
    dbus-send --system /com/nfschina/midhome/signal com.nfschina.midhome.signal.menu_refresh >/dev/null 2>&1
    update-desktop-database /usr/share/applications/hildon >/dev/null 2>&1
fi

exit 0

%preun

InstallDir="$RPM_INSTALL_PREFIX"/__TAG_QUOTED_FILENAME__
AIRInstallDir="/opt/Adobe AIR"
ResourceDir="${AIRInstallDir}/Versions/1.0/Resources"
PATH="${ResourceDir}/xdg-utils:$PATH"
XDG_UTILS_INSTALL_MODE="system"

if which kde-config >/dev/null 2>&1; then
   :
else
   PATH="$PATH:/opt/kde3/bin:/opt/kde/bin"
fi

if which kde4-config >/dev/null 2>&1; then
   :
else
   PATH="$PATH:/opt/kde4/bin:/usr/lib/kde4/bin"
fi


if [ -z "$XDG_DATA_DIRS" ]; then
    XDG_DATA_DIRS="/usr/share/:/usr/local/share/"

    if xdg_data_dir=`kde-config --prefix 2>/dev/null`; then
        XDG_DATA_DIRS="${XDG_DATA_DIRS}:${xdg_data_dir}/share/"
    fi

    if [ -x /opt/gnome/bin/gnome-open ]; then
        XDG_DATA_DIRS="${XDG_DATA_DIRS}:/opt/gnome/share/"
    fi

    export XDG_DATA_DIRS
fi

export PATH
export XDG_UTILS_INSTALL_MODE

InstallMimeType()
{
    xdg-mime uninstall --novendor "__TAG_NAME__.xml" >/dev/null 2>&1
}


InstallMimeIcon()
{
    icon_size="$1"
    icon_path="$2"
    mimetype="`echo "$3" | tr '//' '-'`"

    xdg-icon-resource uninstall --noupdate --novendor --context mimetypes --mode system --size "$icon_size" "$icon_path" "$mimetype" >/dev/null 2>&1
    xdg-icon-resource uninstall --noupdate --novendor --theme gnome --context mimetypes --mode system --size "$icon_size" "$icon_path" "$mimetype" >/dev/null 2>&1
}


InstallAppIcon()
{
    icon_size="$1"
    icon_path="$2"

    xdg-icon-resource uninstall --noupdate --novendor --context apps --size "$icon_size" "$icon_path" >/dev/null 2>&1
    xdg-icon-resource uninstall --noupdate --novendor --theme gnome --context apps --size "$icon_size" "$icon_path" >/dev/null 2>&1
}


SetAsDefaultApplication()
{
    mimetype="$1"

    xdg-mime unset "__TAG_NAME__.desktop" "$mimetype" >/dev/null 2>&1
}

UnInstallMimeType()
{
    mimeFile="`WriteMimeFileForExtension "${mimetype}" "${extension}"`"
    mimeDir="`dirname "$mimeFile"`"
    iconFile="$mimeDir/temp.png"
    tempFile="$mimeDir/temp"
    mimeIconType="`echo "$mimetype" | tr '//' '-'`"

    cat >> "$cmd" <<EOF
XDG_UTILS_INSTALL_MODE="user"
KDE_FULL_SESSION=true
export KDE_FULL_SESSION XDG_UTILS_INSTALL_MODE
EOF

 
    for size in 16 32 48 128; do
        touch "$iconFile"
        cat >> "$cmd" <<EOF

xdg-icon-resource uninstall --mode user --context mimetypes --size "$size" --novendor "$iconFile" "$mimeIconType"
xdg-icon-resource uninstall --mode user --theme gnome --context mimetypes --size "$size" --novendor "$iconFile" "$mimeIconType"

EOF
    done

    cat >> "$cmd" <<EOF

xdg-mime uninstall --mode user --novendor "$mimeFile"

EOF
}


UnInstallDefaultApp()
{
    cat >> "$cmd" <<EOF

XDG_UTILS_INSTALL_MODE="user"
KDE_FULL_SESSION=true
export KDE_FULL_SESSION XDG_UTILS_INSTALL_MODE

## Get the mimetype of the extension and check if it belongs to our mimetype.
## Check if we are default handler for the mimetype and then do the following
xdg-mime unset "__TAG_NAME__.desktop" "$mimetype"

EOF

}

UnInstallAutostart()
{
    cat >> "$cmd" <<EOF

xdg-autostart uninstall "$InstallDir"/bin/__TAG_QUOTED_FILENAME__

EOF
}


UnRegisterMimeTypeAndDefaultHandlersForMultipleUsers()
{
    sharedFolder="/var/opt/Adobe AIR/Shared/.air/app-mimetypes"

    if [ -d "$sharedFolder" ]; then
        cd "$sharedFolder"

        for user in `ls -1 2>/dev/null`; do
            if [ -f "$user" ] && id -u "$user" >/dev/null 2>&1; then
                workArea="`mktemp -d -t air.XXXXXX`"
                cmd="${workArea}/uninstall"

                cat > "$cmd" <<EOF
#!/bin/sh
PATH="${ResourceDir}/xdg-utils:$PATH"
export PATH
EOF
                sed -n -e "s/__TAG_NAME__//p" "$user" |\
                while read operation extension mimetype; do
                    case "$operation" in
                        InstallDefaultApp|InstallMimeType|InstallAutostart) Un${operation} "$extension" "$mimetype" ;;
                        *) ;;
                    esac
                done
            fi

            group="`id -g "$user"`"

            chmod 700 "$cmd"
            chown -R "${user}:${group}" "$workArea"
            ( sudo -H -S -u "${user}" "$cmd" || su "${user}" -c "$cmd" ) < /dev/null >/dev/null 2>&1

            tmpfile="$workArea/tmpfile"
            grep -v "__TAG_NAME__" "$user" > "$tmpfile"
            cat "$tmpfile" > "$user" || rm -f "$tmpfile"

            if [ -s "$user" ]; then
                :
            else
                rm -f "$user"
            fi

            rm -f "$workArea"/*
            rmdir "$workArea"
        done >/dev/null 2>&1

        cd "$RPM_INSTALL_PREFIX"/__TAG_QUOTED_FILENAME__/share/META-INF/AIR
    fi
}


WriteMimeFileForExtension()
{
#    $1 - mimetype
#    $2 - extension

    mimeFile="${workArea}/${2}.xml"

    cat > "${mimeFile}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">

  <mime-type type="${1}">
    <comment>No Comment</comment>
    <glob pattern="*.${2}"/>
  </mime-type>
</mime-info>

EOF

    echo "$mimeFile"
}


if [ "$1" = "0" ]; then         ## last uninstall, in case of upgrade request it gets 1
    cd "$InstallDir/share/META-INF/AIR"

    if [ -n __TAG_QUOTED_PROGRAM_MENU_FOLDER__ ]; then
        xdg-desktop-menu uninstall --novendor "__TAG_NAME__.directory" "__TAG_NAME__.desktop"
    else
        xdg-desktop-menu uninstall --novendor "__TAG_NAME__.desktop"
    fi >/dev/null 2>&1

__TAG_MIME_ICON_CMD__

    xdg-icon-resource forceupdate 2>/dev/null

    if __TAG_SHORTCUT__; then
        if script="`mktemp -t air.XXXXXX`"; then
            cat > "$script" <<EOF
export PATH="$PATH"
xdg-desktop-icon uninstall --novendor "__TAG_NAME__.desktop"
EOF
            chmod 755 "$script"
            ( sudo -H -S -u __TAG_USER__ "$script" || su __TAG_USER__ -c "$script" ) < /dev/null
            rm -f "$script"
        fi
    fi >/dev/null 2>&1

    UnRegisterMimeTypeAndDefaultHandlersForMultipleUsers

    rm -f /usr/share/applications/__TAG_NAME__.desktop 2>/dev/null

#    OLD_IFS="$IFS"
#    IFS=':'

#    xdg_dirs_gnome=$XDG_DATA_DIRS:/usr/share:/usr/local/share

#    for xdg_dir in $xdg_dirs_gnome; do
#        rm -f "$xdg_dir/applications/__TAG_NAME__.desktop"
#    done >/dev/null 2>&1

#    xdg_dirs_kde=`kde-config --install xdgdata-apps --expandvars 2>/dev/null`:`kde-config --install apps --expandvars 2>/dev/null`:`kde4-config --install xdgdata-apps --expandvars 2>/dev/null`:`kde4-config --install apps --expandvars 2>/dev/null`

#    for xdg_dir in $xdg_dirs_kde
#    do
#        rm -f "$xdg_dir/__TAG_NAME__.desktop"
#        rm -f "$xdg_dir/.hidden/__TAG_NAME__.desktop"
#    done >/dev/null 2>&1

#    IFS="$OLD_IFS"
fi

exit 0

%postun

#update-app-install >/dev/null 2>&1

if grep -qi "midinux" /etc/issue >/dev/null 2>&1; then
    dbus-send --system /com/nfschina/midhome/signal com.nfschina.midhome.signal.menu_refresh >/dev/null 2>&1
    update-desktop-database /usr/share/applications/hildon >/dev/null 2>&1
fi

exit 0

%files
%defattr(-, root, root)
__TAG_FILES__
%doc

%changelog

