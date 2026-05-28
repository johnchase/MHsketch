# MHsketch
MHsketch is a high-performance C++ framework for sketch density reduction in long-read mapping workflows. The algorithm of MHsketch is designed to use MinHashing to reduce sketch density for long read mapping. MHsketch supports multiple sketching methods—including minimizers, syncmers, and strobemers—making it flexible for a range of bioinformatics applications. We implemented and tested the multithread execution of the framework (MPI+OpenMP multithreading). 

![figParallelProcessing](https://github.com/user-attachments/assets/c2ffe14b-891e-407f-a804-0c71e14351b1)


# Citation information:
Tazin Rahman, and Ananth Kalyanaraman. "Density-reducing Jaccard Estimators for
Sketch-based Long Read Applications", Under Review

# Dependencies:
MHsketch has the following dependencies:

* MPI library (preferably MPI-3 compatible)
* MPI C++ compiler wrapper, such as `mpicxx`
* MPI launcher, such as `mpiexec`
* OpenMP support
* GNU C++14 (or greater) compatible compiler

# Build:
Build the `jem` binary with:

```sh
make ksize=15
```

`ksize` is passed to the compiler as `WINDW_SIZE`; the code defines
`KMER_LENGTH` as `WINDW_SIZE + 1`. You can also use the uppercase variable:

```sh
make KSIZE=15
```

If your MPI compiler wrapper is not named `mpicxx`, override it:

```sh
make MPICXX=/path/to/mpicxx ksize=15
```

On macOS with Homebrew, install the required MPI/OpenMP dependencies with:

```sh
brew install open-mpi libomp
```

The Makefile detects Homebrew `libomp` and adds the required OpenMP include and
link flags automatically.

# Execute:
For the multi-threaded version, set the number of threads:
```sh
export OMP_NUM_THREADS=$number_of_threads
```
Run MHsketch:
```sh
mpiexec -np $number_of_procs ./jem \
  -c {Contig_Fasta_File} \
  -r {Long_Read_Fasta_File} \
  -a {A_int_Values_File} \
  -b {B_int_Values_File} \
  -p {Prime_int_Values_File} \
  -l $read_segment_length \
  -t $number_of_hash_trials \
  -m minimizer \
  -w $window_size
```

You can run the included example data through the Makefile:

```sh
make run-example ksize=15 NP=4 OMP_NUM_THREADS=8
```

Input arguments 
* -c: input contigs fasta file
* -r: input long reads fasta file
* -a: input file for A values for linear congruential hash function of the form [(Ax+B)%P]
* -b: input file for B values for linear congruential hash function of the form [(Ax+B)%P]
* -p: input file for  prime numbers (P) for hash function  [(Ax+B)%P]
* -l: read segment length
* -t: number of hash trials; must be 1-150 for the included constants files
* -m: sketching method you want to use; it can be minimizer, syncmer, or strobemer
Optional arguments
* -s: if you are using syncmer as the sketching method, then provide the s-size
* -w: if you are using minimizer as the sketching method, then provide the window size; if you are using strobemer as sketching method, provide the w_min size
* -v: if you are using strobemer as sketching method, provide the w_max size

For example, if we want to run it on 8 threads and 4 processes:  
```sh
export OMP_NUM_THREADS=8
mpiexec -np 4 ./jem \
  -c ~/Ecoli_reads_100x_contigs.fasta \
  -r ~/Ecoli_reads_10x_long_reads.fasta \
  -a ~/A.txt \
  -b ~/B.txt \
  -p ~/Prime.txt \
  -l 1000 \
  -t 30 \
  -m minimizer \
  -w 10
```

Notes:
* This code has been tested on high-performance computing cluster (HPC) with MPI compatibility. For the system we used we had to set the number of processes in the given way. Please change the parameters accordingly.
