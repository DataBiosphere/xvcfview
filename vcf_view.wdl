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
    }
    runtime {
        docker: "xbrianh/xsamtools:v0.5.2"
        memory: "${memory}G"
        cpu: "${cpu}"
        preemptible: "${preemptible}"
    }
    command <<<
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
