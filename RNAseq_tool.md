# RNA-seqに使えるツール　
近年のRNA-seq解析の進展は凄まじく，基本的に下流解析においてはSeurat，scanpy，Monocleといった主要なソフトウェアが地位を確立した。解析が簡単に行えるようになった現在では，細胞をクラスタリングし，マーカー遺伝子を定義するだけの解析を行う時代は終わったと言える。そのため，分化解析など様々な応用的解析を行えるようになっておくことが必要となる。 


## 事前処理 
カウントデータを取得してからの解析における，事前処理について説明する。
(1)生データ→(2)正規化データ→(3)修正データ→(4)機能選択データ→(5)次元削減データという流れ。データによっては各ステップを省略することもある。
### Normalization 
シングルセルRNA-seqのようなデータではCPMで発言量比較を行うべきではない。CPMはサンプルあたりのリード数の差が実験主義によるものだけであると仮定している。そのため，scRNA-seqのようにサンプルごとにそもそも保有する遺伝子の量が違うサンプルを比較する上では適さない。 
また，さらに大変な点として，scRNA-seqにおいては常にある正規化が正しいという決まった正規化の手法があるわけではない。そこで，現状では[Scone](https://www.sciencedirect.com/science/article/abs/pii/S2405471219300808?via%3Dihub) というツールを使用し，そのデータセットに適した正規化手法を探るのがベストっぽい(2019 6月現在)
一方で，full-lengthを取ってくるRNA-seq手法においては長さを考慮して正規化することが重要となってくる。多くの場合で利用されているのはTPMであり，多少偽陽性を削減することがわかっている。[[1]](https://www.nature.com/articles/nmeth.4612)
(*しかし，TPMでは上の欠点を除去できていない。シングルセル用のTPMみたいのがあるのか調べる必要がある。*)
また，第一種の過誤(帰無仮説が真であるのにも関わらず，帰無仮説を偽として棄却してしまう誤りのこと。すなわち偽陽性)は，低発現遺伝子を除外するとで，ほとんどのツールにおいてパフフォーマンスが大幅に安定化する。[[1]](https://www.nature.com/articles/nmeth.4612) 
多くの場合，正規化後に`log(x+1)`の変換を行い，比較をする。正規分布を仮定する多くのツールに用いるためや，1セルごとの平均や分散の関係を軽減するなど多くの利点がある。
非全長データセットの正規化にはscran，全長の場合はTPM(CPM)でよい。

#### 遺伝子数の正規化 
遺伝子のカウントデータをz scoreに変換する流派もある。下流の解析で全ての遺伝子を対等に扱うことができるためである。ただし，多くの生物学的情報が失われる側面もあるので意見が別れているところ。この場合，正規化後に`log(x+1)`の変換を行う。

### バッチ処理など 
`ComBat`，Mutual Nearest Neighbors(Haghverdi et al., 2018)など色々な手法があるが，現状でどれが優れているか判断するのは難しい。

## 特徴選択と次元削減 
### 特徴抽出 
多くの場合，多くの情報を提供するHVGsだけに注目する。[[2]](https://www.ncbi.nlm.nih.gov/pubmed/24056876?dopt=Abstract)下流の処理によるが，だいたい1000~5000の遺伝子を用いる。選ぶ量は下流の操作によるらしいので，どのように行うべきかは都度調べるべき。
では，このHVGsをどのように選ぶかという話だが，ScanpyやSeuratには元から実装されている。それらのツールにおいては，平均発現量によってビニングされ，分散と平均の比が最も高い遺伝子が各ビンのHGVsとして選択される。Seuratにおいてはカウントデータにこの処理を施す。HVGs選択についての詳しい情報はこの[論文](https://academic.oup.com/bib/article/20/4/1583/4898116)にあるらしい。

### 次元削減 
大きく分けて*visualization*と*summarization*の二つの方針がある。visualizationでは，2~3次元で表現し，scatter plotなどで視覚的に代表的な情報を取得することを目的とする。summarizationではデータを必須コンポーネントのみに減らすことができ，下流の分析のためのノイズ除去などに役立つ。詳しい[レビュー論文](https://www.sciencedirect.com/science/article/pii/S2452310017301877)も存在するため，tSNEやPCAの詳細な説明が必要な場合はこの論文を読む必要がある。visualizationの代表としてはtSNE，summarizationの代表としてはPCAがある。
主成分分析は線形アプローチで，多くの非線形アプローチに用いるための前処理として利用される。
一方で，visualizationを目的とする場合，非線形の次元削減手法を使用するのが標準的である。tSNEはグローバル構造を犠牲にして局所的な類似性をキャプチャすることに焦点を当てている。現状はUMAPが一強か。　


## Down stream analysis
事前処理が終わった後のカウントマトリックスデータの解析。主に次元削減まで行なったデータに対して行う。下の図にあるように，細胞レベルの解析と遺伝子レベルの解析の2パターンに分類される。
[!dsa](https://www.embopress.org/cms/asset/9ab3954e-cec2-48c6-b8c7-b3f51ced79ff/msb188746-fig-0005-m.jpg)
細胞レベルの解析はさらにクラスター分析とtrajectory(軌道)解析に別れる。

### Clustering 
一般的な手法は，PCで縮小された表現空間で計算される(ユークリッド)距離の類似性スコアからクラスターを生成する。この手法の中にもクラスタリングアルゴリズムとコミュニティ検出法の二つのアプローチがある。 
*クラスタリングアルゴリズム…k-meansなど。k-meansは距離metricに依存するが，相関ベースの距離が優れているとされている。
*コミュニティー検出法…KNN(k nearest neighbor)など。kNNはクラスタリング手法より早く，Seuratにおいてデフォルトで使用されている。Seuratのデフォルトは[Louvain community detectionのkNN](https://iopscience.iop.org/article/10.1088/1742-5468/2008/10/P10008/meta)，優れたクラスタリング結果をもたらし，利用することが推奨されていた。

### Cluster annotation


## 遺伝子発現リファレンスデータセット 
### Tabula muris 
### RefEx 
相対発現量を人体3Dマップしたものを見ることができる。組織ごとにCAGEやRNA-seqでどうなっているかを見ることができる。GOやGTExへのリンクもある。確認用に利用するのが良さそう。

## 配列検索 
### GGGenome 
pandasでそのまま`read_csv`することも可能。 

## 可視化ツール　
[SCope](http://scope.aertslab.org/#/363ee765-464b-40c7-98e6-daba8a91a956/*/welcome) 

## 転写因子解析 
### wPGSA
### SCENIC 
遺伝子発現ネットワーク解析 

### scTsnsor，cellphoneDB 
receptor-ligandネットワーク解析　

# 参考文献　
https://www.embopress.org/doi/10.15252/msb.20188746
https://www.ncbi.nlm.nih.gov/pubmed/24056876?dopt=Abstract