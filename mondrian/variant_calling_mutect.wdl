version 1.0

import "imports/mondrian_tasks/mondrian_tasks/variant_calling/utils.wdl" as utils
import "imports/workflows/variant_calling/mutect.wdl" as mutect
import "imports/types/variant_refdata.wdl"


workflow MutectWorkflow{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        File metadata_input
        Array[String] chromosomes
        String tumour_id
        String normal_id
        String ref_dir
        Int num_threads
        String? singularity_image = ""
        String? docker_image = "ubuntu"
    }

    VariantRefdata ref = {
        "reference": ref_dir+'/human/GRCh37-lite.fa',
        "reference_dict": ref_dir+'/human/GRCh37-lite.dict',
        "reference_fa_fai": ref_dir+'/human/GRCh37-lite.fa.fai',
        'vep_ref': ref_dir + '/vep.tar'
    }

    call mutect.MutectWorkflow as mutect{
        input:
            normal_bam = normal_bam,
            normal_bai = normal_bai,
            tumour_bam = tumour_bam,
            tumour_bai = tumour_bai,
            reference = ref.reference,
            reference_fai = ref.reference_fa_fai,
            reference_dict = ref.reference_dict,
            numThreads = num_threads,
            chromosomes = chromosomes,
            singularity_image = singularity_image,
            docker_image = docker_image,
            filename_prefix = tumour_id
    }


    call utils.VariantMetadata as metadata{
        input:
            files = {
                'mutect_vcf': [mutect.vcffile, mutect.vcffile_csi, mutect.vcffile_tbi],
            },
            metadata_yaml_files = [metadata_input],
            samples = [tumour_id],
            singularity_image = singularity_image,
            docker_image = docker_image
    }


    output{
        File museq_vcf = mutect.vcffile
        File museq_vcf_csi = mutect.vcffile_csi
        File museq_vcf_tbi = mutect.vcffile_tbi
        File metadata_output = metadata.metadata_output
    }
}