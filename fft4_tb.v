// File: fft4_tb.v
// Simple testbench for fft4_stream
`timescale 1ns/1ps
module fft4_tb;
  reg clk;
  reg rst_n;
  reg [31:0] s_axis_tdata;
  reg s_axis_tvalid;
  wire s_axis_tready;
  reg s_axis_tlast;

  wire [31:0] m_axis_tdata;
  wire m_axis_tvalid;
  reg m_axis_tready;
  wire m_axis_tlast;

  fft4_stream dut (
    .clk(clk), .rst_n(rst_n),
    .s_axis_tdata(s_axis_tdata), .s_axis_tvalid(s_axis_tvalid), .s_axis_tready(s_axis_tready), .s_axis_tlast(s_axis_tlast),
    .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid), .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast)
  );

  initial begin
    clk = 0; forever #5 clk = ~clk; end
  initial begin
    rst_n = 0; s_axis_tvalid = 0; s_axis_tlast = 0; m_axis_tready = 1; s_axis_tdata = 32'd0;
    #25; rst_n = 1;

    // feed 4 samples (real only)
    #50;
    s_axis_tdata = {16'sd10, 16'sd0}; s_axis_tvalid = 1; @(posedge clk);
    s_axis_tdata = {16'sd20, 16'sd0}; s_axis_tvalid = 1; @(posedge clk);
    s_axis_tdata = {16'sd30, 16'sd0}; s_axis_tvalid = 1; @(posedge clk);
    s_axis_tdata = {16'sd40, 16'sd0}; s_axis_tvalid = 1; s_axis_tlast = 1; @(posedge clk);
    s_axis_tvalid = 0; s_axis_tlast = 0;

    // wait for outputs
    wait(m_axis_tvalid);
    while (m_axis_tvalid) begin
      @(posedge clk);
      $display("OUT: %h , last=%b", m_axis_tdata, m_axis_tlast);
    end

    #100; $finish;
  end
endmodule


