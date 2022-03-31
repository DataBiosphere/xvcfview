version 1.0

workflow xVCFViewWorkflow {
    input {
        File input_vcf
        File? input_vcf_index
        File? samples
        File? regions
        String view_options = "-Oz"
        String? filters
        String output_filename = "output.vcf.gz"
        Int cpu = 8
        Int memory = 64
        Int preemptible = 0
        Int addl_disk = 1
    }
    call xVCFView { input: input_vcf=input_vcf,
                    input_vcf_index=input_vcf_index,
                    samples=samples,
                    regions=regions,
                    view_options=view_options,
                    filters=filters,
                    output_filename=output_filename,
                    cpu=cpu,
                    memory=memory,
                    preemptible=preemptible }
    output {
        File output_vcf = xVCFView.output_vcf
    }
}

task xVCFView {
    input {
        File input_vcf
        File? input_vcf_index
        File? samples
        File? regions
        String? view_options
        String? filters
        String? output_filename
        Int cpu = 8
        Int memory = 64
        Int preemptible = 0
        Int addl_disk = 1
    }
    # estimate disk size required
    Int vcf_size        = ceil(size(input_vcf, "GB"))
    Int index_size      = select_first([ceil(size(input_vcf_index, "GB")), 0])
    Int samples_size    = select_first([ceil(size(samples, "GB")), 0])
    Int regions_size    = select_first([ceil(size(regions, "GB")), 0])
    Int final_disk_size = vcf_size + index_size + samples_size + regions_size + addl_disk
    runtime {
        disks: "local-disk " + final_disk_size + " HDD"
        docker: "xbrianh/xsamtools:v0.5.2"
        memory: "${memory}G"
        cpu: "${cpu}"
        preemptible: "${preemptible}"
    }
    command <<<
        # do not delete these lines -- they are required for indexing to work properly on Terra
        set -eux -o pipefail
        find . -type d -exec sudo chmod -R 777 {} +

        echo "input vcf: '~{input_vcf}'"
        echo "input vcf index: '~{input_vcf_index}'" 

        if [[ ! "~{input_vcf_index}" ]]; then
            echo "indexing '~{input_vcf}'"
            bcftools index ~{input_vcf}
        fi

        cmd="bcftools view ~{input_vcf} -o output_intermediate"
        if [[ "~{view_options}" ]]; then cmd="${cmd} ~{view_options}"; fi
        if [[ "~{samples}" ]]; then cmd="${cmd} --samples-file ~{samples}"; fi
        if [[ "~{regions}" ]]; then cmd="${cmd} --regions-file ~{regions}"; fi

        bcftools --version
        echo "executing '${cmd}'"
        ${cmd}

        if [[ "~{filters}" ]]; then
            cmd="bcftools view ~{filters} output_intermediate -o ~{output_filename}"
        else
            mv output_intermediate ~{output_filename}
        fi
    >>>
    output {
        File output_vcf = "~{output_filename}"
    }
}
