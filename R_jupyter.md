# jupyterでRを使う 
東大スパコンはRstudioが使えないので，jupyterからRを動かせばノートブック形式でRを記載することができる。
(このメモは確実に正しい情報であるとは限らないので，改めて調べる必要もある。)

#　jupyterでRを起動するのに必要な操作　
様々な記事があり，そのままコピペすれば動く。(例えば[これ](https://www.kimoton.com/entry/20180902/1535819542))
```
$ install.packages(c(‘repr’, ‘IRdisplay’, ‘evaluate’, ‘crayon’, ‘pbdZMQ’, ‘devtools’, ‘uuid’, ‘digest’))
$ devtools::install_github(‘IRkernel/IRkernel’)
$ IRkernel::installspec()
[InstallKernelSpec] Installed kernelspec ir in /home/usr/.local/share/jupyter/kernels/ir
```

# 東大スパコンでRを使う　
この際，東大スパコンでデフォルトのRは`/usr/local`にあり，自由に書き換えることができない。そのため，パッケージのインストール先を自分で明記しないと自由にパッケージをインストールすることができない。
ただ，R本体とパッケージが違う場所にあると管理が大変そうだと思ったので，自分は`/home/usrname`以下に自分用のRをインストールし，それをデフォルトとして使用するようにしている。この際，`~/.bash_profile`に下記の記載をすることで，デフォルトのRを自分でインストールしたものにしている。
```
export PATH=/yshare1/home/myne812/R/3.6.0/lib64/R/bin:$PATH
export R_LIBS_USER=/home/myne812/R/3.6.0/lib64/R/library:$R_LIBS_USER
```
ここで，`library`の方にもパスを通さないとパッケージは`/usr/local`の方をデフォルトとして動いてしまうので注意。 


# 詰まった点 
IRkernelがきちんと挙動せずに下記のエラー
```
Error opening stream: HTTP 404: Not Found (Kernel does not exist: cf2f9da8-d6f0-4910-aadb-ccc2e753273c)
```　
IRkernelは
```
~/.local/share/jupyter/kernels/ir/
```
に設定される。ここにR3.5.0の設定が残っていたことがR3.6.0を使おうとしたときにエラーが生じた原因だった。

# 未解決問題点 
```
 呼び出し:  cat ... system.file -> find.package -> lapply -> FUN -> readRDS
 実行が停止されました
 readRDS(pfile) でエラー:
   R 3.6.0 により書かれたバージョン 3 のワークスペースを読み取ることができません。R 3.5.0 もしくはそれ以上が必要です
``` 
下記のログが出続ける。R 3.6.0なのだが，，，