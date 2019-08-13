## CAT/BATのインストール  
バイオコンダ内に必要なパッケージがまとまっているので以下のコマンドでインストールする。  
```$ conda install -c bioconda cat```  

## Databaseのダウンロード  
CAT/BATを走らせるためにはデータベースが必要となる。自分で用意することも可能らしいが，今回は筆者が用意してくれているpre-buidのdiamondデータベースをダウンロードして行なった。  
この際，最新版がアップデートしているか下記のリンクから確認する必要がある。  >https://tbb.bio.uu.nl/bastiaan/CAT_prepare/  
以下のコマンドで，dataディレクトリにダウンロードした。  
```
$ wget tbb.bio.uu.nl/bastiaan/CAT_prepare/CAT_prepare_20190719.tar.gz

$ tar -xvzf CAT_prepare_20190719.tar.gz
 ```  
 
89GBもあったため，ダウンロードするだけのジョブが1日かかってしまった。もっと早くやる方法はあるか。また，せっかくなのでこのデータベースを東大スパコンのshareディレクトリに入れたい。許可をとって今後行う予定。  
~~また，DIAMONDデータベースの構築とあるが，CATはDIAMONDベースのアルゴリズム？だとしたらBenchmarking Metagenomics Tools for Taxonomic Classification(2019 Cell)の論文的にあまり精度が高くなさそうだが。  
正確に論文を読む必要がある。~~  

(追記)  
DiamondデータベースはCATのアルゴリズムで重要となるORF探索のために使っている。  
実際にアルゴリズムとしてDiamondで分類分けした時との違いが論文中に触れられており，CATの方が精度が高かった。  

## 実行  
* megahitでアセンブリしたcontigに対してアノテーション付けを行う。
