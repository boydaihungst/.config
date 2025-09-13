function lfcd
    set tmp (mktemp)
    set fid (mktemp)

    # lf -last-dir-path=$tmp $argv
    lf -command '$printf $id > '"$fid"'' -last-dir-path=$tmp $argv
    set id (cat "$fid")
    set archivemount_dir "/tmp/__lf_archivemount_$id"
    if [ -f "$archivemount_dir" ]
        cat "$archivemount_dir" | \
            while read -r line
                sudo umount "$line"
                rmdir "$line"
            end
        rm -f "$archivemount_dir"
    end
    if test -f "$tmp"
        set dir (cat $tmp)
        rm -f $tmp
        if test -d "$dir"
            if test "$dir" != (pwd)
                cd $dir
            end
        end
    end
end
