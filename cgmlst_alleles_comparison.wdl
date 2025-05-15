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

    call extract_summary_files {
        input:
            call_outputs = alleles_comparison.call_outputs,
            visualization_outputs = alleles_comparison.visualization_outputs
            
    }

    output {
        File? visualization_file = extract_summary_files.visualization_tsv
        File? alleles_matrix     = extract_summary_files.alleles_matrix
        File? results_alleles    = extract_summary_files.results_alleles
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
            --i ~{assemblies} \
            --o results \
            --sample_prefix ~{sample_prefix} \
            --call_dir results/call \
            --visualization_dir results/visualization
     
    >>>

    output {
        Array[File] call_outputs = glob("results/call/*")
        Array[File] visualization_outputs = glob("results/visualization/*")
    }


    runtime {
        docker: docker
        cpu: 20
    }
}

# I want to fetch specific files from the chewBBaca outputs
task extract_summary_files {
  input {
    Array[File] visualization_outputs
    Array[File] call_outputs
  }

  command <<<
    mkdir -p extracted

    for file in ~{sep=' ' visualization_outputs}; do
      fname=$(basename "$file")
      if [[ "$fname" == "cgMLST.tsv" ]]; then
        cp "$file" extracted/visualization.tsv
      elif [[ "$fname" == "Presence_Absence.tsv" ]]; then
        cp "$file" extracted/alleles_matrix.tsv
      fi
    done

    for file in ~{sep=' ' call_outputs}; do
      fname=$(basename "$file")
      if [[ "$fname" == "results_alleles.tsv" ]]; then
        cp "$file" extracted/results_alleles.tsv
      fi
    done
  >>>

  output {
    File? visualization_tsv = "extracted/visualization.tsv"
    File? alleles_matrix = "extracted/alleles_matrix.tsv"
    File? results_alleles = "extracted/results_alleles.tsv"
  }

  runtime {
    docker: "ubuntu:25.04"
  }
}

