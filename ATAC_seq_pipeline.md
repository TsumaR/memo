# GM12878 50細胞シーケンス結果の解析
とりあえず，今回はバルクのようなデータしか取れないのでピークコールし，アノテーション付するところまで行なった。

### リファレンスの準備
リファレンス配列は通常，ensebmleかUCSCのゲノムブラウザーからダウンロードする。今回はFASTAファイルをUCSC genome browserから，gtfファイルをensembleから持ってきた。gtfファイルはensembleの方が情報量が多いので詳細解析をする時はgtfの方が良いらしい。　
注意しないといけないのが，ensembleのgene idは単なる数字なのに対してUCSCではchr1のように異なる。それを揃えるためensembleから持ってきたgtfファイルの先頭にchrを加えていく。
```
grep -v \# Homo_sapiens.GRCh38.98.gtf | awk '{print "chr" $0 }' > Homo_sapiens.GRCh38.98.addchr.gtf
```

### 仮想環境の準備
`conda create -n atac_seq python3.7.1 numpy`
でatac_seq用の仮想環境を作成　
`conda install -c bioconda macs2`
で必要なmacs2をインストールしておく。　

# 手順
### クリーニング　
`trimmomatic`を利用してアダプター配列や末端の配列を除去する。　
```
java -jar $trimmomatic \
    PE -phred33 -threads $cpu \
    -trimlog $qc_dir/${id}_log.txt \
    ${id}_1.fastq \
    ${id}_2.fastq \
    $cln1 $uncln1 \
    $cln2 $uncln2 \
    ILLUMINACLIP:$adapter:2:30:10 \
    LEADING:20 \
    TRAILING:20 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36
```


### qc
`fastq`を利用してqcファイルの作成。この際，`trimmomatic`を利用してクリーニングした後の配列と，していない配列両方に対してqcreportを作成。その結果を`../result/qcreport`ディレクトリに保存している。　
パイプラインと別に後から，`../result/qcreport`ディレクトリで，
```
multiqc .
```
を用いて１つのqcレポートにまとめる。 ~~その予定だが，`networkx`パッケージを見つけることができないというエラーを吐かれて実行できない。環境が壊れてしまっているのか，改めて入れ直して実行してもうまくいかない。~~　
仕方なく，`pip install networkx`したらうまくいった。

### mapping
`STAR`を用いてmappingする。 この際`STAR`は最低32GBのメモリを確保しておくことが推奨されているそうなのでそこに気をつける。
```
$STAR --runThredN $cpu \
    --genomeDir $star_index \
    --readFileIn $cln1 $cln2 \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix ${id}.
```

### 重複している配列の除去，ミトコンドリア配列の除去
ピークコールする前に`picard`を用いて重複配列の除去を行う。MultiQCによるQCレポートを見るとわかるが，今回はduplicateが異常に多かった(約95%)，そのため，この操作の際にファイル容量が大幅に減少した。 　
```
java -jar $picard MarkDuplicates \
    I=${id}.bamAligned.sortedByCoord.out.bam \
    M=${id}_dupl.bam \
    O=$cln_bam
```　
さらに，ミトコンドリアとY染色体にあったっているリードを除去する。ただし，今回はミトコンドリアに当たっているリードは0だった。　
`samtools`を用いてそれらのクリーニングを行なった後に，のちの解析のため，sortとindex作成を行なっておく。
```
$samtools view -h -F4 $ddup_bam | grep -v chrM | $samtools view -b > $MT_bam
$samtools view -h -F4 $MT_bam | grep -v chrY | $samtools view -b > $cln_bam
$samtools sort -o $cln_bam $cln_bam
$samtools index $cln_bam  
```

### ピークコール　
`macs2`を用いてピークコールする。
```
macs2 callpeak \
    -t $cln_bam \
    -n $id \
    -f BAMPE \
    -g $species \
    --nomodel \
    --nolambda \
    --keep-dup all \
    --call-summits
```

### ピークマージと比較
得られたピークをマージする。
```
cat a.bed b.bed c.bed | sort -k1,1 -k2,2n | bedtools merge -i - > merged.bed
```
マージしたピークとリファレンスゲノムの比較を行うため，重複を調べる。この際，-fパラメータを指定しないので1塩基でも重複していたら重複とした。
```
bedtools intersect -a merged.bed -b ../../../omni_atac/SRR5427886/SRR5427886_peaks.narrowPeak -sorted > intersect_omni.bed
```
この結果を`unique -u intersect_omni.bed | wc -l `で確認したところ，`1105`
一方で，今回の実験で得られたシーケンス結果をマージした際のピーク数は，`uniq -u merged.bed | wc -l`で，`6847`だった。

### ピークのアノテーション付け
HOMERの`annotatePeaks.pl`を用いて，MACS2によって得られたピークにアノテーション付けを行う。
```
$annotate ${id}_peaks.narrowPeak hg38 > $an_peak
```
間違っている気もするので，中身の確認をしっかりと行う必要がある。

### R，pythonでの解析
以上の操作によって得られたファイル，マージのピークファイル，アノテーションファイル(今回はマージしていないもの)，
