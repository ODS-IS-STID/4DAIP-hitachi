#!/bin/bash

#環境変数設定は以下を手動で行う
#vi /root/.bashrc
#最終行に下記１行を追加
#export PROJ_LIB=~/tmp/ct/jar/proj/proj-data_8.2.1/usr/share/proj

cd /usr/lib
ln -sf libgdal.so.30.0.3  libgdal.so.26
cd /usr/lib/x86_64-linux-gnu
ln -sf libproj.so.22.2.0  libproj.so.15
