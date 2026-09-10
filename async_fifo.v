module async_fifo (
    input wclk,
    input wrst_n,
    input wr_en,
    input [7:0] din,
    output full,
    input rclk,
    input rrst_n,
    input rd_en,
    output reg [7:0] dout,
    output empty
);

    reg [7:0] mem [0:15];
    reg [4:0] wbin, wgray;
    reg [4:0] rbin, rgray;
    reg [4:0] wgray_r1, wgray_r2;
    reg [4:0] rgray_r1, rgray_r2;
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin  <= 0;
            wgray <= 0;
        end else if (wr_en && !full) begin
            mem[wbin[3:0]] <= din;
            wbin  <= wbin + 1;
            wgray <= (wbin + 1) ^ ((wbin + 1) >> 1);
        end
    end
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            rgray_r1 <= 0;
            rgray_r2 <= 0;
        end else begin
            rgray_r1 <= rgray;
            rgray_r2 <= rgray_r1;
        end
    end
    assign full = (wgray == {~rgray_r2[4:3], rgray_r2[2:0]});
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin  <= 0;
            rgray <= 0;
            dout  <= 0;
        end else if (rd_en && !empty) begin
            dout  <= mem[rbin[3:0]];
            rbin  <= rbin + 1;
            rgray <= (rbin + 1) ^ ((rbin + 1) >> 1);
        end
    end
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            wgray_r1 <= 0;
            wgray_r2 <= 0;
        end else begin
            wgray_r1 <= wgray;
            wgray_r2 <= wgray_r1;
        end
    end
    assign empty = (rgray == wgray_r2);
endmodule