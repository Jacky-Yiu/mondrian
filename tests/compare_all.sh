#!/usr/bin/env bash

set -e

wget -nv https://mondriantestdata.s3.amazonaws.com/result_reference.tar.gz

tar -xvf result_reference.tar.gz


docker run -w $PWD -v $PWD:$PWD -v $CODEBUILD_SRC_DIR:$CODEBUILD_SRC_DIR quay.io/mondrianscwgs/alignment:${TAG}beta mondrian_build_utils compare_alignment \
    --metrics $CODEBUILD_SRC_DIR/tests/alignment/outputs/results/alignment_workflow_alignment_metrics.csv.gz --metrics_ref result_reference/alignment_metrics.csv.gz \
    --gc_metrics $CODEBUILD_SRC_DIR/tests/alignment/outputs/results/alignment_workflow_alignment_gc_metrics.csv.gz --gc_metrics_ref result_reference/alignment_gc_metrics.csv.gz


docker run -w $PWD -v $PWD:$PWD -v $CODEBUILD_SRC_DIR:$CODEBUILD_SRC_DIR quay.io/mondrianscwgs/hmmcopy:${TAG}beta mondrian_build_utils compare_hmmcopy \
    --reads $CODEBUILD_SRC_DIR/tests/hmmcopy/outputs/results/hmmcopy_hmmcopy_reads.csv.gz --reads_ref result_reference/hmmcopy_reads.csv.gz \
    --metrics $CODEBUILD_SRC_DIR/tests/hmmcopy/outputs/results/hmmcopy_hmmcopy_metrics.csv.gz --metrics_ref result_reference/hmmcopy_metrics.csv.gz


docker run -w $PWD -v $PWD:$PWD -v $CODEBUILD_SRC_DIR:$CODEBUILD_SRC_DIR quay.io/mondrianscwgs/alignment:${TAG}beta mondrian_build_utils compare_breakpoint_calling \
    --destruct $CODEBUILD_SRC_DIR/tests/breakpoint_calling/outputs/results/breakpoint_breakpoint_table.csv --destruct_ref result_reference/destruct.csv \
    --gridss $CODEBUILD_SRC_DIR/tests/breakpoint_calling/outputs/results/breakpoint_gridss.vcf.gz --gridss_ref result_reference/gridss.vcf.gz \
    --lumpy $CODEBUILD_SRC_DIR/tests/breakpoint_calling/outputs/results/breakpoint_lumpy.vcf --lumpy_ref result_reference/lumpy.vcf.gz \
    --svaba $CODEBUILD_SRC_DIR/tests/breakpoint_calling/outputs/results/breakpoint.svaba.somatic.sv.vcf.gz --svaba_ref result_reference/svaba.vcf.gz \

docker run -w $PWD -v $PWD:$PWD -v $CODEBUILD_SRC_DIR:$CODEBUILD_SRC_DIR quay.io/mondrianscwgs/alignment:${TAG}beta mondrian_build_utils compare_variant_calling \
    --museq $CODEBUILD_SRC_DIR/tests/variant_calling/outputs/results/variant_calling_museq.vcf.gz --museq_ref result_reference/museq.vcf.gz \
    --mutect $CODEBUILD_SRC_DIR/tests/variant_calling/outputs/results/variant_calling_mutect.vcf.gz --mutect_ref result_reference/mutect.vcf.gz \
    --strelka_indel $CODEBUILD_SRC_DIR/tests/variant_calling/outputs/results/variant_calling_strelka_indel.vcf.gz --strelka_indel_ref result_reference/strelka_indel.vcf.gz \
    --strelka_snv $CODEBUILD_SRC_DIR/tests/variant_calling/outputs/results/variant_calling_strelka_snv.vcf.gz --strelka_snv_ref result_reference/strelka_snv.vcf.gz \


docker run -w $PWD -v $PWD:$PWD -v $CODEBUILD_SRC_DIR:$CODEBUILD_SRC_DIR quay.io/mondrianscwgs/alignment:${TAG}beta mondrian_build_utils compare_snv_genotyping \
    --genotyper $CODEBUILD_SRC_DIR/tests/snv_genotyping/outputs/results/snv_genotyping_genotyper.csv.gz --genotyper_ref result_reference/genotyper.csv.gz \
    --vartrix $CODEBUILD_SRC_DIR/tests/snv_genotyping/outputs/results/vartrix_vartrix_parsed.csv.gz --vartrix_ref result_reference/vartrix.csv.gz \


docker run -w $PWD -v $PWD:$PWD -v $CODEBUILD_SRC_DIR:$CODEBUILD_SRC_DIR quay.io/mondrianscwgs/alignment:${TAG}beta mondrian_build_utils compare_sv_genotyping \
    --genotyper $CODEBUILD_SRC_DIR/tests/sv_genotyping/outputs/results/sv_genotyping_genotyper.csv.gz --genotyper_ref result_reference/sv_genotyper.csv.gz
