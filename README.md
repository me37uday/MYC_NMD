## 🚀 How to Run

Clone the repository:

git clone https://github.com/<your-username>/MYC_NMD.git
cd MYC_NMD

Open R and restore the environment (first time only):

install.packages("renv")
renv::restore()

Run the script:

source("scripts/main.R")


## 📌 Output

- DESeq2 results are read from: data/DEGs/ and data/IR/
- Plots are saved in: figures/
