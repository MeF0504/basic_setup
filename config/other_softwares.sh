#! /bin/sh

# This file is the installer for software that I think to good.
# Please uncomment and run this script.

## python {{{
echo '- which python3'
which python3
echo '- which pip3'
which pip3

# pip3 install --upgrade pip
# pip3 install numpy          # 数値計算ライブラリ
# pip3 install scipy          # 高機能数値計算ライブラリ
# pip3 install pandas         # テーブル型データ解析ライブラリ？
# pip3 install matplotlib     # 画像描画ライブラリ
# pip3 install ipython        # 高機能対話型python環境
# pip3 install sympy          # 数式計算ライブラリ
# pip3 install h5py           # hdf5 ファイル用ライブラリ
# pip3 install jupyter        # データ解析／表示ツール
# pip3 install send2trash     # ゴミ箱を利用するためのライブラリ
# pip3 install tqdm           # 進捗バー表示ライブラリ
# pip3 install pynvim         # neovim用ライブラリ
# pip3 install pymc pymc3     # MCMC用ライブラリ
# pip3 install healpy         # 球面解析用ライブラリ？
# pip3 install camb           # CMB パワースペクトル計算用ライブラリ
# pip3 install corner         # 相関プロット用ライブラリ？
# pip3 install pillow         # 画像処理用ライブラリ
# pip3 install rawpy          # raw画像用ライブラリ
# pip3 insatll tabulate       # table 作成／表示ライブラリ
# pip3 install python-magic   # magic (file type判定)用ライブラリ
# pip3 install opencv-python  # Open CV package for python
# pip3 install 'python-lsp-server[all]'     # python用 Language Server
echo
# }}}

## go {{{
echo '- which go'
which go
echo '- where is GOPATH'
echo $GOPATH

# go get github.com/jhchen/ansize                 # ascii art化ツール
# go get github.com/itchyny/mmv/cmd/mmv           # ファイルの一括renameツール
# go get github.com/mattn/docx2md                 # wordをmarkdown化するツール
# go get github.com/mattn/go-sixel/cmd/gosr       # 端末上に画像を表示するツール
# git clone https://github.com/skanehira/pst.git  # 高機能プロセス表示ツール
# cd pst/
# go install
echo
# }}}

## ruby {{{
echo '- which ruby'
which ruby
echo '- which gem'
which gem

# gem install tw      # 端末上でtwitterを見るツール
echo
# }}}

## node.js {{{
echo '- which npm'
which npm
# set install directory
# npm set prefix $HOME/workspace/node.js  # globalのインストール場所を設定
echo "- check the prefix (and other) setting(s)"
npm config list

# npm install -g @marp-team/marp-cli    # markdownからスライドを作成するツール
# npm install -g terminalizer           # ターミナル録画ツール
echo
# }}}

## other tools {{{
echo '- other tools gettable by curl'
INSTALL_DIR=${1:-$HOME/opt/bin}
if [ ! -d $INSTALL_DIR ]; then
    echo 'no such install directory: '$INSTALL_DIR
    exit
fi
echo $INSTALL_DIR

echo '- which curl'
which curl

# curl -L -o ${INSTALL_DIR}/hterm-show-file.sh https://raw.githubusercontent.com/libapps/libapps-mirror/main/hterm/etc/hterm-show-file.sh && chmod u+x ${INSTALL_DIR}/hterm-show-file.sh    # hterm (html terminal?)上で画像を見るためのスクリプト。githubはミラーで元のリポジトリは多分 https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc/hterm-show-file.sh

# curl -L -o ${INSTALL_DIR}/imgcat https://iterm2.com/utilities/imgcat && chmod u+x ${INSTALL_DIR}/imgcat     # iterm2上で画像を見る用のscript. 詳細-> https://iterm2.com/documentation-images.html
# }}}

