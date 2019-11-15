## RamDaQを試す
### 1. Installing Nextflow
```
mkdir -p ~/bin
cd ~/bin
wget -qO- https://get.nextflow.io | bash
```
をしたところ以下のエラーが発生した。
```
Picked up JAVA_TOOL_OPTIONS: -XX:+UseSerialGC -Xmx64m -Xms32m
CAPSULE EXCEPTION: Could not parse version line: Picked up JAVA_TOOL_OPTIONS: -XX:+UseSerialGC -Xmx64m -Xms32m (for stack trace, run with -Dcapsule.log=verbose)
USAGE: java <options> -jar ../.nextflow/framework/19.10.0/nextflow-19.10.0-one.jar

Actions:
  capsule.version - Prints the capsule and application versions.
  capsule.modes - Prints all available capsule modes.
  capsule.jvms - Prints a list of all JVM installations found.
  capsule.help - Prints this help message.
  capsule.tree - Prints the capsule's dependency tree.
  capsule.resolve - Downloads all un-cached dependencies.

Options:
  capsule.mode=<value> - Picks the capsule mode to run.
  capsule.reset - Resets the capsule cache before launching. The capsule to be re-extracted (if applicable), and other possibly cached files will be recreated.
  capsule.log=<value> (default: quiet) - Picks a log level. Must be one of none, quiet, verbose, or debug.
  capsule.java.home=<value> - Sets the location of the Java home (JVM installation directory) to use; If 'current' forces the use of the JVM that launched the capsule.
  capsule.java.cmd=<value> - Sets the path to the Java executable to use.
  capsule.jvm.args=<value> - Sets additional JVM arguments to use when running the application.
  capsule.local=<value> - Sets the path of the local Maven repository to use.
Unable to initialize nextflow environment
```

環境を初期化できないと言われ，インストールができなかった。そこで，binディレクトリ内で
```
java -jar ../.nextflow/framework/19.10.0/nextflow-19.10.0-one.jar
```
を実行。それでもうまくいかない，，
Githubのリードミーでanacondaでも利用できるとあったので，anaconda環境で実行することに変更。
したがうまく行かない，
`JAVA_TOOL_OPTIONS: -XX:ParallelGCThreads=2` を指定してみたが，
```
CAPSULE EXCEPTION: Could not parse version line: Picked up JAVA_TOOL_OPTIONS: -XX:ParallelGCThreads=2 (for stack trace, run with -Dcapsule.log=verbose)
```
というエラー。バージョン指定がうまく行っていないという後ろにoptionのコマンドがあるので，　
`unset JAVA_TOOL_OPTIONS`
にしたらhelloはうまく行った。　
しかし，
```
WARN: Singularity cache directory has not been defined -- Remote image will be stored in the path: /yshare1/home/myne812/test/ramda_test_1st/work/singularity
Error executing process > 'run_fastqmcf (ramda_test)'

Caused by:
  Failed to pull singularity image
  command: singularity pull  --name docker.io-myoshimura080822-fastqmcf-1.0.img docker://docker.io/myoshimura080822/fastqmcf:1.0 > /dev/null
  status : 1
  message:
    WARNING: pull for Docker Hub is not guaranteed to produce the
    WARNING: same image on repeated pull. Use Singularity Registry
    WARNING: (shub://) to pull exactly equivalent images.
    ERROR Authentication error, exiting.
    ERROR: pulling container failed!
```
認証エラー。docker.ioからpullするときにエラーが発生していることがわかる。アカウントを指定してあげないといけないっぽい。　
```
https://github.com/sylabs/singularity/issues/1386
```  
`qc_pe/02_ramdaQC_PE_fastqmcf_fastQC.nf` ファイルの，
`container "docker.io/myoshimura080822/fastqmcf:1.0"` を
`container "index.docker.io/myoshimura080822/fastqmcf:1.0"` に書き換え

動いた
今度はファイル見つからないと以下のエラーで言われる。
```
Command executed:

  fastqc -o . --nogroup /yshare1/home/myne812/test/ramda_test_1st/output_ramda_test/FASTQ/c2-x0-5-P_S19_L001_R1_001.fastq.gz && unzip c2-x0-5-P_R1_trim_fastqc.zip
  fastqc -o . --nogroup /yshare1/home/myne812/test/ramda_test_1st/output_ramda_test/FASTQ/c2-x0-5-P_S19_L001_R2_001.fastq.gz && unzip c2-x0-5-P_R2_trim_fastqc.zip
```
そこで，
```
script:
    """
    fastqc -o . --nogroup $fastq_L && unzip ${fastq_L_name}_trim_fastqc.zip
    fastqc -o . --nogroup $fastq_R && unzip ${fastq_R_name}_trim_fastqc.zip
    """
```
でダブルクオテーションを3つの"""から""の2つに変更した。エラーは発生しなくなったが，そもそもコマンドが動いていない。

下流において，

からprocess run_fastQC {の
&& unzip ${fastq_R_name}_trim_fastqc.zip
を消去してみた。
fastqc -o . --nogroup path だけになってもno such fileになってしまった。

うまく行かない。。。
