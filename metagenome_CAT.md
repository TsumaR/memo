### CAT/BATのインストール  
バイオコンダ内に必要なパッケージがまとまっているので以下のコマンドでインストールする。  
```$ conda install -c bioconda cat```  

### Databaseのダウンロード  
CAT/BATを走らせるためにはデータベースが必要となる。自分で用意することも可能らしいが，今回は筆者が用意してくれているpre-buidのdiamondデータベースをダウンロードして行なった。  
この際，最新版がアップデートしているか下記のリンクから確認する必要がある。  >https://tbb.bio.uu.nl/bastiaan/CAT_prepare/  
以下のコマンドで，dataディレクトリにダウンロードした。  
```
$ wget tbb.bio.uu.nl/bastiaan/CAT_prepare/CAT_prepare_20190719.tar.gz

$ tar -xvzf CAT_prepare_20190719.tar.gz
 ```  
### 実行  
* megahitでアセンブリしたcontigに対してアノテーション付けを行う。
