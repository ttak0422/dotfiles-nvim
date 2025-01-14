(local no_exec_files (dofile args.exclude_ft_path))

((. (require :colorful-winsep) :setup) {:smooth false
                                        :exponential_smoothing false
                                        : no_exec_files})
