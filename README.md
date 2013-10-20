chain
=====

_bioinformatic pipelines with minimal effort_

## Warning

This project is pre-alpha. Please don't use the code for anything serious or post issues until we reach alpha.

## Introduction

**chain** is a tool for rapid development, exploration, and use of bioinformatic pipelines. **chain** lets you create and run new pipelines in seconds. Because you can store, share and modify chains, pipeline optimisation becomes easy and reproducible analysis is trivial. Programs can be added with a small amount of code. **chain** comes with several commonly-used bioinformatics tools built in.

### Example workflow

Let's see how it works with some high-throughput RNA sequencing examples.

Designing a reads-to-expression pipeline for de-novo transcriptomics, using default settings, can be as simple as:

```
chain --name denovotrans \
 --description "a gold-standard de-novo transcriptomics pipeline" \
 --define trimmomatic:khmer:velvetoases:gapfiller:cap3:chiminus:transrate:express`
```

Pipeline definitions are stored in plaintext .chain files, so you can share them, import them, or define them directly in the file. The same pipeline would be defined in plaintext as:

```
name = denovotrans
description = "a gold-standard de-novo transcriptomics pipeline, ideal for first pass analysis of a new species"
programs = trimmomatic:khmer:velvetoases:gapfiller:cap3:chiminus:tada:express
```

Running the chain you just designed is then trivial:

`chain --run denovotrans --left l.fastq --right r.fastq`

You can store as many pipelines as you like. Let's save a very simple reference-based RNA-Seq pipeline in which we trim, map and quantify reads:

`chain --name rnaseq --define trimmomatic:express`

Running the RNA-Seq pipeline:

`chain --run rnaseq --left l.fastq --right r.fastq --reference rice_transcriptome.fa`

**chain** knows what inputs each program requires, and can figure out whether the correct ones will be generated by the pipeline. If there's likely to be a problem, you find out right away.

```
> chain --run rnaseq --left l.fastq --right r.fastq
error: the eXpress step requires a reference file, and none of the preceding steps will generate one. 
please re-run the chain specifying a reference with the --reference option
```

To review the chains you've stored:

`chain --list`

To get a detailed protocol for a particular pipeline:

`chain --protocol denovotrans`

Maybe you want to vary the settings of one program in the pipeline. First you list the settings available for that program:

`chain --detail velvetoases`

...then create a child pipeline with some settings changed:

`chain --name denovotrans2 --inherit denovotrans --options velvetoases:k=21-71,step=10,mergek=27`
