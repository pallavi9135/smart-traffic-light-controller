`timescale 1ns / 1ps

module traffic_tb;

    reg        clk = 0;
    reg        rst = 1;
    reg  [1:0] dens_ns = 0;
    reg  [1:0] dens_ew = 0;
    wire       tick;
    wire [2:0] ns_light, ew_light;   // {R, Y, G}

    clk_divider #(.DIV(10)) u_div (   // chhota DIV, taaki sim tez chale
        .clk(clk), .rst(rst), .tick_1hz(tick)
    );

    traffic_fsm u_fsm (
        .clk(clk), .rst(rst), .tick(tick),
        .dens_ns(dens_ns), .dens_ew(dens_ew),
        .ns_light(ns_light), .ew_light(ew_light)
    );

    always #5 clk = ~clk;

    // Safety check: dono direction par ek saath green nahi hona chahiye
    always @(posedge clk)
        if (!rst && ns_light[0] && ew_light[0])
            $display("ERROR: both directions green at %0t", $time);

    initial begin
        $monitor("t=%0t NS=%b EW=%b dens_ns=%0d dens_ew=%0d",
                 $time, ns_light, ew_light, dens_ns, dens_ew);

        #30 rst = 0;

        // 1. Dono low traffic: green 5 s (500 ns)
        #3500;

        // 2. NS heavy, EW low: NS ka green lamba hoga
        dens_ns = 2; dens_ew = 0;
        #5000;

        // 3. NS low, EW heavy: EW ka green lamba hoga
        dens_ns = 0; dens_ew = 2;
        #5000;

        // 4. Dono medium
        dens_ns = 1; dens_ew = 1;
        #5000;

        $display("Simulation complete");
        $finish;
    end

endmodule
