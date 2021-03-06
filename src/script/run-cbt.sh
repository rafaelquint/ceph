#!/bin/sh

usage() {
    local prog_name=$1
    shift
    cat <<EOF
usage:
  $prog_name [options] <config-file>...

options:
  -a,--archive-dir    directory in which the test result is stored, default to $PWD/cbt-archive
  --build-dir         directory where CMakeCache.txt is located, default to $PWD
  --cbt-dir           directory of cbt if you have already a copy of it. ceph/cbt:master will be cloned from github if not specified
  -h,--help           print this help message
  --source-dir        the path to the top level of Ceph source tree, default to $PWD/..
  --use-existing      do not setup/teardown a vstart cluster for testing

example:
  $prog_name --cbt ~/dev/cbt -a /tmp ../src/test/crimson/cbt/radosbench_4K_read.yaml
EOF
}

prog_name=$(basename $0)
archive_dir=$PWD/cbt-archive
build_dir=$PWD
source_dir=$(dirname $PWD)
use_existing=false
opts=$(getopt --options "a:h" --longoptions "archive-dir:,build-dir:,source-dir:,cbt:,help,use-existing" --name $prog_name -- "$@")
eval set -- "$opts"

while true; do
    case "$1" in
        -a|--archive-dir)
            archive_dir=$2
            shift 2
            ;;
        --build-dir)
            build_dir=$2
            shift 2
            ;;
        --source_dir)
            source_dir=$2
            shift 2
            ;;
        --cbt)
            cbt_dir=$2
            shift 2
            ;;
        --use-existing)
            use_existing=true
            shift
            ;;
        -h|--help)
            usage $prog_name
            return 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "unexpected argument $1" 1>&2
            return 1
            ;;
    esac
done

if test $# -gt 0; then
    config_files="$@"
else
    echo "$prog_name: please specify one or more .yaml files" 1>&2
    usage $prog_name
    return 1
fi

if test -z "$cbt_dir"; then
    cbt_dir=$PWD/cbt
    git clone --depth 1 -b master https://github.com/ceph/cbt.git $cbt_dir
fi

if ! $use_existing; then
    MDS=0 MGR=1 OSD=3 MON=1 $source_dir/src/vstart.sh -n -X \
       --without-dashboard --memstore \
       -o "memstore_device_bytes=34359738368" \
       --crimson --nodaemon --redirect-output \
       --osd-args "--memory 4G"
fi

for config_file in $config_files; do
    echo "testing $config_file"
    cbt_config=$(mktemp $config_file.XXXX.yaml)
    $source_dir/src/test/crimson/cbt//t2c.py \
        --build-dir $build_dir \
        --input $config_file \
        --output $cbt_config
    $cbt_dir/cbt.py \
        --archive $archive_dir \
        --conf $build_dir/ceph.conf \
        $cbt_config
    rm -f $cbt_config
done

if ! $use_existing; then
    $source_dir/src/stop.sh --crimson
fi
