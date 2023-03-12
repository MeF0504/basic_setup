#! /bin/sh

cd $(dirname $0)/..
curdir=$(pwd)
mkdir -p tmp_dir/bin

touch tmp_dir/bin/version.py
echo 'aaa\nbbb' >> tmp_dir/bin/version.py

ln -s $curdir/opt/bin/hoge tmp_dir/bin/pytree
cp opt/bin/optlink tmp_dir/bin/optlink

args="-t opt --prefix $curdir/tmp_dir"
# args="$args --link"
# args="$args --force"
# args="$args --test"
# args="$args -s opt/test/setup_file_template.json"
args="$args --show_all"
# args="$args --show_no_update_files"
# args="$args --show_target_files"

python3 setup.py $args

rm -rf tmp_dir

