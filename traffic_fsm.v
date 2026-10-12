`timescale 1ns / 1ps

module traffic_fsm #(
    parameter YELLOW_T = 2,
    parameter G_LOW    = 5,
    parameter G_MED    = 10,
    parameter G_HIGH   = 15
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tick,       // 1 Hz tick
    input  wire [1:0] dens_ns,    // 0 low, 1 medium, 2-3 high
    input  wire [1:0] dens_ew,
    output reg  [2:0] ns_light,   // {R, Y, G}
    output reg  [2:0] ew_light
);
    localparam NS_G = 2'd0, NS_Y = 2'd1, EW_G = 2'd2, EW_Y = 2'd3;
    localparam RED = 3'b100, YEL = 3'b010, GRN = 3'b001;

    reg [1:0] state;
    reg [4:0] timer;

    function [4:0] green_time;
        input [1:0] d;
        begin
            case (d)
                2'd0:    green_time = G_LOW;
                2'd1:    green_time = G_MED;
                default: green_time = G_HIGH;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            state <= NS_G;
            timer <= green_time(dens_ns);
        end else if (tick) begin
            if (timer <= 1) begin
                case (state)
                    NS_G: begin state <= NS_Y; timer <= YELLOW_T;            end
                    NS_Y: begin state <= EW_G; timer <= green_time(dens_ew); end
                    EW_G: begin state <= EW_Y; timer <= YELLOW_T;            end
                    EW_Y: begin state <= NS_G; timer <= green_time(dens_ns); end
                endcase
            end else
                timer <= timer - 1;
        end
    end

    always @(*) begin
        case (state)
            NS_G:    begin ns_light = GRN; ew_light = RED; end
            NS_Y:    begin ns_light = YEL; ew_light = RED; end
            EW_G:    begin ns_light = RED; ew_light = GRN; end
            default: begin ns_light = RED; ew_light = YEL; end
        endcase
    end
endmodule