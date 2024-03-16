#!/bin/bash

# toil-cwl-runnerがvenv環境下にインストールされている前提
## 例
## python3 -m venv venv-toil.5.12.0-ubuntu
## source venv-toil.5.12.0-ubuntu/bin/activate
## pip install toil[cwl]==5.12.0

## 16Giの最後のiは、javaでのメモリ指定に合わせるため。このiがなく16Gだと、1000の倍数で計算されて
## 若干メモリが足りず、ジョブスケジューラまたはjavaでエラーになることがある。
# MAXMEM
MAXMEM=16Gi
# 実際のメモリ、以前はMAXMEM - 1 GBがよいとおもっていたが、toilのメモリ指定のときに 8Gi となるようにしてjavaと合わせるようにしたので、おなじでよい
ACTUALMEM=16Gi

# ジョブファイル
JOBFILE=dfast_dfastqc_mgnify_chicken-gut.yaml
# 出力用のディレクトリのprefix、カレントディレクトリ以下に次のディレクトリが作られる。
PREFIX=output_mgnify_chicken-gut_all_samples_1/$(basename -s .yaml ${JOBFILE})
# CWLファイル
CWLFILE=workflow/dfast-dfastqc-filelist-mgnify.cwl 
# 

#
# restart
#  初回の実行では、RESTARTは、空文字列にする。
#  エラーがでる、スタックするなどしたあと、再開するときは、RESTARTに--restartをしていする。
#  toilのjobstoreが存在する前提
RESTART=""
#RESTART="--restart"

## 基本的に以下の部分は、変更の必要ない

## qacct error 対策用コード開始

#ACCOUNTINGFILE=$PWD/${PREFIX}/accounting.txt
#mkdir -p ${PREFIX}
#mkdir -p ${PREFIX}/bin
#cat << EOS >  ${PREFIX}/bin/qacct
##!/bin/bash
#for i in \`seq 1 10\`
#do
#  touch ${ACCOUNTINGFILE}
#  if /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@" &> /dev/null ; then
#    break
#  fi
#  sleep 1
#done
#if /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@" &> /dev/null ; then
#  /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@"
#else
#  /home/geadmin2/UGES/bin/lx-amd64/qacct "\$@"
#fi
#EOS
#chmod 755  ${PREFIX}/bin/qacct
#PATH=${PREFIX}/bin:${PATH}

mkdir -p ${PREFIX}
mkdir -p ${PREFIX}/bin
cat << EOS >  ${PREFIX}/bin/qacct
#!/bin/bash
#for i in \`seq 1 10\`
#do
#  if /home/geadmin2/UGES/bin/lx-amd64/qacct "\$@" &> /dev/null ; then
#    break
#  fi
#  sleep 1
#done
#sleep 10
max_attempts=3

attempt=1

while [ \$attempt -le \$max_attempts ]
do
    command_output=\$(/home/geadmin2/UGES/bin/lx-amd64/qacct "\$@")
    if [ \$? -eq 0 ]; then
        break
    else
        echo "コマンド失敗、再試行します... (試行回数: \$attempt)\n\$@\n" >> ${PREFIX}/qacct-log.txt
        sleep 1
    fi

    # 試行回数を増やす
    attempt=\$((attempt+1))
done
/home/geadmin2/UGES/bin/lx-amd64/qacct "\$@"
EOS
chmod 755  ${PREFIX}/bin/qacct
PATH=${PREFIX}/bin:${PATH}
#
## qacct用
#tail -f /home/geadmin2/UGES/uges/common/accounting | grep ":${USER}:" > ${ACCOUNTINGFILE} &
#TAILPROCESS=$!
#echo ${TAILPROCESS} > ${PREFIX}/tail.process.pid.txt
## qacct error 対策用コード終了

# 情報のダンプ
NOW=$(date "+%Y%m%d%H%M%S")
NOWDIR=${PREFIX}/${NOW}
mkdir -p ${NOWDIR}
VERSIONFILE=${NOWDIR}/versions.txt
#
cwltool --version > ${VERSIONFILE}
toil-cwl-runner --version >> ${VERSIONFILE}
echo "python path" >> ${VERSIONFILE}
echo "    python $(which python)" >> ${VERSIONFILE}
echo "    python version $(python --version)" >> ${VERSIONFILE}
echo "    python sys.path $(python -c 'import sys; print(sys.path)')" >> ${VERSIONFILE}
echo "    python \$HOME  = $(python -c 'import os; print(os.path.expanduser("~"))')" >> ${VERSIONFILE}

echo "VIRTUAL_ENV=[${VIRTUAL_ENV}]" >> ${VERSIONFILE}

mkdir -p ${PREFIX}/writeLogs
mkdir -p ${PREFIX}/workdir
mkdir -p ${PREFIX}/coorddir
mkdir -p ${PREFIX}/tmpdir
cp $0 ${NOWDIR}
cp ${JOBFILE} ${NOWDIR}
cp ${CWLFILE} ${NOWDIR}

WRITELOGSDIR=$PWD/${PREFIX}/writeLogs
WRITELOGSDIR_RESOLVED=$(readlink -f ${WRITELOGSDIR})


# toil options

## for debug
# --cleanWorkDir never \
# --servicePollingInterval 20 \


## IMPORTANT: at least SLURM and singularity, slurm erace XDG_RUNTIME_DIR 
## SINGULARITY_BIND for writeLogs is required when job finished with fail.
# --coordinationDir /tmp \
# --writeLogs ${PREFIX}/writeLogs \


TMPDIR=${PREFIX}/tmpdir \
SINGULARITY_BIND=${WRITELOGSDIR}:${WRITELOGSDIR},${WRITELOGSDIR_RESOLVED}:${WRITELOGSDIR_RESOLVED} \
TOIL_GRIDENGINE_ARGS=" -l s_vmem=${MAXMEM}  -l mem_req=${MAXMEM} " \
OMP_NUM_THREADS=1 \
MALLOC_ARENA_MAX=1 \
CWL_SINGULARITY_CACHE=~/.singularity_cache_dfast \
TOIL_CHECK_ENV=True \
toil-cwl-runner \
 ${RESTART} \
 --retryCount 3 \
 --relax-path-checks \
 --jobStore ${PREFIX}/jobstore \
 --bypass-file-store \
 --singularity \
 --batchSystem grid_engine \
 --defaultMemory ${ACTUALMEM} \
 --maxMemory ${MAXMEM} \
 --outdir ${PREFIX}/output \
  ${CWLFILE} ${JOBFILE} &> ${PREFIX}/toil_output.${NOW}.txt
TOILRESULT=$?
# stop tail process
#kill ${TAILPROCESS}
exit ${TOILRESULT}

