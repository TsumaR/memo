# 東大スパコンでRを使う　

`/usr/local/`に入っているRは編集権限がないため，そのままだと好きにパッケージをインストールして使うことができない。 
この際，自分でRをインストールし，ビルドしてあげればいいのだが，自分の場合以下のエラーによりうまくいかなかった。 

```
checking libcurl version ... 7.64.1
checking curl/curl.h usability... yes
checking curl/curl.h presence... yes
checking for curl/curl.h... yes
checking if libcurl is version 7 and >= 7.22.0... no
configure: error: libcurl >= 7.22.0 library and headers are required with support for https
``` 

そこで，インストールするのではなく，Rが参照するライブラリのディレクトリの設定を変更し，実行できるようにした。

## R_LIBS_USER環境変数の設定 
`.bash_profile`に以下のpathを通し，Rが参照するディレクトリを自分の編集権限があるディレクトリに設定した。 
``` 
$export PATH=/yshare1/home/myne812/R/3.6.0/lib64/R/bin:$PATH
$export R_LIBS_USER=/home/myne812/R/3.6.0/lib64/R/library:$R_LIBS_USER
``` 
また，自分の場合はデフォルトでコピーしたRが起動するようにコピーしたRにもpathを通した。 

## jupyter labで使えるようにする　
以上の操作を加えたら，jupyter labでRを使うのに必要な`IRkernel`パッケージのインストールも可能になっている。 
``` 
>install.packages("devtools")
>install.packages("IRkernel") 
>IRkernel::installspec()
```
を行い，jupyter labでRを自由に操作できるようにした。

 