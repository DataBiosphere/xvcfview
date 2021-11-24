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

    String basename_input = basename(input_vcf)
    command <<<
        echo "input vcf: '~{input_vcf}'"
        echo "input vcf index: '~{input_vcf_index}'"

        # On Terra, the inputs directory is read-only. By default bcftools would create the index
        # in the inputs directory since that's where the input vcf is. Additionally the vcf and
        # its index must be in either the same dir or one softlink away from each other.
        # To satisfy both conditions whether or not the user provides an index file, we softlink
        # the input vcf to the workdir and, if it exists, softlink the user-given index file
        # into the workdir too. 

        ln -s ~{input_vcf} .
        if [[ "~{input_vcf_index}" ]]; then
            ln -s ~{input_vcf_index} .
        fi

        if [[ ! "~{input_vcf_index}" ]]; then
            echo "indexing '~{input_vcf}'"
            bcftools index ~{input_vcf} -o ~{basename_input}.csi # terra requires this in workdir
        fi

        cmd="bcftools view ~{basename_input} -o output_intermediate"
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
