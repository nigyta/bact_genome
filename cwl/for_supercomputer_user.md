## This document

This document NIG General Analysis Section.

But almost case, you can run any computer center.

- First login to gateway, Second qlogin to compute node.



### qloign

after connect to the gateway machine,
qlogin to machine.

## Install toil to exec dfast and dfastqc in CWL

`python3 -m venv venv`
`source venv/bin/activate`

Finally install toil.

`pip install toil[cwl]==5.11.0`

### Which version is good ?

python latest version on your environment is good.
toil latest stable version is good.

[python](https://www.python.org/downloads/)
[toil release history](https://pypi.org/project/toil/#history)

### Check toil and cwltool version

- `toil-cwl-runner --version`
- `cwltool --version`

|Tool|version|
|---|---|
|toil-cwl-runner|5.11.0|
|cwltool|3.1.20230425144158|

### mutltiplexa is strongly recommended

Such kind of multiplexa is recommended.

- screen
- tmux
- byobu

Almost case, job executions are take times.
If you don't use such a software, network is disconnected, execution stops.

## Install dfast and dfastqc

dfast

https://github.com/nigyta/bact_genome/blob/master/cwl/tool/dfast/dfast.cwl

dfastqc



### dfast and dfastqc version

|Tool|version|
|---|---|
|dfast|1.20.0|
|dfastqc|0.5.7_2|

## TODO repository

dfast and dfastqc.

## Job file structure.

### dfast

```yaml
dbroot:
    class: Directory
    path: /gpfs1/dpl0/ddbjshare/public/ddbj.nig.ac.jp/dfast/dfast_core_db
cpu: 1
no_hmm: true
no_cdd: true

genome_list:
    - class: File
      path: fna or fna.gz
    ### samples here
```

### dfastqc

```yaml
num_threads: 1
reference:
    class: Directory
    path: /gpfs1/dpl0/ddbjshare/public/ddbj.nig.ac.jp/dfast/dqc_reference

genome_list:
    - class: File
      path: fna or fna.gz
    ### samples here
```

### for qacct

for qacct

accounting file is big.
To check job status almost 10sec per job.

```shell
${SGE_ROOT}/${SGE_CELL}/common/accounting
```

### create singularity cache

If there is no singularity cache, it will be created on demand.
But for that, it will needs internet connection.
If internet connection is down even if 

```
cd jga-analysis
CWL_SINGULARITY_CACHE=~/.singularity_cache_dfast ./create_singularity.sh per-sample
```



## how to execute



### cwltool

```
cwltool dfast-filelist.cwl jobfile.yaml
```

### toil

```
toil-cwl-runner --batchSystem grid-engine dfast-filelist.cwl jobfile.yaml
```



## script

TODO: install distributing shebang 


```bash
#!/bin/bash

# MAXMEM
MAXMEM=8G
# Actual mem, MAXMEM - 1 GB is recommended
ACTUALMEM=7G

# Job file
JOBFILE=dfastqc_GCA_under10M_ag.yaml
PREFIX=MAGoutput_dfastqc_218655/$(basename -s .yaml ${JOBFILE})
# CWL description
CWLFILE=dfast_qc_filelist_0.5.7_2.cwl
DESCRIPTION="dfast_qc 0.5.7_2 toil"

ACCOUNTINGFILE=$PWD/${PREFIX}/accounting.txt
mkdir -p ${PREFIX}
mkdir -p ${PREFIX}/bin
cat << EOS >  ${PREFIX}/bin/qacct
#!/bin/bash
for i in \`seq 1 10\`
do
  touch ${ACCOUNTINGFILE}
  if /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@" &> /dev/null ; then
    break
  fi
  sleep 1
done
if /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@" &> /dev/null ; then
  /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@"
else
  /home/geadmin2/UGES/bin/lx-amd64/qacct "\$@"
fi
EOS
chmod 755  ${PREFIX}/bin/qacct
PATH=${PREFIX}/bin:${PATH}

# for qacct
tail -f /home/geadmin2/UGES/uges/common/accounting | grep ":${USER}:" > ${ACCOUNTINGFILE} &
TAILPROCESS=$!
echo ${TAILPROCESS} > ${PREFIX}/tail.process.pid.txt

# dump info
NOW=$(date "+%Y%m%d%H%M%S")
NOWDIR=${PREFIX}/${NOW}
mkdir -p ${NOWDIR}
VERSIONFILE=${NOWDIR}/versions.txt
#
cwltool --version > ${VERSIONFILE}
toil-cwl-runner --version >> ${VERSIONFILE}
echo "python path" >> ${VERSIONFILE}
ls -l $(which python3) >> ${VERSIONFILE}
echo "VIRTUAL_ENV=[${VIRTUAL_ENV}]" >> ${VERSIONFILE}


mkdir -p ${PREFIX}/writeLogs
mkdir -p ${PREFIX}/coorddir
mkdir -p ${PREFIX}/tmpdir
cp $0 ${NOWDIR}
cp ${JOBFILE} ${NOWDIR}
cp ${CWLFILE} ${NOWDIR}

## Exec toil

TMPDIR=${PREFIX}/tmpdir \
TOIL_GRIDENGINE_ARGS=" -l s_vmem=${MAXMEM}  -l mem_req=${MAXMEM} " \
OMP_NUM_THREADS=1 \
MALLOC_ARENA_MAX=1 \
SINGULARITY_BIND=/lustre7/home/manabu/work/MAG/cwl/MAGoutput_dfastqc_218655,/lustre9/open/public/assembly/genomes/all:/lustre9/open/public/assembly/genomes/all:ro,/gpfs1/dpl0/ddbjshare/public/ddbj.nig.ac.jp/dfast/dqc_reference:/gpfs1/dpl0/ddbjshare/public/ddbj.nig.ac.jp/dfast/dqc_reference:ro \
CWL_SINGULARITY_CACHE=~/.singularity_cache_dfast \
TOIL_CHECK_ENV=True \
toil-cwl-runner \
 --servicePollingInterval 20 \
 --manualMemArgs \
 --relax-path-checks \
 --jobStore ${PREFIX}/jobstore \
 --writeLogs ${PREFIX}/writeLogs \
 --logFile ${NOWDIR}/logfile.txt \
 --stats \
  --bypass-file-store \
 --singularity \
 --batchSystem grid_engine \
 --cleanWorkDir never \
 --defaultDisk 32000 \
 --defaultMemory ${ACTUALMEM} \
 --defaultCores 1.0 \
 --maxDisk 248G \
 --maxMemory ${MAXMEM} \
 --outdir ${PREFIX}/output \
  ${CWLFILE} ${JOBFILE} &> ${PREFIX}/toil_output.${NOW}.txt
TOILRESULT=$?
# stop tail process
kill ${TAILPROCESS}
exit ${TOILRESULT}
```

## restart

Sometimes, jobs are failed.
After the fail, you can restart.

Add following option to 

```
 --restart \
```

## Increase memory

Almost case, 8GB RAM is enough.
But some files require more memory.

So such a situation,

```shell
# MAXMEM
MAXMEM=24G
# Actual mem, MAXMEM - 1 GB is recommended
ACTUALMEM=23G
```

Sometimes, 32GB and 31GB is good.


## Use another batch system


### Tips

Unable to run job: failed receiving gdi request response for mid=1 (got syncron message receive timeout error).



