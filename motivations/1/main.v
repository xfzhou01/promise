`timescale 1ns/1ps
module addi #(
  parameter DATA_TYPE = 32
)(
  // inputs
  input  clk,
  input  rst,
  input  [DATA_TYPE - 1 : 0] lhs,
  input  lhs_valid,
  input  [DATA_TYPE - 1 : 0] rhs,
  input  rhs_valid,
  input  result_ready,
  // outputs
  output [DATA_TYPE - 1 : 0] result,
  output result_valid,
  output lhs_ready,
  output rhs_ready
);

  // Instantiate the join node
  join_type #(
    .SIZE(2)
  ) join_inputs (
    .ins_valid  ({rhs_valid, lhs_valid}),
    .outs_ready (result_ready             ),
    .ins_ready  ({rhs_ready, lhs_ready}  ),
    .outs_valid (result_valid             )
  );

assign result = lhs + rhs;


endmodule
`timescale 1ns/1ps
// In the original implementation
// Data Organization: out2-:32, out1+:32
// condition is implemeted as [0:0], I removed the redudancy
module cond_br_dataless (
	input  clk,
	input  rst,
  // Data Input Channel
	input  data_valid,
  output data_ready,
  // Condition Input Channel
	input  condition,		   
	input  condition_valid,
  output condition_ready,
  // True Output Channel, Channel 1
  output trueOut_valid,
	input  trueOut_ready,
  // False Output Channel, Channel 2
  output falseOut_valid,
	input  falseOut_ready
);	
	wire [1 : 0] ins_valid_vec; // Vector for the join's ins_valid
	wire [1 : 0] ins_ready_vec; // Vector for the join's ins_ready
	
	wire branchInputs_valid;
	wire branch_ready;

	// Assign individual signals to the vector
	assign ins_valid_vec = {condition_valid, data_valid};

	join_type #(
		.SIZE(2)
	) join_branch (
		.ins_valid  (ins_valid_vec     ),
		.outs_ready (branch_ready      ),
		.ins_ready  (ins_ready_vec     ),
		.outs_valid (branchInputs_valid)
	);

	// Connect the outputs of the join module to appropriate external signals
	assign data_ready = ins_ready_vec[0];
	assign condition_ready = ins_ready_vec[1];

	assign trueOut_valid  = condition & branchInputs_valid;
	assign falseOut_valid = ~condition & branchInputs_valid;
	assign branch_ready = (falseOut_ready & ~condition) | (trueOut_ready & condition);

endmodule
`timescale 1ns/1ps
module cond_br #(
	parameter DATA_TYPE = 32 // Default set to 32 bits
)(
	input clk,
	input rst,
  // Data Input Channel
	input [DATA_TYPE - 1 : 0] data,				
	input data_valid,
  output data_ready,
  // Condition Input Channel
	input condition,		
	input condition_valid,
  output condition_ready,
  // True Output Channel
  output [DATA_TYPE - 1 : 0] trueOut,
  output trueOut_valid,
	input trueOut_ready,
  // False Output Channel
  output [DATA_TYPE - 1 : 0] falseOut,
  output falseOut_valid,
	input falseOut_ready
);
	cond_br_dataless control (
		.clk			       (clk			       ),
		.rst			       (rst	    	     ),
		.data_valid		   (data_valid	   ),
    .data_ready		   (data_ready	   ),
		.condition		   (condition		   ),
		.condition_valid (condition_valid),
    .condition_ready (condition_ready),
    .trueOut_valid	 (trueOut_valid	 ),
		.trueOut_ready	 (trueOut_ready	 ),
		.falseOut_valid	 (falseOut_valid ),
		.falseOut_ready	 (falseOut_ready )
	);

	assign trueOut = data;
	assign falseOut = data;

endmodule
`timescale 1ns/1ps
module control_merge_dataless #(
  parameter SIZE = 2,
  parameter INDEX_TYPE = 1
)(
  input  clk,
  input  rst,
  // Input Channels, default 2 inputs
  input  [SIZE - 1 : 0] ins_valid,
  output [SIZE - 1 : 0] ins_ready,  
  // Data Output Channel
  output outs_valid,
  input  outs_ready,            
  // Index output Channel
  output [INDEX_TYPE - 1 : 0] index,
  output index_valid,
  input  index_ready
);
  wire dataAvailable;
  wire readyToFork;
  wire tehbOut_valid;
  wire tehbOut_ready;

  reg [INDEX_TYPE - 1 : 0] index_tehb;
  integer i;
  reg found;
  always @(ins_valid) begin
    index_tehb = {INDEX_TYPE{1'b0}};
    found = 1'b0;

    for (i = 0; i < SIZE; i = i + 1) begin
      if (!found && ins_valid[i]) begin
        index_tehb = i[INDEX_TYPE - 1 : 0];
        found = 1'b1; // Set flag to indicate the value has been found
      end
    end
  end

  // Instantiate Merge_dataless
  merge_dataless #(
    .SIZE(SIZE)
  ) merge_ins (
    .clk        (clk          ),
    .rst        (rst          ),
    .ins_valid  (ins_valid    ),
    .ins_ready  (ins_ready    ),
    .outs_valid (dataAvailable),
    .outs_ready (tehbOut_ready)
  );

  // Instantiate TEHB
  tehb #(
    .DATA_TYPE(INDEX_TYPE)
  ) tehb (
    .clk        (clk          ),
    .rst        (rst          ),
    .ins        (index_tehb   ),
    .ins_valid  (dataAvailable),
    .ins_ready  (tehbOut_ready),
    .outs       (index        ),
    .outs_valid (tehbOut_valid),
    .outs_ready (readyToFork  )
  );

  // Instantiate Fork_dataless
  fork_dataless #(
    .SIZE(2)
  ) fork_dataless (
    .clk        (clk                      ),
    .rst        (rst                      ),
    .ins_valid  (tehbOut_valid            ),
    .ins_ready  (readyToFork              ),
    .outs_valid ({index_valid, outs_valid}),
    .outs_ready ({index_ready, outs_ready})
  );

endmodule
`timescale 1ns/1ps
module delay_buffer #(
  parameter SIZE = 32
) (
  input  clk,
  input  rst,
  input  valid_in,
  input  ready_in,
  output valid_out
);
  integer i;
  reg [SIZE - 1 : 0] regs = 0;

  always @(posedge clk) begin
    if (rst)
      regs[0] <= 0;
    else if (ready_in)
      regs[0] <= valid_in;
  end

  always @(posedge clk) begin
    if (rst) begin
      for (i = 1; i < SIZE; i = i + 1) begin
        regs[i] <= 0;
      end
    end else if (ready_in) begin
      for (i = 1; i < SIZE; i = i + 1) begin
        regs[i] <= regs[i - 1];
      end
    end
  end

  assign valid_out = regs[SIZE - 1];
endmodule
`timescale 1ns/1ps
module eager_fork_register_block (
	input clk,
	input rst,

	input ins_valid,	// Input Channel
	input outs_ready,	// Output Channel
	input backpressure,

	output outs_valid,
	output blockStop
);
	reg transmitValue = 1;
	wire keepValue;

	assign keepValue = ~outs_ready & transmitValue;

	always @(posedge clk) begin
		if (rst) begin
			transmitValue <= 1;
		end else begin
			transmitValue <= keepValue | ~backpressure;
		end
	end

	assign outs_valid = transmitValue & ins_valid;
	assign blockStop = keepValue;

endmodule
`timescale 1ns/1ps
module extsi #(
  parameter INPUT_TYPE = 32,
  parameter OUTPUT_TYPE = 64
)(
  // inputs
  input  clk,
  input  rst,
  input  [INPUT_TYPE - 1 : 0] ins,
  input  ins_valid,
  output  ins_ready,
  // outputs
  output [OUTPUT_TYPE - 1 : 0] outs,
  output outs_valid,
  input outs_ready
);

  assign outs = {{(OUTPUT_TYPE - INPUT_TYPE){ins[INPUT_TYPE - 1]}}, ins};
  assign outs_valid = ins_valid;
  assign ins_ready = outs_ready;

endmodule`timescale 1ns/1ps
module fork_dataless #(
	parameter SIZE = 2
)(
	input  clk,
	input  rst,
  // Input Channel
	input  ins_valid,
  output ins_ready,
  // Output Channel
  output [SIZE - 1 : 0] outs_valid,
	input  [SIZE - 1: 0] outs_ready
);
	// Internal Signal Definition
	wire [SIZE - 1 : 0] blockStopArray;
	wire anyBlockStop;
	wire backpressure;

	or_n #(
		.SIZE(SIZE)
	) anyBlockFull (
		.ins  (blockStopArray),
		.outs (anyBlockStop  )
	);

	assign ins_ready = ~anyBlockStop;
	assign backpressure = ins_valid & anyBlockStop;

	// Define generate variable
	genvar gen;

	generate
		for (gen = SIZE - 1; gen >= 0; gen = gen - 1) begin: regBlock
			eager_fork_register_block regblock (
				.clk 			    (clk				        ),
				.rst 			    (rst				        ),
				.ins_valid 		(ins_valid			    ),
				.outs_ready 	(outs_ready[gen]	  ),
				.backpressure (backpressure		    ),
				.outs_valid 	(outs_valid[gen]	  ),
				.blockStop 		(blockStopArray[gen])
			);
		end
	endgenerate


endmodule
`timescale 1ns/1ps
module fork_type #(
	parameter SIZE = 2,
	parameter DATA_TYPE = 32
)(
	input  clk,
	input  rst,
  // Input Channel
	input  [DATA_TYPE - 1 : 0] ins,
	input  ins_valid,
  output ins_ready,
  // Output Channel
  output [SIZE * (DATA_TYPE) - 1 : 0] outs,
  output [SIZE - 1 : 0] outs_valid,
	input  [SIZE - 1 : 0] outs_ready
);

  fork_dataless #(
    .SIZE(SIZE)
  ) control (
    .clk        (clk        ),
    .rst        (rst        ),
    .ins_valid  (ins_valid  ),
    .ins_ready  (ins_ready  ),
    .outs_valid (outs_valid ),
    .outs_ready (outs_ready )
  );

  // Broadcast the input data to all output channels
  assign outs = {SIZE{ins}};

endmodule
module gaussian(
  input [7:0] c_loadData,
  input [7:0] a_loadData,
  input  c_start_valid,
  input  a_start_valid,
  input  start_valid,
  input  clk,
  input  rst,
  input  out0_ready,
  input  c_end_ready,
  input  a_end_ready,
  input  end_ready,
  output  c_start_ready,
  output  a_start_ready,
  output  start_ready,
  output [7:0] out0,
  output  out0_valid,
  output  c_end_valid,
  output  a_end_valid,
  output  end_valid,
  output  c_loadEn,
  output [3:0] c_loadAddr,
  output  c_storeEn,
  output [3:0] c_storeAddr,
  output [7:0] c_storeData,
  output  a_loadEn,
  output [6:0] a_loadAddr,
  output  a_storeEn,
  output [6:0] a_storeAddr,
  output [7:0] a_storeData
);
  wire  fork0_outs_0_valid;
  wire  fork0_outs_0_ready;
  wire  fork0_outs_1_valid;
  wire  fork0_outs_1_ready;
  wire  fork0_outs_2_valid;
  wire  fork0_outs_2_ready;
  wire  fork0_outs_3_valid;
  wire  fork0_outs_3_ready;
  wire [7:0] mem_controller2_ldData_0;
  wire  mem_controller2_ldData_0_valid;
  wire  mem_controller2_ldData_0_ready;
  wire [7:0] mem_controller2_ldData_1;
  wire  mem_controller2_ldData_1_valid;
  wire  mem_controller2_ldData_1_ready;
  wire  mem_controller2_memEnd_valid;
  wire  mem_controller2_memEnd_ready;
  wire  mem_controller2_loadEn;
  wire [6:0] mem_controller2_loadAddr;
  wire  mem_controller2_storeEn;
  wire [6:0] mem_controller2_storeAddr;
  wire [7:0] mem_controller2_storeData;
  wire [7:0] mem_controller3_ldData_0;
  wire  mem_controller3_ldData_0_valid;
  wire  mem_controller3_ldData_0_ready;
  wire  mem_controller3_memEnd_valid;
  wire  mem_controller3_memEnd_ready;
  wire  mem_controller3_loadEn;
  wire [3:0] mem_controller3_loadAddr;
  wire  mem_controller3_storeEn;
  wire [3:0] mem_controller3_storeAddr;
  wire [7:0] mem_controller3_storeData;
  wire [0:0] constant4_outs;
  wire  constant4_outs_valid;
  wire  constant4_outs_ready;
  wire [1:0] constant5_outs;
  wire  constant5_outs_valid;
  wire  constant5_outs_ready;
  wire [4:0] extsi18_outs;
  wire  extsi18_outs_valid;
  wire  extsi18_outs_ready;
  wire [7:0] extsi19_outs;
  wire  extsi19_outs_valid;
  wire  extsi19_outs_ready;
  wire [4:0] mux0_outs;
  wire  mux0_outs_valid;
  wire  mux0_outs_ready;
  wire [4:0] buffer0_outs;
  wire  buffer0_outs_valid;
  wire  buffer0_outs_ready;
  wire [4:0] buffer1_outs;
  wire  buffer1_outs_valid;
  wire  buffer1_outs_ready;
  wire [4:0] fork1_outs_0;
  wire  fork1_outs_0_valid;
  wire  fork1_outs_0_ready;
  wire [4:0] fork1_outs_1;
  wire  fork1_outs_1_valid;
  wire  fork1_outs_1_ready;
  wire [5:0] extsi20_outs;
  wire  extsi20_outs_valid;
  wire  extsi20_outs_ready;
  wire [7:0] mux1_outs;
  wire  mux1_outs_valid;
  wire  mux1_outs_ready;
  wire  control_merge0_outs_valid;
  wire  control_merge0_outs_ready;
  wire [0:0] control_merge0_index;
  wire  control_merge0_index_valid;
  wire  control_merge0_index_ready;
  wire [0:0] fork2_outs_0;
  wire  fork2_outs_0_valid;
  wire  fork2_outs_0_ready;
  wire [0:0] fork2_outs_1;
  wire  fork2_outs_1_valid;
  wire  fork2_outs_1_ready;
  wire  source0_outs_valid;
  wire  source0_outs_ready;
  wire [1:0] constant17_outs;
  wire  constant17_outs_valid;
  wire  constant17_outs_ready;
  wire [5:0] extsi21_outs;
  wire  extsi21_outs_valid;
  wire  extsi21_outs_ready;
  wire [5:0] addi2_result;
  wire  addi2_result_valid;
  wire  addi2_result_ready;
  wire [7:0] buffer2_outs;
  wire  buffer2_outs_valid;
  wire  buffer2_outs_ready;
  wire [7:0] buffer3_outs;
  wire  buffer3_outs_valid;
  wire  buffer3_outs_ready;
  wire  buffer4_outs_valid;
  wire  buffer4_outs_ready;
  wire  buffer5_outs_valid;
  wire  buffer5_outs_ready;
  wire [5:0] mux2_outs;
  wire  mux2_outs_valid;
  wire  mux2_outs_ready;
  wire [5:0] buffer6_outs;
  wire  buffer6_outs_valid;
  wire  buffer6_outs_ready;
  wire [5:0] buffer7_outs;
  wire  buffer7_outs_valid;
  wire  buffer7_outs_ready;
  wire [5:0] fork3_outs_0;
  wire  fork3_outs_0_valid;
  wire  fork3_outs_0_ready;
  wire [5:0] fork3_outs_1;
  wire  fork3_outs_1_valid;
  wire  fork3_outs_1_ready;
  wire [4:0] trunci2_outs;
  wire  trunci2_outs_valid;
  wire  trunci2_outs_ready;
  wire [7:0] mux3_outs;
  wire  mux3_outs_valid;
  wire  mux3_outs_ready;
  wire [4:0] mux4_outs;
  wire  mux4_outs_valid;
  wire  mux4_outs_ready;
  wire  control_merge1_outs_valid;
  wire  control_merge1_outs_ready;
  wire [0:0] control_merge1_index;
  wire  control_merge1_index_valid;
  wire  control_merge1_index_ready;
  wire [0:0] fork4_outs_0;
  wire  fork4_outs_0_valid;
  wire  fork4_outs_0_ready;
  wire [0:0] fork4_outs_1;
  wire  fork4_outs_1_valid;
  wire  fork4_outs_1_ready;
  wire [0:0] fork4_outs_2;
  wire  fork4_outs_2_valid;
  wire  fork4_outs_2_ready;
  wire  buffer12_outs_valid;
  wire  buffer12_outs_ready;
  wire  buffer13_outs_valid;
  wire  buffer13_outs_ready;
  wire  fork5_outs_0_valid;
  wire  fork5_outs_0_ready;
  wire  fork5_outs_1_valid;
  wire  fork5_outs_1_ready;
  wire  source1_outs_valid;
  wire  source1_outs_ready;
  wire [4:0] constant18_outs;
  wire  constant18_outs_valid;
  wire  constant18_outs_ready;
  wire [5:0] extsi22_outs;
  wire  extsi22_outs_valid;
  wire  extsi22_outs_ready;
  wire [1:0] constant19_outs;
  wire  constant19_outs_valid;
  wire  constant19_outs_ready;
  wire [1:0] fork6_outs_0;
  wire  fork6_outs_0_valid;
  wire  fork6_outs_0_ready;
  wire [1:0] fork6_outs_1;
  wire  fork6_outs_1_valid;
  wire  fork6_outs_1_ready;
  wire [0:0] cmpi2_result;
  wire  cmpi2_result_valid;
  wire  cmpi2_result_ready;
  wire [0:0] fork7_outs_0;
  wire  fork7_outs_0_valid;
  wire  fork7_outs_0_ready;
  wire [0:0] fork7_outs_1;
  wire  fork7_outs_1_valid;
  wire  fork7_outs_1_ready;
  wire [0:0] fork7_outs_2;
  wire  fork7_outs_2_valid;
  wire  fork7_outs_2_ready;
  wire [0:0] fork7_outs_3;
  wire  fork7_outs_3_valid;
  wire  fork7_outs_3_ready;
  wire [0:0] fork7_outs_4;
  wire  fork7_outs_4_valid;
  wire  fork7_outs_4_ready;
  wire [0:0] fork7_outs_5;
  wire  fork7_outs_5_valid;
  wire  fork7_outs_5_ready;
  wire [1:0] cond_br3_trueOut;
  wire  cond_br3_trueOut_valid;
  wire  cond_br3_trueOut_ready;
  wire [1:0] cond_br3_falseOut;
  wire  cond_br3_falseOut_valid;
  wire  cond_br3_falseOut_ready;
  wire [4:0] extsi17_outs;
  wire  extsi17_outs_valid;
  wire  extsi17_outs_ready;
  wire [1:0] cond_br4_trueOut;
  wire  cond_br4_trueOut_valid;
  wire  cond_br4_trueOut_ready;
  wire [1:0] cond_br4_falseOut;
  wire  cond_br4_falseOut_valid;
  wire  cond_br4_falseOut_ready;
  wire [31:0] extsi23_outs;
  wire  extsi23_outs_valid;
  wire  extsi23_outs_ready;
  wire [7:0] buffer8_outs;
  wire  buffer8_outs_valid;
  wire  buffer8_outs_ready;
  wire [7:0] buffer9_outs;
  wire  buffer9_outs_valid;
  wire  buffer9_outs_ready;
  wire [7:0] cond_br5_trueOut;
  wire  cond_br5_trueOut_valid;
  wire  cond_br5_trueOut_ready;
  wire [7:0] cond_br5_falseOut;
  wire  cond_br5_falseOut_valid;
  wire  cond_br5_falseOut_ready;
  wire [4:0] buffer10_outs;
  wire  buffer10_outs_valid;
  wire  buffer10_outs_ready;
  wire [4:0] buffer11_outs;
  wire  buffer11_outs_valid;
  wire  buffer11_outs_ready;
  wire [4:0] cond_br6_trueOut;
  wire  cond_br6_trueOut_valid;
  wire  cond_br6_trueOut_ready;
  wire [4:0] cond_br6_falseOut;
  wire  cond_br6_falseOut_valid;
  wire  cond_br6_falseOut_ready;
  wire [4:0] cond_br7_trueOut;
  wire  cond_br7_trueOut_valid;
  wire  cond_br7_trueOut_ready;
  wire [4:0] cond_br7_falseOut;
  wire  cond_br7_falseOut_valid;
  wire  cond_br7_falseOut_ready;
  wire  cond_br8_trueOut_valid;
  wire  cond_br8_trueOut_ready;
  wire  cond_br8_falseOut_valid;
  wire  cond_br8_falseOut_ready;
  wire [4:0] mux5_outs;
  wire  mux5_outs_valid;
  wire  mux5_outs_ready;
  wire [4:0] buffer14_outs;
  wire  buffer14_outs_valid;
  wire  buffer14_outs_ready;
  wire [4:0] buffer15_outs;
  wire  buffer15_outs_valid;
  wire  buffer15_outs_ready;
  wire [5:0] extsi24_outs;
  wire  extsi24_outs_valid;
  wire  extsi24_outs_ready;
  wire [31:0] mux6_outs;
  wire  mux6_outs_valid;
  wire  mux6_outs_ready;
  wire [31:0] buffer16_outs;
  wire  buffer16_outs_valid;
  wire  buffer16_outs_ready;
  wire [31:0] buffer17_outs;
  wire  buffer17_outs_valid;
  wire  buffer17_outs_ready;
  wire [31:0] fork8_outs_0;
  wire  fork8_outs_0_valid;
  wire  fork8_outs_0_ready;
  wire [31:0] fork8_outs_1;
  wire  fork8_outs_1_valid;
  wire  fork8_outs_1_ready;
  wire [31:0] fork8_outs_2;
  wire  fork8_outs_2_valid;
  wire  fork8_outs_2_ready;
  wire [31:0] fork8_outs_3;
  wire  fork8_outs_3_valid;
  wire  fork8_outs_3_ready;
  wire [31:0] fork8_outs_4;
  wire  fork8_outs_4_valid;
  wire  fork8_outs_4_ready;
  wire [6:0] trunci3_outs;
  wire  trunci3_outs_valid;
  wire  trunci3_outs_ready;
  wire [6:0] trunci4_outs;
  wire  trunci4_outs_valid;
  wire  trunci4_outs_ready;
  wire [6:0] trunci5_outs;
  wire  trunci5_outs_valid;
  wire  trunci5_outs_ready;
  wire [7:0] mux7_outs;
  wire  mux7_outs_valid;
  wire  mux7_outs_ready;
  wire [4:0] mux8_outs;
  wire  mux8_outs_valid;
  wire  mux8_outs_ready;
  wire [4:0] buffer20_outs;
  wire  buffer20_outs_valid;
  wire  buffer20_outs_ready;
  wire [4:0] buffer21_outs;
  wire  buffer21_outs_valid;
  wire  buffer21_outs_ready;
  wire [4:0] fork9_outs_0;
  wire  fork9_outs_0_valid;
  wire  fork9_outs_0_ready;
  wire [4:0] fork9_outs_1;
  wire  fork9_outs_1_valid;
  wire  fork9_outs_1_ready;
  wire [4:0] fork9_outs_2;
  wire  fork9_outs_2_valid;
  wire  fork9_outs_2_ready;
  wire [31:0] extsi25_outs;
  wire  extsi25_outs_valid;
  wire  extsi25_outs_ready;
  wire [31:0] fork10_outs_0;
  wire  fork10_outs_0_valid;
  wire  fork10_outs_0_ready;
  wire [31:0] fork10_outs_1;
  wire  fork10_outs_1_valid;
  wire  fork10_outs_1_ready;
  wire [3:0] trunci6_outs;
  wire  trunci6_outs_valid;
  wire  trunci6_outs_ready;
  wire [4:0] mux9_outs;
  wire  mux9_outs_valid;
  wire  mux9_outs_ready;
  wire [4:0] buffer22_outs;
  wire  buffer22_outs_valid;
  wire  buffer22_outs_ready;
  wire [4:0] buffer23_outs;
  wire  buffer23_outs_valid;
  wire  buffer23_outs_ready;
  wire [4:0] fork11_outs_0;
  wire  fork11_outs_0_valid;
  wire  fork11_outs_0_ready;
  wire [4:0] fork11_outs_1;
  wire  fork11_outs_1_valid;
  wire  fork11_outs_1_ready;
  wire [31:0] extsi26_outs;
  wire  extsi26_outs_valid;
  wire  extsi26_outs_ready;
  wire [31:0] fork12_outs_0;
  wire  fork12_outs_0_valid;
  wire  fork12_outs_0_ready;
  wire [31:0] fork12_outs_1;
  wire  fork12_outs_1_valid;
  wire  fork12_outs_1_ready;
  wire [31:0] fork12_outs_2;
  wire  fork12_outs_2_valid;
  wire  fork12_outs_2_ready;
  wire [31:0] fork12_outs_3;
  wire  fork12_outs_3_valid;
  wire  fork12_outs_3_ready;
  wire  control_merge2_outs_valid;
  wire  control_merge2_outs_ready;
  wire [0:0] control_merge2_index;
  wire  control_merge2_index_valid;
  wire  control_merge2_index_ready;
  wire [0:0] fork13_outs_0;
  wire  fork13_outs_0_valid;
  wire  fork13_outs_0_ready;
  wire [0:0] fork13_outs_1;
  wire  fork13_outs_1_valid;
  wire  fork13_outs_1_ready;
  wire [0:0] fork13_outs_2;
  wire  fork13_outs_2_valid;
  wire  fork13_outs_2_ready;
  wire [0:0] fork13_outs_3;
  wire  fork13_outs_3_valid;
  wire  fork13_outs_3_ready;
  wire [0:0] fork13_outs_4;
  wire  fork13_outs_4_valid;
  wire  fork13_outs_4_ready;
  wire  buffer24_outs_valid;
  wire  buffer24_outs_ready;
  wire  buffer25_outs_valid;
  wire  buffer25_outs_ready;
  wire  fork14_outs_0_valid;
  wire  fork14_outs_0_ready;
  wire  fork14_outs_1_valid;
  wire  fork14_outs_1_ready;
  wire [1:0] constant20_outs;
  wire  constant20_outs_valid;
  wire  constant20_outs_ready;
  wire [31:0] extsi9_outs;
  wire  extsi9_outs_valid;
  wire  extsi9_outs_ready;
  wire  source2_outs_valid;
  wire  source2_outs_ready;
  wire [4:0] constant21_outs;
  wire  constant21_outs_valid;
  wire  constant21_outs_ready;
  wire [5:0] extsi27_outs;
  wire  extsi27_outs_valid;
  wire  extsi27_outs_ready;
  wire  source3_outs_valid;
  wire  source3_outs_ready;
  wire [1:0] constant22_outs;
  wire  constant22_outs_valid;
  wire  constant22_outs_ready;
  wire [1:0] fork15_outs_0;
  wire  fork15_outs_0_valid;
  wire  fork15_outs_0_ready;
  wire [1:0] fork15_outs_1;
  wire  fork15_outs_1_valid;
  wire  fork15_outs_1_ready;
  wire [1:0] fork15_outs_2;
  wire  fork15_outs_2_valid;
  wire  fork15_outs_2_ready;
  wire [5:0] extsi28_outs;
  wire  extsi28_outs_valid;
  wire  extsi28_outs_ready;
  wire [31:0] extsi11_outs;
  wire  extsi11_outs_valid;
  wire  extsi11_outs_ready;
  wire [31:0] extsi12_outs;
  wire  extsi12_outs_valid;
  wire  extsi12_outs_ready;
  wire [31:0] fork16_outs_0;
  wire  fork16_outs_0_valid;
  wire  fork16_outs_0_ready;
  wire [31:0] fork16_outs_1;
  wire  fork16_outs_1_valid;
  wire  fork16_outs_1_ready;
  wire [31:0] fork16_outs_2;
  wire  fork16_outs_2_valid;
  wire  fork16_outs_2_ready;
  wire  source5_outs_valid;
  wire  source5_outs_ready;
  wire [2:0] constant23_outs;
  wire  constant23_outs_valid;
  wire  constant23_outs_ready;
  wire [31:0] extsi13_outs;
  wire  extsi13_outs_valid;
  wire  extsi13_outs_ready;
  wire [31:0] fork17_outs_0;
  wire  fork17_outs_0_valid;
  wire  fork17_outs_0_ready;
  wire [31:0] fork17_outs_1;
  wire  fork17_outs_1_valid;
  wire  fork17_outs_1_ready;
  wire [31:0] fork17_outs_2;
  wire  fork17_outs_2_valid;
  wire  fork17_outs_2_ready;
  wire [31:0] shli0_result;
  wire  shli0_result_valid;
  wire  shli0_result_ready;
  wire [6:0] trunci7_outs;
  wire  trunci7_outs_valid;
  wire  trunci7_outs_ready;
  wire [31:0] shli1_result;
  wire  shli1_result_valid;
  wire  shli1_result_ready;
  wire [6:0] trunci8_outs;
  wire  trunci8_outs_valid;
  wire  trunci8_outs_ready;
  wire [6:0] addi9_result;
  wire  addi9_result_valid;
  wire  addi9_result_ready;
  wire [6:0] addi3_result;
  wire  addi3_result_valid;
  wire  addi3_result_ready;
  wire [6:0] load0_addrOut;
  wire  load0_addrOut_valid;
  wire  load0_addrOut_ready;
  wire [7:0] load0_dataOut;
  wire  load0_dataOut_valid;
  wire  load0_dataOut_ready;
  wire [3:0] load1_addrOut;
  wire  load1_addrOut_valid;
  wire  load1_addrOut_ready;
  wire [7:0] load1_dataOut;
  wire  load1_dataOut_valid;
  wire  load1_dataOut_ready;
  wire [15:0] extsi29_outs;
  wire  extsi29_outs_valid;
  wire  extsi29_outs_ready;
  wire [31:0] shli2_result;
  wire  shli2_result_valid;
  wire  shli2_result_ready;
  wire [6:0] trunci9_outs;
  wire  trunci9_outs_valid;
  wire  trunci9_outs_ready;
  wire [31:0] shli3_result;
  wire  shli3_result_valid;
  wire  shli3_result_ready;
  wire [6:0] trunci10_outs;
  wire  trunci10_outs_valid;
  wire  trunci10_outs_ready;
  wire [6:0] addi10_result;
  wire  addi10_result_valid;
  wire  addi10_result_ready;
  wire [6:0] addi4_result;
  wire  addi4_result_valid;
  wire  addi4_result_ready;
  wire [6:0] load2_addrOut;
  wire  load2_addrOut_valid;
  wire  load2_addrOut_ready;
  wire [7:0] load2_dataOut;
  wire  load2_dataOut_valid;
  wire  load2_dataOut_ready;
  wire [15:0] extsi30_outs;
  wire  extsi30_outs_valid;
  wire  extsi30_outs_ready;
  wire [15:0] muli0_result;
  wire  muli0_result_valid;
  wire  muli0_result_ready;
  wire [7:0] trunci11_outs;
  wire  trunci11_outs_valid;
  wire  trunci11_outs_ready;
  wire [7:0] subi0_result;
  wire  subi0_result_valid;
  wire  subi0_result_ready;
  wire [31:0] shli4_result;
  wire  shli4_result_valid;
  wire  shli4_result_ready;
  wire [6:0] trunci12_outs;
  wire  trunci12_outs_valid;
  wire  trunci12_outs_ready;
  wire [31:0] shli5_result;
  wire  shli5_result_valid;
  wire  shli5_result_ready;
  wire [6:0] trunci13_outs;
  wire  trunci13_outs_valid;
  wire  trunci13_outs_ready;
  wire [6:0] addi11_result;
  wire  addi11_result_valid;
  wire  addi11_result_ready;
  wire [6:0] addi5_result;
  wire  addi5_result_valid;
  wire  addi5_result_ready;
  wire [6:0] store0_addrOut;
  wire  store0_addrOut_valid;
  wire  store0_addrOut_ready;
  wire [7:0] store0_dataToMem;
  wire  store0_dataToMem_valid;
  wire  store0_dataToMem_ready;
  wire [7:0] trunci1_outs;
  wire  trunci1_outs_valid;
  wire  trunci1_outs_ready;
  wire [7:0] buffer18_outs;
  wire  buffer18_outs_valid;
  wire  buffer18_outs_ready;
  wire [7:0] buffer19_outs;
  wire  buffer19_outs_valid;
  wire  buffer19_outs_ready;
  wire [7:0] addi0_result;
  wire  addi0_result_valid;
  wire  addi0_result_ready;
  wire [31:0] addi1_result;
  wire  addi1_result_valid;
  wire  addi1_result_ready;
  wire [5:0] addi6_result;
  wire  addi6_result_valid;
  wire  addi6_result_ready;
  wire [5:0] fork18_outs_0;
  wire  fork18_outs_0_valid;
  wire  fork18_outs_0_ready;
  wire [5:0] fork18_outs_1;
  wire  fork18_outs_1_valid;
  wire  fork18_outs_1_ready;
  wire [4:0] trunci14_outs;
  wire  trunci14_outs_valid;
  wire  trunci14_outs_ready;
  wire [0:0] cmpi0_result;
  wire  cmpi0_result_valid;
  wire  cmpi0_result_ready;
  wire [0:0] fork19_outs_0;
  wire  fork19_outs_0_valid;
  wire  fork19_outs_0_ready;
  wire [0:0] fork19_outs_1;
  wire  fork19_outs_1_valid;
  wire  fork19_outs_1_ready;
  wire [0:0] fork19_outs_2;
  wire  fork19_outs_2_valid;
  wire  fork19_outs_2_ready;
  wire [0:0] fork19_outs_3;
  wire  fork19_outs_3_valid;
  wire  fork19_outs_3_ready;
  wire [0:0] fork19_outs_4;
  wire  fork19_outs_4_valid;
  wire  fork19_outs_4_ready;
  wire [0:0] fork19_outs_5;
  wire  fork19_outs_5_valid;
  wire  fork19_outs_5_ready;
  wire [4:0] cond_br9_trueOut;
  wire  cond_br9_trueOut_valid;
  wire  cond_br9_trueOut_ready;
  wire [4:0] cond_br9_falseOut;
  wire  cond_br9_falseOut_valid;
  wire  cond_br9_falseOut_ready;
  wire [31:0] cond_br10_trueOut;
  wire  cond_br10_trueOut_valid;
  wire  cond_br10_trueOut_ready;
  wire [31:0] cond_br10_falseOut;
  wire  cond_br10_falseOut_valid;
  wire  cond_br10_falseOut_ready;
  wire [7:0] cond_br11_trueOut;
  wire  cond_br11_trueOut_valid;
  wire  cond_br11_trueOut_ready;
  wire [7:0] cond_br11_falseOut;
  wire  cond_br11_falseOut_valid;
  wire  cond_br11_falseOut_ready;
  wire [4:0] cond_br12_trueOut;
  wire  cond_br12_trueOut_valid;
  wire  cond_br12_trueOut_ready;
  wire [4:0] cond_br12_falseOut;
  wire  cond_br12_falseOut_valid;
  wire  cond_br12_falseOut_ready;
  wire [4:0] cond_br13_trueOut;
  wire  cond_br13_trueOut_valid;
  wire  cond_br13_trueOut_ready;
  wire [4:0] cond_br13_falseOut;
  wire  cond_br13_falseOut_valid;
  wire  cond_br13_falseOut_ready;
  wire  cond_br14_trueOut_valid;
  wire  cond_br14_trueOut_ready;
  wire  cond_br14_falseOut_valid;
  wire  cond_br14_falseOut_ready;
  wire [4:0] buffer28_outs;
  wire  buffer28_outs_valid;
  wire  buffer28_outs_ready;
  wire [4:0] buffer29_outs;
  wire  buffer29_outs_valid;
  wire  buffer29_outs_ready;
  wire [5:0] extsi31_outs;
  wire  extsi31_outs_valid;
  wire  extsi31_outs_ready;
  wire  source6_outs_valid;
  wire  source6_outs_ready;
  wire [1:0] constant24_outs;
  wire  constant24_outs_valid;
  wire  constant24_outs_ready;
  wire [5:0] extsi32_outs;
  wire  extsi32_outs_valid;
  wire  extsi32_outs_ready;
  wire [5:0] addi8_result;
  wire  addi8_result_valid;
  wire  addi8_result_ready;
  wire [7:0] buffer30_outs;
  wire  buffer30_outs_valid;
  wire  buffer30_outs_ready;
  wire [7:0] buffer31_outs;
  wire  buffer31_outs_valid;
  wire  buffer31_outs_ready;
  wire [4:0] buffer26_outs;
  wire  buffer26_outs_valid;
  wire  buffer26_outs_ready;
  wire [4:0] buffer27_outs;
  wire  buffer27_outs_valid;
  wire  buffer27_outs_ready;
  wire  buffer32_outs_valid;
  wire  buffer32_outs_ready;
  wire  buffer33_outs_valid;
  wire  buffer33_outs_ready;
  wire [4:0] buffer34_outs;
  wire  buffer34_outs_valid;
  wire  buffer34_outs_ready;
  wire [4:0] buffer35_outs;
  wire  buffer35_outs_valid;
  wire  buffer35_outs_ready;
  wire [5:0] extsi33_outs;
  wire  extsi33_outs_valid;
  wire  extsi33_outs_ready;
  wire  source7_outs_valid;
  wire  source7_outs_ready;
  wire [4:0] constant25_outs;
  wire  constant25_outs_valid;
  wire  constant25_outs_ready;
  wire [5:0] extsi34_outs;
  wire  extsi34_outs_valid;
  wire  extsi34_outs_ready;
  wire  source8_outs_valid;
  wire  source8_outs_ready;
  wire [1:0] constant26_outs;
  wire  constant26_outs_valid;
  wire  constant26_outs_ready;
  wire [5:0] extsi35_outs;
  wire  extsi35_outs_valid;
  wire  extsi35_outs_ready;
  wire [5:0] addi7_result;
  wire  addi7_result_valid;
  wire  addi7_result_ready;
  wire [5:0] fork20_outs_0;
  wire  fork20_outs_0_valid;
  wire  fork20_outs_0_ready;
  wire [5:0] fork20_outs_1;
  wire  fork20_outs_1_valid;
  wire  fork20_outs_1_ready;
  wire [4:0] trunci15_outs;
  wire  trunci15_outs_valid;
  wire  trunci15_outs_ready;
  wire [0:0] cmpi1_result;
  wire  cmpi1_result_valid;
  wire  cmpi1_result_ready;
  wire [0:0] fork21_outs_0;
  wire  fork21_outs_0_valid;
  wire  fork21_outs_0_ready;
  wire [0:0] fork21_outs_1;
  wire  fork21_outs_1_valid;
  wire  fork21_outs_1_ready;
  wire [0:0] fork21_outs_2;
  wire  fork21_outs_2_valid;
  wire  fork21_outs_2_ready;
  wire [4:0] cond_br15_trueOut;
  wire  cond_br15_trueOut_valid;
  wire  cond_br15_trueOut_ready;
  wire [4:0] cond_br15_falseOut;
  wire  cond_br15_falseOut_valid;
  wire  cond_br15_falseOut_ready;
  wire [7:0] buffer36_outs;
  wire  buffer36_outs_valid;
  wire  buffer36_outs_ready;
  wire [7:0] buffer37_outs;
  wire  buffer37_outs_valid;
  wire  buffer37_outs_ready;
  wire [7:0] cond_br16_trueOut;
  wire  cond_br16_trueOut_valid;
  wire  cond_br16_trueOut_ready;
  wire [7:0] cond_br16_falseOut;
  wire  cond_br16_falseOut_valid;
  wire  cond_br16_falseOut_ready;
  wire  buffer38_outs_valid;
  wire  buffer38_outs_ready;
  wire  buffer39_outs_valid;
  wire  buffer39_outs_ready;
  wire  cond_br17_trueOut_valid;
  wire  cond_br17_trueOut_ready;
  wire  cond_br17_falseOut_valid;
  wire  cond_br17_falseOut_ready;
  wire  buffer42_outs_valid;
  wire  buffer42_outs_ready;
  wire  buffer43_outs_valid;
  wire  buffer43_outs_ready;
  wire  fork22_outs_0_valid;
  wire  fork22_outs_0_ready;
  wire  fork22_outs_1_valid;
  wire  fork22_outs_1_ready;
  wire [7:0] buffer40_outs;
  wire  buffer40_outs_valid;
  wire  buffer40_outs_ready;
  wire [7:0] buffer41_outs;
  wire  buffer41_outs_valid;
  wire  buffer41_outs_ready;

  assign out0 = buffer41_outs;
  assign out0_valid = buffer41_outs_valid;
  assign buffer41_outs_ready = out0_ready;
  assign c_end_valid = mem_controller3_memEnd_valid;
  assign mem_controller3_memEnd_ready = c_end_ready;
  assign a_end_valid = mem_controller2_memEnd_valid;
  assign mem_controller2_memEnd_ready = a_end_ready;
  assign end_valid = fork0_outs_2_valid;
  assign fork0_outs_2_ready = end_ready;
  assign c_loadEn = mem_controller3_loadEn;
  assign c_loadAddr = mem_controller3_loadAddr;
  assign c_storeEn = mem_controller3_storeEn;
  assign c_storeAddr = mem_controller3_storeAddr;
  assign c_storeData = mem_controller3_storeData;
  assign a_loadEn = mem_controller2_loadEn;
  assign a_loadAddr = mem_controller2_loadAddr;
  assign a_storeEn = mem_controller2_storeEn;
  assign a_storeAddr = mem_controller2_storeAddr;
  assign a_storeData = mem_controller2_storeData;

  fork_dataless #(.SIZE(4)) fork0(
    .ins_valid (start_valid),
    .ins_ready (start_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid ({fork0_outs_3_valid, fork0_outs_2_valid, fork0_outs_1_valid, fork0_outs_0_valid}),
    .outs_ready ({fork0_outs_3_ready, fork0_outs_2_ready, fork0_outs_1_ready, fork0_outs_0_ready})
  );

  mem_controller #(.NUM_CONTROLS(1), .NUM_LOADS(2), .NUM_STORES(1), .DATA_TYPE(8), .ADDR_TYPE(7)) mem_controller2(
    .loadData (a_loadData),
    .memStart_valid (a_start_valid),
    .memStart_ready (a_start_ready),
    .ctrl ({extsi9_outs}),
    .ctrl_valid ({extsi9_outs_valid}),
    .ctrl_ready ({extsi9_outs_ready}),
    .ldAddr ({load2_addrOut, load0_addrOut}),
    .ldAddr_valid ({load2_addrOut_valid, load0_addrOut_valid}),
    .ldAddr_ready ({load2_addrOut_ready, load0_addrOut_ready}),
    .stAddr ({store0_addrOut}),
    .stAddr_valid ({store0_addrOut_valid}),
    .stAddr_ready ({store0_addrOut_ready}),
    .stData ({store0_dataToMem}),
    .stData_valid ({store0_dataToMem_valid}),
    .stData_ready ({store0_dataToMem_ready}),
    .ctrlEnd_valid (fork22_outs_1_valid),
    .ctrlEnd_ready (fork22_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .ldData ({mem_controller2_ldData_1, mem_controller2_ldData_0}),
    .ldData_valid ({mem_controller2_ldData_1_valid, mem_controller2_ldData_0_valid}),
    .ldData_ready ({mem_controller2_ldData_1_ready, mem_controller2_ldData_0_ready}),
    .memEnd_valid (mem_controller2_memEnd_valid),
    .memEnd_ready (mem_controller2_memEnd_ready),
    .loadEn (mem_controller2_loadEn),
    .loadAddr (mem_controller2_loadAddr),
    .storeEn (mem_controller2_storeEn),
    .storeAddr (mem_controller2_storeAddr),
    .storeData (mem_controller2_storeData)
  );

  mem_controller_storeless #(.NUM_LOADS(1), .DATA_TYPE(8), .ADDR_TYPE(4)) mem_controller3(
    .loadData (c_loadData),
    .memStart_valid (c_start_valid),
    .memStart_ready (c_start_ready),
    .ldAddr ({load1_addrOut}),
    .ldAddr_valid ({load1_addrOut_valid}),
    .ldAddr_ready ({load1_addrOut_ready}),
    .ctrlEnd_valid (fork22_outs_0_valid),
    .ctrlEnd_ready (fork22_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .ldData ({mem_controller3_ldData_0}),
    .ldData_valid ({mem_controller3_ldData_0_valid}),
    .ldData_ready ({mem_controller3_ldData_0_ready}),
    .memEnd_valid (mem_controller3_memEnd_valid),
    .memEnd_ready (mem_controller3_memEnd_ready),
    .loadEn (mem_controller3_loadEn),
    .loadAddr (mem_controller3_loadAddr),
    .storeEn (mem_controller3_storeEn),
    .storeAddr (mem_controller3_storeAddr),
    .storeData (mem_controller3_storeData)
  );

  handshake_constant_0 #(.DATA_WIDTH(1)) constant4(
    .ctrl_valid (fork0_outs_1_valid),
    .ctrl_ready (fork0_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant4_outs),
    .outs_valid (constant4_outs_valid),
    .outs_ready (constant4_outs_ready)
  );

  handshake_constant_1 #(.DATA_WIDTH(2)) constant5(
    .ctrl_valid (fork0_outs_0_valid),
    .ctrl_ready (fork0_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant5_outs),
    .outs_valid (constant5_outs_valid),
    .outs_ready (constant5_outs_ready)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(5)) extsi18(
    .ins (constant5_outs),
    .ins_valid (constant5_outs_valid),
    .ins_ready (constant5_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi18_outs),
    .outs_valid (extsi18_outs_valid),
    .outs_ready (extsi18_outs_ready)
  );

  extsi #(.INPUT_TYPE(1), .OUTPUT_TYPE(8)) extsi19(
    .ins (constant4_outs),
    .ins_valid (constant4_outs_valid),
    .ins_ready (constant4_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi19_outs),
    .outs_valid (extsi19_outs_valid),
    .outs_ready (extsi19_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(5), .SELECT_TYPE(1)) mux0(
    .index (fork2_outs_0),
    .index_valid (fork2_outs_0_valid),
    .index_ready (fork2_outs_0_ready),
    .ins ({cond_br15_trueOut, extsi18_outs}),
    .ins_valid ({cond_br15_trueOut_valid, extsi18_outs_valid}),
    .ins_ready ({cond_br15_trueOut_ready, extsi18_outs_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux0_outs),
    .outs_valid (mux0_outs_valid),
    .outs_ready (mux0_outs_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer0(
    .ins (mux0_outs),
    .ins_valid (mux0_outs_valid),
    .ins_ready (mux0_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer0_outs),
    .outs_valid (buffer0_outs_valid),
    .outs_ready (buffer0_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer1(
    .ins (buffer0_outs),
    .ins_valid (buffer0_outs_valid),
    .ins_ready (buffer0_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer1_outs),
    .outs_valid (buffer1_outs_valid),
    .outs_ready (buffer1_outs_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(5)) fork1(
    .ins (buffer1_outs),
    .ins_valid (buffer1_outs_valid),
    .ins_ready (buffer1_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork1_outs_1, fork1_outs_0}),
    .outs_valid ({fork1_outs_1_valid, fork1_outs_0_valid}),
    .outs_ready ({fork1_outs_1_ready, fork1_outs_0_ready})
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(6)) extsi20(
    .ins (fork1_outs_1),
    .ins_valid (fork1_outs_1_valid),
    .ins_ready (fork1_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi20_outs),
    .outs_valid (extsi20_outs_valid),
    .outs_ready (extsi20_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(8), .SELECT_TYPE(1)) mux1(
    .index (fork2_outs_1),
    .index_valid (fork2_outs_1_valid),
    .index_ready (fork2_outs_1_ready),
    .ins ({cond_br16_trueOut, extsi19_outs}),
    .ins_valid ({cond_br16_trueOut_valid, extsi19_outs_valid}),
    .ins_ready ({cond_br16_trueOut_ready, extsi19_outs_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux1_outs),
    .outs_valid (mux1_outs_valid),
    .outs_ready (mux1_outs_ready)
  );

  control_merge_dataless #(.SIZE(2), .INDEX_TYPE(1)) control_merge0(
    .ins_valid ({cond_br17_trueOut_valid, fork0_outs_3_valid}),
    .ins_ready ({cond_br17_trueOut_ready, fork0_outs_3_ready}),
    .clk (clk),
    .rst (rst),
    .outs_valid (control_merge0_outs_valid),
    .outs_ready (control_merge0_outs_ready),
    .index (control_merge0_index),
    .index_valid (control_merge0_index_valid),
    .index_ready (control_merge0_index_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(1)) fork2(
    .ins (control_merge0_index),
    .ins_valid (control_merge0_index_valid),
    .ins_ready (control_merge0_index_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork2_outs_1, fork2_outs_0}),
    .outs_valid ({fork2_outs_1_valid, fork2_outs_0_valid}),
    .outs_ready ({fork2_outs_1_ready, fork2_outs_0_ready})
  );

  source source0(
    .clk (clk),
    .rst (rst),
    .outs_valid (source0_outs_valid),
    .outs_ready (source0_outs_ready)
  );

  handshake_constant_1 #(.DATA_WIDTH(2)) constant17(
    .ctrl_valid (source0_outs_valid),
    .ctrl_ready (source0_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant17_outs),
    .outs_valid (constant17_outs_valid),
    .outs_ready (constant17_outs_ready)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(6)) extsi21(
    .ins (constant17_outs),
    .ins_valid (constant17_outs_valid),
    .ins_ready (constant17_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi21_outs),
    .outs_valid (extsi21_outs_valid),
    .outs_ready (extsi21_outs_ready)
  );

  addi #(.DATA_TYPE(6)) addi2(
    .lhs (extsi20_outs),
    .lhs_valid (extsi20_outs_valid),
    .lhs_ready (extsi20_outs_ready),
    .rhs (extsi21_outs),
    .rhs_valid (extsi21_outs_valid),
    .rhs_ready (extsi21_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi2_result),
    .result_valid (addi2_result_valid),
    .result_ready (addi2_result_ready)
  );

  oehb #(.DATA_TYPE(8)) buffer2(
    .ins (mux1_outs),
    .ins_valid (mux1_outs_valid),
    .ins_ready (mux1_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer2_outs),
    .outs_valid (buffer2_outs_valid),
    .outs_ready (buffer2_outs_ready)
  );

  tehb #(.DATA_TYPE(8)) buffer3(
    .ins (buffer2_outs),
    .ins_valid (buffer2_outs_valid),
    .ins_ready (buffer2_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer3_outs),
    .outs_valid (buffer3_outs_valid),
    .outs_ready (buffer3_outs_ready)
  );

  oehb_dataless buffer4(
    .ins_valid (control_merge0_outs_valid),
    .ins_ready (control_merge0_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer4_outs_valid),
    .outs_ready (buffer4_outs_ready)
  );

  tehb_dataless buffer5(
    .ins_valid (buffer4_outs_valid),
    .ins_ready (buffer4_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer5_outs_valid),
    .outs_ready (buffer5_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(6), .SELECT_TYPE(1)) mux2(
    .index (fork4_outs_1),
    .index_valid (fork4_outs_1_valid),
    .index_ready (fork4_outs_1_ready),
    .ins ({addi8_result, addi2_result}),
    .ins_valid ({addi8_result_valid, addi2_result_valid}),
    .ins_ready ({addi8_result_ready, addi2_result_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux2_outs),
    .outs_valid (mux2_outs_valid),
    .outs_ready (mux2_outs_ready)
  );

  oehb #(.DATA_TYPE(6)) buffer6(
    .ins (mux2_outs),
    .ins_valid (mux2_outs_valid),
    .ins_ready (mux2_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer6_outs),
    .outs_valid (buffer6_outs_valid),
    .outs_ready (buffer6_outs_ready)
  );

  tehb #(.DATA_TYPE(6)) buffer7(
    .ins (buffer6_outs),
    .ins_valid (buffer6_outs_valid),
    .ins_ready (buffer6_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer7_outs),
    .outs_valid (buffer7_outs_valid),
    .outs_ready (buffer7_outs_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(6)) fork3(
    .ins (buffer7_outs),
    .ins_valid (buffer7_outs_valid),
    .ins_ready (buffer7_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork3_outs_1, fork3_outs_0}),
    .outs_valid ({fork3_outs_1_valid, fork3_outs_0_valid}),
    .outs_ready ({fork3_outs_1_ready, fork3_outs_0_ready})
  );

  trunci #(.INPUT_TYPE(6), .OUTPUT_TYPE(5)) trunci2(
    .ins (fork3_outs_0),
    .ins_valid (fork3_outs_0_valid),
    .ins_ready (fork3_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci2_outs),
    .outs_valid (trunci2_outs_valid),
    .outs_ready (trunci2_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(8), .SELECT_TYPE(1)) mux3(
    .index (fork4_outs_2),
    .index_valid (fork4_outs_2_valid),
    .index_ready (fork4_outs_2_ready),
    .ins ({buffer31_outs, buffer3_outs}),
    .ins_valid ({buffer31_outs_valid, buffer3_outs_valid}),
    .ins_ready ({buffer31_outs_ready, buffer3_outs_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux3_outs),
    .outs_valid (mux3_outs_valid),
    .outs_ready (mux3_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(5), .SELECT_TYPE(1)) mux4(
    .index (fork4_outs_0),
    .index_valid (fork4_outs_0_valid),
    .index_ready (fork4_outs_0_ready),
    .ins ({buffer27_outs, fork1_outs_0}),
    .ins_valid ({buffer27_outs_valid, fork1_outs_0_valid}),
    .ins_ready ({buffer27_outs_ready, fork1_outs_0_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux4_outs),
    .outs_valid (mux4_outs_valid),
    .outs_ready (mux4_outs_ready)
  );

  control_merge_dataless #(.SIZE(2), .INDEX_TYPE(1)) control_merge1(
    .ins_valid ({buffer33_outs_valid, buffer5_outs_valid}),
    .ins_ready ({buffer33_outs_ready, buffer5_outs_ready}),
    .clk (clk),
    .rst (rst),
    .outs_valid (control_merge1_outs_valid),
    .outs_ready (control_merge1_outs_ready),
    .index (control_merge1_index),
    .index_valid (control_merge1_index_valid),
    .index_ready (control_merge1_index_ready)
  );

  fork_type #(.SIZE(3), .DATA_TYPE(1)) fork4(
    .ins (control_merge1_index),
    .ins_valid (control_merge1_index_valid),
    .ins_ready (control_merge1_index_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork4_outs_2, fork4_outs_1, fork4_outs_0}),
    .outs_valid ({fork4_outs_2_valid, fork4_outs_1_valid, fork4_outs_0_valid}),
    .outs_ready ({fork4_outs_2_ready, fork4_outs_1_ready, fork4_outs_0_ready})
  );

  oehb_dataless buffer12(
    .ins_valid (control_merge1_outs_valid),
    .ins_ready (control_merge1_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer12_outs_valid),
    .outs_ready (buffer12_outs_ready)
  );

  tehb_dataless buffer13(
    .ins_valid (buffer12_outs_valid),
    .ins_ready (buffer12_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer13_outs_valid),
    .outs_ready (buffer13_outs_ready)
  );

  fork_dataless #(.SIZE(2)) fork5(
    .ins_valid (buffer13_outs_valid),
    .ins_ready (buffer13_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid ({fork5_outs_1_valid, fork5_outs_0_valid}),
    .outs_ready ({fork5_outs_1_ready, fork5_outs_0_ready})
  );

  source source1(
    .clk (clk),
    .rst (rst),
    .outs_valid (source1_outs_valid),
    .outs_ready (source1_outs_ready)
  );

  handshake_constant_2 #(.DATA_WIDTH(5)) constant18(
    .ctrl_valid (source1_outs_valid),
    .ctrl_ready (source1_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant18_outs),
    .outs_valid (constant18_outs_valid),
    .outs_ready (constant18_outs_ready)
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(6)) extsi22(
    .ins (constant18_outs),
    .ins_valid (constant18_outs_valid),
    .ins_ready (constant18_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi22_outs),
    .outs_valid (extsi22_outs_valid),
    .outs_ready (extsi22_outs_ready)
  );

  handshake_constant_1 #(.DATA_WIDTH(2)) constant19(
    .ctrl_valid (fork5_outs_0_valid),
    .ctrl_ready (fork5_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant19_outs),
    .outs_valid (constant19_outs_valid),
    .outs_ready (constant19_outs_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(2)) fork6(
    .ins (constant19_outs),
    .ins_valid (constant19_outs_valid),
    .ins_ready (constant19_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork6_outs_1, fork6_outs_0}),
    .outs_valid ({fork6_outs_1_valid, fork6_outs_0_valid}),
    .outs_ready ({fork6_outs_1_ready, fork6_outs_0_ready})
  );

  handshake_cmpi_0 #(.DATA_TYPE(6)) cmpi2(
    .lhs (fork3_outs_1),
    .lhs_valid (fork3_outs_1_valid),
    .lhs_ready (fork3_outs_1_ready),
    .rhs (extsi22_outs),
    .rhs_valid (extsi22_outs_valid),
    .rhs_ready (extsi22_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (cmpi2_result),
    .result_valid (cmpi2_result_valid),
    .result_ready (cmpi2_result_ready)
  );

  fork_type #(.SIZE(6), .DATA_TYPE(1)) fork7(
    .ins (cmpi2_result),
    .ins_valid (cmpi2_result_valid),
    .ins_ready (cmpi2_result_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork7_outs_5, fork7_outs_4, fork7_outs_3, fork7_outs_2, fork7_outs_1, fork7_outs_0}),
    .outs_valid ({fork7_outs_5_valid, fork7_outs_4_valid, fork7_outs_3_valid, fork7_outs_2_valid, fork7_outs_1_valid, fork7_outs_0_valid}),
    .outs_ready ({fork7_outs_5_ready, fork7_outs_4_ready, fork7_outs_3_ready, fork7_outs_2_ready, fork7_outs_1_ready, fork7_outs_0_ready})
  );

  cond_br #(.DATA_TYPE(2)) cond_br3(
    .condition (fork7_outs_5),
    .condition_valid (fork7_outs_5_valid),
    .condition_ready (fork7_outs_5_ready),
    .data (fork6_outs_0),
    .data_valid (fork6_outs_0_valid),
    .data_ready (fork6_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br3_trueOut),
    .trueOut_valid (cond_br3_trueOut_valid),
    .trueOut_ready (cond_br3_trueOut_ready),
    .falseOut (cond_br3_falseOut),
    .falseOut_valid (cond_br3_falseOut_valid),
    .falseOut_ready (cond_br3_falseOut_ready)
  );

  sink #(.DATA_TYPE(2)) sink0(
    .ins (cond_br3_falseOut),
    .ins_valid (cond_br3_falseOut_valid),
    .ins_ready (cond_br3_falseOut_ready),
    .clk (clk),
    .rst (rst)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(5)) extsi17(
    .ins (cond_br3_trueOut),
    .ins_valid (cond_br3_trueOut_valid),
    .ins_ready (cond_br3_trueOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi17_outs),
    .outs_valid (extsi17_outs_valid),
    .outs_ready (extsi17_outs_ready)
  );

  cond_br #(.DATA_TYPE(2)) cond_br4(
    .condition (fork7_outs_4),
    .condition_valid (fork7_outs_4_valid),
    .condition_ready (fork7_outs_4_ready),
    .data (fork6_outs_1),
    .data_valid (fork6_outs_1_valid),
    .data_ready (fork6_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br4_trueOut),
    .trueOut_valid (cond_br4_trueOut_valid),
    .trueOut_ready (cond_br4_trueOut_ready),
    .falseOut (cond_br4_falseOut),
    .falseOut_valid (cond_br4_falseOut_valid),
    .falseOut_ready (cond_br4_falseOut_ready)
  );

  sink #(.DATA_TYPE(2)) sink1(
    .ins (cond_br4_falseOut),
    .ins_valid (cond_br4_falseOut_valid),
    .ins_ready (cond_br4_falseOut_ready),
    .clk (clk),
    .rst (rst)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(32)) extsi23(
    .ins (cond_br4_trueOut),
    .ins_valid (cond_br4_trueOut_valid),
    .ins_ready (cond_br4_trueOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi23_outs),
    .outs_valid (extsi23_outs_valid),
    .outs_ready (extsi23_outs_ready)
  );

  oehb #(.DATA_TYPE(8)) buffer8(
    .ins (mux3_outs),
    .ins_valid (mux3_outs_valid),
    .ins_ready (mux3_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer8_outs),
    .outs_valid (buffer8_outs_valid),
    .outs_ready (buffer8_outs_ready)
  );

  tehb #(.DATA_TYPE(8)) buffer9(
    .ins (buffer8_outs),
    .ins_valid (buffer8_outs_valid),
    .ins_ready (buffer8_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer9_outs),
    .outs_valid (buffer9_outs_valid),
    .outs_ready (buffer9_outs_ready)
  );

  cond_br #(.DATA_TYPE(8)) cond_br5(
    .condition (fork7_outs_2),
    .condition_valid (fork7_outs_2_valid),
    .condition_ready (fork7_outs_2_ready),
    .data (buffer9_outs),
    .data_valid (buffer9_outs_valid),
    .data_ready (buffer9_outs_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br5_trueOut),
    .trueOut_valid (cond_br5_trueOut_valid),
    .trueOut_ready (cond_br5_trueOut_ready),
    .falseOut (cond_br5_falseOut),
    .falseOut_valid (cond_br5_falseOut_valid),
    .falseOut_ready (cond_br5_falseOut_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer10(
    .ins (mux4_outs),
    .ins_valid (mux4_outs_valid),
    .ins_ready (mux4_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer10_outs),
    .outs_valid (buffer10_outs_valid),
    .outs_ready (buffer10_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer11(
    .ins (buffer10_outs),
    .ins_valid (buffer10_outs_valid),
    .ins_ready (buffer10_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer11_outs),
    .outs_valid (buffer11_outs_valid),
    .outs_ready (buffer11_outs_ready)
  );

  cond_br #(.DATA_TYPE(5)) cond_br6(
    .condition (fork7_outs_1),
    .condition_valid (fork7_outs_1_valid),
    .condition_ready (fork7_outs_1_ready),
    .data (buffer11_outs),
    .data_valid (buffer11_outs_valid),
    .data_ready (buffer11_outs_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br6_trueOut),
    .trueOut_valid (cond_br6_trueOut_valid),
    .trueOut_ready (cond_br6_trueOut_ready),
    .falseOut (cond_br6_falseOut),
    .falseOut_valid (cond_br6_falseOut_valid),
    .falseOut_ready (cond_br6_falseOut_ready)
  );

  cond_br #(.DATA_TYPE(5)) cond_br7(
    .condition (fork7_outs_0),
    .condition_valid (fork7_outs_0_valid),
    .condition_ready (fork7_outs_0_ready),
    .data (trunci2_outs),
    .data_valid (trunci2_outs_valid),
    .data_ready (trunci2_outs_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br7_trueOut),
    .trueOut_valid (cond_br7_trueOut_valid),
    .trueOut_ready (cond_br7_trueOut_ready),
    .falseOut (cond_br7_falseOut),
    .falseOut_valid (cond_br7_falseOut_valid),
    .falseOut_ready (cond_br7_falseOut_ready)
  );

  sink #(.DATA_TYPE(5)) sink2(
    .ins (cond_br7_falseOut),
    .ins_valid (cond_br7_falseOut_valid),
    .ins_ready (cond_br7_falseOut_ready),
    .clk (clk),
    .rst (rst)
  );

  cond_br_dataless cond_br8(
    .condition (fork7_outs_3),
    .condition_valid (fork7_outs_3_valid),
    .condition_ready (fork7_outs_3_ready),
    .data_valid (fork5_outs_1_valid),
    .data_ready (fork5_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .trueOut_valid (cond_br8_trueOut_valid),
    .trueOut_ready (cond_br8_trueOut_ready),
    .falseOut_valid (cond_br8_falseOut_valid),
    .falseOut_ready (cond_br8_falseOut_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(5), .SELECT_TYPE(1)) mux5(
    .index (fork13_outs_2),
    .index_valid (fork13_outs_2_valid),
    .index_ready (fork13_outs_2_ready),
    .ins ({cond_br9_trueOut, extsi17_outs}),
    .ins_valid ({cond_br9_trueOut_valid, extsi17_outs_valid}),
    .ins_ready ({cond_br9_trueOut_ready, extsi17_outs_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux5_outs),
    .outs_valid (mux5_outs_valid),
    .outs_ready (mux5_outs_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer14(
    .ins (mux5_outs),
    .ins_valid (mux5_outs_valid),
    .ins_ready (mux5_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer14_outs),
    .outs_valid (buffer14_outs_valid),
    .outs_ready (buffer14_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer15(
    .ins (buffer14_outs),
    .ins_valid (buffer14_outs_valid),
    .ins_ready (buffer14_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer15_outs),
    .outs_valid (buffer15_outs_valid),
    .outs_ready (buffer15_outs_ready)
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(6)) extsi24(
    .ins (buffer15_outs),
    .ins_valid (buffer15_outs_valid),
    .ins_ready (buffer15_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi24_outs),
    .outs_valid (extsi24_outs_valid),
    .outs_ready (extsi24_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(32), .SELECT_TYPE(1)) mux6(
    .index (fork13_outs_3),
    .index_valid (fork13_outs_3_valid),
    .index_ready (fork13_outs_3_ready),
    .ins ({cond_br10_trueOut, extsi23_outs}),
    .ins_valid ({cond_br10_trueOut_valid, extsi23_outs_valid}),
    .ins_ready ({cond_br10_trueOut_ready, extsi23_outs_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux6_outs),
    .outs_valid (mux6_outs_valid),
    .outs_ready (mux6_outs_ready)
  );

  oehb #(.DATA_TYPE(32)) buffer16(
    .ins (mux6_outs),
    .ins_valid (mux6_outs_valid),
    .ins_ready (mux6_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer16_outs),
    .outs_valid (buffer16_outs_valid),
    .outs_ready (buffer16_outs_ready)
  );

  tehb #(.DATA_TYPE(32)) buffer17(
    .ins (buffer16_outs),
    .ins_valid (buffer16_outs_valid),
    .ins_ready (buffer16_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer17_outs),
    .outs_valid (buffer17_outs_valid),
    .outs_ready (buffer17_outs_ready)
  );

  fork_type #(.SIZE(5), .DATA_TYPE(32)) fork8(
    .ins (buffer17_outs),
    .ins_valid (buffer17_outs_valid),
    .ins_ready (buffer17_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork8_outs_4, fork8_outs_3, fork8_outs_2, fork8_outs_1, fork8_outs_0}),
    .outs_valid ({fork8_outs_4_valid, fork8_outs_3_valid, fork8_outs_2_valid, fork8_outs_1_valid, fork8_outs_0_valid}),
    .outs_ready ({fork8_outs_4_ready, fork8_outs_3_ready, fork8_outs_2_ready, fork8_outs_1_ready, fork8_outs_0_ready})
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci3(
    .ins (fork8_outs_0),
    .ins_valid (fork8_outs_0_valid),
    .ins_ready (fork8_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci3_outs),
    .outs_valid (trunci3_outs_valid),
    .outs_ready (trunci3_outs_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci4(
    .ins (fork8_outs_1),
    .ins_valid (fork8_outs_1_valid),
    .ins_ready (fork8_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci4_outs),
    .outs_valid (trunci4_outs_valid),
    .outs_ready (trunci4_outs_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci5(
    .ins (fork8_outs_2),
    .ins_valid (fork8_outs_2_valid),
    .ins_ready (fork8_outs_2_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci5_outs),
    .outs_valid (trunci5_outs_valid),
    .outs_ready (trunci5_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(8), .SELECT_TYPE(1)) mux7(
    .index (fork13_outs_4),
    .index_valid (fork13_outs_4_valid),
    .index_ready (fork13_outs_4_ready),
    .ins ({cond_br11_trueOut, cond_br5_trueOut}),
    .ins_valid ({cond_br11_trueOut_valid, cond_br5_trueOut_valid}),
    .ins_ready ({cond_br11_trueOut_ready, cond_br5_trueOut_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux7_outs),
    .outs_valid (mux7_outs_valid),
    .outs_ready (mux7_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(5), .SELECT_TYPE(1)) mux8(
    .index (fork13_outs_0),
    .index_valid (fork13_outs_0_valid),
    .index_ready (fork13_outs_0_ready),
    .ins ({cond_br12_trueOut, cond_br6_trueOut}),
    .ins_valid ({cond_br12_trueOut_valid, cond_br6_trueOut_valid}),
    .ins_ready ({cond_br12_trueOut_ready, cond_br6_trueOut_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux8_outs),
    .outs_valid (mux8_outs_valid),
    .outs_ready (mux8_outs_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer20(
    .ins (mux8_outs),
    .ins_valid (mux8_outs_valid),
    .ins_ready (mux8_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer20_outs),
    .outs_valid (buffer20_outs_valid),
    .outs_ready (buffer20_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer21(
    .ins (buffer20_outs),
    .ins_valid (buffer20_outs_valid),
    .ins_ready (buffer20_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer21_outs),
    .outs_valid (buffer21_outs_valid),
    .outs_ready (buffer21_outs_ready)
  );

  fork_type #(.SIZE(3), .DATA_TYPE(5)) fork9(
    .ins (buffer21_outs),
    .ins_valid (buffer21_outs_valid),
    .ins_ready (buffer21_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork9_outs_2, fork9_outs_1, fork9_outs_0}),
    .outs_valid ({fork9_outs_2_valid, fork9_outs_1_valid, fork9_outs_0_valid}),
    .outs_ready ({fork9_outs_2_ready, fork9_outs_1_ready, fork9_outs_0_ready})
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(32)) extsi25(
    .ins (fork9_outs_2),
    .ins_valid (fork9_outs_2_valid),
    .ins_ready (fork9_outs_2_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi25_outs),
    .outs_valid (extsi25_outs_valid),
    .outs_ready (extsi25_outs_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(32)) fork10(
    .ins (extsi25_outs),
    .ins_valid (extsi25_outs_valid),
    .ins_ready (extsi25_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork10_outs_1, fork10_outs_0}),
    .outs_valid ({fork10_outs_1_valid, fork10_outs_0_valid}),
    .outs_ready ({fork10_outs_1_ready, fork10_outs_0_ready})
  );

  trunci #(.INPUT_TYPE(5), .OUTPUT_TYPE(4)) trunci6(
    .ins (fork9_outs_0),
    .ins_valid (fork9_outs_0_valid),
    .ins_ready (fork9_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci6_outs),
    .outs_valid (trunci6_outs_valid),
    .outs_ready (trunci6_outs_ready)
  );

  mux #(.SIZE(2), .DATA_TYPE(5), .SELECT_TYPE(1)) mux9(
    .index (fork13_outs_1),
    .index_valid (fork13_outs_1_valid),
    .index_ready (fork13_outs_1_ready),
    .ins ({cond_br13_trueOut, cond_br7_trueOut}),
    .ins_valid ({cond_br13_trueOut_valid, cond_br7_trueOut_valid}),
    .ins_ready ({cond_br13_trueOut_ready, cond_br7_trueOut_ready}),
    .clk (clk),
    .rst (rst),
    .outs (mux9_outs),
    .outs_valid (mux9_outs_valid),
    .outs_ready (mux9_outs_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer22(
    .ins (mux9_outs),
    .ins_valid (mux9_outs_valid),
    .ins_ready (mux9_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer22_outs),
    .outs_valid (buffer22_outs_valid),
    .outs_ready (buffer22_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer23(
    .ins (buffer22_outs),
    .ins_valid (buffer22_outs_valid),
    .ins_ready (buffer22_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer23_outs),
    .outs_valid (buffer23_outs_valid),
    .outs_ready (buffer23_outs_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(5)) fork11(
    .ins (buffer23_outs),
    .ins_valid (buffer23_outs_valid),
    .ins_ready (buffer23_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork11_outs_1, fork11_outs_0}),
    .outs_valid ({fork11_outs_1_valid, fork11_outs_0_valid}),
    .outs_ready ({fork11_outs_1_ready, fork11_outs_0_ready})
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(32)) extsi26(
    .ins (fork11_outs_1),
    .ins_valid (fork11_outs_1_valid),
    .ins_ready (fork11_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi26_outs),
    .outs_valid (extsi26_outs_valid),
    .outs_ready (extsi26_outs_ready)
  );

  fork_type #(.SIZE(4), .DATA_TYPE(32)) fork12(
    .ins (extsi26_outs),
    .ins_valid (extsi26_outs_valid),
    .ins_ready (extsi26_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork12_outs_3, fork12_outs_2, fork12_outs_1, fork12_outs_0}),
    .outs_valid ({fork12_outs_3_valid, fork12_outs_2_valid, fork12_outs_1_valid, fork12_outs_0_valid}),
    .outs_ready ({fork12_outs_3_ready, fork12_outs_2_ready, fork12_outs_1_ready, fork12_outs_0_ready})
  );

  control_merge_dataless #(.SIZE(2), .INDEX_TYPE(1)) control_merge2(
    .ins_valid ({cond_br14_trueOut_valid, cond_br8_trueOut_valid}),
    .ins_ready ({cond_br14_trueOut_ready, cond_br8_trueOut_ready}),
    .clk (clk),
    .rst (rst),
    .outs_valid (control_merge2_outs_valid),
    .outs_ready (control_merge2_outs_ready),
    .index (control_merge2_index),
    .index_valid (control_merge2_index_valid),
    .index_ready (control_merge2_index_ready)
  );

  fork_type #(.SIZE(5), .DATA_TYPE(1)) fork13(
    .ins (control_merge2_index),
    .ins_valid (control_merge2_index_valid),
    .ins_ready (control_merge2_index_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork13_outs_4, fork13_outs_3, fork13_outs_2, fork13_outs_1, fork13_outs_0}),
    .outs_valid ({fork13_outs_4_valid, fork13_outs_3_valid, fork13_outs_2_valid, fork13_outs_1_valid, fork13_outs_0_valid}),
    .outs_ready ({fork13_outs_4_ready, fork13_outs_3_ready, fork13_outs_2_ready, fork13_outs_1_ready, fork13_outs_0_ready})
  );

  oehb_dataless buffer24(
    .ins_valid (control_merge2_outs_valid),
    .ins_ready (control_merge2_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer24_outs_valid),
    .outs_ready (buffer24_outs_ready)
  );

  tehb_dataless buffer25(
    .ins_valid (buffer24_outs_valid),
    .ins_ready (buffer24_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer25_outs_valid),
    .outs_ready (buffer25_outs_ready)
  );

  fork_dataless #(.SIZE(2)) fork14(
    .ins_valid (buffer25_outs_valid),
    .ins_ready (buffer25_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid ({fork14_outs_1_valid, fork14_outs_0_valid}),
    .outs_ready ({fork14_outs_1_ready, fork14_outs_0_ready})
  );

  handshake_constant_1 #(.DATA_WIDTH(2)) constant20(
    .ctrl_valid (fork14_outs_0_valid),
    .ctrl_ready (fork14_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant20_outs),
    .outs_valid (constant20_outs_valid),
    .outs_ready (constant20_outs_ready)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(32)) extsi9(
    .ins (constant20_outs),
    .ins_valid (constant20_outs_valid),
    .ins_ready (constant20_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi9_outs),
    .outs_valid (extsi9_outs_valid),
    .outs_ready (extsi9_outs_ready)
  );

  source source2(
    .clk (clk),
    .rst (rst),
    .outs_valid (source2_outs_valid),
    .outs_ready (source2_outs_ready)
  );

  handshake_constant_3 #(.DATA_WIDTH(5)) constant21(
    .ctrl_valid (source2_outs_valid),
    .ctrl_ready (source2_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant21_outs),
    .outs_valid (constant21_outs_valid),
    .outs_ready (constant21_outs_ready)
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(6)) extsi27(
    .ins (constant21_outs),
    .ins_valid (constant21_outs_valid),
    .ins_ready (constant21_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi27_outs),
    .outs_valid (extsi27_outs_valid),
    .outs_ready (extsi27_outs_ready)
  );

  source source3(
    .clk (clk),
    .rst (rst),
    .outs_valid (source3_outs_valid),
    .outs_ready (source3_outs_ready)
  );

  handshake_constant_1 #(.DATA_WIDTH(2)) constant22(
    .ctrl_valid (source3_outs_valid),
    .ctrl_ready (source3_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant22_outs),
    .outs_valid (constant22_outs_valid),
    .outs_ready (constant22_outs_ready)
  );

  fork_type #(.SIZE(3), .DATA_TYPE(2)) fork15(
    .ins (constant22_outs),
    .ins_valid (constant22_outs_valid),
    .ins_ready (constant22_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork15_outs_2, fork15_outs_1, fork15_outs_0}),
    .outs_valid ({fork15_outs_2_valid, fork15_outs_1_valid, fork15_outs_0_valid}),
    .outs_ready ({fork15_outs_2_ready, fork15_outs_1_ready, fork15_outs_0_ready})
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(6)) extsi28(
    .ins (fork15_outs_0),
    .ins_valid (fork15_outs_0_valid),
    .ins_ready (fork15_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi28_outs),
    .outs_valid (extsi28_outs_valid),
    .outs_ready (extsi28_outs_ready)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(32)) extsi11(
    .ins (fork15_outs_1),
    .ins_valid (fork15_outs_1_valid),
    .ins_ready (fork15_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi11_outs),
    .outs_valid (extsi11_outs_valid),
    .outs_ready (extsi11_outs_ready)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(32)) extsi12(
    .ins (fork15_outs_2),
    .ins_valid (fork15_outs_2_valid),
    .ins_ready (fork15_outs_2_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi12_outs),
    .outs_valid (extsi12_outs_valid),
    .outs_ready (extsi12_outs_ready)
  );

  fork_type #(.SIZE(3), .DATA_TYPE(32)) fork16(
    .ins (extsi12_outs),
    .ins_valid (extsi12_outs_valid),
    .ins_ready (extsi12_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork16_outs_2, fork16_outs_1, fork16_outs_0}),
    .outs_valid ({fork16_outs_2_valid, fork16_outs_1_valid, fork16_outs_0_valid}),
    .outs_ready ({fork16_outs_2_ready, fork16_outs_1_ready, fork16_outs_0_ready})
  );

  source source5(
    .clk (clk),
    .rst (rst),
    .outs_valid (source5_outs_valid),
    .outs_ready (source5_outs_ready)
  );

  handshake_constant_4 #(.DATA_WIDTH(3)) constant23(
    .ctrl_valid (source5_outs_valid),
    .ctrl_ready (source5_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant23_outs),
    .outs_valid (constant23_outs_valid),
    .outs_ready (constant23_outs_ready)
  );

  extsi #(.INPUT_TYPE(3), .OUTPUT_TYPE(32)) extsi13(
    .ins (constant23_outs),
    .ins_valid (constant23_outs_valid),
    .ins_ready (constant23_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi13_outs),
    .outs_valid (extsi13_outs_valid),
    .outs_ready (extsi13_outs_ready)
  );

  fork_type #(.SIZE(3), .DATA_TYPE(32)) fork17(
    .ins (extsi13_outs),
    .ins_valid (extsi13_outs_valid),
    .ins_ready (extsi13_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork17_outs_2, fork17_outs_1, fork17_outs_0}),
    .outs_valid ({fork17_outs_2_valid, fork17_outs_1_valid, fork17_outs_0_valid}),
    .outs_ready ({fork17_outs_2_ready, fork17_outs_1_ready, fork17_outs_0_ready})
  );

  shli #(.DATA_TYPE(32)) shli0(
    .lhs (fork12_outs_0),
    .lhs_valid (fork12_outs_0_valid),
    .lhs_ready (fork12_outs_0_ready),
    .rhs (fork16_outs_0),
    .rhs_valid (fork16_outs_0_valid),
    .rhs_ready (fork16_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .result (shli0_result),
    .result_valid (shli0_result_valid),
    .result_ready (shli0_result_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci7(
    .ins (shli0_result),
    .ins_valid (shli0_result_valid),
    .ins_ready (shli0_result_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci7_outs),
    .outs_valid (trunci7_outs_valid),
    .outs_ready (trunci7_outs_ready)
  );

  shli #(.DATA_TYPE(32)) shli1(
    .lhs (fork12_outs_1),
    .lhs_valid (fork12_outs_1_valid),
    .lhs_ready (fork12_outs_1_ready),
    .rhs (fork17_outs_0),
    .rhs_valid (fork17_outs_0_valid),
    .rhs_ready (fork17_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .result (shli1_result),
    .result_valid (shli1_result_valid),
    .result_ready (shli1_result_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci8(
    .ins (shli1_result),
    .ins_valid (shli1_result_valid),
    .ins_ready (shli1_result_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci8_outs),
    .outs_valid (trunci8_outs_valid),
    .outs_ready (trunci8_outs_ready)
  );

  addi #(.DATA_TYPE(7)) addi9(
    .lhs (trunci7_outs),
    .lhs_valid (trunci7_outs_valid),
    .lhs_ready (trunci7_outs_ready),
    .rhs (trunci8_outs),
    .rhs_valid (trunci8_outs_valid),
    .rhs_ready (trunci8_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi9_result),
    .result_valid (addi9_result_valid),
    .result_ready (addi9_result_ready)
  );

  addi #(.DATA_TYPE(7)) addi3(
    .lhs (trunci3_outs),
    .lhs_valid (trunci3_outs_valid),
    .lhs_ready (trunci3_outs_ready),
    .rhs (addi9_result),
    .rhs_valid (addi9_result_valid),
    .rhs_ready (addi9_result_ready),
    .clk (clk),
    .rst (rst),
    .result (addi3_result),
    .result_valid (addi3_result_valid),
    .result_ready (addi3_result_ready)
  );

  load #(.DATA_TYPE(8), .ADDR_TYPE(7)) load0(
    .addrIn (addi3_result),
    .addrIn_valid (addi3_result_valid),
    .addrIn_ready (addi3_result_ready),
    .dataFromMem (mem_controller2_ldData_0),
    .dataFromMem_valid (mem_controller2_ldData_0_valid),
    .dataFromMem_ready (mem_controller2_ldData_0_ready),
    .clk (clk),
    .rst (rst),
    .addrOut (load0_addrOut),
    .addrOut_valid (load0_addrOut_valid),
    .addrOut_ready (load0_addrOut_ready),
    .dataOut (load0_dataOut),
    .dataOut_valid (load0_dataOut_valid),
    .dataOut_ready (load0_dataOut_ready)
  );

  load #(.DATA_TYPE(8), .ADDR_TYPE(4)) load1(
    .addrIn (trunci6_outs),
    .addrIn_valid (trunci6_outs_valid),
    .addrIn_ready (trunci6_outs_ready),
    .dataFromMem (mem_controller3_ldData_0),
    .dataFromMem_valid (mem_controller3_ldData_0_valid),
    .dataFromMem_ready (mem_controller3_ldData_0_ready),
    .clk (clk),
    .rst (rst),
    .addrOut (load1_addrOut),
    .addrOut_valid (load1_addrOut_valid),
    .addrOut_ready (load1_addrOut_ready),
    .dataOut (load1_dataOut),
    .dataOut_valid (load1_dataOut_valid),
    .dataOut_ready (load1_dataOut_ready)
  );

  extsi #(.INPUT_TYPE(8), .OUTPUT_TYPE(16)) extsi29(
    .ins (load1_dataOut),
    .ins_valid (load1_dataOut_valid),
    .ins_ready (load1_dataOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi29_outs),
    .outs_valid (extsi29_outs_valid),
    .outs_ready (extsi29_outs_ready)
  );

  shli #(.DATA_TYPE(32)) shli2(
    .lhs (fork10_outs_0),
    .lhs_valid (fork10_outs_0_valid),
    .lhs_ready (fork10_outs_0_ready),
    .rhs (fork16_outs_1),
    .rhs_valid (fork16_outs_1_valid),
    .rhs_ready (fork16_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .result (shli2_result),
    .result_valid (shli2_result_valid),
    .result_ready (shli2_result_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci9(
    .ins (shli2_result),
    .ins_valid (shli2_result_valid),
    .ins_ready (shli2_result_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci9_outs),
    .outs_valid (trunci9_outs_valid),
    .outs_ready (trunci9_outs_ready)
  );

  shli #(.DATA_TYPE(32)) shli3(
    .lhs (fork10_outs_1),
    .lhs_valid (fork10_outs_1_valid),
    .lhs_ready (fork10_outs_1_ready),
    .rhs (fork17_outs_1),
    .rhs_valid (fork17_outs_1_valid),
    .rhs_ready (fork17_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .result (shli3_result),
    .result_valid (shli3_result_valid),
    .result_ready (shli3_result_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci10(
    .ins (shli3_result),
    .ins_valid (shli3_result_valid),
    .ins_ready (shli3_result_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci10_outs),
    .outs_valid (trunci10_outs_valid),
    .outs_ready (trunci10_outs_ready)
  );

  addi #(.DATA_TYPE(7)) addi10(
    .lhs (trunci9_outs),
    .lhs_valid (trunci9_outs_valid),
    .lhs_ready (trunci9_outs_ready),
    .rhs (trunci10_outs),
    .rhs_valid (trunci10_outs_valid),
    .rhs_ready (trunci10_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi10_result),
    .result_valid (addi10_result_valid),
    .result_ready (addi10_result_ready)
  );

  addi #(.DATA_TYPE(7)) addi4(
    .lhs (trunci4_outs),
    .lhs_valid (trunci4_outs_valid),
    .lhs_ready (trunci4_outs_ready),
    .rhs (addi10_result),
    .rhs_valid (addi10_result_valid),
    .rhs_ready (addi10_result_ready),
    .clk (clk),
    .rst (rst),
    .result (addi4_result),
    .result_valid (addi4_result_valid),
    .result_ready (addi4_result_ready)
  );

  load #(.DATA_TYPE(8), .ADDR_TYPE(7)) load2(
    .addrIn (addi4_result),
    .addrIn_valid (addi4_result_valid),
    .addrIn_ready (addi4_result_ready),
    .dataFromMem (mem_controller2_ldData_1),
    .dataFromMem_valid (mem_controller2_ldData_1_valid),
    .dataFromMem_ready (mem_controller2_ldData_1_ready),
    .clk (clk),
    .rst (rst),
    .addrOut (load2_addrOut),
    .addrOut_valid (load2_addrOut_valid),
    .addrOut_ready (load2_addrOut_ready),
    .dataOut (load2_dataOut),
    .dataOut_valid (load2_dataOut_valid),
    .dataOut_ready (load2_dataOut_ready)
  );

  extsi #(.INPUT_TYPE(8), .OUTPUT_TYPE(16)) extsi30(
    .ins (load2_dataOut),
    .ins_valid (load2_dataOut_valid),
    .ins_ready (load2_dataOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi30_outs),
    .outs_valid (extsi30_outs_valid),
    .outs_ready (extsi30_outs_ready)
  );

  muli #(.DATA_TYPE(16)) muli0(
    .lhs (extsi29_outs),
    .lhs_valid (extsi29_outs_valid),
    .lhs_ready (extsi29_outs_ready),
    .rhs (extsi30_outs),
    .rhs_valid (extsi30_outs_valid),
    .rhs_ready (extsi30_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (muli0_result),
    .result_valid (muli0_result_valid),
    .result_ready (muli0_result_ready)
  );

  trunci #(.INPUT_TYPE(16), .OUTPUT_TYPE(8)) trunci11(
    .ins (muli0_result),
    .ins_valid (muli0_result_valid),
    .ins_ready (muli0_result_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci11_outs),
    .outs_valid (trunci11_outs_valid),
    .outs_ready (trunci11_outs_ready)
  );

  subi #(.DATA_TYPE(8)) subi0(
    .lhs (load0_dataOut),
    .lhs_valid (load0_dataOut_valid),
    .lhs_ready (load0_dataOut_ready),
    .rhs (trunci11_outs),
    .rhs_valid (trunci11_outs_valid),
    .rhs_ready (trunci11_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (subi0_result),
    .result_valid (subi0_result_valid),
    .result_ready (subi0_result_ready)
  );

  shli #(.DATA_TYPE(32)) shli4(
    .lhs (fork12_outs_2),
    .lhs_valid (fork12_outs_2_valid),
    .lhs_ready (fork12_outs_2_ready),
    .rhs (fork16_outs_2),
    .rhs_valid (fork16_outs_2_valid),
    .rhs_ready (fork16_outs_2_ready),
    .clk (clk),
    .rst (rst),
    .result (shli4_result),
    .result_valid (shli4_result_valid),
    .result_ready (shli4_result_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci12(
    .ins (shli4_result),
    .ins_valid (shli4_result_valid),
    .ins_ready (shli4_result_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci12_outs),
    .outs_valid (trunci12_outs_valid),
    .outs_ready (trunci12_outs_ready)
  );

  shli #(.DATA_TYPE(32)) shli5(
    .lhs (fork12_outs_3),
    .lhs_valid (fork12_outs_3_valid),
    .lhs_ready (fork12_outs_3_ready),
    .rhs (fork17_outs_2),
    .rhs_valid (fork17_outs_2_valid),
    .rhs_ready (fork17_outs_2_ready),
    .clk (clk),
    .rst (rst),
    .result (shli5_result),
    .result_valid (shli5_result_valid),
    .result_ready (shli5_result_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(7)) trunci13(
    .ins (shli5_result),
    .ins_valid (shli5_result_valid),
    .ins_ready (shli5_result_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci13_outs),
    .outs_valid (trunci13_outs_valid),
    .outs_ready (trunci13_outs_ready)
  );

  addi #(.DATA_TYPE(7)) addi11(
    .lhs (trunci12_outs),
    .lhs_valid (trunci12_outs_valid),
    .lhs_ready (trunci12_outs_ready),
    .rhs (trunci13_outs),
    .rhs_valid (trunci13_outs_valid),
    .rhs_ready (trunci13_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi11_result),
    .result_valid (addi11_result_valid),
    .result_ready (addi11_result_ready)
  );

  addi #(.DATA_TYPE(7)) addi5(
    .lhs (trunci5_outs),
    .lhs_valid (trunci5_outs_valid),
    .lhs_ready (trunci5_outs_ready),
    .rhs (addi11_result),
    .rhs_valid (addi11_result_valid),
    .rhs_ready (addi11_result_ready),
    .clk (clk),
    .rst (rst),
    .result (addi5_result),
    .result_valid (addi5_result_valid),
    .result_ready (addi5_result_ready)
  );

  store #(.DATA_TYPE(8), .ADDR_TYPE(7)) store0(
    .addrIn (addi5_result),
    .addrIn_valid (addi5_result_valid),
    .addrIn_ready (addi5_result_ready),
    .dataIn (subi0_result),
    .dataIn_valid (subi0_result_valid),
    .dataIn_ready (subi0_result_ready),
    .clk (clk),
    .rst (rst),
    .addrOut (store0_addrOut),
    .addrOut_valid (store0_addrOut_valid),
    .addrOut_ready (store0_addrOut_ready),
    .dataToMem (store0_dataToMem),
    .dataToMem_valid (store0_dataToMem_valid),
    .dataToMem_ready (store0_dataToMem_ready)
  );

  trunci #(.INPUT_TYPE(32), .OUTPUT_TYPE(8)) trunci1(
    .ins (fork8_outs_4),
    .ins_valid (fork8_outs_4_valid),
    .ins_ready (fork8_outs_4_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci1_outs),
    .outs_valid (trunci1_outs_valid),
    .outs_ready (trunci1_outs_ready)
  );

  oehb #(.DATA_TYPE(8)) buffer18(
    .ins (mux7_outs),
    .ins_valid (mux7_outs_valid),
    .ins_ready (mux7_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer18_outs),
    .outs_valid (buffer18_outs_valid),
    .outs_ready (buffer18_outs_ready)
  );

  tehb #(.DATA_TYPE(8)) buffer19(
    .ins (buffer18_outs),
    .ins_valid (buffer18_outs_valid),
    .ins_ready (buffer18_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer19_outs),
    .outs_valid (buffer19_outs_valid),
    .outs_ready (buffer19_outs_ready)
  );

  addi #(.DATA_TYPE(8)) addi0(
    .lhs (buffer19_outs),
    .lhs_valid (buffer19_outs_valid),
    .lhs_ready (buffer19_outs_ready),
    .rhs (trunci1_outs),
    .rhs_valid (trunci1_outs_valid),
    .rhs_ready (trunci1_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi0_result),
    .result_valid (addi0_result_valid),
    .result_ready (addi0_result_ready)
  );

  addi #(.DATA_TYPE(32)) addi1(
    .lhs (fork8_outs_3),
    .lhs_valid (fork8_outs_3_valid),
    .lhs_ready (fork8_outs_3_ready),
    .rhs (extsi11_outs),
    .rhs_valid (extsi11_outs_valid),
    .rhs_ready (extsi11_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi1_result),
    .result_valid (addi1_result_valid),
    .result_ready (addi1_result_ready)
  );

  addi #(.DATA_TYPE(6)) addi6(
    .lhs (extsi24_outs),
    .lhs_valid (extsi24_outs_valid),
    .lhs_ready (extsi24_outs_ready),
    .rhs (extsi28_outs),
    .rhs_valid (extsi28_outs_valid),
    .rhs_ready (extsi28_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi6_result),
    .result_valid (addi6_result_valid),
    .result_ready (addi6_result_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(6)) fork18(
    .ins (addi6_result),
    .ins_valid (addi6_result_valid),
    .ins_ready (addi6_result_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork18_outs_1, fork18_outs_0}),
    .outs_valid ({fork18_outs_1_valid, fork18_outs_0_valid}),
    .outs_ready ({fork18_outs_1_ready, fork18_outs_0_ready})
  );

  trunci #(.INPUT_TYPE(6), .OUTPUT_TYPE(5)) trunci14(
    .ins (fork18_outs_0),
    .ins_valid (fork18_outs_0_valid),
    .ins_ready (fork18_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci14_outs),
    .outs_valid (trunci14_outs_valid),
    .outs_ready (trunci14_outs_ready)
  );

  handshake_cmpi_0 #(.DATA_TYPE(6)) cmpi0(
    .lhs (fork18_outs_1),
    .lhs_valid (fork18_outs_1_valid),
    .lhs_ready (fork18_outs_1_ready),
    .rhs (extsi27_outs),
    .rhs_valid (extsi27_outs_valid),
    .rhs_ready (extsi27_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (cmpi0_result),
    .result_valid (cmpi0_result_valid),
    .result_ready (cmpi0_result_ready)
  );

  fork_type #(.SIZE(6), .DATA_TYPE(1)) fork19(
    .ins (cmpi0_result),
    .ins_valid (cmpi0_result_valid),
    .ins_ready (cmpi0_result_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork19_outs_5, fork19_outs_4, fork19_outs_3, fork19_outs_2, fork19_outs_1, fork19_outs_0}),
    .outs_valid ({fork19_outs_5_valid, fork19_outs_4_valid, fork19_outs_3_valid, fork19_outs_2_valid, fork19_outs_1_valid, fork19_outs_0_valid}),
    .outs_ready ({fork19_outs_5_ready, fork19_outs_4_ready, fork19_outs_3_ready, fork19_outs_2_ready, fork19_outs_1_ready, fork19_outs_0_ready})
  );

  cond_br #(.DATA_TYPE(5)) cond_br9(
    .condition (fork19_outs_0),
    .condition_valid (fork19_outs_0_valid),
    .condition_ready (fork19_outs_0_ready),
    .data (trunci14_outs),
    .data_valid (trunci14_outs_valid),
    .data_ready (trunci14_outs_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br9_trueOut),
    .trueOut_valid (cond_br9_trueOut_valid),
    .trueOut_ready (cond_br9_trueOut_ready),
    .falseOut (cond_br9_falseOut),
    .falseOut_valid (cond_br9_falseOut_valid),
    .falseOut_ready (cond_br9_falseOut_ready)
  );

  sink #(.DATA_TYPE(5)) sink3(
    .ins (cond_br9_falseOut),
    .ins_valid (cond_br9_falseOut_valid),
    .ins_ready (cond_br9_falseOut_ready),
    .clk (clk),
    .rst (rst)
  );

  cond_br #(.DATA_TYPE(32)) cond_br10(
    .condition (fork19_outs_3),
    .condition_valid (fork19_outs_3_valid),
    .condition_ready (fork19_outs_3_ready),
    .data (addi1_result),
    .data_valid (addi1_result_valid),
    .data_ready (addi1_result_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br10_trueOut),
    .trueOut_valid (cond_br10_trueOut_valid),
    .trueOut_ready (cond_br10_trueOut_ready),
    .falseOut (cond_br10_falseOut),
    .falseOut_valid (cond_br10_falseOut_valid),
    .falseOut_ready (cond_br10_falseOut_ready)
  );

  sink #(.DATA_TYPE(32)) sink4(
    .ins (cond_br10_falseOut),
    .ins_valid (cond_br10_falseOut_valid),
    .ins_ready (cond_br10_falseOut_ready),
    .clk (clk),
    .rst (rst)
  );

  cond_br #(.DATA_TYPE(8)) cond_br11(
    .condition (fork19_outs_4),
    .condition_valid (fork19_outs_4_valid),
    .condition_ready (fork19_outs_4_ready),
    .data (addi0_result),
    .data_valid (addi0_result_valid),
    .data_ready (addi0_result_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br11_trueOut),
    .trueOut_valid (cond_br11_trueOut_valid),
    .trueOut_ready (cond_br11_trueOut_ready),
    .falseOut (cond_br11_falseOut),
    .falseOut_valid (cond_br11_falseOut_valid),
    .falseOut_ready (cond_br11_falseOut_ready)
  );

  cond_br #(.DATA_TYPE(5)) cond_br12(
    .condition (fork19_outs_1),
    .condition_valid (fork19_outs_1_valid),
    .condition_ready (fork19_outs_1_ready),
    .data (fork9_outs_1),
    .data_valid (fork9_outs_1_valid),
    .data_ready (fork9_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br12_trueOut),
    .trueOut_valid (cond_br12_trueOut_valid),
    .trueOut_ready (cond_br12_trueOut_ready),
    .falseOut (cond_br12_falseOut),
    .falseOut_valid (cond_br12_falseOut_valid),
    .falseOut_ready (cond_br12_falseOut_ready)
  );

  cond_br #(.DATA_TYPE(5)) cond_br13(
    .condition (fork19_outs_2),
    .condition_valid (fork19_outs_2_valid),
    .condition_ready (fork19_outs_2_ready),
    .data (fork11_outs_0),
    .data_valid (fork11_outs_0_valid),
    .data_ready (fork11_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br13_trueOut),
    .trueOut_valid (cond_br13_trueOut_valid),
    .trueOut_ready (cond_br13_trueOut_ready),
    .falseOut (cond_br13_falseOut),
    .falseOut_valid (cond_br13_falseOut_valid),
    .falseOut_ready (cond_br13_falseOut_ready)
  );

  cond_br_dataless cond_br14(
    .condition (fork19_outs_5),
    .condition_valid (fork19_outs_5_valid),
    .condition_ready (fork19_outs_5_ready),
    .data_valid (fork14_outs_1_valid),
    .data_ready (fork14_outs_1_ready),
    .clk (clk),
    .rst (rst),
    .trueOut_valid (cond_br14_trueOut_valid),
    .trueOut_ready (cond_br14_trueOut_ready),
    .falseOut_valid (cond_br14_falseOut_valid),
    .falseOut_ready (cond_br14_falseOut_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer28(
    .ins (cond_br13_falseOut),
    .ins_valid (cond_br13_falseOut_valid),
    .ins_ready (cond_br13_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer28_outs),
    .outs_valid (buffer28_outs_valid),
    .outs_ready (buffer28_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer29(
    .ins (buffer28_outs),
    .ins_valid (buffer28_outs_valid),
    .ins_ready (buffer28_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer29_outs),
    .outs_valid (buffer29_outs_valid),
    .outs_ready (buffer29_outs_ready)
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(6)) extsi31(
    .ins (buffer29_outs),
    .ins_valid (buffer29_outs_valid),
    .ins_ready (buffer29_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi31_outs),
    .outs_valid (extsi31_outs_valid),
    .outs_ready (extsi31_outs_ready)
  );

  source source6(
    .clk (clk),
    .rst (rst),
    .outs_valid (source6_outs_valid),
    .outs_ready (source6_outs_ready)
  );

  handshake_constant_1 #(.DATA_WIDTH(2)) constant24(
    .ctrl_valid (source6_outs_valid),
    .ctrl_ready (source6_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant24_outs),
    .outs_valid (constant24_outs_valid),
    .outs_ready (constant24_outs_ready)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(6)) extsi32(
    .ins (constant24_outs),
    .ins_valid (constant24_outs_valid),
    .ins_ready (constant24_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi32_outs),
    .outs_valid (extsi32_outs_valid),
    .outs_ready (extsi32_outs_ready)
  );

  addi #(.DATA_TYPE(6)) addi8(
    .lhs (extsi31_outs),
    .lhs_valid (extsi31_outs_valid),
    .lhs_ready (extsi31_outs_ready),
    .rhs (extsi32_outs),
    .rhs_valid (extsi32_outs_valid),
    .rhs_ready (extsi32_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi8_result),
    .result_valid (addi8_result_valid),
    .result_ready (addi8_result_ready)
  );

  oehb #(.DATA_TYPE(8)) buffer30(
    .ins (cond_br11_falseOut),
    .ins_valid (cond_br11_falseOut_valid),
    .ins_ready (cond_br11_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer30_outs),
    .outs_valid (buffer30_outs_valid),
    .outs_ready (buffer30_outs_ready)
  );

  tehb #(.DATA_TYPE(8)) buffer31(
    .ins (buffer30_outs),
    .ins_valid (buffer30_outs_valid),
    .ins_ready (buffer30_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer31_outs),
    .outs_valid (buffer31_outs_valid),
    .outs_ready (buffer31_outs_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer26(
    .ins (cond_br12_falseOut),
    .ins_valid (cond_br12_falseOut_valid),
    .ins_ready (cond_br12_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer26_outs),
    .outs_valid (buffer26_outs_valid),
    .outs_ready (buffer26_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer27(
    .ins (buffer26_outs),
    .ins_valid (buffer26_outs_valid),
    .ins_ready (buffer26_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer27_outs),
    .outs_valid (buffer27_outs_valid),
    .outs_ready (buffer27_outs_ready)
  );

  oehb_dataless buffer32(
    .ins_valid (cond_br14_falseOut_valid),
    .ins_ready (cond_br14_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer32_outs_valid),
    .outs_ready (buffer32_outs_ready)
  );

  tehb_dataless buffer33(
    .ins_valid (buffer32_outs_valid),
    .ins_ready (buffer32_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer33_outs_valid),
    .outs_ready (buffer33_outs_ready)
  );

  oehb #(.DATA_TYPE(5)) buffer34(
    .ins (cond_br6_falseOut),
    .ins_valid (cond_br6_falseOut_valid),
    .ins_ready (cond_br6_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer34_outs),
    .outs_valid (buffer34_outs_valid),
    .outs_ready (buffer34_outs_ready)
  );

  tehb #(.DATA_TYPE(5)) buffer35(
    .ins (buffer34_outs),
    .ins_valid (buffer34_outs_valid),
    .ins_ready (buffer34_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer35_outs),
    .outs_valid (buffer35_outs_valid),
    .outs_ready (buffer35_outs_ready)
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(6)) extsi33(
    .ins (buffer35_outs),
    .ins_valid (buffer35_outs_valid),
    .ins_ready (buffer35_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi33_outs),
    .outs_valid (extsi33_outs_valid),
    .outs_ready (extsi33_outs_ready)
  );

  source source7(
    .clk (clk),
    .rst (rst),
    .outs_valid (source7_outs_valid),
    .outs_ready (source7_outs_ready)
  );

  handshake_constant_2 #(.DATA_WIDTH(5)) constant25(
    .ctrl_valid (source7_outs_valid),
    .ctrl_ready (source7_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant25_outs),
    .outs_valid (constant25_outs_valid),
    .outs_ready (constant25_outs_ready)
  );

  extsi #(.INPUT_TYPE(5), .OUTPUT_TYPE(6)) extsi34(
    .ins (constant25_outs),
    .ins_valid (constant25_outs_valid),
    .ins_ready (constant25_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi34_outs),
    .outs_valid (extsi34_outs_valid),
    .outs_ready (extsi34_outs_ready)
  );

  source source8(
    .clk (clk),
    .rst (rst),
    .outs_valid (source8_outs_valid),
    .outs_ready (source8_outs_ready)
  );

  handshake_constant_1 #(.DATA_WIDTH(2)) constant26(
    .ctrl_valid (source8_outs_valid),
    .ctrl_ready (source8_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (constant26_outs),
    .outs_valid (constant26_outs_valid),
    .outs_ready (constant26_outs_ready)
  );

  extsi #(.INPUT_TYPE(2), .OUTPUT_TYPE(6)) extsi35(
    .ins (constant26_outs),
    .ins_valid (constant26_outs_valid),
    .ins_ready (constant26_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (extsi35_outs),
    .outs_valid (extsi35_outs_valid),
    .outs_ready (extsi35_outs_ready)
  );

  addi #(.DATA_TYPE(6)) addi7(
    .lhs (extsi33_outs),
    .lhs_valid (extsi33_outs_valid),
    .lhs_ready (extsi33_outs_ready),
    .rhs (extsi35_outs),
    .rhs_valid (extsi35_outs_valid),
    .rhs_ready (extsi35_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (addi7_result),
    .result_valid (addi7_result_valid),
    .result_ready (addi7_result_ready)
  );

  fork_type #(.SIZE(2), .DATA_TYPE(6)) fork20(
    .ins (addi7_result),
    .ins_valid (addi7_result_valid),
    .ins_ready (addi7_result_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork20_outs_1, fork20_outs_0}),
    .outs_valid ({fork20_outs_1_valid, fork20_outs_0_valid}),
    .outs_ready ({fork20_outs_1_ready, fork20_outs_0_ready})
  );

  trunci #(.INPUT_TYPE(6), .OUTPUT_TYPE(5)) trunci15(
    .ins (fork20_outs_0),
    .ins_valid (fork20_outs_0_valid),
    .ins_ready (fork20_outs_0_ready),
    .clk (clk),
    .rst (rst),
    .outs (trunci15_outs),
    .outs_valid (trunci15_outs_valid),
    .outs_ready (trunci15_outs_ready)
  );

  handshake_cmpi_0 #(.DATA_TYPE(6)) cmpi1(
    .lhs (fork20_outs_1),
    .lhs_valid (fork20_outs_1_valid),
    .lhs_ready (fork20_outs_1_ready),
    .rhs (extsi34_outs),
    .rhs_valid (extsi34_outs_valid),
    .rhs_ready (extsi34_outs_ready),
    .clk (clk),
    .rst (rst),
    .result (cmpi1_result),
    .result_valid (cmpi1_result_valid),
    .result_ready (cmpi1_result_ready)
  );

  fork_type #(.SIZE(3), .DATA_TYPE(1)) fork21(
    .ins (cmpi1_result),
    .ins_valid (cmpi1_result_valid),
    .ins_ready (cmpi1_result_ready),
    .clk (clk),
    .rst (rst),
    .outs ({fork21_outs_2, fork21_outs_1, fork21_outs_0}),
    .outs_valid ({fork21_outs_2_valid, fork21_outs_1_valid, fork21_outs_0_valid}),
    .outs_ready ({fork21_outs_2_ready, fork21_outs_1_ready, fork21_outs_0_ready})
  );

  cond_br #(.DATA_TYPE(5)) cond_br15(
    .condition (fork21_outs_0),
    .condition_valid (fork21_outs_0_valid),
    .condition_ready (fork21_outs_0_ready),
    .data (trunci15_outs),
    .data_valid (trunci15_outs_valid),
    .data_ready (trunci15_outs_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br15_trueOut),
    .trueOut_valid (cond_br15_trueOut_valid),
    .trueOut_ready (cond_br15_trueOut_ready),
    .falseOut (cond_br15_falseOut),
    .falseOut_valid (cond_br15_falseOut_valid),
    .falseOut_ready (cond_br15_falseOut_ready)
  );

  sink #(.DATA_TYPE(5)) sink7(
    .ins (cond_br15_falseOut),
    .ins_valid (cond_br15_falseOut_valid),
    .ins_ready (cond_br15_falseOut_ready),
    .clk (clk),
    .rst (rst)
  );

  oehb #(.DATA_TYPE(8)) buffer36(
    .ins (cond_br5_falseOut),
    .ins_valid (cond_br5_falseOut_valid),
    .ins_ready (cond_br5_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer36_outs),
    .outs_valid (buffer36_outs_valid),
    .outs_ready (buffer36_outs_ready)
  );

  tehb #(.DATA_TYPE(8)) buffer37(
    .ins (buffer36_outs),
    .ins_valid (buffer36_outs_valid),
    .ins_ready (buffer36_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer37_outs),
    .outs_valid (buffer37_outs_valid),
    .outs_ready (buffer37_outs_ready)
  );

  cond_br #(.DATA_TYPE(8)) cond_br16(
    .condition (fork21_outs_1),
    .condition_valid (fork21_outs_1_valid),
    .condition_ready (fork21_outs_1_ready),
    .data (buffer37_outs),
    .data_valid (buffer37_outs_valid),
    .data_ready (buffer37_outs_ready),
    .clk (clk),
    .rst (rst),
    .trueOut (cond_br16_trueOut),
    .trueOut_valid (cond_br16_trueOut_valid),
    .trueOut_ready (cond_br16_trueOut_ready),
    .falseOut (cond_br16_falseOut),
    .falseOut_valid (cond_br16_falseOut_valid),
    .falseOut_ready (cond_br16_falseOut_ready)
  );

  oehb_dataless buffer38(
    .ins_valid (cond_br8_falseOut_valid),
    .ins_ready (cond_br8_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer38_outs_valid),
    .outs_ready (buffer38_outs_ready)
  );

  tehb_dataless buffer39(
    .ins_valid (buffer38_outs_valid),
    .ins_ready (buffer38_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer39_outs_valid),
    .outs_ready (buffer39_outs_ready)
  );

  cond_br_dataless cond_br17(
    .condition (fork21_outs_2),
    .condition_valid (fork21_outs_2_valid),
    .condition_ready (fork21_outs_2_ready),
    .data_valid (buffer39_outs_valid),
    .data_ready (buffer39_outs_ready),
    .clk (clk),
    .rst (rst),
    .trueOut_valid (cond_br17_trueOut_valid),
    .trueOut_ready (cond_br17_trueOut_ready),
    .falseOut_valid (cond_br17_falseOut_valid),
    .falseOut_ready (cond_br17_falseOut_ready)
  );

  oehb_dataless buffer42(
    .ins_valid (cond_br17_falseOut_valid),
    .ins_ready (cond_br17_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer42_outs_valid),
    .outs_ready (buffer42_outs_ready)
  );

  tehb_dataless buffer43(
    .ins_valid (buffer42_outs_valid),
    .ins_ready (buffer42_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid (buffer43_outs_valid),
    .outs_ready (buffer43_outs_ready)
  );

  fork_dataless #(.SIZE(2)) fork22(
    .ins_valid (buffer43_outs_valid),
    .ins_ready (buffer43_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs_valid ({fork22_outs_1_valid, fork22_outs_0_valid}),
    .outs_ready ({fork22_outs_1_ready, fork22_outs_0_ready})
  );

  oehb #(.DATA_TYPE(8)) buffer40(
    .ins (cond_br16_falseOut),
    .ins_valid (cond_br16_falseOut_valid),
    .ins_ready (cond_br16_falseOut_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer40_outs),
    .outs_valid (buffer40_outs_valid),
    .outs_ready (buffer40_outs_ready)
  );

  tehb #(.DATA_TYPE(8)) buffer41(
    .ins (buffer40_outs),
    .ins_valid (buffer40_outs_valid),
    .ins_ready (buffer40_outs_ready),
    .clk (clk),
    .rst (rst),
    .outs (buffer41_outs),
    .outs_valid (buffer41_outs_valid),
    .outs_ready (buffer41_outs_ready)
  );

endmodule
module gaussian_wrapper(
  input [7:0] c_din0,
  input [7:0] c_din1,
  input [7:0] a_din0,
  input [7:0] a_din1,
  input  c_start_valid,
  input  a_start_valid,
  input  start_valid,
  input  clk,
  input  rst,
  input  out0_ready,
  input  c_end_ready,
  input  a_end_ready,
  input  end_ready,
  output  c_start_ready,
  output  a_start_ready,
  output  start_ready,
  output [7:0] out0,
  output  out0_valid,
  output  c_end_valid,
  output  a_end_valid,
  output  end_valid,
  output  c_ce0,
  output  c_we0,
  output [3:0] c_address0,
  output [7:0] c_dout0,
  output  c_ce1,
  output  c_we1,
  output [3:0] c_address1,
  output [7:0] c_dout1,
  output  a_ce0,
  output  a_we0,
  output [6:0] a_address0,
  output [7:0] a_dout0,
  output  a_ce1,
  output  a_we1,
  output [6:0] a_address1,
  output [7:0] a_dout1
);
  wire  mem_to_bram_converter_c_ce0;
  wire  mem_to_bram_converter_c_we0;
  wire [3:0] mem_to_bram_converter_c_address0;
  wire [7:0] mem_to_bram_converter_c_dout0;
  wire  mem_to_bram_converter_c_ce1;
  wire  mem_to_bram_converter_c_we1;
  wire [3:0] mem_to_bram_converter_c_address1;
  wire [7:0] mem_to_bram_converter_c_dout1;
  wire [7:0] mem_to_bram_converter_c_loadData;
  wire  mem_to_bram_converter_a_ce0;
  wire  mem_to_bram_converter_a_we0;
  wire [6:0] mem_to_bram_converter_a_address0;
  wire [7:0] mem_to_bram_converter_a_dout0;
  wire  mem_to_bram_converter_a_ce1;
  wire  mem_to_bram_converter_a_we1;
  wire [6:0] mem_to_bram_converter_a_address1;
  wire [7:0] mem_to_bram_converter_a_dout1;
  wire [7:0] mem_to_bram_converter_a_loadData;
  wire [7:0] gaussian_wrapped_out0;
  wire  gaussian_wrapped_out0_valid;
  wire  gaussian_wrapped_out0_ready;
  wire  gaussian_wrapped_c_end_valid;
  wire  gaussian_wrapped_c_end_ready;
  wire  gaussian_wrapped_a_end_valid;
  wire  gaussian_wrapped_a_end_ready;
  wire  gaussian_wrapped_end_valid;
  wire  gaussian_wrapped_end_ready;
  wire  gaussian_wrapped_c_loadEn;
  wire [3:0] gaussian_wrapped_c_loadAddr;
  wire  gaussian_wrapped_c_storeEn;
  wire [3:0] gaussian_wrapped_c_storeAddr;
  wire [7:0] gaussian_wrapped_c_storeData;
  wire  gaussian_wrapped_a_loadEn;
  wire [6:0] gaussian_wrapped_a_loadAddr;
  wire  gaussian_wrapped_a_storeEn;
  wire [6:0] gaussian_wrapped_a_storeAddr;
  wire [7:0] gaussian_wrapped_a_storeData;

  assign out0 = gaussian_wrapped_out0;
  assign out0_valid = gaussian_wrapped_out0_valid;
  assign gaussian_wrapped_out0_ready = out0_ready;
  assign c_end_valid = gaussian_wrapped_c_end_valid;
  assign gaussian_wrapped_c_end_ready = c_end_ready;
  assign a_end_valid = gaussian_wrapped_a_end_valid;
  assign gaussian_wrapped_a_end_ready = a_end_ready;
  assign end_valid = gaussian_wrapped_end_valid;
  assign gaussian_wrapped_end_ready = end_ready;
  assign c_ce0 = mem_to_bram_converter_c_ce0;
  assign c_we0 = mem_to_bram_converter_c_we0;
  assign c_address0 = mem_to_bram_converter_c_address0;
  assign c_dout0 = mem_to_bram_converter_c_dout0;
  assign c_ce1 = mem_to_bram_converter_c_ce1;
  assign c_we1 = mem_to_bram_converter_c_we1;
  assign c_address1 = mem_to_bram_converter_c_address1;
  assign c_dout1 = mem_to_bram_converter_c_dout1;
  assign a_ce0 = mem_to_bram_converter_a_ce0;
  assign a_we0 = mem_to_bram_converter_a_we0;
  assign a_address0 = mem_to_bram_converter_a_address0;
  assign a_dout0 = mem_to_bram_converter_a_dout0;
  assign a_ce1 = mem_to_bram_converter_a_ce1;
  assign a_we1 = mem_to_bram_converter_a_we1;
  assign a_address1 = mem_to_bram_converter_a_address1;
  assign a_dout1 = mem_to_bram_converter_a_dout1;

  mem_to_bram #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) mem_to_bram_converter_c(
    .loadEn (gaussian_wrapped_c_loadEn),
    .loadAddr (gaussian_wrapped_c_loadAddr),
    .storeEn (gaussian_wrapped_c_storeEn),
    .storeAddr (gaussian_wrapped_c_storeAddr),
    .storeData (gaussian_wrapped_c_storeData),
    .din0 (c_din0),
    .din1 (c_din1),
    .ce0 (mem_to_bram_converter_c_ce0),
    .we0 (mem_to_bram_converter_c_we0),
    .address0 (mem_to_bram_converter_c_address0),
    .dout0 (mem_to_bram_converter_c_dout0),
    .ce1 (mem_to_bram_converter_c_ce1),
    .we1 (mem_to_bram_converter_c_we1),
    .address1 (mem_to_bram_converter_c_address1),
    .dout1 (mem_to_bram_converter_c_dout1),
    .loadData (mem_to_bram_converter_c_loadData)
  );

  mem_to_bram #(.DATA_WIDTH(8), .ADDR_WIDTH(7)) mem_to_bram_converter_a(
    .loadEn (gaussian_wrapped_a_loadEn),
    .loadAddr (gaussian_wrapped_a_loadAddr),
    .storeEn (gaussian_wrapped_a_storeEn),
    .storeAddr (gaussian_wrapped_a_storeAddr),
    .storeData (gaussian_wrapped_a_storeData),
    .din0 (a_din0),
    .din1 (a_din1),
    .ce0 (mem_to_bram_converter_a_ce0),
    .we0 (mem_to_bram_converter_a_we0),
    .address0 (mem_to_bram_converter_a_address0),
    .dout0 (mem_to_bram_converter_a_dout0),
    .ce1 (mem_to_bram_converter_a_ce1),
    .we1 (mem_to_bram_converter_a_we1),
    .address1 (mem_to_bram_converter_a_address1),
    .dout1 (mem_to_bram_converter_a_dout1),
    .loadData (mem_to_bram_converter_a_loadData)
  );

  gaussian gaussian_wrapped(
    .c_loadData (mem_to_bram_converter_c_loadData),
    .a_loadData (mem_to_bram_converter_a_loadData),
    .c_start_valid (c_start_valid),
    .c_start_ready (c_start_ready),
    .a_start_valid (a_start_valid),
    .a_start_ready (a_start_ready),
    .start_valid (start_valid),
    .start_ready (start_ready),
    .clk (clk),
    .rst (rst),
    .out0 (gaussian_wrapped_out0),
    .out0_valid (gaussian_wrapped_out0_valid),
    .out0_ready (gaussian_wrapped_out0_ready),
    .c_end_valid (gaussian_wrapped_c_end_valid),
    .c_end_ready (gaussian_wrapped_c_end_ready),
    .a_end_valid (gaussian_wrapped_a_end_valid),
    .a_end_ready (gaussian_wrapped_a_end_ready),
    .end_valid (gaussian_wrapped_end_valid),
    .end_ready (gaussian_wrapped_end_ready),
    .c_loadEn (gaussian_wrapped_c_loadEn),
    .c_loadAddr (gaussian_wrapped_c_loadAddr),
    .c_storeEn (gaussian_wrapped_c_storeEn),
    .c_storeAddr (gaussian_wrapped_c_storeAddr),
    .c_storeData (gaussian_wrapped_c_storeData),
    .a_loadEn (gaussian_wrapped_a_loadEn),
    .a_loadAddr (gaussian_wrapped_a_loadAddr),
    .a_storeEn (gaussian_wrapped_a_storeEn),
    .a_storeAddr (gaussian_wrapped_a_storeAddr),
    .a_storeData (gaussian_wrapped_a_storeData)
  );

endmodule
`timescale 1ns/1ps
module handshake_cmpi_0 #(
  parameter DATA_TYPE = 32
)(
  // inputs
  input  clk,
  input  rst,
  input  [DATA_TYPE - 1 : 0] lhs,
  input  lhs_valid,
  input  [DATA_TYPE - 1 : 0] rhs,
  input  rhs_valid,
  input  result_ready,
  // outputs
  output result,
  output result_valid,
  output lhs_ready,
  output rhs_ready
);

  wire constant_one = 1'b1;
  wire constant_zero = 1'b0;

  // Instantiate the join node
  join_type #(
    .SIZE(2)
  ) join_inputs (
    .ins_valid  ({rhs_valid, lhs_valid}),
    .outs_ready (result_ready             ),
    .ins_ready  ({rhs_ready, lhs_ready}  ),
    .outs_valid (result_valid             )
  );

  assign result = ((lhs) < (rhs)) ? constant_one : constant_zero;

endmodule
`timescale 1ns / 1ps
module handshake_constant_0 #(
  parameter DATA_WIDTH = 32  // Default set to 32 bits
) (
  input                       clk,
  input                       rst,
  // Input Channel
  input                       ctrl_valid,
  output                      ctrl_ready,
  // Output Channel
  output [DATA_WIDTH - 1 : 0] outs,
  output                      outs_valid,
  input                       outs_ready
);
  assign outs       = 1'b0;
  assign outs_valid = ctrl_valid;
  assign ctrl_ready = outs_ready;

endmodule
`timescale 1ns / 1ps
module handshake_constant_1 #(
  parameter DATA_WIDTH = 32  // Default set to 32 bits
) (
  input                       clk,
  input                       rst,
  // Input Channel
  input                       ctrl_valid,
  output                      ctrl_ready,
  // Output Channel
  output [DATA_WIDTH - 1 : 0] outs,
  output                      outs_valid,
  input                       outs_ready
);
  assign outs       = 2'b01;
  assign outs_valid = ctrl_valid;
  assign ctrl_ready = outs_ready;

endmodule
`timescale 1ns / 1ps
module handshake_constant_2 #(
  parameter DATA_WIDTH = 32  // Default set to 32 bits
) (
  input                       clk,
  input                       rst,
  // Input Channel
  input                       ctrl_valid,
  output                      ctrl_ready,
  // Output Channel
  output [DATA_WIDTH - 1 : 0] outs,
  output                      outs_valid,
  input                       outs_ready
);
  assign outs       = 5'b01001;
  assign outs_valid = ctrl_valid;
  assign ctrl_ready = outs_ready;

endmodule
`timescale 1ns / 1ps
module handshake_constant_3 #(
  parameter DATA_WIDTH = 32  // Default set to 32 bits
) (
  input                       clk,
  input                       rst,
  // Input Channel
  input                       ctrl_valid,
  output                      ctrl_ready,
  // Output Channel
  output [DATA_WIDTH - 1 : 0] outs,
  output                      outs_valid,
  input                       outs_ready
);
  assign outs       = 5'b01010;
  assign outs_valid = ctrl_valid;
  assign ctrl_ready = outs_ready;

endmodule
`timescale 1ns / 1ps
module handshake_constant_4 #(
  parameter DATA_WIDTH = 32  // Default set to 32 bits
) (
  input                       clk,
  input                       rst,
  // Input Channel
  input                       ctrl_valid,
  output                      ctrl_ready,
  // Output Channel
  output [DATA_WIDTH - 1 : 0] outs,
  output                      outs_valid,
  input                       outs_ready
);
  assign outs       = 3'b011;
  assign outs_valid = ctrl_valid;
  assign ctrl_ready = outs_ready;

endmodule
`timescale 1ns/1ps
module join_type #(
	parameter SIZE = 2 // Default Join input set to 2
)(
	input [SIZE - 1 : 0] ins_valid,
	input outs_ready,

	output reg  [SIZE - 1 : 0] ins_ready,
	output outs_valid
);
	
	assign outs_valid = &ins_valid; // AND of all the bits in ins_valid vector
	
	reg [SIZE - 1 : 0] singleValid = 0;
	integer i, j;
	
	always @(*)begin
		for (i = 0; i < SIZE; i = i + 1) begin
			singleValid[i] = 1;
			for (j = 0; j < SIZE; j = j + 1)
				if (i != j)
					singleValid[i] = singleValid[i] & ins_valid[j];
		end
		
		for (i = 0; i < SIZE; i = i + 1) begin
			ins_ready[i] = singleValid[i] & outs_ready;
		end
	end
	
endmodule
`timescale 1ns/1ps
module load #(
  parameter DATA_TYPE = 32,
  parameter ADDR_TYPE = 32
)(
  input clk,
  input rst,
  // Address from Circuit Channel
  input  [ADDR_TYPE - 1 : 0] addrIn,
  input  addrIn_valid,
  output addrIn_ready,
  // Address to Interface Channel
  output [ADDR_TYPE - 1 : 0] addrOut,
  output addrOut_valid,
  input  addrOut_ready,
  // Data from Interface Channel
  input  [DATA_TYPE - 1 : 0] dataFromMem,
  input  dataFromMem_valid,
  output dataFromMem_ready,
  // Data from Memory Channel
  output [DATA_TYPE - 1 : 0] dataOut,
  output dataOut_valid,
  input  dataOut_ready
);
  tehb #(
    .DATA_TYPE(ADDR_TYPE)
  ) addr_tehb (
    .clk        (clk            ),
    .rst        (rst            ),
    .ins        (addrIn         ),
    .ins_valid  (addrIn_valid   ),
    .ins_ready  (addrIn_ready   ),
    .outs       (addrOut        ),
    .outs_valid (addrOut_valid  ),
    .outs_ready (addrOut_ready  )
  );

  tehb #(
    .DATA_TYPE(DATA_TYPE)
  ) data_tehb (
    .clk        (clk                ),
    .rst        (rst                ),
    .ins        (dataFromMem        ),
    .ins_valid  (dataFromMem_valid  ),
    .ins_ready  (dataFromMem_ready  ),
    .outs       (dataOut            ),
    .outs_valid (dataOut_valid      ),
    .outs_ready (dataOut_ready      )
  );

endmodule
`timescale 1ns/1ps
module and_n #(
	parameter SIZE = 2	// Default set to 2 inputs
)(
	input [SIZE - 1 : 0] ins,
	
	output outs
);
	// Generate a constant vector of ones
	wire [SIZE - 1 : 0] all_ones = {SIZE{1'b1}};

	assign outs = (ins == all_ones) ? 1'b1 : 1'b0;

endmodule

module nand_n #(
	parameter SIZE = 2
)(
	input [SIZE - 1 : 0] ins,

	output outs
);
	wire [SIZE - 1 : 0] all_ones = {SIZE{1'b1}};

	assign outs = (ins == all_ones) ? 1'b0 : 1'b1;

endmodule

module or_n #(
	parameter SIZE = 2
)(
	input [SIZE - 1 : 0] ins,

	output outs
);
	wire [SIZE - 1 : 0] all_zeros = {SIZE{1'b0}};

	assign outs = (ins == all_zeros) ? 1'b0 : 1'b1;

endmodule

module nor_n #(
	parameter SIZE = 2
)(
	input [SIZE - 1 : 0] ins,

	output outs
);
	wire [SIZE - 1 : 0] all_zeros = {SIZE{1'b0}};

	assign outs = (ins == all_zeros) ? 1'b1 : 1'b0;

endmodule
`timescale 1ns / 1ps


// An 1-slot buffer that stores the argument
module kernel_arg_buffer #(
  parameter DATA_TYPE = 32
)(
  clk,
  rst,
  kernel_state,
  ap_start,
  data_in,
  data_out,
  valid,
  ready
);
  input clk;
  input rst;
  input [DATA_TYPE-1:0]data_in;
  output [DATA_TYPE-1:0]data_out;
  output valid;
  input ready;
  input ap_start;
  input kernel_state;

  reg [DATA_TYPE-1:0]data_reg = 0;
  reg sent = 0;

  always @(posedge clk) begin
    if (rst) 
      data_reg <= 0;
    else begin
      if (ap_start && kernel_state == 0) 
        data_reg <= data_in;
    end
  end

  always @(posedge clk) begin
    if (rst || (ap_start && kernel_state == 0))
      sent <= 0;
    else begin
      if (valid && ready)
        sent <= 1;
    end
  end 

  assign valid = (!sent) && (kernel_state == 1);
  assign data_out = data_reg;
endmodule

module kernel_state_reg (
  clk,
  rst, 
  ap_start,
  ap_ready,
  kernel_state,
  all_finish,
  ap_done
);
  input clk;
  input rst;
  input ap_start;
  output ap_ready;
  output kernel_state;
  // All the output channels of the handshake kernel are valid
  input all_finish;
  output ap_done;

  reg kernel_state_reg = 0;

  assign kernel_state = kernel_state_reg;
  assign ap_done = all_finish && (kernel_state_reg == 1);
  assign ap_ready = (kernel_state == 0);

  always @(posedge clk) begin
    if (rst) begin
      kernel_state_reg <= 0;
    end else if (ap_start && kernel_state_reg == 0)
      kernel_state_reg <= 1;
    // ap_done will be high for one cycle (when all_finish and we are in the
    // running state). After that we return to the idle state
    else if (ap_done)
      kernel_state_reg <= 0;
  end
endmodule

module kernel_join #(
  parameter SIZE = 2
)(
  input [SIZE - 1 : 0] ins_valid,
  input outs_ready,

  output reg  [SIZE - 1 : 0] ins_ready,
  output outs_valid
);
  // AND of all the bits in ins_valid vector
  assign outs_valid = &ins_valid;

  reg [SIZE - 1 : 0] singleValid = 0;
  integer i, j;

  always @(*)begin
    for (i = 0; i < SIZE; i = i + 1) begin
      singleValid[i] = 1;
      for (j = 0; j < SIZE; j = j + 1)
        if (i != j)
          singleValid[i] = singleValid[i] & ins_valid[j];
    end
    for (i = 0; i < SIZE; i = i + 1) begin
      ins_ready[i] = singleValid[i] & outs_ready;
    end
  end
endmodule


module top(rst,clk,ap_start,c_loadData,a_loadData,equiv);
  input rst;
  input clk;
  input ap_start;
  
  input [7:0] c_loadData;
  
  
  input [7:0] a_loadData;
  


output equiv;

wire ap_ready_a;
wire ap_done_a;
wire [3:0] c_loadAddr_a;
wire c_loadEn_a;
wire c_storeEn_a;
wire [3:0] c_storeAddr_a;
wire [7:0] c_storeData_a;
wire [6:0] a_loadAddr_a;
wire a_loadEn_a;
wire a_storeEn_a;
wire [6:0] a_storeAddr_a;
wire [7:0] a_storeData_a;
wire [7:0] out0_a;

wire ap_ready_b;
wire ap_done_b;
wire [3:0] c_loadAddr_b;
wire c_loadEn_b;
wire c_storeEn_b;
wire [3:0] c_storeAddr_b;
wire [7:0] c_storeData_b;
wire [6:0] a_loadAddr_b;
wire a_loadEn_b;
wire a_storeEn_b;
wire [6:0] a_storeAddr_b;
wire [7:0] a_storeData_b;
wire [7:0] out0_b;

assign equiv = 
  (ap_ready_a == ap_ready_b) &&
  (ap_done_a  == ap_done_b) &&
  (c_loadAddr_a == c_loadAddr_b) &&
  (c_loadEn_a == c_loadEn_b) &&
  (c_storeEn_a == c_storeEn_b) && 
  (c_storeAddr_a == c_storeAddr_b) &&
  (c_storeData_a == c_storeData_b) &&
  (a_loadAddr_a == a_loadAddr_b) &&
  (a_loadEn_a == a_loadEn_b) &&
  (a_storeEn_a == a_storeEn_b) &&
  (a_storeAddr_a == a_storeAddr_b) &&
  (a_storeData_a == a_storeData_b) &&
  (out0_a == out0_b)
  ;

assert property (@(posedge clk) equiv);


main inst_a (
  .rst(rst),
  .clk(clk),
  .ap_start(ap_start),
  .ap_ready(ap_ready_a),
  .ap_done(ap_done_a),
  .c_loadAddr(c_loadAddr_a),
  .c_loadEn(c_loadEn_a),
  .c_storeEn(c_storeEn_a),
  .c_storeAddr(c_storeAddr_a),
  .c_storeData(c_storeData_a),
  .c_loadData(c_loadData),
  .a_loadAddr(a_loadAddr_a),
  .a_loadEn(a_loadEn_a),
  .a_storeEn(a_storeEn_a),
  .a_storeAddr(a_storeAddr_a),
  .a_storeData(a_storeData_a),
  .a_loadData(a_loadData),
  .out0(out0_a)
);

main inst_b (
  .rst(rst),
  .clk(clk),
  .ap_start(ap_start),
  .ap_ready(ap_ready_b),
  .ap_done(ap_done_b),
  .c_loadAddr(c_loadAddr_b),
  .c_loadEn(c_loadEn_b),
  .c_storeEn(c_storeEn_b),
  .c_storeAddr(c_storeAddr_b),
  .c_storeData(c_storeData_b),
  .c_loadData(c_loadData),
  .a_loadAddr(a_loadAddr_b),
  .a_loadEn(a_loadEn_b),
  .a_storeEn(a_storeEn_b),
  .a_storeAddr(a_storeAddr_b),
  .a_storeData(a_storeData_b),
  .a_loadData(a_loadData),
  .out0(out0_b)
);

endmodule

module main(rst,
  clk,
  ap_start,
  ap_ready,
  ap_done,
  c_loadAddr,
  c_loadEn,
  c_storeEn,
  c_storeAddr,
  c_storeData,
  c_loadData,
  a_loadAddr,
  a_loadEn,
  a_storeEn,
  a_storeAddr,
  a_storeData,
  a_loadData,
  out0
);
  input rst;
  input clk;
  input ap_start;
  output ap_ready;
  output ap_done;
  output [3:0] c_loadAddr;
  output c_loadEn;
  output c_storeEn;
  output [3:0] c_storeAddr;
  output [7:0] c_storeData;
  input [7:0] c_loadData;
  output [6:0] a_loadAddr;
  output a_loadEn;
  output a_storeEn;
  output [6:0] a_storeAddr;
  output [7:0] a_storeData;
  input [7:0] a_loadData;
  output [7:0] out0;
  wire kernel_state;
  wire all_finish;
  wire c_start_valid;
  wire c_start_ready;
  wire a_start_valid;
  wire a_start_ready;
  wire start_valid;
  wire start_ready;
  wire out0_valid;
  wire out0_ready;
  wire c_end_valid;
  wire c_end_ready;
  wire a_end_valid;
  wire a_end_ready;
  wire end_valid;
  wire end_ready;
  gaussian gaussian_inst (
    .clk(clk),
    .rst(rst),
    .c_loadEn(c_loadEn),
    .c_loadAddr(c_loadAddr),
    .c_loadData(c_loadData),
    .c_storeEn(c_storeEn),
    .c_storeAddr(c_storeAddr),
    .c_storeData(c_storeData),
    .a_loadEn(a_loadEn),
    .a_loadAddr(a_loadAddr),
    .a_loadData(a_loadData),
    .a_storeEn(a_storeEn),
    .a_storeAddr(a_storeAddr),
    .a_storeData(a_storeData),
    .c_start_valid(c_start_valid),
    .c_start_ready(c_start_ready),
    .a_start_valid(a_start_valid),
    .a_start_ready(a_start_ready),
    .start_valid(start_valid),
    .start_ready(start_ready),
    .out0(out0),
    .out0_valid(out0_valid),
    .out0_ready(out0_ready),
    .c_end_valid(c_end_valid),
    .c_end_ready(c_end_ready),
    .a_end_valid(a_end_valid),
    .a_end_ready(a_end_ready),
    .end_valid(end_valid),
    .end_ready(end_ready)
  );
  kernel_state_reg kernel_state_reg_inst (
    .clk(clk),
    .rst(rst),
    .ap_start(ap_start),
    .ap_ready(ap_ready),
    .kernel_state(kernel_state),
    .all_finish(all_finish),
    .ap_done(ap_done)
  );
  kernel_arg_buffer #(1) c_start_data_reg_inst (
    .clk(clk),
    .rst(rst),
    .kernel_state(kernel_state),
    .ap_start(ap_start),
    .data_in(1'b1),
    .data_out(),
    .valid(c_start_valid),
    .ready(c_start_ready)
  );
  kernel_arg_buffer #(1) a_start_data_reg_inst (
    .clk(clk),
    .rst(rst),
    .kernel_state(kernel_state),
    .ap_start(ap_start),
    .data_in(1'b1),
    .data_out(),
    .valid(a_start_valid),
    .ready(a_start_ready)
  );
  kernel_arg_buffer #(1) start_data_reg_inst (
    .clk(clk),
    .rst(rst),
    .kernel_state(kernel_state),
    .ap_start(ap_start),
    .data_in(1'b1),
    .data_out(),
    .valid(start_valid),
    .ready(start_ready)
  );
  kernel_join #(4) join_inst (
    .ins_valid({out0_valid, c_end_valid, a_end_valid, end_valid}),
    .ins_ready({out0_ready, c_end_ready, a_end_ready, end_ready}),
    .outs_valid(all_finish),
    .outs_ready(1'b1)
  );
endmodule
`timescale 1ns / 1ps

//
//  read_address_mux Module
//

module read_address_mux #(
  parameter ARBITER_SIZE = 1,
  parameter ADDR_TYPE   = 32
) (
  input  [             ARBITER_SIZE - 1 : 0] sel,
  input  [ARBITER_SIZE * ADDR_TYPE - 1 : 0] addr_in,
  output [               ADDR_TYPE - 1 : 0] addr_out
);
  integer                      i;
  reg     [ADDR_TYPE - 1 : 0] addr_out_var;

  always @(*) begin
    addr_out_var = {ADDR_TYPE{1'b0}};

    for (i = 0; i < ARBITER_SIZE; i = i + 1) begin
      if (sel[i]) begin
        addr_out_var = addr_in[i*ADDR_TYPE+:ADDR_TYPE];
      end
    end
  end

  assign addr_out = addr_out_var;

endmodule

//
//  read_address_ready Module
//

module read_address_ready #(
  parameter ARBITER_SIZE = 1
) (
  input  [ARBITER_SIZE-1:0] sel,
  input  [ARBITER_SIZE-1:0] nReady,
  output [ARBITER_SIZE-1:0] ready
);
  assign ready = nReady & sel;

endmodule

//
//  read_data_signals Module
//

module read_data_signals #(
  parameter ARBITER_SIZE = 1,
  parameter DATA_TYPE   = 32
) (
  input                                          rst,
  input                                          clk,
  input      [             ARBITER_SIZE - 1 : 0] sel,
  input      [               DATA_TYPE - 1 : 0] read_data,
  output reg [ARBITER_SIZE * DATA_TYPE - 1 : 0] out_data,
  output reg [             ARBITER_SIZE - 1 : 0] valid,
  input      [             ARBITER_SIZE - 1 : 0] nReady
);
  reg     [              ARBITER_SIZE - 1 : 0] sel_prev = 0;
  reg     [ARBITER_SIZE * DATA_TYPE  - 1 : 0] out_reg = 0;

  integer                                      i;
  initial valid = 0;

  always @(posedge clk) begin
    if (rst) begin
      valid    <= 0;
      sel_prev <= 0;
    end else begin
      sel_prev <= sel;
      for (i = 0; i <= ARBITER_SIZE - 1; i = i + 1)
      if (sel[i]) valid[i] <= 1;
      else if (nReady[i]) valid[i] <= 0;
    end
  end

  always @(posedge clk) begin
    for (i = 0; i <= ARBITER_SIZE - 1; i = i + 1)
      if (rst)
        out_reg[i*DATA_TYPE+:DATA_TYPE] <= 0;
      else if (sel_prev[i])
        out_reg[i*DATA_TYPE+:DATA_TYPE] <= read_data;
    end

  always @(*) begin
    for (i = 0; i <= ARBITER_SIZE - 1; i = i + 1) begin
      if (sel_prev[i]) out_data[i*DATA_TYPE+:DATA_TYPE] = read_data;
      else out_data[i*DATA_TYPE+:DATA_TYPE] = out_reg[i*DATA_TYPE+:DATA_TYPE];
    end
  end

endmodule

//
//  read_priority Module
//

module read_priority #(
  parameter ARBITER_SIZE = 1
) (
  input      [ARBITER_SIZE - 1 : 0] req,
  input      [ARBITER_SIZE - 1 : 0] data_ready,
  output reg [ARBITER_SIZE - 1 : 0] priority_out
);
  reg     prio_req = 0;
  integer i;

  always @(req, data_ready) begin
    priority_out[0] = req[0] & data_ready[0];
    prio_req        = req[0] & data_ready[0];

    for (i = 1; i <= ARBITER_SIZE - 1; i = i + 1) begin
      priority_out[i] = ~prio_req & req[i] & data_ready[i];
      prio_req        = prio_req | (req[i] & data_ready[i]);
    end
  end
endmodule

module read_memory_arbiter #(
  parameter ARBITER_SIZE = 2,
  parameter ADDR_TYPE   = 32,
  parameter DATA_TYPE   = 32
) (
  input                                      clk,
  input                                      rst,
  // Interface to previous
  input  [             ARBITER_SIZE - 1 : 0] pValid,
  output [             ARBITER_SIZE - 1 : 0] ready,
  input  [ARBITER_SIZE * ADDR_TYPE - 1 : 0] address_in,
  // Interface to next
  input  [             ARBITER_SIZE - 1 : 0] nReady,
  output [             ARBITER_SIZE - 1 : 0] valid,
  output [ARBITER_SIZE * DATA_TYPE - 1 : 0] data_out,
  // Interface to memory
  output                                     read_enable,
  output [               ADDR_TYPE - 1 : 0] read_address,
  input  [               DATA_TYPE - 1 : 0] data_from_memory
);

  wire [ARBITER_SIZE - 1 : 0] priorityOut;

  // Instance of read_priority
  read_priority #(
    .ARBITER_SIZE(ARBITER_SIZE)
  ) prio (
    .req         (pValid),
    .data_ready  (nReady),
    .priority_out(priorityOut)
  );

  // Instance of read_address_mux
  read_address_mux #(
    .ARBITER_SIZE(ARBITER_SIZE),
    .ADDR_TYPE  (ADDR_TYPE)
  ) addressing (
    .sel     (priorityOut),
    .addr_in (address_in),
    .addr_out(read_address)
  );

  // Instance of read_address_ready
  read_address_ready #(
    .ARBITER_SIZE(ARBITER_SIZE)
  ) adderssReady (
    .sel   (priorityOut),
    .nReady(nReady),
    .ready (ready)
  );

  // Instance of read_data_signals
  read_data_signals #(
    .ARBITER_SIZE(ARBITER_SIZE),
    .DATA_TYPE  (DATA_TYPE)
  ) data_signals_inst (
    .rst      (rst),
    .clk      (clk),
    .sel      (priorityOut),
    .read_data(data_from_memory),
    .out_data (data_out),
    .valid    (valid),
    .nReady   (nReady)
  );

  assign read_enable = |priorityOut;

endmodule


//
//  write_address_mux Module
//

module write_address_mux #(
  parameter ARBITER_SIZE = 1,
  parameter ADDR_TYPE   = 32
) (
  input  [             ARBITER_SIZE - 1 : 0] sel,
  input  [ARBITER_SIZE * ADDR_TYPE - 1 : 0] addr_in,
  output [               ADDR_TYPE - 1 : 0] addr_out
);
  integer                      i;
  reg     [ADDR_TYPE - 1 : 0] addr_out_var;

  always @(*) begin
    //! May need to chaneg the following line to remove the assignment to 0
    addr_out_var = {ADDR_TYPE{1'b0}};

    for (i = 0; i < ARBITER_SIZE; i = i + 1) begin
      if (sel[i]) begin
        addr_out_var = addr_in[i*ADDR_TYPE+:ADDR_TYPE];
      end
    end
  end

  assign addr_out = addr_out_var;

endmodule

//
//  write_address_mux Module
//

module write_address_ready #(
  parameter ARBITER_SIZE = 1
) (
  input  [ARBITER_SIZE-1:0] sel,
  input  [ARBITER_SIZE-1:0] nReady,
  output [ARBITER_SIZE-1:0] ready
);
  assign ready = nReady & sel;

endmodule

//
//  write_data_signals Module
//

module write_data_signals #(
  parameter ARBITER_SIZE = 1,
  parameter DATA_TYPE   = 32
) (
  input                                           clk,
  input                                           rst,
  input      [              ARBITER_SIZE - 1 : 0] sel,
  output     [                DATA_TYPE - 1 : 0] write_data,
  input      [ARBITER_SIZE * DATA_TYPE  - 1 : 0] in_data,
  output     [              ARBITER_SIZE - 1 : 0] valid
);
  integer                      i;
  reg     [DATA_TYPE - 1 : 0] data_out_var = 0;
  reg     [ARBITER_SIZE - 1: 0] valid_out_var = 0;

  always @(*) begin
    data_out_var = {DATA_TYPE{1'b0}};
    for (i = 0; i < ARBITER_SIZE; i = i + 1) begin
      if (sel[i]) begin
        data_out_var = in_data[i*DATA_TYPE+:DATA_TYPE];
      end
    end
  end

  assign write_data = data_out_var;

  always @(posedge clk) begin
    if (rst) begin
      valid_out_var <= 0;
    end else begin
      valid_out_var <= sel;
    end
  end

  assign valid = valid_out_var;

endmodule

//
//  write_priority Module
//

module write_priority #(
  parameter ARBITER_SIZE = 1
) (
  input      [ARBITER_SIZE - 1 : 0] req,
  input      [ARBITER_SIZE - 1 : 0] data_ready,
  output reg [ARBITER_SIZE - 1 : 0] priority_out
);
  reg     prio_req = 0;
  integer i;

  always @(req, data_ready) begin
    priority_out[0] = req[0] & data_ready[0];
    prio_req        = req[0] & data_ready[0];

    for (i = 1; i <= ARBITER_SIZE - 1; i = i + 1) begin
      priority_out[i] = ~prio_req & req[i] & data_ready[i];
      prio_req        = prio_req | (req[i] & data_ready[i]);
    end
  end

endmodule

//
//  write_memory_arbiter Module
//

module write_memory_arbiter #(
  parameter ARBITER_SIZE = 2,
  parameter ADDR_TYPE   = 32,
  parameter DATA_TYPE   = 32
) (
  input                                      rst,
  input                                      clk,
  // Interface to previous
  input  [             ARBITER_SIZE - 1 : 0] pValid,
  output [             ARBITER_SIZE - 1 : 0] ready,
  input  [ADDR_TYPE * ARBITER_SIZE - 1 : 0] address_in,
  input  [DATA_TYPE * ARBITER_SIZE - 1 : 0] data_in,
  // Interface to next    
  input  [             ARBITER_SIZE - 1 : 0] nReady,
  output [             ARBITER_SIZE - 1 : 0] valid,
  // Interface to memory   
  output                                     write_enable,
  output                                     enable,
  output [               ADDR_TYPE - 1 : 0] write_address,
  output [               DATA_TYPE - 1 : 0] data_to_memory
);
  wire [ARBITER_SIZE - 1 : 0] priorityOut;

  // Priority handling
  write_priority #(
    .ARBITER_SIZE(ARBITER_SIZE)
  ) prio (
    .req         (pValid),
    .data_ready  (nReady),
    .priority_out(priorityOut)
  );

  // Address multiplexing
  write_address_mux #(
    .ARBITER_SIZE(ARBITER_SIZE),
    .ADDR_TYPE  (ADDR_TYPE)
  ) addressing (
    .sel     (priorityOut),
    .addr_in (address_in),
    .addr_out(write_address)
  );

  // Ready signal handling
  write_address_ready #(
    .ARBITER_SIZE(ARBITER_SIZE)
  ) addressReady (
    .sel   (priorityOut),
    .nReady(nReady),
    .ready (ready)
  );

  // Data handling
  write_data_signals #(
    .ARBITER_SIZE(ARBITER_SIZE),
    .DATA_TYPE  (DATA_TYPE)
  ) data_signals_inst (
    .rst       (rst),
    .clk       (clk),
    .sel       (priorityOut),
    .in_data   (data_in),
    .write_data(data_to_memory),
    .valid     (valid)
  );

  assign write_enable = |priorityOut;
  assign enable       = |priorityOut;

endmodule

//
//  mc_control
//

module mc_control (
  input  clk,
  input  rst,
  // start input control
  input  memStart_valid,
  output memStart_ready,
  // end output control
  output memEnd_valid,
  input  memEnd_ready,
  // "no more requests" input control
  input  ctrlEnd_valid,
  output ctrlEnd_ready,
  // all requests completed
  input  allRequestsDone
);
  reg memIdle = 1;
  reg memDone = 0;
  reg memAckCtrl = 0;

  assign memStart_ready = memIdle;
  assign memEnd_valid   = memDone;
  assign ctrlEnd_ready  = memAckCtrl;

  always @(posedge clk) begin
    if (rst) begin
      memIdle    <= 1;
      memDone    <= 0;
      memAckCtrl <= 0;
    end else begin
      memIdle    <= memIdle;
      memDone    <= memDone;
      memAckCtrl <= memAckCtrl;

      // determine when the memory has completed all requests
      if (ctrlEnd_valid && allRequestsDone) begin
        memDone    <= 1;
        memAckCtrl <= 1;
      end

      // acknowledge the 'ctrlEnd' control
      if (ctrlEnd_valid && memAckCtrl) begin
        memAckCtrl <= 0;
      end

      // determine when the memory is idle
      if (memStart_valid && memIdle) begin
        memIdle <= 0;
      end
      if (memDone && memEnd_ready) begin
        memIdle <= 1;
        memDone <= 0;
      end
    end
  end
endmodule
`timescale 1ns / 1ps


module mem_controller_loadless #(
  parameter NUM_CONTROLS = 1,
  parameter NUM_STORES   = 1,
  parameter DATA_TYPE   = 32,
  parameter ADDR_TYPE   = 32
) (
  input                                      clk,
  input                                      rst,
  // start input control
  input                                      memStart_valid,
  output                                     memStart_ready,
  // end output control
  output                                     memEnd_valid,
  input                                      memEnd_ready,
  // "no more requests" input control
  input                                      ctrlEnd_valid,
  output                                     ctrlEnd_ready,
  // Control Input Channels
  input  [      (NUM_CONTROLS * 32) - 1 : 0] ctrl,
  input  [             NUM_CONTROLS - 1 : 0] ctrl_valid,
  output [             NUM_CONTROLS - 1 : 0] ctrl_ready,
  // Store Address Input Channels
  input  [(NUM_STORES * ADDR_TYPE) - 1 : 0] stAddr,
  input  [               NUM_STORES - 1 : 0] stAddr_valid,
  output [               NUM_STORES - 1 : 0] stAddr_ready,
  // Store Data Input Channels
  input  [(NUM_STORES * DATA_TYPE) - 1 : 0] stData,
  input  [               NUM_STORES - 1 : 0] stData_valid,
  output [               NUM_STORES - 1 : 0] stData_ready,
  // Interface to Dual-port BRAM
  input  [               DATA_TYPE - 1 : 0] loadData,
  output                                     loadEn,
  output [               ADDR_TYPE - 1 : 0] loadAddr,
  output                                     storeEn,
  output [               ADDR_TYPE - 1 : 0] storeAddr,
  output [               DATA_TYPE - 1 : 0] storeData
);
  // Terminology:
  // Access ports    : circuit to memory_controller;
  // Interface ports : memory_controller to memory_interface (e.g., BRAM/AXI);

  // WIDTH_COUNTER_PENDING_STORES sets the number of maximum pending stores to
  // 2^WIDTH_COUNTER_PENDING_STORES - 1
  // TODO: We should be able configure this number to save resources.
  localparam WIDTH_COUNTER_PENDING_STORES=2;

  wire [WIDTH_COUNTER_PENDING_STORES-1 : 0] remainingStores;
  // Indicating the store interface port that there is a valid store request
  // (currently not used).
  wire [NUM_STORES - 1 : 0] interface_port_valid;
  // Indicating a store port has both a valid data and a valid address.
  wire [NUM_STORES - 1 : 0] store_access_port_complete_request;
  // Indicating the store port is selected by the arbiter.
  wire [NUM_STORES - 1 : 0] store_access_port_selected;
  wire allRequestsDone;

  // Local Parameter
  localparam [WIDTH_COUNTER_PENDING_STORES-1:0] zeroStore = {WIDTH_COUNTER_PENDING_STORES{1'b0}};
  localparam [NUM_CONTROLS-1:0] zeroCtrl = {NUM_CONTROLS{1'b0}};

  assign loadEn   = 0;
  assign loadAddr = {ADDR_TYPE{1'b0}};

  // A store request is complete if both address and data are valid.
  assign store_access_port_complete_request = stAddr_valid & stData_valid;

  // Instantiate write memory arbiter
  write_memory_arbiter #(
    .ARBITER_SIZE(NUM_STORES),
    .ADDR_TYPE  (ADDR_TYPE),
    .DATA_TYPE  (DATA_TYPE)
  ) write_arbiter (
    .rst           (rst),
    .clk           (clk),
    .pValid        (store_access_port_complete_request),
    .ready         (store_access_port_selected),
    .address_in    (stAddr),
    .data_in       (stData),
    .nReady        ({NUM_STORES{1'b1}}),
    .valid         (interface_port_valid),
    .write_enable  (storeEn),
    .write_address (storeAddr),
    .data_to_memory(storeData)
  );

  assign stData_ready = store_access_port_selected;
  assign stAddr_ready = store_access_port_selected;
  assign ctrl_ready   = {NUM_CONTROLS{1'b1}};

  integer          i;
  reg     [WIDTH_COUNTER_PENDING_STORES-1 : 0] counter = {WIDTH_COUNTER_PENDING_STORES{1'd0}};

  // Counting Stores
  always @(posedge clk) begin
    if (rst) begin
      counter = {WIDTH_COUNTER_PENDING_STORES{1'd0}};
    end else begin
      for (i = 0; i <= NUM_CONTROLS - 1; i = i + 1) begin
        if (ctrl_valid[i]) begin
          counter = counter + ctrl[i*32+:32];
        end
      end
      if (storeEn) begin
        counter = counter - 1;
      end
    end
  end

  assign remainingStores = counter;

  // NOTE: (lucas-rami) In addition to making sure there are no stores pending,
  // we should also check that there are no loads pending as well. To achieve 
  // this the control signals could simply start indicating the total number
  // of accesses in the block instead of just the number of stores.
  assign allRequestsDone = (remainingStores == zeroStore && ctrl_valid == zeroCtrl) ? 1'b1 : 1'b0;

  mc_control control (
    .rst            (rst),
    .clk            (clk),
    .memStart_valid (memStart_valid),
    .memStart_ready (memStart_ready),
    .memEnd_valid   (memEnd_valid),
    .memEnd_ready   (memEnd_ready),
    .ctrlEnd_valid  (ctrlEnd_valid),
    .ctrlEnd_ready  (ctrlEnd_ready),
    .allRequestsDone(allRequestsDone)
  );

endmodule`timescale 1ns / 1ps
module mem_controller_storeless #(
  parameter NUM_LOADS  = 1,
  parameter DATA_TYPE = 32,
  parameter ADDR_TYPE = 32
) (
  input                                     clk,
  input                                     rst,
  // start input control
  input                                     memStart_valid,
  output                                    memStart_ready,
  // end output control
  output                                    memEnd_valid,
  input                                     memEnd_ready,
  // "no more requests" input control
  input                                     ctrlEnd_valid,
  output                                    ctrlEnd_ready,
  // Load address input channels
  input  [(NUM_LOADS * ADDR_TYPE) - 1 : 0] ldAddr,
  input  [               NUM_LOADS - 1 : 0] ldAddr_valid,
  output [               NUM_LOADS - 1 : 0] ldAddr_ready,
  // Load data output channels
  output [(NUM_LOADS * DATA_TYPE) - 1 : 0] ldData,
  output [               NUM_LOADS - 1 : 0] ldData_valid,
  input  [               NUM_LOADS - 1 : 0] ldData_ready,
  // Interface to dual-port BRAM
  input  [              DATA_TYPE - 1 : 0] loadData,
  output                                    loadEn,
  output [              ADDR_TYPE - 1 : 0] loadAddr,
  output                                    storeEn,
  output [              ADDR_TYPE - 1 : 0] storeAddr,
  output [              DATA_TYPE - 1 : 0] storeData
);
  wire allRequestsDone;

  // No stores will ever be issused
  assign storeAddr = {ADDR_TYPE{1'b0}};
  assign storeData = {DATA_TYPE{1'b0}};
  assign storeEn   = 1'b0;

  // MC is "always done with stores"

  read_memory_arbiter #(
    .ARBITER_SIZE(NUM_LOADS),
    .ADDR_TYPE  (ADDR_TYPE),
    .DATA_TYPE  (DATA_TYPE)
  ) read_arbiter (
    .rst             (rst),
    .clk             (clk),
    .pValid          (ldAddr_valid),
    .ready           (ldAddr_ready),
    .address_in      (ldAddr),
    .nReady          (ldData_ready),
    .valid           (ldData_valid),
    .data_out        (ldData),
    .read_enable     (loadEn),
    .read_address    (loadAddr),
    .data_from_memory(loadData)
  );

  // NOTE: (lucas-rami) In addition to making sure there are no stores pending,
  // we should also check that there are no loads pending as well. To achieve 
  // this the control signals could simply start indicating the total number
  // of accesses in the block instead of just the number of stores.
  assign allRequestsDone = 1'b1;

  mc_control control (
    .rst            (rst),
    .clk            (clk),
    .memStart_valid (memStart_valid),
    .memStart_ready (memStart_ready),
    .memEnd_valid   (memEnd_valid),
    .memEnd_ready   (memEnd_ready),
    .ctrlEnd_valid  (ctrlEnd_valid),
    .ctrlEnd_ready  (ctrlEnd_ready),
    .allRequestsDone(allRequestsDone)
  );

endmodule
`timescale 1ns / 1ps
module mem_controller #(
  parameter NUM_CONTROLS = 1,
  parameter NUM_LOADS    = 1,
  parameter NUM_STORES   = 1,
  parameter DATA_TYPE   = 32,
  parameter ADDR_TYPE   = 32
) (
  input                                      clk,
  input                                      rst,
  // start input control
  input                                      memStart_valid,
  output                                     memStart_ready,
  // end output control
  output                                     memEnd_valid,
  input                                      memEnd_ready,
  // "no more requests" input control
  input                                      ctrlEnd_valid,
  output                                     ctrlEnd_ready,
  // Control Input Channels
  input  [      (NUM_CONTROLS * 32) - 1 : 0] ctrl,
  input  [             NUM_CONTROLS - 1 : 0] ctrl_valid,
  output [             NUM_CONTROLS - 1 : 0] ctrl_ready,
  // Load address input channels
  input  [ (NUM_LOADS * ADDR_TYPE) - 1 : 0] ldAddr,
  input  [                NUM_LOADS - 1 : 0] ldAddr_valid,
  output [                NUM_LOADS - 1 : 0] ldAddr_ready,
  // Load data output channels
  output [ (NUM_LOADS * DATA_TYPE) - 1 : 0] ldData,
  output [                NUM_LOADS - 1 : 0] ldData_valid,
  input  [                NUM_LOADS - 1 : 0] ldData_ready,
  // Store Address Input Channels
  input  [(NUM_STORES * ADDR_TYPE) - 1 : 0] stAddr,
  input  [               NUM_STORES - 1 : 0] stAddr_valid,
  output [               NUM_STORES - 1 : 0] stAddr_ready,
  // Store Data Input Channels
  input  [(NUM_STORES * DATA_TYPE) - 1 : 0] stData,
  input  [               NUM_STORES - 1 : 0] stData_valid,
  output [               NUM_STORES - 1 : 0] stData_ready,
  // Interface to Dual-port BRAM
  input  [               DATA_TYPE - 1 : 0] loadData,
  output                                     loadEn,
  output [               ADDR_TYPE - 1 : 0] loadAddr,
  output                                     storeEn,
  output [               ADDR_TYPE - 1 : 0] storeAddr,
  output [               DATA_TYPE - 1 : 0] storeData
);
  // Internal signal declarations
  wire                      dropLoadEn;
  wire [ADDR_TYPE - 1 : 0] dropLoadAddr;
  wire [DATA_TYPE - 1 : 0] dropLoadData;

  assign dropLoadData = {{DATA_TYPE{1'b0}}};

  mem_controller_loadless #(
    .NUM_CONTROLS(NUM_CONTROLS),
    .NUM_STORES  (NUM_STORES),
    .DATA_TYPE  (DATA_TYPE),
    .ADDR_TYPE  (ADDR_TYPE)
  ) stores (
    .clk           (clk),
    .rst           (rst),
    .memStart_valid(memStart_valid),
    .memStart_ready(memStart_ready),
    .memEnd_valid  (memEnd_valid),
    .memEnd_ready  (memEnd_ready),
    .ctrlEnd_valid (ctrlEnd_valid),
    .ctrlEnd_ready (ctrlEnd_ready),
    .ctrl          (ctrl),
    .ctrl_valid    (ctrl_valid),
    .ctrl_ready    (ctrl_ready),
    .stAddr        (stAddr),
    .stAddr_valid  (stAddr_valid),
    .stAddr_ready  (stAddr_ready),
    .stData        (stData),
    .stData_valid  (stData_valid),
    .stData_ready  (stData_ready),
    .loadData      (dropLoadData),
    .loadEn        (dropLoadEn),
    .loadAddr      (dropLoadAddr),
    .storeEn       (storeEn),
    .storeAddr     (storeAddr),
    .storeData     (storeData)
  );

  read_memory_arbiter #(
    .ARBITER_SIZE(NUM_LOADS),
    .ADDR_TYPE  (ADDR_TYPE),
    .DATA_TYPE  (DATA_TYPE)
  ) read_arbiter (
    .rst             (rst),
    .clk             (clk),
    .pValid          (ldAddr_valid),
    .ready           (ldAddr_ready),
    .address_in      (ldAddr),
    .nReady          (ldData_ready),
    .valid           (ldData_valid),
    .data_out        (ldData),
    .read_enable     (loadEn),
    .read_address    (loadAddr),
    .data_from_memory(loadData)
  );

endmodule
`timescale 1ns / 1ps
module mem_to_bram #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
) (
  // Inputs from circuit
  input                       loadEn,
  input  [ADDR_WIDTH - 1 : 0] loadAddr,
  input                       storeEn,
  input  [ADDR_WIDTH - 1 : 0] storeAddr,
  input  [DATA_WIDTH - 1 : 0] storeData,
  // Inputs from BRAM
  input  [DATA_WIDTH - 1 : 0] din0,
  input  [DATA_WIDTH - 1 : 0] din1,
  // Outputs to BRAM
  output                      ce0,
  output                      we0,
  output [ADDR_WIDTH - 1 : 0] address0,
  output [DATA_WIDTH - 1 : 0] dout0,
  output                      ce1,
  output                      we1,
  output [ADDR_WIDTH - 1 : 0] address1,
  output [DATA_WIDTH - 1 : 0] dout1,
  // Outputs back to circuit
  output [DATA_WIDTH - 1 : 0] loadData
);
  // Store request
  assign ce0 = storeEn;
  assign we0 = storeEn;
  assign address0 = storeAddr;
  assign dout0 = storeData;

  // Load request
  assign ce1 = loadEn;
  assign we1 = 1'b0;  // Write enable is always 0 for load operations
  assign address1 = loadAddr;
  assign dout1 = {DATA_WIDTH{1'b0}};  // Data output is zero since no data is written during loads

  // Data back to circuit from BRAM
  assign loadData = din1;

endmodule
`timescale 1ns/1ps
module merge_dataless #(
  parameter SIZE = 2
)(
  input  clk,
  input  rst,
  // Input Channels
  input  [SIZE - 1 : 0] ins_valid,
  output [SIZE - 1 : 0] ins_ready,
  // Output Channel
  output outs_valid,
  input  outs_ready
);

  reg tmp_valid_out;
  reg [SIZE - 1 : 0] tmp_ready_out;
  integer i;

  always @(*) begin
    tmp_valid_out = 0;
    tmp_ready_out = {SIZE{1'b0}}; 
    for (i = 0; i < SIZE; i = i + 1) begin
      if (ins_valid[i] && !tmp_valid_out) begin
        tmp_valid_out = 1;
        tmp_ready_out[i] = outs_ready;
      end
    end
  end
  
  assign outs_valid = tmp_valid_out;
  assign ins_ready = tmp_ready_out;

endmodule
`timescale 1ns/1ps
module mul_4_stage #(
  parameter DATA_TYPE = 32
)(
  // inputs
  input  clk,
  input  ce,
  input  [DATA_TYPE - 1 : 0] a,
  input  [DATA_TYPE - 1 : 0] b,
  // outputs
  output [DATA_TYPE - 1 : 0] p
);

  reg  [DATA_TYPE - 1 : 0] a_reg = 0;
  reg  [DATA_TYPE - 1 : 0] b_reg = 0;
  reg  [DATA_TYPE - 1 : 0] q0 = 0;
  reg  [DATA_TYPE - 1 : 0] q1 = 0;
  reg  [DATA_TYPE - 1 : 0] q2 = 0;
  wire  [DATA_TYPE - 1 : 0] mul;

  assign mul = a_reg * b_reg;

  always @(posedge clk) begin
    if (ce) begin
      a_reg <= a;
      b_reg <= b;
      q0 <= mul;
      q1 <= q0;
      q2 <= q1;
    end
  end

  assign p = q2;

endmodule


module muli #(
  parameter DATA_TYPE = 32,
  parameter LATENCY = 4
)(
  // inputs
  input  clk,
  input  rst,
  input  [DATA_TYPE - 1 : 0] lhs,
  input  lhs_valid,
  input  [DATA_TYPE - 1 : 0] rhs,
  input  rhs_valid,
  input  result_ready,
  // outputs
  output [DATA_TYPE - 1 : 0] result,
  output result_valid,
  output lhs_ready,
  output rhs_ready
);

  //assert(LATENCY != 4) else $fatal("muli only supports LATENCY = 4");

  wire join_valid;
  wire oehb_ready;
  wire buff_valid;

  // Instantiate the join node
  join_type #(
    .SIZE(2)
  ) join_inputs (
    .ins_valid  ({rhs_valid, lhs_valid}),
    .outs_ready (oehb_ready             ),
    .ins_ready  ({rhs_ready, lhs_ready}  ),
    .outs_valid (join_valid             )
  );

  mul_4_stage #(
    .DATA_TYPE(DATA_TYPE)
  ) mul_4_stage_inst (
    .clk(clk),
    .ce(oehb_ready),
    .a(lhs),
    .b(rhs),
    .p(result)
  );

  delay_buffer #(
    .SIZE( LATENCY - 1)
  ) buff (
    .clk(clk),
    .rst(rst),
    .valid_in(join_valid),
    .ready_in(oehb_ready),
    .valid_out(buff_valid)
  );

  oehb_dataless oehb_inst (
    .clk(clk),
    .rst(rst),
    .ins_valid(buff_valid),
    .ins_ready(oehb_ready),
    .outs_valid(result_valid),
    .outs_ready(result_ready)
  );


endmodule
`timescale 1ns/1ps
module mux #(
  parameter SIZE = 2,
  parameter DATA_TYPE = 32,
  parameter SELECT_TYPE = 2
)(
  input  clk,
  input  rst,
  // Data input channels
  input  [(SIZE * DATA_TYPE) - 1 : 0] ins, 
  input  [SIZE - 1 : 0] ins_valid,
  output reg [SIZE - 1 : 0] ins_ready,
  // Index input channel
  input  [SELECT_TYPE - 1 : 0] index,
  input  index_valid,
  output index_ready,
  // Output channel
  output [DATA_TYPE - 1 : 0] outs,
  output outs_valid,
  input  outs_ready
);
  reg [DATA_TYPE - 1 : 0] selectedData;
  reg selectedData_valid;

  integer i;
  always @(*) begin
    if(rst) begin
      selectedData_valid = 0;
      for (i = DATA_TYPE - 1; i >= 0; i = i - 1) begin
        selectedData[i] = 0;
      end
      for (i = SIZE - 1; i >= 0; i = i - 1) begin
        ins_ready[i] = 0;
      end
    end else begin
      selectedData = ins[0 * DATA_TYPE +: DATA_TYPE];
      selectedData_valid = 0;

      for (i = SIZE - 1; i >= 0; i = i - 1) begin
        if (((i[SELECT_TYPE - 1 : 0] == index) & index_valid & outs_ready & ins_valid[i]) | ~ins_valid[i]) begin
          ins_ready[i] = 1;
        end else begin
          ins_ready[i] = 0;
        end

        if (index == i[SELECT_TYPE - 1 : 0] && index_valid && ins_valid[i]) begin
          selectedData = ins[i * DATA_TYPE +: DATA_TYPE];
          selectedData_valid = 1;
        end
      end
    end 

  end

  assign index_ready = ~index_valid | (selectedData_valid & outs_ready);
  assign outs = selectedData;
  assign outs_valid = selectedData_valid;

endmodule
`timescale 1ns/1ps
module oehb_dataless (
  input  clk,
  input  rst,
  // Input channel
  input  ins_valid,
  output ins_ready,
  // Output channel
  output outs_valid,
  input  outs_ready
);
  // Define internal signals
  reg outputValid = 0;

  always @(posedge clk) begin
    if (rst) begin
      outputValid <= 0;
    end else begin
      outputValid <= ins_valid | (~outs_ready & outputValid);
    end
  end

  assign ins_ready = ~outputValid | outs_ready;
  assign outs_valid = outputValid;
  
endmodule
`timescale 1ns/1ps
module oehb #(
  parameter DATA_TYPE = 32
) (
  input  clk,
  input  rst,
  // Input channel
  input  [DATA_TYPE - 1 : 0] ins,
  input  ins_valid,
  output ins_ready,
  // Output channel
  output [DATA_TYPE - 1 : 0] outs,
  output outs_valid,
  input  outs_ready
);
  wire regEn, inputReady;
  reg [DATA_TYPE - 1 : 0] dataReg = 0;
  
  // Instance of oehb_dataless to manage handshaking
  oehb_dataless control (
    .clk        (clk       ),
    .rst        (rst       ),
    .ins_valid  (ins_valid ),
    .ins_ready  (inputReady),
    .outs_valid (outs_valid),
    .outs_ready (outs_ready)
  );

  always @(posedge clk) begin
    if (rst) begin
      dataReg <= {DATA_TYPE{1'b0}};
    end else if (regEn) begin
      dataReg <= ins;
    end
  end

  assign ins_ready = inputReady;
  assign regEn = inputReady & ins_valid;
  assign outs = dataReg;

endmodule
`timescale 1ns/1ps
module shli #(
  parameter DATA_TYPE = 32
)(
  // inputs
  input  clk,
  input  rst,
  input  [DATA_TYPE - 1 : 0] lhs,
  input  lhs_valid,
  input  [DATA_TYPE - 1 : 0] rhs,
  input  rhs_valid,
  input  result_ready,
  // outputs
  output [DATA_TYPE - 1 : 0] result,
  output result_valid,
  output lhs_ready,
  output rhs_ready
);
  
    // Instantiate the join node
    join_type #(
      .SIZE(2)
    ) join_inputs (
      .ins_valid  ({rhs_valid, lhs_valid}),
      .outs_ready (result_ready             ),
      .ins_ready  ({rhs_ready, lhs_ready}  ),
      .outs_valid (result_valid             )
    );
  
    assign result = lhs << rhs;

endmodule`timescale 1ns/1ps
module sink #(
  parameter DATA_TYPE = 32
) (
  input  clk,      
  input  rst,       
  input  [DATA_TYPE-1:0] ins, 
  input  ins_valid, 
  output ins_ready 
);
  assign ins_ready = 1'b1;

endmodule
`timescale 1ns/1ps
module source (
  input  clk,        
  input  rst,        
  input  outs_ready, 
  output outs_valid 
);
  assign outs_valid = 1;

endmodule
`timescale 1ns/1ps
module store #(
  parameter DATA_TYPE = 32,
  parameter ADDR_TYPE = 32
)(
  input  clk,
  input  rst,
  // Data from Circuit Channel
  input  [DATA_TYPE - 1 : 0] dataIn,
  input  dataIn_valid,
  output dataIn_ready,
  // Address from Circuit Channel
  input  [ADDR_TYPE - 1 : 0] addrIn,
  input  addrIn_valid,
  output addrIn_ready,
  // Data to Interface Channel
  output [DATA_TYPE - 1 : 0] dataToMem,
  output dataToMem_valid,
  input  dataToMem_ready,
  // Address to Interface Channel
  output [ADDR_TYPE - 1 : 0] addrOut,
  output addrOut_valid,
  input  addrOut_ready 
);

  // Data assignment
  assign dataToMem = dataIn;
  assign dataToMem_valid = dataIn_valid;
  assign dataIn_ready = dataToMem_ready;

  // Address assignment
  assign addrOut = addrIn;
  assign addrOut_valid = addrIn_valid;
  assign addrIn_ready = addrOut_ready;

endmodule
`timescale 1ns/1ps
module subi #(
  parameter DATA_TYPE = 32
)(
  // inputs
  input  clk,
  input  rst,
  input  [DATA_TYPE - 1 : 0] lhs,
  input  lhs_valid,
  input  [DATA_TYPE - 1 : 0] rhs,
  input  rhs_valid,
  input  result_ready,
  // outputs
  output [DATA_TYPE - 1 : 0] result,
  output result_valid,
  output lhs_ready,
  output rhs_ready
);

  // Instantiate the join node
  join_type #(
    .SIZE(2)
  ) join_inputs (
    .ins_valid  ({rhs_valid, lhs_valid}),
    .outs_ready (result_ready             ),
    .ins_ready  ({rhs_ready, lhs_ready}  ),
    .outs_valid (result_valid             )
  );

  assign result = lhs - rhs;

endmodule`timescale 1ns/1ps
module tehb_dataless (
	input  clk,
	input  rst,
  // Input Channel
	input  ins_valid,
  output ins_ready,
  // Output Channel
  output outs_valid,	
	input  outs_ready
);
	reg fullReg = 0;
	
	always @(posedge clk) begin
		if (rst) begin
			fullReg <= 0;
		end else begin
			fullReg <= (ins_valid | fullReg) & ~outs_ready;
		end
	end

	assign ins_ready = ~fullReg;
	assign outs_valid = ins_valid | fullReg;

endmodule
`timescale 1ns/1ps
module tehb #(
	parameter DATA_TYPE = 32 // Default set to 32 bits
)(
	input  clk,
	input  rst,
  // Input Channel
	input  [DATA_TYPE - 1 : 0] ins,
	input  ins_valid,
  output ins_ready,
  // Output Channel
  output [DATA_TYPE - 1 : 0]	outs,
  output outs_valid,
	input  outs_ready
);
	// Signal Definition
	wire regEnable, regNotFull;
	reg [DATA_TYPE - 1 : 0] dataReg = 0;

	// Instantiate control logic part
	tehb_dataless control (
		.clk		    (clk	     ),
		.rst		    (rst	     ),
		.ins_valid	(ins_valid ),
    .ins_ready	(regNotFull),
		.outs_valid	(outs_valid),
		.outs_ready	(outs_ready)
	);

	assign regEnable = regNotFull & ins_valid & ~outs_ready;

	always @(posedge clk) begin
		if (rst) begin
			dataReg <= 0;
		end else if (regEnable) begin
			dataReg <= ins;
		end
	end

	// Output Assignment
	assign outs = regNotFull ? ins : dataReg;

	assign ins_ready = regNotFull;

endmodule
`timescale 1ns/1ps
module trunci #(
  parameter INPUT_TYPE = 32,
  parameter OUTPUT_TYPE = 32
)(
  // inputs
  input  clk,
  input  rst,
  input  [INPUT_TYPE - 1 : 0] ins,
  input  ins_valid,
  input  outs_ready,
  // outputs
  output [OUTPUT_TYPE - 1 : 0] outs,
  output outs_valid,
  output ins_ready
);

  assign outs = ins[OUTPUT_TYPE - 1 : 0];
  assign outs_valid = ins_valid;
  assign ins_ready = ~ins_valid | (ins_valid & outs_ready);

endmodule