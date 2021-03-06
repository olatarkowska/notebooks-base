# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook

USER root

# pre-requisites
RUN apt-get update && apt-get install -yq --no-install-recommends \
    python3-software-properties \
    software-properties-common \
    apt-utils \
    gnupg2 \
    fonts-dejavu \
    tzdata \
    gfortran \
    curl \
    less \
    gcc \
    clang-6.0 \
    openssh-client \
    openssh-server \
    cmake \
    python-dev \
    libgsl-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2 \
    libxml2-dev \
    libapparmor1 \
    libedit2 \
    libhdf5-dev \
    lsb-release \
    psmisc \
    rsync \
    vim \
    default-jdk \
    libbz2-dev \
    libpcre3-dev \
    liblzma-dev \
    zlib1g-dev \
    xz-utils \
    liblapack-dev \
    libopenblas-dev \
    libigraph0-dev \
    libreadline-dev \
    libblas-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Select the right versio of libblas to be used
# there was a problem running R in python and vice versa
RUN pip install simplegeneric
RUN update-alternatives --install /etc/alternatives/libblas.so.3-x86_64-linux-gnu libblas /usr/lib/x86_64-linux-gnu/blas/libblas.so.3 5

# RStudio
ENV RSTUDIO_PKG=rstudio-server-1.1.456-amd64.deb
RUN wget -q http://download2.rstudio.org/${RSTUDIO_PKG}
RUN dpkg -i ${RSTUDIO_PKG}
RUN rm ${RSTUDIO_PKG}
# The desktop package uses /usr/lib/rstudio/bin
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/lib/R/lib"

# jupyter-rsession-proxy extension
RUN pip install git+https://github.com/jupyterhub/jupyter-rsession-proxy

# R packages
# https://askubuntu.com/questions/610449/w-gpg-error-the-following-signatures-couldnt-be-verified-because-the-public-k
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# https://cran.r-project.org/bin/linux/ubuntu/README.html
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" | sudo tee -a /etc/apt/sources.list
# https://launchpad.net/~marutter/+archive/ubuntu/c2d4u3.5
RUN add-apt-repository ppa:marutter/c2d4u3.5
# Install CRAN binaries from ubuntu
RUN apt-get update && apt-get install -yq --no-install-recommends \
    r-base \
    r-cran-devtools \
    r-cran-tidyverse \
    r-cran-pheatmap \
    r-cran-plyr \
    r-cran-dplyr \
    r-cran-readr \
    r-cran-reshape \
    r-cran-reshape2 \
    r-cran-reticulate \
    r-cran-viridis \
    r-cran-ggplot2 \
    r-cran-ggthemes \
    r-cran-cowplot \
    r-cran-ggforce \
    r-cran-ggridges \
    r-cran-ggrepel \
    r-cran-gplots \
    r-cran-igraph \
    r-cran-car \
    r-cran-ggpubr \
    r-cran-httpuv \
    r-cran-xtable \
    r-cran-sourcetools \
    r-cran-modeltools \
    r-cran-R.oo \
    r-cran-R.methodsS3 \
    r-cran-shiny \
    r-cran-later \
    r-cran-checkmate \
    r-cran-bibtex \
    r-cran-lsei \
    r-cran-bit \
    r-cran-segmented \
    r-cran-mclust \
    r-cran-flexmix \
    r-cran-prabclus \
    r-cran-diptest \
    r-cran-mvtnorm \
    r-cran-robustbase \
    r-cran-kernlab \
    r-cran-trimcluster \
    r-cran-proxy \
    r-cran-R.utils \
    r-cran-htmlwidgets \
    r-cran-hexbin \
    r-cran-crosstalk \
    r-cran-promises \
    r-cran-acepack \
    r-cran-zoo \
    r-cran-npsurv \
    r-cran-iterators \
    r-cran-snow \
    r-cran-bit64 \
    r-cran-permute \
    r-cran-mixtools \
    r-cran-lars \
    r-cran-ica \
    r-cran-fpc \
    r-cran-ape \
    r-cran-pbapply \
    r-cran-irlba \
    r-cran-dtw \
    r-cran-plotly \
    r-cran-metap \
    r-cran-lmtest \
    r-cran-fitdistrplus \
    r-cran-png \
    r-cran-foreach \
    r-cran-vegan \
    r-cran-tidyr \
    r-cran-withr \
    r-cran-magrittr \
    r-cran-rmpi \
    r-cran-biocmanager \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install hdf5r for Seurat
RUN Rscript -e 'install.packages("hdf5r",configure.args="--with-hdf5=/usr/bin/h5cc")'
# Install other CRAN
RUN Rscript -e 'install.packages(c("Seurat", "vcfR", "rJava", "gProfileR"))'

# Install Bioconductor packages
RUN Rscript -e 'BiocManager::install(c("graph", "RBGL", "gtools", "xtable", "pcaMethods", "limma", "SingleCellExperiment", "Rhdf5lib", "beachmat", "scater", "scran", "RUVSeq", "sva", "SC3", "TSCAN", "monocle", "destiny", "DESeq2", "edgeR", "MAST", "scfind", "scmap", "BiocParallel", "zinbwave", "GenomicAlignments", "RSAMtools", "M3Drop", "DropletUtils", "switchde", "biomaRt", "org.Hs.eg.db", "goseq", "ccfindR"), version = "3.8")'

# Install Vennerable for Venn diagrams
RUN Rscript -e 'install.packages("Vennerable", repos="http://R-Forge.R-project.org")'

# install github packages
# see here for with_libpaths description:
# https://stackoverflow.com/questions/24646065/how-to-specify-lib-directory-when-installing-development-version-r-packages-from
# (do not install anything in the home directory, it will be wiped out when a volume is mounted to the docker container)
RUN Rscript -e 'withr::with_libpaths(new = "/usr/lib/R/site-library/", devtools::install_github(c("GreenleafLab/motifmatchr", "immunogenomics/harmony")))'

# create local R library
RUN Rscript -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
RUN Rscript -e '.libPaths( c( Sys.getenv("R_LIBS_USER"), .libPaths() ) )'

# Install scanpy and other python packages
RUN pip install scanpy python-igraph louvain bbknn rpy2 tzlocal scvelo leidenalg

# scanorama
RUN git clone https://github.com/brianhie/scanorama.git
RUN cd scanorama/ && python setup.py install

# necessary for creating user environments
RUN conda install --quiet --yes nb_conda_kernels

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.0.0

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "bea4570d7358016d8ed29d2c15787dbefaea3e746c570763e7ad6040f17831f3 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    fix-permissions $JULIA_PKGDIR

# Fix permissions
RUN conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

USER $NB_UID

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'import Pkg; Pkg.update()' && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') && \
    julia -e 'import Pkg; Pkg.add("Gadfly")' && \
    julia -e 'import Pkg; Pkg.add("RDatasets")' && \
    julia -e 'import Pkg; Pkg.add("IJulia")' && \
    julia -e 'import Pkg; Pkg.add("Distances")' && \
    julia -e 'import Pkg; Pkg.add("StatsBase")' && \
    julia -e 'import Pkg; Pkg.add("Hadamard")' && \
    julia -e 'import Pkg; Pkg.add("JLD")' && \
    julia -e 'import Pkg; Pkg.add("StatsBase")' && \
    julia -e 'import Pkg; Pkg.add("Statistics")' && \
    julia -e 'import Pkg; Pkg.add("Embeddings")' && \
    julia -e 'import Pkg; Pkg.add("DataFrames")' && \
    julia -e 'import Pkg; Pkg.add("GLM")' && \
    julia -e 'import Pkg; Pkg.add("LsqFit")' && \
    julia -e 'import Pkg; Pkg.add("Combinatorics")' \
    # Precompile Julia packages \
    julia -e 'using IJulia'


USER root

# move kernelspec out of home
RUN mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local && \
    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter