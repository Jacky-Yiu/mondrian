

*Prerequisite: [quickstart](README.md)*


1. create a directory 
    ```
    mkdir mondrian_haplotype_calling && cd mondrian_haplotype_calling
    ```
2. Download test data set

    ```
    wget https://mondriantestdata.s3.amazonaws.com/haplotype_calling_testdata.tar.gz
    tar -xvf haplotype_calling_testdata.tar.gz
    ```
3. create singularity sif file (for singularity only)
    ```
    singularity build haplotype_calling_<insert version>.sif docker://quay.io/mondrianscwgs/haplotype_calling:<insert version>
    ```


4. create input json file

    replace `<path to refdir>` with the reference dir we downloaded in the beginning of this guide.
    
    ```
    {
      "HaplotypeWorkflow.singularity_image": "<path-to-singularity-sif>",
      "HaplotypeWorkflow.normal_bam": "haplotype_calling_testdata/data/HCC1395BL_chr15.bam",
      "HaplotypeWorkflow.normal_bai": "haplotype_calling_testdata/data/HCC1395BL_chr15.bam.bai",
      "HaplotypeWorkflow.normal_id": "HCC1395BL",
      "HaplotypeWorkflow.samples": [
        {
          "sample_id": "SA607",
          "tumour": "haplotype_calling_testdata/data/merged_reheader.bam",
          "tumour_bai": "haplotype_calling_testdata/data/merged_reheader.bam.bai",
          "metadata_input": "haplotype_calling_testdata/data/metadata.yaml"
        }
      ],
      "HaplotypeWorkflow.reference": {
        "reference_fai": "haplotype_calling_testdata/ref/GRCh37-lite.fa.fai",
        "gap_table": "haplotype_calling_testdata/ref/hg19_gap.txt.gz",
        "snp_positions": "haplotype_calling_testdata/ref/thousand_genomes_snps.tsv",
        "genetic_map_filename_template": "ALL_1000G_phase1integrated_v3_impute/genetic_map_chr{chromosome}_combined_b37.txt",
        "haplotypes_filename_template": "ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chromosome}_impute.hap.gz",
        "legend_filename_template": "ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chromosome}_impute.legend.gz",
        "sample_filename": "ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3.sample",
        "phased_chromosome_x": "X_nonPAR",
        "thousand_genomes_impute_tar": "haplotype_calling_testdata/ref/ALL_1000G_phase1integrated_v3_impute.tar"
      },
      "HaplotypeWorkflow.chromosomes": ["15"]
    }
    ```

    To run with docker: Replace `singularity_image` in `input.json` with
    ```
    "SnvGenotypingWorkflow.docker_image": "docker://quay.io/mondrianscwgs/haplotype_calling:<insert version>",
    ```

5. run the pipeline on test dataset

    Ensure java and singularity/docker are installed and on PATH. On juno you can load  java and singularity by running:
    
    ```
    module load java/jdk-11.0.11
    module load singularity/3.6.2
    ```
    
    Launch the pipeline with the following command (replace the file paths):
    
    ```
    wget https://raw.githubusercontent.com/mondrian-scwgs/mondrian/<insert version>/mondrian/haplotype_calling.wdl
    java -Dconfig.file=<path to run.config> -jar <path to downloaded cromwell>.jar run \
    haplotype_calling.wdl \
    -i <path to input.json>  -o <path to options.json> --imports <path to imports zip>
    ```
