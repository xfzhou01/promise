set moduleName update_weights
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set C_modelName {update_weights}
set C_modelType { void 0 }
set C_modelArgList {
	{ weights1 int 32 regular {array 832 { 2 3 } 3 1 }  }
	{ weights2 int 32 regular {array 4096 { 2 3 } 3 1 }  }
	{ weights3 int 32 regular {array 192 { 2 1 } 3 1 }  }
	{ biases1 int 32 regular {array 64 { 0 1 } 3 1 }  }
	{ biases2 int 32 regular {array 64 { 0 1 } 3 1 }  }
	{ biases3 int 32 regular {array 3 { 2 1 } 3 1 }  }
	{ d_weights1 int 32 regular {array 832 { 1 3 } 3 1 }  }
	{ d_weights2 int 32 regular {array 4096 { 1 3 } 3 1 }  }
	{ d_weights3 int 32 regular {array 192 { 1 3 } 3 1 }  }
	{ d_biases1 int 32 regular {array 64 { 1 3 } 3 1 }  }
	{ d_biases2 int 32 regular {array 64 { 1 3 } 3 1 }  }
	{ p_read int 32 regular  }
	{ p_read1 int 32 regular  }
	{ p_read2 int 32 regular  }
}
set C_modelArgMapList {[ 
	{ "Name" : "weights1", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} , 
 	{ "Name" : "weights2", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} , 
 	{ "Name" : "weights3", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} , 
 	{ "Name" : "biases1", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} , 
 	{ "Name" : "biases2", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} , 
 	{ "Name" : "biases3", "interface" : "memory", "bitwidth" : 32, "direction" : "READWRITE"} , 
 	{ "Name" : "d_weights1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "d_weights2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "d_weights3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "d_biases1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "d_biases2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_read", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_read1", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_read2", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} ]}
# RTL Port declarations: 
set portNum 112
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ weights1_address0 sc_out sc_lv 10 signal 0 } 
	{ weights1_ce0 sc_out sc_logic 1 signal 0 } 
	{ weights1_we0 sc_out sc_logic 1 signal 0 } 
	{ weights1_d0 sc_out sc_lv 32 signal 0 } 
	{ weights1_q0 sc_in sc_lv 32 signal 0 } 
	{ weights2_address0 sc_out sc_lv 12 signal 1 } 
	{ weights2_ce0 sc_out sc_logic 1 signal 1 } 
	{ weights2_we0 sc_out sc_logic 1 signal 1 } 
	{ weights2_d0 sc_out sc_lv 32 signal 1 } 
	{ weights2_q0 sc_in sc_lv 32 signal 1 } 
	{ weights3_address0 sc_out sc_lv 8 signal 2 } 
	{ weights3_ce0 sc_out sc_logic 1 signal 2 } 
	{ weights3_we0 sc_out sc_logic 1 signal 2 } 
	{ weights3_d0 sc_out sc_lv 32 signal 2 } 
	{ weights3_q0 sc_in sc_lv 32 signal 2 } 
	{ weights3_address1 sc_out sc_lv 8 signal 2 } 
	{ weights3_ce1 sc_out sc_logic 1 signal 2 } 
	{ weights3_q1 sc_in sc_lv 32 signal 2 } 
	{ biases1_address0 sc_out sc_lv 6 signal 3 } 
	{ biases1_ce0 sc_out sc_logic 1 signal 3 } 
	{ biases1_we0 sc_out sc_logic 1 signal 3 } 
	{ biases1_d0 sc_out sc_lv 32 signal 3 } 
	{ biases1_address1 sc_out sc_lv 6 signal 3 } 
	{ biases1_ce1 sc_out sc_logic 1 signal 3 } 
	{ biases1_q1 sc_in sc_lv 32 signal 3 } 
	{ biases2_address0 sc_out sc_lv 6 signal 4 } 
	{ biases2_ce0 sc_out sc_logic 1 signal 4 } 
	{ biases2_we0 sc_out sc_logic 1 signal 4 } 
	{ biases2_d0 sc_out sc_lv 32 signal 4 } 
	{ biases2_address1 sc_out sc_lv 6 signal 4 } 
	{ biases2_ce1 sc_out sc_logic 1 signal 4 } 
	{ biases2_q1 sc_in sc_lv 32 signal 4 } 
	{ biases3_address0 sc_out sc_lv 2 signal 5 } 
	{ biases3_ce0 sc_out sc_logic 1 signal 5 } 
	{ biases3_we0 sc_out sc_logic 1 signal 5 } 
	{ biases3_d0 sc_out sc_lv 32 signal 5 } 
	{ biases3_q0 sc_in sc_lv 32 signal 5 } 
	{ biases3_address1 sc_out sc_lv 2 signal 5 } 
	{ biases3_ce1 sc_out sc_logic 1 signal 5 } 
	{ biases3_q1 sc_in sc_lv 32 signal 5 } 
	{ d_weights1_address0 sc_out sc_lv 10 signal 6 } 
	{ d_weights1_ce0 sc_out sc_logic 1 signal 6 } 
	{ d_weights1_q0 sc_in sc_lv 32 signal 6 } 
	{ d_weights2_address0 sc_out sc_lv 12 signal 7 } 
	{ d_weights2_ce0 sc_out sc_logic 1 signal 7 } 
	{ d_weights2_q0 sc_in sc_lv 32 signal 7 } 
	{ d_weights3_address0 sc_out sc_lv 8 signal 8 } 
	{ d_weights3_ce0 sc_out sc_logic 1 signal 8 } 
	{ d_weights3_q0 sc_in sc_lv 32 signal 8 } 
	{ d_biases1_address0 sc_out sc_lv 6 signal 9 } 
	{ d_biases1_ce0 sc_out sc_logic 1 signal 9 } 
	{ d_biases1_q0 sc_in sc_lv 32 signal 9 } 
	{ d_biases2_address0 sc_out sc_lv 6 signal 10 } 
	{ d_biases2_ce0 sc_out sc_logic 1 signal 10 } 
	{ d_biases2_q0 sc_in sc_lv 32 signal 10 } 
	{ p_read sc_in sc_lv 32 signal 11 } 
	{ p_read1 sc_in sc_lv 32 signal 12 } 
	{ p_read2 sc_in sc_lv 32 signal 13 } 
	{ grp_fu_31749_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_31749_p_din1 sc_out sc_lv 11 signal -1 } 
	{ grp_fu_31749_p_dout0 sc_in sc_lv 43 signal -1 } 
	{ grp_fu_31749_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_6703_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6703_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6703_p_dout0 sc_in sc_lv 48 signal -1 } 
	{ grp_fu_6703_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_31753_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_31753_p_din1 sc_out sc_lv 11 signal -1 } 
	{ grp_fu_31753_p_dout0 sc_in sc_lv 43 signal -1 } 
	{ grp_fu_31753_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_6722_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6722_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6722_p_dout0 sc_in sc_lv 48 signal -1 } 
	{ grp_fu_6722_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_31757_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_31757_p_din1 sc_out sc_lv 11 signal -1 } 
	{ grp_fu_31757_p_dout0 sc_in sc_lv 43 signal -1 } 
	{ grp_fu_31757_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_6731_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6731_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6731_p_dout0 sc_in sc_lv 48 signal -1 } 
	{ grp_fu_6731_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_31761_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_31761_p_din1 sc_out sc_lv 11 signal -1 } 
	{ grp_fu_31761_p_dout0 sc_in sc_lv 43 signal -1 } 
	{ grp_fu_31761_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_6740_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6740_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6740_p_dout0 sc_in sc_lv 48 signal -1 } 
	{ grp_fu_6740_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_31765_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_31765_p_din1 sc_out sc_lv 11 signal -1 } 
	{ grp_fu_31765_p_dout0 sc_in sc_lv 43 signal -1 } 
	{ grp_fu_31765_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_6749_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6749_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6749_p_dout0 sc_in sc_lv 48 signal -1 } 
	{ grp_fu_6749_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_31769_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_31769_p_din1 sc_out sc_lv 11 signal -1 } 
	{ grp_fu_31769_p_dout0 sc_in sc_lv 43 signal -1 } 
	{ grp_fu_31769_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_6758_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6758_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_6758_p_dout0 sc_in sc_lv 48 signal -1 } 
	{ grp_fu_6758_p_ce sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "weights1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "weights1", "role": "address0" }} , 
 	{ "name": "weights1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "weights1", "role": "ce0" }} , 
 	{ "name": "weights1_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "weights1", "role": "we0" }} , 
 	{ "name": "weights1_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "weights1", "role": "d0" }} , 
 	{ "name": "weights1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "weights1", "role": "q0" }} , 
 	{ "name": "weights2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":12, "type": "signal", "bundle":{"name": "weights2", "role": "address0" }} , 
 	{ "name": "weights2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "weights2", "role": "ce0" }} , 
 	{ "name": "weights2_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "weights2", "role": "we0" }} , 
 	{ "name": "weights2_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "weights2", "role": "d0" }} , 
 	{ "name": "weights2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "weights2", "role": "q0" }} , 
 	{ "name": "weights3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "weights3", "role": "address0" }} , 
 	{ "name": "weights3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "weights3", "role": "ce0" }} , 
 	{ "name": "weights3_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "weights3", "role": "we0" }} , 
 	{ "name": "weights3_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "weights3", "role": "d0" }} , 
 	{ "name": "weights3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "weights3", "role": "q0" }} , 
 	{ "name": "weights3_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "weights3", "role": "address1" }} , 
 	{ "name": "weights3_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "weights3", "role": "ce1" }} , 
 	{ "name": "weights3_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "weights3", "role": "q1" }} , 
 	{ "name": "biases1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "biases1", "role": "address0" }} , 
 	{ "name": "biases1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases1", "role": "ce0" }} , 
 	{ "name": "biases1_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases1", "role": "we0" }} , 
 	{ "name": "biases1_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "biases1", "role": "d0" }} , 
 	{ "name": "biases1_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "biases1", "role": "address1" }} , 
 	{ "name": "biases1_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases1", "role": "ce1" }} , 
 	{ "name": "biases1_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "biases1", "role": "q1" }} , 
 	{ "name": "biases2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "biases2", "role": "address0" }} , 
 	{ "name": "biases2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases2", "role": "ce0" }} , 
 	{ "name": "biases2_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases2", "role": "we0" }} , 
 	{ "name": "biases2_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "biases2", "role": "d0" }} , 
 	{ "name": "biases2_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "biases2", "role": "address1" }} , 
 	{ "name": "biases2_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases2", "role": "ce1" }} , 
 	{ "name": "biases2_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "biases2", "role": "q1" }} , 
 	{ "name": "biases3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "biases3", "role": "address0" }} , 
 	{ "name": "biases3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases3", "role": "ce0" }} , 
 	{ "name": "biases3_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases3", "role": "we0" }} , 
 	{ "name": "biases3_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "biases3", "role": "d0" }} , 
 	{ "name": "biases3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "biases3", "role": "q0" }} , 
 	{ "name": "biases3_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "biases3", "role": "address1" }} , 
 	{ "name": "biases3_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "biases3", "role": "ce1" }} , 
 	{ "name": "biases3_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "biases3", "role": "q1" }} , 
 	{ "name": "d_weights1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "d_weights1", "role": "address0" }} , 
 	{ "name": "d_weights1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "d_weights1", "role": "ce0" }} , 
 	{ "name": "d_weights1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "d_weights1", "role": "q0" }} , 
 	{ "name": "d_weights2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":12, "type": "signal", "bundle":{"name": "d_weights2", "role": "address0" }} , 
 	{ "name": "d_weights2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "d_weights2", "role": "ce0" }} , 
 	{ "name": "d_weights2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "d_weights2", "role": "q0" }} , 
 	{ "name": "d_weights3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "d_weights3", "role": "address0" }} , 
 	{ "name": "d_weights3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "d_weights3", "role": "ce0" }} , 
 	{ "name": "d_weights3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "d_weights3", "role": "q0" }} , 
 	{ "name": "d_biases1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "d_biases1", "role": "address0" }} , 
 	{ "name": "d_biases1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "d_biases1", "role": "ce0" }} , 
 	{ "name": "d_biases1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "d_biases1", "role": "q0" }} , 
 	{ "name": "d_biases2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "d_biases2", "role": "address0" }} , 
 	{ "name": "d_biases2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "d_biases2", "role": "ce0" }} , 
 	{ "name": "d_biases2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "d_biases2", "role": "q0" }} , 
 	{ "name": "p_read", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_read", "role": "default" }} , 
 	{ "name": "p_read1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_read1", "role": "default" }} , 
 	{ "name": "p_read2", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_read2", "role": "default" }} , 
 	{ "name": "grp_fu_31749_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_31749_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_31749_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "grp_fu_31749_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_31749_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":43, "type": "signal", "bundle":{"name": "grp_fu_31749_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_31749_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_31749_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_6703_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6703_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_6703_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6703_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_6703_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":48, "type": "signal", "bundle":{"name": "grp_fu_6703_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_6703_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_6703_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_31753_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_31753_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_31753_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "grp_fu_31753_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_31753_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":43, "type": "signal", "bundle":{"name": "grp_fu_31753_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_31753_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_31753_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_6722_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6722_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_6722_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6722_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_6722_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":48, "type": "signal", "bundle":{"name": "grp_fu_6722_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_6722_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_6722_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_31757_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_31757_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_31757_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "grp_fu_31757_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_31757_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":43, "type": "signal", "bundle":{"name": "grp_fu_31757_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_31757_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_31757_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_6731_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6731_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_6731_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6731_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_6731_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":48, "type": "signal", "bundle":{"name": "grp_fu_6731_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_6731_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_6731_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_31761_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_31761_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_31761_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "grp_fu_31761_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_31761_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":43, "type": "signal", "bundle":{"name": "grp_fu_31761_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_31761_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_31761_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_6740_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6740_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_6740_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6740_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_6740_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":48, "type": "signal", "bundle":{"name": "grp_fu_6740_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_6740_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_6740_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_31765_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_31765_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_31765_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "grp_fu_31765_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_31765_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":43, "type": "signal", "bundle":{"name": "grp_fu_31765_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_31765_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_31765_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_6749_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6749_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_6749_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6749_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_6749_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":48, "type": "signal", "bundle":{"name": "grp_fu_6749_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_6749_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_6749_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_31769_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_31769_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_31769_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "grp_fu_31769_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_31769_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":43, "type": "signal", "bundle":{"name": "grp_fu_31769_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_31769_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_31769_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_6758_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6758_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_6758_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_6758_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_6758_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":48, "type": "signal", "bundle":{"name": "grp_fu_6758_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_6758_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_6758_p_ce", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "67", "133", "134", "135", "136", "137", "138", "139", "140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150", "151", "152", "153", "154", "155", "156", "157", "158", "159", "160", "161", "162", "163", "164", "165", "166", "167", "168", "169", "170", "171", "172", "173", "174", "175", "176", "177", "178", "179", "180", "181", "182", "183"],
		"CDFG" : "update_weights",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "283449", "EstimateLatencyMax" : "283449",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "weights1", "Type" : "Memory", "Direction" : "IO"},
			{"Name" : "weights2", "Type" : "Memory", "Direction" : "IO"},
			{"Name" : "weights3", "Type" : "Memory", "Direction" : "IO"},
			{"Name" : "biases1", "Type" : "Memory", "Direction" : "IO"},
			{"Name" : "biases2", "Type" : "Memory", "Direction" : "IO"},
			{"Name" : "biases3", "Type" : "Memory", "Direction" : "IO"},
			{"Name" : "d_weights1", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "d_weights2", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "d_weights3", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "d_biases1", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "d_biases2", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "p_read", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_read1", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_read2", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772", "Parent" : "0", "Child" : ["2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66"],
		"CDFG" : "sqrt_fixed_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "0", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "116", "EstimateLatencyMin" : "116", "EstimateLatencyMax" : "116",
		"Combinational" : "0",
		"Datapath" : "1",
		"ClockEnable" : "1",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "2", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_3s_3s_3_2_0_U40", "Parent" : "1"},
	{"ID" : "3", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_4ns_4ns_4_2_0_U41", "Parent" : "1"},
	{"ID" : "4", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_5ns_5ns_5_2_0_U42", "Parent" : "1"},
	{"ID" : "5", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_6ns_6ns_6_2_0_U43", "Parent" : "1"},
	{"ID" : "6", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_7ns_7ns_7_2_0_U44", "Parent" : "1"},
	{"ID" : "7", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_8ns_8ns_8_2_0_U45", "Parent" : "1"},
	{"ID" : "8", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_9ns_9ns_9_2_0_U46", "Parent" : "1"},
	{"ID" : "9", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_10ns_10ns_10_2_0_U47", "Parent" : "1"},
	{"ID" : "10", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U48", "Parent" : "1"},
	{"ID" : "11", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U49", "Parent" : "1"},
	{"ID" : "12", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17s_17_2_0_U50", "Parent" : "1"},
	{"ID" : "13", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U51", "Parent" : "1"},
	{"ID" : "14", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U52", "Parent" : "1"},
	{"ID" : "15", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U53", "Parent" : "1"},
	{"ID" : "16", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U54", "Parent" : "1"},
	{"ID" : "17", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U55", "Parent" : "1"},
	{"ID" : "18", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U56", "Parent" : "1"},
	{"ID" : "19", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U57", "Parent" : "1"},
	{"ID" : "20", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U58", "Parent" : "1"},
	{"ID" : "21", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U59", "Parent" : "1"},
	{"ID" : "22", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U60", "Parent" : "1"},
	{"ID" : "23", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U61", "Parent" : "1"},
	{"ID" : "24", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U62", "Parent" : "1"},
	{"ID" : "25", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U63", "Parent" : "1"},
	{"ID" : "26", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U64", "Parent" : "1"},
	{"ID" : "27", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U65", "Parent" : "1"},
	{"ID" : "28", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U66", "Parent" : "1"},
	{"ID" : "29", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U67", "Parent" : "1"},
	{"ID" : "30", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U68", "Parent" : "1"},
	{"ID" : "31", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U69", "Parent" : "1"},
	{"ID" : "32", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U70", "Parent" : "1"},
	{"ID" : "33", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_19ns_19ns_19_2_0_U71", "Parent" : "1"},
	{"ID" : "34", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U72", "Parent" : "1"},
	{"ID" : "35", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U73", "Parent" : "1"},
	{"ID" : "36", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U74", "Parent" : "1"},
	{"ID" : "37", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U75", "Parent" : "1"},
	{"ID" : "38", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U76", "Parent" : "1"},
	{"ID" : "39", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U77", "Parent" : "1"},
	{"ID" : "40", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U78", "Parent" : "1"},
	{"ID" : "41", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U79", "Parent" : "1"},
	{"ID" : "42", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U80", "Parent" : "1"},
	{"ID" : "43", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U81", "Parent" : "1"},
	{"ID" : "44", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U82", "Parent" : "1"},
	{"ID" : "45", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U83", "Parent" : "1"},
	{"ID" : "46", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U84", "Parent" : "1"},
	{"ID" : "47", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U85", "Parent" : "1"},
	{"ID" : "48", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U86", "Parent" : "1"},
	{"ID" : "49", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U87", "Parent" : "1"},
	{"ID" : "50", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U88", "Parent" : "1"},
	{"ID" : "51", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U89", "Parent" : "1"},
	{"ID" : "52", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U90", "Parent" : "1"},
	{"ID" : "53", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U91", "Parent" : "1"},
	{"ID" : "54", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U92", "Parent" : "1"},
	{"ID" : "55", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U93", "Parent" : "1"},
	{"ID" : "56", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U94", "Parent" : "1"},
	{"ID" : "57", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U95", "Parent" : "1"},
	{"ID" : "58", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U96", "Parent" : "1"},
	{"ID" : "59", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U97", "Parent" : "1"},
	{"ID" : "60", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_19ns_19s_19_2_0_U98", "Parent" : "1"},
	{"ID" : "61", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U99", "Parent" : "1"},
	{"ID" : "62", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.sub_17ns_17ns_17_2_0_U100", "Parent" : "1"},
	{"ID" : "63", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U101", "Parent" : "1"},
	{"ID" : "64", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_18ns_18ns_18_2_0_U102", "Parent" : "1"},
	{"ID" : "65", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_17ns_17ns_17_2_0_U103", "Parent" : "1"},
	{"ID" : "66", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_772.add_8ns_8ns_8_2_0_U104", "Parent" : "1"},
	{"ID" : "67", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778", "Parent" : "0", "Child" : ["68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120", "121", "122", "123", "124", "125", "126", "127", "128", "129", "130", "131", "132"],
		"CDFG" : "sqrt_fixed_32_16_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "0", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "116", "EstimateLatencyMin" : "116", "EstimateLatencyMax" : "116",
		"Combinational" : "0",
		"Datapath" : "1",
		"ClockEnable" : "1",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "x", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "68", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_3s_3s_3_2_0_U40", "Parent" : "67"},
	{"ID" : "69", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_4ns_4ns_4_2_0_U41", "Parent" : "67"},
	{"ID" : "70", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_5ns_5ns_5_2_0_U42", "Parent" : "67"},
	{"ID" : "71", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_6ns_6ns_6_2_0_U43", "Parent" : "67"},
	{"ID" : "72", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_7ns_7ns_7_2_0_U44", "Parent" : "67"},
	{"ID" : "73", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_8ns_8ns_8_2_0_U45", "Parent" : "67"},
	{"ID" : "74", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_9ns_9ns_9_2_0_U46", "Parent" : "67"},
	{"ID" : "75", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_10ns_10ns_10_2_0_U47", "Parent" : "67"},
	{"ID" : "76", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U48", "Parent" : "67"},
	{"ID" : "77", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U49", "Parent" : "67"},
	{"ID" : "78", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17s_17_2_0_U50", "Parent" : "67"},
	{"ID" : "79", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U51", "Parent" : "67"},
	{"ID" : "80", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U52", "Parent" : "67"},
	{"ID" : "81", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U53", "Parent" : "67"},
	{"ID" : "82", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U54", "Parent" : "67"},
	{"ID" : "83", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U55", "Parent" : "67"},
	{"ID" : "84", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U56", "Parent" : "67"},
	{"ID" : "85", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U57", "Parent" : "67"},
	{"ID" : "86", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U58", "Parent" : "67"},
	{"ID" : "87", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U59", "Parent" : "67"},
	{"ID" : "88", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U60", "Parent" : "67"},
	{"ID" : "89", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U61", "Parent" : "67"},
	{"ID" : "90", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U62", "Parent" : "67"},
	{"ID" : "91", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U63", "Parent" : "67"},
	{"ID" : "92", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U64", "Parent" : "67"},
	{"ID" : "93", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U65", "Parent" : "67"},
	{"ID" : "94", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U66", "Parent" : "67"},
	{"ID" : "95", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U67", "Parent" : "67"},
	{"ID" : "96", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U68", "Parent" : "67"},
	{"ID" : "97", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U69", "Parent" : "67"},
	{"ID" : "98", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U70", "Parent" : "67"},
	{"ID" : "99", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_19ns_19ns_19_2_0_U71", "Parent" : "67"},
	{"ID" : "100", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U72", "Parent" : "67"},
	{"ID" : "101", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U73", "Parent" : "67"},
	{"ID" : "102", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U74", "Parent" : "67"},
	{"ID" : "103", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U75", "Parent" : "67"},
	{"ID" : "104", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U76", "Parent" : "67"},
	{"ID" : "105", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U77", "Parent" : "67"},
	{"ID" : "106", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U78", "Parent" : "67"},
	{"ID" : "107", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U79", "Parent" : "67"},
	{"ID" : "108", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U80", "Parent" : "67"},
	{"ID" : "109", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U81", "Parent" : "67"},
	{"ID" : "110", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U82", "Parent" : "67"},
	{"ID" : "111", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U83", "Parent" : "67"},
	{"ID" : "112", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U84", "Parent" : "67"},
	{"ID" : "113", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U85", "Parent" : "67"},
	{"ID" : "114", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U86", "Parent" : "67"},
	{"ID" : "115", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U87", "Parent" : "67"},
	{"ID" : "116", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U88", "Parent" : "67"},
	{"ID" : "117", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U89", "Parent" : "67"},
	{"ID" : "118", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U90", "Parent" : "67"},
	{"ID" : "119", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U91", "Parent" : "67"},
	{"ID" : "120", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U92", "Parent" : "67"},
	{"ID" : "121", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U93", "Parent" : "67"},
	{"ID" : "122", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U94", "Parent" : "67"},
	{"ID" : "123", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U95", "Parent" : "67"},
	{"ID" : "124", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U96", "Parent" : "67"},
	{"ID" : "125", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U97", "Parent" : "67"},
	{"ID" : "126", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_19ns_19s_19_2_0_U98", "Parent" : "67"},
	{"ID" : "127", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U99", "Parent" : "67"},
	{"ID" : "128", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.sub_17ns_17ns_17_2_0_U100", "Parent" : "67"},
	{"ID" : "129", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U101", "Parent" : "67"},
	{"ID" : "130", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_18ns_18ns_18_2_0_U102", "Parent" : "67"},
	{"ID" : "131", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_17ns_17ns_17_2_0_U103", "Parent" : "67"},
	{"ID" : "132", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_sqrt_fixed_32_16_s_fu_778.add_8ns_8ns_8_2_0_U104", "Parent" : "67"},
	{"ID" : "133", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_10ns_10ns_10_2_1_U121", "Parent" : "0"},
	{"ID" : "134", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_4ns_4ns_4_2_1_U122", "Parent" : "0"},
	{"ID" : "135", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_10ns_10ns_10_2_1_U123", "Parent" : "0"},
	{"ID" : "136", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U124", "Parent" : "0"},
	{"ID" : "137", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_48ns_48s_48_2_1_U126", "Parent" : "0"},
	{"ID" : "138", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_48ns_48ns_48_2_1_U128", "Parent" : "0"},
	{"ID" : "139", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U129", "Parent" : "0"},
	{"ID" : "140", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_48ns_48s_48_2_1_U131", "Parent" : "0"},
	{"ID" : "141", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_48ns_48ns_48_2_1_U133", "Parent" : "0"},
	{"ID" : "142", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_10ns_10ns_10_2_1_U134", "Parent" : "0"},
	{"ID" : "143", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_4ns_4ns_4_2_1_U135", "Parent" : "0"},
	{"ID" : "144", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sdiv_48ns_25ns_32_52_1_U136", "Parent" : "0"},
	{"ID" : "145", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U137", "Parent" : "0"},
	{"ID" : "146", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U138", "Parent" : "0"},
	{"ID" : "147", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sdiv_48ns_25ns_32_52_1_U139", "Parent" : "0"},
	{"ID" : "148", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_13ns_13ns_13_2_1_U140", "Parent" : "0"},
	{"ID" : "149", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U141", "Parent" : "0"},
	{"ID" : "150", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_12ns_12ns_12_2_1_U142", "Parent" : "0"},
	{"ID" : "151", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U143", "Parent" : "0"},
	{"ID" : "152", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_48ns_48s_48_2_1_U145", "Parent" : "0"},
	{"ID" : "153", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_48ns_48ns_48_2_1_U147", "Parent" : "0"},
	{"ID" : "154", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U148", "Parent" : "0"},
	{"ID" : "155", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_48ns_48s_48_2_1_U150", "Parent" : "0"},
	{"ID" : "156", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_48ns_48ns_48_2_1_U152", "Parent" : "0"},
	{"ID" : "157", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_13ns_13ns_13_2_1_U153", "Parent" : "0"},
	{"ID" : "158", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U154", "Parent" : "0"},
	{"ID" : "159", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sdiv_48ns_25ns_32_52_1_U155", "Parent" : "0"},
	{"ID" : "160", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U156", "Parent" : "0"},
	{"ID" : "161", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U157", "Parent" : "0"},
	{"ID" : "162", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sdiv_48ns_25ns_32_52_1_U158", "Parent" : "0"},
	{"ID" : "163", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_8ns_8ns_8_2_0_U159", "Parent" : "0"},
	{"ID" : "164", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_8ns_8ns_8_2_0_U160", "Parent" : "0"},
	{"ID" : "165", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U161", "Parent" : "0"},
	{"ID" : "166", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_8ns_8ns_8_2_0_U162", "Parent" : "0"},
	{"ID" : "167", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_2ns_2ns_2_2_1_U163", "Parent" : "0"},
	{"ID" : "168", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_8ns_8ns_8_2_0_U164", "Parent" : "0"},
	{"ID" : "169", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_48ns_48s_48_2_1_U166", "Parent" : "0"},
	{"ID" : "170", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_48ns_48ns_48_2_1_U168", "Parent" : "0"},
	{"ID" : "171", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_2ns_2ns_2_2_1_U169", "Parent" : "0"},
	{"ID" : "172", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_32_4_1_U170", "Parent" : "0"},
	{"ID" : "173", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_48ns_48s_48_2_1_U172", "Parent" : "0"},
	{"ID" : "174", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_48ns_48ns_48_2_1_U174", "Parent" : "0"},
	{"ID" : "175", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_8ns_8ns_8_2_0_U175", "Parent" : "0"},
	{"ID" : "176", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_8ns_8ns_8_2_0_U176", "Parent" : "0"},
	{"ID" : "177", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_7ns_7ns_7_2_1_U177", "Parent" : "0"},
	{"ID" : "178", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sub_8ns_8ns_8_2_0_U178", "Parent" : "0"},
	{"ID" : "179", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_2ns_2ns_2_2_1_U179", "Parent" : "0"},
	{"ID" : "180", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_8ns_8ns_8_2_0_U180", "Parent" : "0"},
	{"ID" : "181", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sdiv_48ns_25ns_32_52_1_U181", "Parent" : "0"},
	{"ID" : "182", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.add_2ns_2ns_2_2_1_U182", "Parent" : "0"},
	{"ID" : "183", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sdiv_48ns_25ns_32_52_1_U183", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	update_weights {
		weights1 {Type IO LastRead 127 FirstWrite 19}
		weights2 {Type IO LastRead 256 FirstWrite 148}
		weights3 {Type IO LastRead 389 FirstWrite 279}
		biases1 {Type IO LastRead 128 FirstWrite 18}
		biases2 {Type IO LastRead 257 FirstWrite 147}
		biases3 {Type IO LastRead 385 FirstWrite 275}
		d_weights1 {Type I LastRead 6 FirstWrite -1}
		d_weights2 {Type I LastRead 135 FirstWrite -1}
		d_weights3 {Type I LastRead 266 FirstWrite -1}
		d_biases1 {Type I LastRead 5 FirstWrite -1}
		d_biases2 {Type I LastRead 134 FirstWrite -1}
		p_read {Type I LastRead 0 FirstWrite -1}
		p_read1 {Type I LastRead 0 FirstWrite -1}
		p_read2 {Type I LastRead 0 FirstWrite -1}}
	sqrt_fixed_32_16_s {
		x {Type I LastRead 0 FirstWrite -1}}
	sqrt_fixed_32_16_s {
		x {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "283449", "Max" : "283449"}
	, {"Name" : "Interval", "Min" : "283449", "Max" : "283449"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
	{"Pipeline" : "1", "EnableSignal" : "ap_enable_pp1"}
	{"Pipeline" : "2", "EnableSignal" : "ap_enable_pp2"}
	{"Pipeline" : "3", "EnableSignal" : "ap_enable_pp3"}
	{"Pipeline" : "4", "EnableSignal" : "ap_enable_pp4"}
	{"Pipeline" : "5", "EnableSignal" : "ap_enable_pp5"}
	{"Pipeline" : "6", "EnableSignal" : "ap_enable_pp6"}
	{"Pipeline" : "7", "EnableSignal" : "ap_enable_pp7"}
	{"Pipeline" : "8", "EnableSignal" : "ap_enable_pp8"}
	{"Pipeline" : "9", "EnableSignal" : "ap_enable_pp9"}
	{"Pipeline" : "10", "EnableSignal" : "ap_enable_pp10"}
	{"Pipeline" : "11", "EnableSignal" : "ap_enable_pp11"}
]}

set Spec2ImplPortList { 
	weights1 { ap_memory {  { weights1_address0 mem_address 1 10 }  { weights1_ce0 mem_ce 1 1 }  { weights1_we0 mem_we 1 1 }  { weights1_d0 mem_din 1 32 }  { weights1_q0 mem_dout 0 32 } } }
	weights2 { ap_memory {  { weights2_address0 mem_address 1 12 }  { weights2_ce0 mem_ce 1 1 }  { weights2_we0 mem_we 1 1 }  { weights2_d0 mem_din 1 32 }  { weights2_q0 mem_dout 0 32 } } }
	weights3 { ap_memory {  { weights3_address0 mem_address 1 8 }  { weights3_ce0 mem_ce 1 1 }  { weights3_we0 mem_we 1 1 }  { weights3_d0 mem_din 1 32 }  { weights3_q0 mem_dout 0 32 }  { weights3_address1 MemPortADDR2 1 8 }  { weights3_ce1 MemPortCE2 1 1 }  { weights3_q1 MemPortDOUT2 0 32 } } }
	biases1 { ap_memory {  { biases1_address0 mem_address 1 6 }  { biases1_ce0 mem_ce 1 1 }  { biases1_we0 mem_we 1 1 }  { biases1_d0 mem_din 1 32 }  { biases1_address1 MemPortADDR2 1 6 }  { biases1_ce1 MemPortCE2 1 1 }  { biases1_q1 MemPortDOUT2 0 32 } } }
	biases2 { ap_memory {  { biases2_address0 mem_address 1 6 }  { biases2_ce0 mem_ce 1 1 }  { biases2_we0 mem_we 1 1 }  { biases2_d0 mem_din 1 32 }  { biases2_address1 MemPortADDR2 1 6 }  { biases2_ce1 MemPortCE2 1 1 }  { biases2_q1 MemPortDOUT2 0 32 } } }
	biases3 { ap_memory {  { biases3_address0 mem_address 1 2 }  { biases3_ce0 mem_ce 1 1 }  { biases3_we0 mem_we 1 1 }  { biases3_d0 mem_din 1 32 }  { biases3_q0 mem_dout 0 32 }  { biases3_address1 MemPortADDR2 1 2 }  { biases3_ce1 MemPortCE2 1 1 }  { biases3_q1 MemPortDOUT2 0 32 } } }
	d_weights1 { ap_memory {  { d_weights1_address0 mem_address 1 10 }  { d_weights1_ce0 mem_ce 1 1 }  { d_weights1_q0 mem_dout 0 32 } } }
	d_weights2 { ap_memory {  { d_weights2_address0 mem_address 1 12 }  { d_weights2_ce0 mem_ce 1 1 }  { d_weights2_q0 mem_dout 0 32 } } }
	d_weights3 { ap_memory {  { d_weights3_address0 mem_address 1 8 }  { d_weights3_ce0 mem_ce 1 1 }  { d_weights3_q0 mem_dout 0 32 } } }
	d_biases1 { ap_memory {  { d_biases1_address0 mem_address 1 6 }  { d_biases1_ce0 mem_ce 1 1 }  { d_biases1_q0 mem_dout 0 32 } } }
	d_biases2 { ap_memory {  { d_biases2_address0 mem_address 1 6 }  { d_biases2_ce0 mem_ce 1 1 }  { d_biases2_q0 mem_dout 0 32 } } }
	p_read { ap_none {  { p_read in_data 0 32 } } }
	p_read1 { ap_none {  { p_read1 in_data 0 32 } } }
	p_read2 { ap_none {  { p_read2 in_data 0 32 } } }
}
