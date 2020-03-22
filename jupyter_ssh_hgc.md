# 東大スパコンでjupyter labとVSCode

## 概要 
jupyter lab，jupyter notebookはAnacondaパッケージに内包されているデータ解析用のIDE。  
ローカルサーバー上で操作させるため，そのままではssh接続しているリモートのファイルを編集することができない。 
そこで必要となる設定を，東大スパコンに対して行なった結果を記載する。 
(追記) 
*VScodeの設定を追加した，個人的にはjupyterよりも便利だと思うので利用していきたい。*  
<span style="color: red; ">(2020/03/22 追記)</span> 
webの勉強を少しして，勘違いがあったことに気づいたので，修正する。IPアドレスとは，ポートとは，そこら辺をしっかり理解しておくことの重要性に気づいた。 


詳しい説明は[井手さんのホームページ](http://133.9.8.88/~ide/analysis/others/jupyter-notebook/)にあるが，OILスパコンをメインとした説明である。 
東大スパコンへの設定で自分が手こずった部分を中心に記載する。 


## 操作 
### ssh configの設定 
まず，`vim .ssh/config`でssh接続の設定ファイルを編集する。 

通常，スパコンで操作する際，`slogin.hgc.jp`というログインノードに入り，そこから計算ノードに`qlogin`する。(正確にはログインノードも２つあり，それぞれに異なるIPアドレスが振られている)。 
jupyer labを利用するためには，ローカルホストから計算ノードに直接入り込む必要があり，繋がる先がログインノードではいけない。(jupyter接続起動中にqloginを打ち込むタイミングがないため)
自分がつまづいたのはこの部分で，SHIROKANE wikiにも計算ノードのIPアドレスは記載されておらず，どういう風に指定してあげれば，直接計算ノードに入り込むことができるのかがわからなかった。
今回は，jupyterやvs codeがスパコン上の計算ノードに直接張り込むためにはどうしたらいいのかを詳しく記載する。 

<span style="color: red; ">(2020/03/22まで)</span> 
ロボットのためのログインノードである`sutil.hgc.jp`を利用することで解決した。
このノードにはグローバルIPアドレスが与えられているため，ローカルPCの`.ssh/config`ファイルに以下の通り記載してあげることで，jupyerから計算ノードに接続できるようになる。
このログインノードではqloginした際の計算ノードと同じ環境になっている。
一方で，このノードで人が直接操作することは推奨されていなかったらしい。(jupyterによる操作は人の操作であるかよくわかっていなかった。)
```
Host hgc
HostName slogin.hgc.jp
User myne812
LocalForward 8888 localhost:8888

Host sutil
HostName 202.175.151.65
User myne812
Port 22
LocalForward 8888 localhost:8888
``` 
自分の場合ローカルPCの`.ssh/config`ファイルは上記のようにしている。　

### <span style="color: red; ">(2020/03/22変更点)</span>  
ロボットのための計算ノードを使用するのはやはりよくないのではないかということで，スパコン上の`.ssh/config`ファイルを編集して，通常の計算ノードにjupyterから入り込むことができるようにすることを目指した。 
この際，やはり計算ノードのグローバルIPアドレスを見つけることができなかったが，あることに気付いた。
*計算ノードにはグローバルIPアドレスが与えられておらず，プライベートIPアドレスしか与えられていない。すなわち，スパコンではゲートウェイ方式を取っており，ログインノードにだけグローバルIPアドレスをふり，計算ノードにはその中でプライベートIPアドレスを振っているのだ。* 
実際に`qlogin`した際のログをみてみると， 
```
Permanently added ‘gc014i,172.28.1.22’ (ECDSA) to the list of known hosts. 
``` 
となっている。ここに表示されているIPアドレスは`172.28.1.22`である。
プライベートIPアドレスには取りうる値が決まっており，そのうちの一つが，
``` 
172.16.0.0 ~ 172.31.255.255 
``` 
であり，実際に今回ログインした計算ノードにはプライベートIPアドレスが振られてたことがわかった。 
では，

#### スパコン上のconfigファイルにプライベートIPアドレスを指定する。 
ここから先は井手さんのホームページを見ればそのまま作業できる。
スパコン上の`.ssh/config`ファイルに適当なプライベートIPアドレスを指定したホストを記載することで，jupyterを起動することができるようになる。(現在はまだ試せていない。)


### スパコン上のjupyter configファイルを設定する。 
井手さんのconfigファイルをお借りしている。下記のコマンドでjupyter configファイルを作成，編集する。 
```
jupyter notebook --generate-config
vi ~/.jupyter/jupyter_notebook_config.py
```
開かれたら，ファイルの最下部に以下の内容を記載する。井手さんのホームページの内容をお借りしている。 
``` 
c = get_config()

# matplotlibで描画したものがnotebook上で表示できるようにする
c.IPKernelApp.pylab = 'inline'
# 全てのIPから接続を許可
c.NotebookApp.ip = '0.0.0.0'
# IPython notebookのログインパスワード
#c.NotebookApp.password = 'sha1:f6aaa78c99d3:1229eee791191644436957a2626cf5619a1bad06'
# 起動時にブラウザを起動させるかの設定(デフォルトは起動させる)
c.NotebookApp.open_browser = False
# ポート指定(デフォルトは8888)
c.NotebookApp.port = 8888

c.NotebookApp.token = '890'
```

### 使ってみる
anaconda(もしくはjupyerに)にpathを通しているなら，編集したいファイルがあるディレクトリに移動し，下記のコマンドを入力する。 
```　
jupyer lab 
```
その際得られるlogが以下のようになっている。 
```
(base) [myne812@gc003 ~]$ jupyter lab
[I 22:34:33.094 LabApp] JupyterLab extension loaded from /home/myne812/anaconda3/lib/python3.7/site-packages/jupyterlab
[I 22:34:33.094 LabApp] JupyterLab application directory is /home/myne812/anaconda3/share/jupyter/lab
[I 22:34:33.127 LabApp] Serving notebooks from local directory: /yshare1/home/myne812
[I 22:34:33.127 LabApp] The Jupyter Notebook is running at:
[I 22:34:33.127 LabApp] http://gc003:8888/?token=...
[I 22:34:33.127 LabApp]  or http://127.0.0.1:8888/?token=...
[I 22:34:33.127 LabApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
``` 
jupyterのconfigファイルにおいて， 
`c.NotebookApp.open_browser = False`と設定している場合，自動ではブラウザが立ち上がらないので， 
上記ログのURLのうち，...の部分をjupyterのconfigファイルで設定したtokenに書き換え，好きなブラウザーに貼り付けることでjupyterが立ち上がる。 
細かい設定などは井手さんのホームページなり自分で調べると色々拡張できる。 

### bashの追加 
一番使うであろうbashスクリプトをjupyter labで編集できるようにする設定を記載する。以下のコマンドをスパコン上で入力すれば良い。 
``` 
pip install bash_kernel
python -m bash_kernel.install 
```  



# VScode 
configファイルにsutilを追加すると，VScodeでもスパコン上のファイルを編集することができる。 
vimの操作になれない自分にとっては非常に便利で重宝している。 

## 操作
macならとても簡単。[このサイト](https://dev.classmethod.jp/etc/vs-code-remote-development-ec2/)を参考にした。
以下に簡単な設定方法を記載するが，configファイルさえ作成してあれば1分ほどで完了する。windowsでも簡単にできる模様。

VScodeの拡張機能である，`Remote Development`をインストールする。これで必要な拡張機能が全てインストールされる。

<img src="https://cdn-ssl-devio-img.classmethod.jp/wp-content/uploads/2019/05/030-min2-960x631.png" width="40%">

すると左のツールバーにRemote-SSHアイコンが現れる
アイコンをクリックすると，configファイルに設定された接続先の一覧が表示される。

<img src="https://cdn-ssl-devio-img.classmethod.jp/wp-content/uploads/2019/05/040-min2.png" width="40%">


接続したいリモート先をクリックするとssh接続される。あとはディレクトリをローカル環境のように移動し，様々なファイルを編集することができる。VScodeの拡張機能を利用することもできるので大変便利である。 
ドラッグ&ドロップなどでファイルを追加することができないのなどは残念なところ。
*もちろんターミナル操作もVScode上で行うことができる。*
