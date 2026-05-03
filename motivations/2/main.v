module top (clk,rst,pi,equiv);

input clk,rst,pi;
wire po_a, po_b;
output equiv;

assign equiv = po_a == po_b;
main m_a(
  .clk(clk),
  .rst(rst),
  .pi_1(pi),
  .po_1(po_a)
);

main m_b(
  .clk(clk),
  .rst(rst),
  .pi_1(pi),
  .po_1(po_b)
);

assert property (@(posedge clk) equiv);

endmodule


module main(
  clk,
  rst,
  pi_1,
  po_1
);

input clk;
input rst;
input pi_1;
output po_1;

reg f1;
reg f2;
reg f3;
reg f4;
reg f5;
reg f6;

initial f1 = 0;
initial f2 = 0;
initial f3 = 0;
initial f4 = 0;
initial f5 = 0;
initial f6 = 0;

wire f1_prev;

assign f1_prev = pi_1 && (f6 == 1'b0);


wire [1:0]f6_prev;
assign f6_prev = {{2{f6}} - {2{f5}} + {2{f1_prev}}};
assign po_1 = f5;

always @(posedge clk)
begin
  if (rst) begin
    f1 <= 1'b0;
    f2 <= 1'b0;
    f3 <= 1'b0;
    f4 <= 1'b0;
    f5 <= 1'b0;
    f6 <= 1'b0;
  end else begin
    f1 <= f1_prev;
    f2 <= f1;
    f3 <= f2;
    f4 <= f3;
    f5 <= f4;
    f6 <= f6_prev[0];
  end
end

endmodule