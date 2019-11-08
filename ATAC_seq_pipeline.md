### ATAC-seq pipelineの作成
とりあえず，今回はバルクのようなデータしか取れないので

#### リファレンスの準備
リファレンス配列は通常，ensebmleかUCSCのゲノムブラウザーからダウンロードする。今回はFASTAファイルをUCSC genome browserから，gtfファイルをensembleから持ってきた。gtfファイルはensembleの方が情報量が多いので詳細解析をする時はgtfの方が良いらしい。　
注意しないといけないのが，ensembleのgene idは単なる数字なのに対してUCSCではchr1のように異なる。それを揃えるためensembleから持ってきたgtfファイルの先頭にchrを加えていく。
```
grep -v \# Homo_sapiens.GRCh38.98.gtf | awk '{print "chr" $0 }' > Homo_sapiens.GRCh38.98.addchr.gtf
```

#### 仮想環境の準備
`conda create -n atac_seq python3.7.1 numpy`
でatac_seq用の仮想環境を作成　
`conda install -c bioconda macs2`
で必要なmacs2をインストールしておく。　

# 手順
#### クリーニング　
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

#### qc
`fastq`を利用してqcファイルの作成。この際，`trimmomatic`を利用してクリーニングした後の配列と，していない配列両方に対してqcreportを作成。その結果を`../result/qcreport`ディレクトリに保存している。後から`multiqc`を用いて１つのqc結果として出力する。　

#### mapping
`STAR`を用いてmappingする。 この際`STAR`は最低32GBのメモリを確保しておくことが推奨されているそうなのでそこに気をつける。
```
$STAR --runThredN $cpu \
    --genomeDir $star_index \
    --readFileIn $cln1 $cln2 \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix ${id}.
```

#### 重複している配列の除去
ピークコールする前に`picard`を用いて重複配列の除去を行う。　

#### ピークコール　
