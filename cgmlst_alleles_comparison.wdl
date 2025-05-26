version 1.0

workflow cgmlst_alleles_comparison {
    input {
        Array[File] assemblies
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
            visualization_outputs = alleles_comparison.visualization_outputs

    }
    
    call generate_mst {
        input:
            alleles_matrix = extract_summary_files.visualization_alleles_matrix,
            docker = docker
                
    }
    
    output {
        File cg_visualization_file = extract_summary_files.visualization_alleles_matrix
        File cg_presence_absence   = extract_summary_files.presence_absence
        File cg_mst                = generate_mst.mst
    }
}


task alleles_comparison {
    input {
        Array[File] assemblies
        String sample_prefix
        String docker
    }

    command <<<

        mkdir -p assemblies_dir
        for f in ~{sep=' ' assemblies}; do
            cp "$f" assemblies_dir/
        done
    
        sample_prefix_lower=$(echo ~{sample_prefix} | tr '[:upper:]' '[:lower:]')

        mkdir results
         
        cgmlst_alleles_comparison \
            --i assemblies_dir \
            --o results \
            --sample_prefix ${sample_prefix_lower} \
            --call_dir results/call \
            --visualization_dir results/visualization
     
    >>>

    output {
        Array[File] visualization_outputs = glob("results/visualization/*")
    }


    runtime {
        docker: docker
        cpu: 20
    }
}

task extract_summary_files {
  input {
    Array[File] visualization_outputs
  }

  command <<<
    mkdir -p extracted

    for file in ~{sep=' ' visualization_outputs}; do
      fname=$(basename "$file")
      if [[ "$fname" == "cgMLST.tsv" ]]; then
        cp "$file" extracted/visualization_alleles_matrix.tsv
      elif [[ "$fname" == "Presence_Absence.tsv" ]]; then
        cp "$file" extracted/presence_absence.tsv
      fi
    done

  >>>

  output {
    File visualization_alleles_matrix = "extracted/visualization_alleles_matrix.tsv"
    File presence_absence    = "extracted/presence_absence.tsv"
  }

  runtime {
    docker: "ubuntu:25.04"
  }
}

task generate_mst {
    input {
        File alleles_matrix
        String docker
    }

    command <<<
        generate_mst --i ~{alleles_matrix} --o mst.png
    >>>

    output {
        File mst = 'mst.png'
    }

    runtime {
        docker: docker
    }
}

