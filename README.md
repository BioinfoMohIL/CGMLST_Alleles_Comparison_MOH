# 🔬 cgMLST Alleles Comparison Workflow

**Version:** 1.0  
**Author:** bioinfomoh  
**Docker Image:** `bioinfomoh/cgmlst_alleles_comparison:1`

---

## 🧩 Overview

This WDL workflow performs **cgMLST alleles comparison** (via ChewBBaca in the docker container) across a set of genome assemblies and produces:
- A **cgMLST allele matrix**
- A **presence/absence matrix**
- A **minimum spanning tree (MST)** for visualization

---

## 📁 Input Parameters

| Name             | Type         | Description                                               |
|------------------|--------------|-----------------------------------------------------------|
| `assemblies`     | `Array[File]`| List of genome assembly files (`.fasta`)                 |
| `sample_prefix`  | `String`     | Sample prefix ("nm", "bp", "ec"...)                 |
| `docker`         | `String`     | Docker image to use (default: `bioinfomoh/cgmlst_alleles_comparison:1`) |

---

## 📤 Output Files

| Output Name              | Description                                            |
|--------------------------|--------------------------------------------------------|
| `cg_visualization_file`  | `cgMLST.tsv` matrix of allele presence/absence         |
| `cg_presence_absence`    | Presence/absence summary table                         |
| `cg_mst`                 | Minimum spanning tree image (`mst.png`)                |

---

## 🛠️ Workflow Steps

1. **alleles_comparison**  
   - Copies all assemblies to a local directory  
   - Runs `cgmlst_alleles_comparison` with the provided prefix  
   - Produces `cgMLST.tsv` and `Presence_Absence.tsv` in `results/visualization/`

2. **extract_summary_files**  
   - Extracts the key summary files from the visualization folder

3. **generate_mst**  
   - Uses the allele matrix to generate a minimum spanning tree image using `generate_mst`

---

## 📦 Requirements

- Cromwell or miniWDL to run the WDL workflow
- Docker must be installed and available on the system

---

## ▶️ Example Run

```bash
java -jar cromwell.jar run cgmlst_alleles_comparison.wdl   --inputs inputs.json
```

**Example `inputs.json`:**
```json
{
  "cgmlst_alleles_comparison.assemblies": ["sample1.fasta", "sample2.fasta"],
  "cgmlst_alleles_comparison.sample_prefix": "MySamples"
}
```

---

## 📘 Notes

- The `sample_prefix` will be converted to lowercase automatically.
- Ensure all input files are accessible in your working directory or mounted into Docker properly.
