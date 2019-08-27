### データハッカソンに向けて学習したscATAC-seq analysis  
 **使用する論文**   
 Building gene regulatory networks from scATAC-seq and scRNA-seq using Linked Self-Organizing Maps (bioRxiv, 2018)
 この論文中のSOMaticを使用して論文中のデータをまず再現する。  
 手動でクラスタリングした際の結果と比較する。  

### SOMatic論文   
 ![SOMの方法](https://www.biorxiv.org/content/biorxiv/early/2018/10/09/438937/F5.large.jpg?width=800&height=600&carousel=1 )

 融合するのにこんな面倒な方法を取っているのは，別の細胞からexpressionデータとopen chromatinデータを取っているから生じることだと考えられる。  
 だとしたら今後このようなツールを使う必要はなくなっていく？   
 1. Joint profiling of chromatin accessibility and gene expression in thousands of single cells(Science, 2019)  
 2. Deconvolution of single-cell multi-omics layers reveals regulatory heterogeneity(Nat com, 2019)  
 などで同一細胞からscRNA-seqとscATAC-seqを行なっている。2の方法では，ピーク検出にはMACS2を，ピークのカウントにはChromVARを用いている。1ではピークカウントにHTseqを用いている。同じセル由来のデータなので，単純にカウントして比較することができる？ただし，この場合，N数がだいぶ必要になってくるのは間違いなく，low データの除去を判断するのも大変そう。  
 これらので論文のデータを読み込んで，データとしての価値を理解することが重要。

 モチーフ探索  
 "The regulatory regions in each Linked SOM metacluster were separately scanned for motifs from the HOCOMOCOv11 mouse motif database53 with FIMO v4.9.0_454 using a q-value threshold of .05. "
 これは実際に使うことになる可能性が高い。転写因子のDNA結合領域データベースを利用する。  
 * HOCOMOCO: expansion and enhancement of the collection of transcription factor binding sites models(Nuc acid 2015)

### Seuratのtutrialを動かす
gtfをアノテーションとして，遺伝子本体から+2kbいないのピークカウントの数の合計を単純に遺伝子活動マトリックスとしている。この遺伝子活動マトリックスに対して，教師なしクラスタリングを行う。この際，下のbenchmark論文でも性能の高かったCusanovich2018と同じような原理を用いている。  
scRNA-seqのデータ，scATAC-seqのデータを別々にクラスタリングし，scRNA-seqの結果とアンカーで比較することで２つのデータを紐付けする，この際のアンカーも活動遺伝子に対してのみ。マーカージーンによってscRNA-seqで決まったラベルを，scATAC-seqの結果に加える。  

### SOMaticのtutorialを動かす  
githubから複製する。
```
$git clone http://github.com/csjansen/SOMatic  
$cd SOMatic/bin  
$make  
```
サンプルデータの解凍  
```
cd examples  
tar -zxf *.tgz
```
すると，example.matrixというピークのカウントデータを得られる。  

スパコン上からweb serverを起動する権利が多分ない。他の方法というか対処法はあるのだろうが一旦断念。

### 他の手法の解析を検討
この際に用いる方法としての候補はMACS2でのカウント操作の箇所と，ChromVAR，SnapATAC，Destinのクラスタリング等のかしょ？になってくる？今回はATAC-seqのbamファイル，ここからの解析を考える。
* Assessment of computational methods for the analysis of single-cell ATAC-seq data(bioRxiv 2019)  
でscATAC-seq解析法の比較を行っている。上記の方法も比較対象に入っている。この論文で上位だった方法を試すことが良いかと考えられる。  
この論文中のスクリプトはjupyter notebookとして![ここ](https://github.com/pinellolab/scATAC-benchmarking)にある。  
ただし，今回はRNA-seqとのデータ統合が重要なテーマ，他の方法を試す際にそこらへんの話が重要になることに注意する必要もある。
この論文ではクラス分けする際の能力だけで見ていた。その際に優れていたSnapATACは系統的進化を保存しない可能性が高く，その場合chromVARが優れているとdiscussionで述べられている。
HISAT2-MACS2-ChromVARを，SOMaticの論文データに試してみる。ただし，MACS2は主にBowtie2と使われていることが多いよう(ENCODEのパイプラインがそうなっている。)  

### SeuratデータをSnapATACで解析してみる  
Seuratからダウンロードできるデータは`atac_v1_pbmc_10k_filtered_peak_bc_matrix.h5`，` atac_v1_pbmc_10k_singlecell.csv`,
  `pbmc_10k_v3_filtered_feature_bc_matrix.h5`の３つ。この3つ以外の必要なデータは[!10X Genomicsの公式ページ](https://support.10xgenomics.com/single-cell-atac/datasets/1.1.0/atac_v1_pbmc_10k)よりダウンロードする必要がある。  
  今回は，10k Peripheral blood mononuclear cells (PBMCs) from a healthy donor "Single Cell ATAC Dataset by Cell Ranger ATAC 1.1.0"のデータセットを用いた。Seuratのものと完全に一致しているかは確認していない。

##### Step 1. Create snap file.  
```
$ ~/packages/fetchChromSizes.sh hg38 > hg38.chrom.size
$ #chimeric列でsort
$ sort -k4,4 data/atac_v1_pbmc_10k_singlecell.csv | gzip - > data/atac_v1_pbmc_10k_singlecell.srt.bed.gz
```
`fetchChromSizes`がない場合，`conda install ucsc-fetchchromsizes`でダウンロードして権限を与えて使用する。


 ### Seuratを動かしてみる  
 ### 他の手法を組み合わせてやってみる  
