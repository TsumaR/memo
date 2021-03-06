### Seurat tutorialを行なって
single cell解析パイプラインであるSeuraのtutorialを行なってみて，今後全ての解析において注意していかないといけない，いくつかの事柄があったので記載する。  

### データのスケーリング（線形変換)
PCAなどで，細胞ごとの特徴を比較する際に，カウント結果などを線形変換により正規化することは重要である。  
これを行わない場合，発現の高い遺伝子がPCAなどのクラスタリング結果に与える影響が大きくなってしまう。  

### 優位に発現が変動している遺伝子の抽出  
必ずしも全遺伝子を対象に次元削減を行う必要はない。その前に，群を意識せずにサンプル全体に対して，あるサンプルで優位に発現が変動している遺伝子だけを取り出し，その遺伝子のみをPCAなどの対象にすることができる。この際Seuraのデフォルトでは標準偏差1を利用していた。

### データセットの次元を決定する
メタデータに対してPCAを行い，影響の大きいPCの数でデータの次元を決定する。  
ランダムにデータのサブセットを取り出しPCAを繰り返して重要なPCの数を決定する方法もあるが，時間がかかる。  
簡単に行う場合は ```heuristic method generates an ‘Elbow plot’``` を行うのが良い。
各PCの分散を計算し，横軸にPC，縦軸にPCでプロットすることで単純に次元ごとの分散を目視することができる。  
この際に，本当に消去していいPCか見るために，各PCでtopの遺伝子を表示して実際に確認してみるのも良い。  

この次元は，UMAPやtSNEで次元削減した際にグループとして認識するためのセルクラスターの数の計算に利用される。tSNEなどでの色の違いは，セルを統計的にクラスタリングした結果を表している。  
SeuratではまずKNNを行うのだが，この時に先ほど決定した次元を指定してクラスの数を規定するのである。    
Seuratでは，Louvainアルゴリズム（デフォルト）またはSLMを使用して，クラスタリングを最適化している。  

###

