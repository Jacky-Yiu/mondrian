version 1.0

import "imports/mondrian_tasks/mondrian_tasks/breakpoint_calling/utils.wdl" as utils
import "imports/workflows/breakpoint_calling/lumpy.wdl" as lumpy


workflow LumpyWorkflow{
    input{
        File normal_bam
        File tumour_bam
        File metadata_input
        String tumour_id
        String? singularity_image = ""
        String? docker_image = "ubuntu"
    }

    call lumpy.LumpyWorkflow as lumpy{
        input:
            normal_bam = normal_bam,
            tumour_bam = tumour_bam,
            filename_prefix = tumour_id,
            singularity_image = singularity_image,
            docker_image = docker_image
    }

    call utils.BreakpointMetadata as metadata{
        input:
            files = {
                'lumpy_vcf': [lumpy.lumpy_vcf],
            },
            metadata_yaml_files = [metadata_input],
            samples = [tumour_id],
            singularity_image = singularity_image,
            docker_image = docker_image
    }

    output{
        File lumpy_vcf = lumpy.lumpy_vcf
        File metadata_output = metadata.metadata_output
    }
}
