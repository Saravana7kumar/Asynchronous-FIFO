`timescale 1ns/1ps

module async_fifo_tb;

    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg wr_en, rd_en;
    reg  [7:0] din;
    wire [7:0] dout;
    wire full, empty;

    async_fifo dut (
        .wclk(wclk), .wrst_n(wrst_n), .wr_en(wr_en), .din(din), .full(full),
        .rclk(rclk), .rrst_n(rrst_n), .rd_en(rd_en), .dout(dout), .empty(empty)
    );

    // two different clocks on purpose - write faster than read
    always #5  wclk = ~wclk;   // 100MHz
    always #7  rclk = ~rclk;   // ~71MHz

    initial begin
        wclk = 0; rclk = 0;
        wrst_n = 0; rrst_n = 0;
        wr_en = 0; rd_en = 0;
        din = 0;
        #20 wrst_n = 1;
        #20 rrst_n = 1;
        repeat (25) begin
            @(posedge wclk);
            if (!full) begin
                wr_en <= 1;
                din   <= din + 1;
            end else begin
                wr_en <= 0;
                $display("T=%0t WRITE side sees FULL", $time);
            end
        end
        wr_en <= 0;
        #50;
        repeat (25) begin
            @(posedge rclk);
            if (!empty) begin
                rd_en <= 1;
            end else begin
                rd_en <= 0;
                $display("T=%0t READ side sees EMPTY", $time);
            end
        end
        rd_en <= 0;
        #50;
        $display("done");
        $finish;
    end

    always @(posedge rclk)
        if (rd_en && !empty)
            $display("T=%0t read dout=%0d", $time, dout);

endmodule