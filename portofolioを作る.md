# portfolioを作る 
HUGOとnetifyで作成したportfolioにすることを目指した，ログブログ。
git submoduleの使い方に詰まったので，[この記事](https://qiita.com/sotarok/items/0d525e568a6088f6f6bb)などを参考にした。

## HUGOのインストール　
```
brew update
brew install HUGO
``` 

## HUGOの準備 
まず，自分のportfolioを設置するディレクトリを作成し，`.git`を作成する。
```
hugo new site portfolio
cd portfolio
git init
git add .
git commit -m 'Initial commit'
```
## HUGOテーマのintroductionをsubmoduleとして導入 
今回のportfolioにはHUGOの[introduction](https://themes.gohugo.io/hugo-theme-introduction/)テーマを用いた。
先ほど作成したportfolioディレクトリに上記のテーマのサブモジュールを追加する。
*(注釈)*
git submodule は、外部の git リポジトリを、自分の git リポジトリのサブディレクトリとして登録し、特定の commit を参照する仕組みです。
通常のレポジトリがブランチ単位で管理するのに対して，サブモジュールはCommitID単位で管理するというのが大きな違い。
`push`権限のため，自分のgithubにフォークしたレポジトリのサブモジュールを加えた。この方法が正しいのかは不確か。
```
git submodule add https://github.com/TsumaR/hugo-theme-introduction.git themes/introduction
git submodule init
git submodule update
git submodule update —remote themes/introduction
``` 





```
git merge --allow-unrelated-histories origin/master
```
で強行突破

## configファイルの編集
```
cd ../../ #元のportfolioディレクトリに移動
cp ./themes/introduction/exampleSite/config.toml ./config.toml
```
言語設定を日本語に，contentDirの設定を`content`に変更する。
```
vim config.toml
git add config.toml
git commit -m "setting config file"
```

## 基本ファイルの作成　

とりあえず，骨格となる書類を追加していく。
```
hugo new home/index.md
hugo new blog/_index.md
hugo new work/_index.md
```
形式はsubmoduleした`themes/introduction/exampleSite`の中にあるファイルを参考にしてvimで編集した。

## ローカルでサイトの確認
```
hugo server
```
上記のコマンドにより，ポート1313のローカルサーバーが立ち上がる。ブラウザから`http://localhost:1313/`にアクセスして挙動を確認する。

# netlifyでの公開 
次に作成したホームページを公開する。
```
hugo
```
でpublicディレクトリの作成。さらに，netlifyの公式[サイト](https://gohugo.io/hosting-and-deployment/hosting-on-netlify/)よりコピーした`netlify.toml`を[これらのサイト](https://qiita.com/jrfk/items/4c6df87ca72a76e30224)を参考にして修正。

[参考文献1](https://blog.tomoya.dev/2019/01/hugo-with-netlify/)



# 注意　
submoduleを理解していないせいで
```
git merge --allow-unrelated-histories origin/master
```
をする羽目になった。
というかもしかしたらそれですらなく，readmeを作ったならまずそれをpullしないと時系列がずれてしまっているだけかもしれない。ていうか多分そうだ。すごい基本的なことをミスっていた。