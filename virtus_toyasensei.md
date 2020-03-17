# 遠野先生Hi-Seqランの追加解析

Mi-Seqのデータでサイトメガロウイルスにマップされるリードが存在しなかったため，HiSeqで追加ランしたが，結局ヒットしなかったデータ。
目的ウイルスをリファレンスにし，直接マッピングする手法を取っていた。今回，ヒトなどに対する通常のRNA-seq結果から，763ウイルスにマッピングしてくれる[パイプラインツール](https://github.com/yyoshiaki/VIRTUS)を用いて包括的にウイルスゲノムを調べる。

## 必要ツールのインストール
このパイプラインはワークフロー言語のCWLを用いており，docker環境を利用できるので，基本的にツールのインストールは必要ない。自分の場合，CWLがスパコン上に存在しなかったため，CWLのインストールだけ行った。
また，このパイプラインはdockerを利用することを前提としているが，東大スパコンとOILのスパコンにdockerは存在しないため，singularityを利用する必要がある。その点を変更して記載したのが以下の手順スクリプトである。


#### 1. 仮想環境作成 
```
conda create -n cwl_env 
``` 

#### 2. cwlインストール 
```
pip install cwl 
``` 
この際，condaでインストールしようとしたが，謎のエラーが発生したので，pipを使った。　
また，一部のcwlはjavascriptを利用しているため，node.jsが必要になるのでインストールする。 
``` 
conda install nodejs 
```

#### 3. VIRTUSレポジトリのクローン 
``` 
git clone https://github.com/yyoshiaki/VIRTUS.git 
``` 

#### 4. インデックスの作成 
この操作は最初の一回のみで良い。 
``` 
cwltool --singularity VIRTUS/workflow/createindex.cwl createindex.job.yaml 
``` 

#### 5.　実行　
1ファイルごとにコマンドを実行する必要がある。自分の場合はサンプルごとにディレクトリを作成し，作成したジョブスクリプトを投げるごとで同時に処理できるようにした。 
```
cwltool --singularity ../../VIRTUS/workflow/VIRTUS.PE.cwl \
--fastq1 raw_1.fastq.gz \
--fastq2 raw_2.fastq.gz \
--genomeDir_human ../../STAR_index_human \
--genomeDir_virus ../../STAR_index_virus \
--salmon_index_human ../../salmon_index_human \
--salmon_quantdir_human salmon_human \
--outFileNamePrefix_human human \
--nthreads 8
``` 
で動いた。

## 処理内容 
STARでヒトゲノムにマッピングを行い，`samtools view`でunmapを抽出。`bedtools bamtofastq`でそれらをfastqに戻す。[VirTect](https://github.com/WGLab/VirTect)のウイルスゲノムをリファレンスにしてマッピングし，ウイルスにマッピングされる配列を取得する。  

## 結果 
目的のサイトメガロウイルスにマッピングされなかったが，同じヘルペスウイルス属の7型に1条件だけマッピングされた。　
この時，どのように張り付いているのかが気になる。

#### ヘルペスウイルスだけのbamファイル 
VIRTUSを動かした後には，ヒトゲノムにアンマップだったリードをウイルスゲノムにマップした結果のbamファイルが含まれる。 
今回，ヘルペスウイルスのどのあたりにマッピングされているのかを確認するために，とりあえずherpesvirus_7に張り付いているリードをbamファイルから抽出した。 
```
samtools view -@ 10 -h virusAligned.sortedByCoord.out.bam | grep "herpesvirus_7" samtools view -b | samtools sort -@ 8> herpesvirus7.bam 
``` 

その結果をigvで表示した。この際fastaファイルをツールで参照しているウイルス763を含むものにしないと，参照名の違いによりエラーが発生して表示されなかった。

#### リード数が与える影響の確認 

リード数 
../P14_E1-01/humanLog.final.out:                          Number of input reads | 38649055
../P14_E1-02/humanLog.final.out:                          Number of input reads | 33191521
../P14_E1-03/humanLog.final.out:                          Number of input reads | 35365741
../P14_E1-04/humanLog.final.out:                          Number of input reads | 60064508
../P14_E1-05/humanLog.final.out:                          Number of input reads | 33287752
../P14_E1-07/humanLog.final.out:                          Number of input reads | 28832664
../P14_E1-08/humanLog.final.out:                          Number of input reads | 29778196
../P14_E1-09/humanLog.final.out:                          Number of input reads | 29911098
../P14_E1-10/humanLog.final.out:                          Number of input reads | 16698732
../P14_E1-11/humanLog.final.out:                          Number of input reads | 17289084
../P14_E1-12/humanLog.final.out:                          Number of input reads | 39701191

ウイルスにマッピングした際のリード数は 
../P14_E1-01/virusLog.final.out:                          Number of input reads | 2655508
../P14_E1-02/virusLog.final.out:                          Number of input reads | 3124898
../P14_E1-03/virusLog.final.out:                          Number of input reads | 2428111
../P14_E1-04/virusLog.final.out:                          Number of input reads | 10639309
../P14_E1-05/virusLog.final.out:                          Number of input reads | 2781987
../P14_E1-07/virusLog.final.out:                          Number of input reads | 2996344
../P14_E1-08/virusLog.final.out:                          Number of input reads | 5947061
../P14_E1-09/virusLog.final.out:                          Number of input reads | 6377769
../P14_E1-10/virusLog.final.out:                          Number of input reads | 4254719
../P14_E1-11/virusLog.final.out:                          Number of input reads | 3842958
../P14_E1-12/virusLog.final.out:                          Number of input reads | 5601884 

であり，リード数自体が条件に影響を与えているわけではなさそう。 

#### 挿入箇所の確認 
igvの結果を見ると，同じ箇所が挿入されていることがわかった。
700~900(1200)くらいと，9800ふきん，143000ふきん，153000付近。 
この箇所の配列と，特徴を文献より調べる。

全て遺伝子領域と重複していなかった。おそらく配列特異性によるエラーであると考えられる。マッピングされている領域の長さも,共通してcoverageが高くなっているところは100bp未満であり，反復配列などのエラーによるものである可能性が高いことがわかる。
