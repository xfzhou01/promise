    open_project aes
    set_top aes_top
    add_files aes.cpp
    open_solution "solution1" -flow_target vivado
    set_part {xc7z020clg484-1}
    create_clock -period 2 -name default
    csynth_design
    exit