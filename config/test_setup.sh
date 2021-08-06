#! /bin/sh

cd $(dirname $0)/..
curdir=$(pwd)
mkdir -p tmp_dir/bin

touch tmp_dir/bin/envar
echo 'aaa\nbbb' >> tmp_dir/bin/envar

ln -s $curdir/opt/bin/hoge tmp_dir/bin/pyviewer

# args="--prefix $curdir/tmp_dir"
# args="--prefix $curdir/tmp_dir --link"
args="--prefix $curdir/tmp_dir --test -s opt/test/setup_file_template.json"

python setup.py $args

rm -rf tmp_dir

