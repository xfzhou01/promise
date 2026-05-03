    open_project aes
    set_top backprop_top
    add_files backprop.cpp
    open_solution "solution1" -flow_target vivado
    set_part {xc7z020clg484-1}
    create_clock -period 2 -name default
    csynth_design
    exit