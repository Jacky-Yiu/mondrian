version 1.0

import "../../mondrian_tasks/mondrian_tasks/haplotypes/utils.wdl" as haplotypes
import "../../mondrian_tasks/mondrian_tasks/io/csverve/csverve.wdl" as csverve


workflow InferHaplotypes{
    input{
        File normal_bam
        File normal_bai
        String genetic_map_filename_template
        String haplotypes_filename_template
        String legend_filename_template
        String sample_filename
        File thousand_genomes_impute_tar
        File snp_positions
        Array[String] chromosomes
        String? singularity_image
        String? docker_image
        Int? low_mem = 7
        Int? med_mem = 15
        Int? high_mem = 25
        String? low_walltime = 24
        String? med_walltime = 48
        String? high_walltime = 96
    }

    scatter(chromosome in chromosomes){
        call haplotypes.ExtractChromosomeSeqData as chrom_seqdata{
            input:
                bam = normal_bam,
                bai = normal_bai,
                snp_positions = snp_positions,
                chromosome = chromosome,
                singularity_image = singularity_image,
                docker_image = docker_image,
                memory_gb = med_mem,
                walltime_hours = high_walltime
        }

        call haplotypes.InferSnpGenotypeFromNormal as infer_genotype{
            input:
                seqdata = chrom_seqdata.seqdata,
                chromosome = chromosome,
                singularity_image = singularity_image,
                docker_image = docker_image,
                memory_gb = med_mem,
                walltime_hours = high_walltime
        }

        call haplotypes.InferHaps as infer_haps{
            input:
                snp_genotype = infer_genotype.snp_genotype,
                chromosome = chromosome,
                thousand_genomes_impute_tar = thousand_genomes_impute_tar,
                genetic_map_filename_template = genetic_map_filename_template,
                haplotypes_filename_template=haplotypes_filename_template,
                legend_filename_template=legend_filename_template,
                sample_filename=sample_filename,
                singularity_image = singularity_image,
                docker_image = docker_image,
                memory_gb = med_mem,
                walltime_hours = high_walltime
        }
    }

    call haplotypes.MergeHaps as merge_haps{
        input:
            infiles = infer_haps.haplotypes,
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_gb = med_mem,
            walltime_hours = high_walltime
    }

    call haplotypes.AnnotateHaps as annotate_haps{
        input:
            infile = merge_haps.merged_haps,
            thousand_genomes_snps = snp_positions,
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_gb = med_mem,
            walltime_hours = high_walltime
    }

    output{
        File haplotypes = annotate_haps.outfile
        File haplotypes_yaml = annotate_haps.outfile_yaml
    }

}