`timescale 1ns / 1ps

module top (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] dens_ns,
    input  wire [1:0] dens_ew,
    output wire [2:0] ns_light,   // {R, Y, G}
    output wire [2:0] ew_light
);
    wire tick;

    clk_divider #(.DIV(100_000_000)) u_div (
        .clk(clk), .rst(rst), .tick_1hz(tick)
    );

    traffic_fsm u_fsm (
        .clk(clk), .rst(rst), .tick(tick),
        .dens_ns(dens_ns), .dens_ew(dens_ew),
        .ns_light(ns_light), .ew_light(ew_light)
    );
endmodule