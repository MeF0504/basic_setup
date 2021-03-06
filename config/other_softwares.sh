#! /bin/sh

# This file is the installer for software that I think to good.
# Please uncomment and run this script.

## python
echo 'which python3'
which python3
echo 'which pip3'
which pip3

# pip3 install numpy      # 数値計算ライブラリ
# pip3 install scipy      # 高機能数値計算ライブラリ
# pip3 install pandas     # テーブル型データ解析ライブラリ？
# pip3 install matplotlib # 画像描画ライブラリ
# pip3 install ipython    # 高機能対話型python環境
# pip3 install sympy      # 数式計算ライブラリ
# pip3 install h5py       # hdf5 ファイル用ライブラリ
# pip3 install jupyter    # データ解析／表示ツール
# pip3 install send2trash # ゴミ箱を利用するためのライブラリ
# pip3 install tqdm       # 進捗バー表示ライブラリ
# pip3 install pynvim     # neovim用ライブラリ
# pip3 install pymc pymc3 # MCMC用ライブラリ
# pip3 install healpy     # 球面解析用ライブラリ？
# pip3 install camb       # CMB パワースペクトル計算用ライブラリ
# pip3 install corner     # 相関プロット用ライブラリ？
echo

## go
echo 'which go'
which go
echo GOPATH
echo $GOPATH

# go get github.com/jhchen/ansize                 # ascii art化ツール
# go get github.com/itchyny/mmv/cmd/mmv           # ファイルの一括renameツール
# go get github.com/mattn/docx2md                 # wordをmarkdown化するツール
# go get github.com/mattn/go-sixel/cmd/gosr       # 端末上に画像を表示するツール
# git clone https://github.com/skanehira/pst.git  # 高機能プロセス表示ツール
# cd pst/
# go install
echo

## ruby
echo 'which ruby'
which ruby
echo 'which gem'
which gem

# gem install tw      # 端末上でtwitterを見るツール

