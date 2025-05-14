version 1.0

workflow cgmlst_alleles_comparison {
    input {
        File assemblies
        String docker = 'bioinfomoh/cgmlst_alleles_comparison:1'
        String sample_prefix
    }

        
    call alleles_comparison {
        input:
            assemblies = assemblies,
            sample_prefix = sample_prefix,
            docker = docker
    
    }

    output {
        File cg_results_alleles = alleles_comparison.results_alleles
        File cg_loci_presence   = alleles_comparison.loci_presence
        File cg_stats           = alleles_comparison.stats
    }
}


task alleles_comparison {
    input {
        File assemblies
        String sample_prefix
        String docker
    }

    command <<<

        if [ ! -f "~{assemblies}" ]; then
            echo "[ERROR] File '~{assemblies}' not found."
            exit 1
        fi

        filename="~{assemblies}"
        if [[ ! "$filename" == *.tar.gz && ! "$filename" == *.gz && ! "$filename" == *.zip ]]; then
            echo "Error: Unsupported file type: $filename"
            exit 1
        fi
    
        sample_prefix=$(echo ~{sample_prefix} | tr '[:upper:]' '[:lower:]')

        mkdir results
         
        cgmlst_alleles_comparison \
            --i ~{assemblies} --o results \
            --sample_prefix ${sample_prefix} \
            --results_file results_alleles.tsv \
            --loci_presence_file results/loci_presence.tsv ]
            --results_stats results/stats_summary.tsv
    >>>

    output {
        File results_alleles = "results/results_alleles.tsv"
        File loci_presence   = "results/loci_presence.tsv"
        File stats           = "results/stats_summary.tsv"
    }


    runtime {
        docker: docker
    }
}
