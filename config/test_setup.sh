#! /bin/sh

cd $(dirname $0)/..
curdir=$(pwd)
mkdir -p tmp_dir/bin

touch tmp_dir/bin/version.py
echo 'aaa\nbbb' >> tmp_dir/bin/version.py

ln -s $curdir/opt/bin/hoge tmp_dir/bin/pytree

args="-t opt --prefix $curdir/tmp_dir"
# args="-t opt --prefix $curdir/tmp_dir --link"
# args="-t opt --prefix $curdir/tmp_dir --force"
# args="-t opt --prefix $curdir/tmp_dir --test -s opt/test/setup_file_template.json"

python3 setup.py $args

rm -rf tmp_dir

