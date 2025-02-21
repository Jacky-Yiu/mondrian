version 1.0

import "imports/mondrian_tasks/mondrian_tasks/io/csverve/csverve.wdl" as csverve
import "imports/mondrian_tasks/mondrian_tasks/io/pdf/pdf.wdl" as pdf
import "imports/mondrian_tasks/mondrian_tasks/hmmcopy/utils.wdl" as utils
import "imports/types/hmmcopy_refdata.wdl" as refdata_struct


workflow HmmcopyWorkflow{
    input{
        File bam
        File bai
        File contaminated_bam
        File contaminated_bai
        File control_bam
        File control_bai
        File alignment_metrics
        File alignment_metrics_yaml
        File gc_metrics
        File gc_metrics_yaml
        File add_order
        File add_order_yaml
        File metadata_input
        HmmcopyRefdata reference
        Array[String] chromosomes
        String? filename_prefix = "hmmcopy"
        String? singularity_image = ""
        String? docker_image = "quay.io/baselibrary/ubuntu"
        Int? memory_override
        Int? walltime_override
    }


    call utils.RunReadCounter as readcounter{
        input:
            bamfile = bam,
            baifile = bai,
            contaminated_bamfile = contaminated_bam,
            contaminated_baifile = contaminated_bai,
            control_bamfile = control_bam,
            control_baifile = control_bai,
            repeats_satellite_regions = reference.repeats_satellite_regions,
            chromosomes = chromosomes,
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    scatter(wigfile in readcounter.wigs){
        call utils.Hmmcopy as hmmcopy{
            input:
                readcount_wig = wigfile,
                gc_wig = reference.gc_wig,
                map_wig = reference.map_wig,
                reference = reference.reference,
                reference_fai = reference.reference_fai,
                map_cutoff = '0.9',
                singularity_image = singularity_image,
                docker_image = docker_image,
                memory_override = memory_override,
                walltime_override = walltime_override
        }
    }
    call csverve.ConcatenateCsv as concat_metrics{
        input:
            inputfile = hmmcopy.metrics,
            inputyaml = hmmcopy.metrics_yaml,
            filename_prefix = "hmmcopy_metrics",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call csverve.MergeCsv as merge_alignment_metrics{
        input:
            inputfiles = [concat_metrics.outfile, alignment_metrics],
            inputyamls = [concat_metrics.outfile_yaml, alignment_metrics_yaml],
            on = "cell_id",
            how="outer",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }


    call csverve.ConcatenateCsv as concat_params{
        input:
            inputfile = hmmcopy.params,
            inputyaml = hmmcopy.params_yaml,
            filename_prefix = filename_prefix + "_hmmcopy_params",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call csverve.ConcatenateCsv as concat_segments{
        input:
            inputfile = hmmcopy.segments,
            inputyaml = hmmcopy.segments_yaml,
            filename_prefix = filename_prefix + "_hmmcopy_segments",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call csverve.ConcatenateCsv as concat_reads{
        input:
            inputfile = hmmcopy.reads,
            inputyaml = hmmcopy.reads_yaml,
            filename_prefix = filename_prefix + "_hmmcopy_reads",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }


    call utils.AddMappability as add_mappability{
        input:
            infile = concat_reads.outfile,
            infile_yaml = concat_reads.outfile_yaml,
            filename_prefix = filename_prefix + "_hmmcopy_reads",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call utils.CellCycleClassifier as cell_cycle_classifier{
        input:
            hmmcopy_reads = add_mappability.outfile,
            hmmcopy_metrics = merge_alignment_metrics.outfile,
            alignment_metrics = alignment_metrics,
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call csverve.MergeCsv as merge_cell_cycle{
        input:
            inputfiles = [merge_alignment_metrics.outfile, cell_cycle_classifier.outfile],
            inputyamls = [merge_alignment_metrics.outfile_yaml, cell_cycle_classifier.outfile_yaml],
            on = 'cell_id',
            how = 'outer',
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call utils.AddQuality as add_quality{
        input:
            hmmcopy_metrics = add_order,
            hmmcopy_metrics_yaml = add_order_yaml,
            alignment_metrics = alignment_metrics,
            alignment_metrics_yaml = alignment_metrics_yaml,
            classifier_training_data = reference.classifier_training_data,
            filename_prefix = filename_prefix + "_hmmcopy_metrics",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call utils.CreateSegmentsTar as merge_segments{
        input:
            hmmcopy_metrics = add_quality.outfile,
            hmmcopy_metrics_yaml = add_quality.outfile_yaml,
            segments_plot = hmmcopy.segments_pdf,
            segments_plot_sample = hmmcopy.segments_sample,
            filename_prefix = filename_prefix + "_hmmcopy_segments",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call utils.PlotHeatmap as heatmap{
        input:
            metrics = add_quality.outfile,
            metrics_yaml = add_quality.outfile_yaml,
            reads = add_mappability.outfile,
            reads_yaml = add_mappability.outfile_yaml,
            chromosomes=chromosomes,
            filename_prefix = filename_prefix + "_hmmcopy_heatmap",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call utils.GenerateHtmlReport as html_report{
        input:
            metrics = add_quality.outfile,
            metrics_yaml = add_quality.outfile_yaml,
            gc_metrics = gc_metrics,
            gc_metrics_yaml = gc_metrics_yaml,
            filename_prefix = filename_prefix + "_qc_html",
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    call utils.HmmcopyMetadata as hmmcopy_metadata{
        input:
            reads = add_mappability.outfile,
            reads_yaml = add_mappability.outfile_yaml,
            segments = concat_segments.outfile,
            segments_yaml = concat_segments.outfile_yaml,
            params = concat_params.outfile,
            params_yaml = concat_params.outfile_yaml,
            metrics = add_quality.outfile,
            metrics_yaml = add_quality.outfile_yaml,
            heatmap = heatmap.heatmap_pdf,
            segments_pass = merge_segments.segments_pass,
            segments_fail = merge_segments.segments_fail,
            metadata_input = metadata_input,
            singularity_image = singularity_image,
            docker_image = docker_image,
            memory_override = memory_override,
            walltime_override = walltime_override
    }

    output{
        File reads = add_mappability.outfile
        File reads_yaml = add_mappability.outfile_yaml
        File segments = concat_segments.outfile
        File segments_yaml = concat_segments.outfile_yaml
        File params = concat_params.outfile
        File params_yaml = concat_params.outfile_yaml
        File metrics = add_quality.outfile
        File metrics_yaml = add_quality.outfile_yaml
        File segments_pass = merge_segments.segments_pass
        File segments_fail = merge_segments.segments_fail
        File heatmap_pdf = heatmap.heatmap_pdf
        File final_html_report = html_report.html_report
        File metadata = hmmcopy_metadata.metadata_output
        File final_html_report = html_report.html_report
    }
}
