    open_project bfs_bulk
    set_top bfs_top
    add_files bfs_bulk.cpp
    open_solution "solution1" -flow_target vivado
    set_part {xc7z020clg484-1}
    create_clock -period 2 -name default
    csynth_design
    exit