version 1.0

import "../../mondrian_tasks/mondrian_tasks/breakpoint_calling/svaba.wdl" as svaba
import "../../types/breakpoint_refdata.wdl" as refdata_struct


workflow SvabaWorkflow{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        Int num_threads
        BreakpointRefdata ref
        String filename_prefix = "output"
        String? singularity_image
        String? docker_image
        Int? low_mem = 7
        Int? med_mem = 15
        Int? high_mem = 25
        Int? low_walltime = 24
        Int? med_walltime = 48
        Int? high_walltime = 96
    }


    call svaba.RunSvaba as run_svaba{
        input:
            normal_bam = normal_bam,
            normal_bai = normal_bai,
            tumour_bam = tumour_bam,
            tumour_bai = tumour_bai,
            num_threads = num_threads,
            reference = ref.reference,
            reference_fa_fai = ref.reference_fa_fai,
            reference_fa_amb = ref.reference_fa_amb,
            reference_fa_ann = ref.reference_fa_ann,
            reference_fa_pac = ref.reference_fa_pac,
            reference_fa_sa = ref.reference_fa_sa,
            reference_fa_bwt = ref.reference_fa_bwt,
            filename_prefix = filename_prefix,
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_gb = high_mem,
            walltime_hours = high_walltime
    }
    output{
        File output_vcf = run_svaba.output_vcf
    }
}
