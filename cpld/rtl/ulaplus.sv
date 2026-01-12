import common::*;
module ulaplus(
    input rst_n,
    input clk28,
    input en,

    cpu_bus bus,
    output [7:0] d_out,
    output d_out_active,

    output reg active,
    output reg read_req,
    output reg write_req,
    output [5:0] rw_addr,
    output reg [5:0] timex_mode,
    output reg suspend_multicolor,
    input magic_map
);


wire port_bf3b_cs = en && bus.ioreq && bus.a == 16'hBF3B;
wire port_ff3b_cs = en && bus.ioreq && bus.a == 16'hFF3B;
reg port_ff3b_rd;
wire [7:0] port_ff3b_data = {7'b0000000, active};
reg [7:0] addr_reg;
assign rw_addr = addr_reg[5:0];

//shadowing timex mode from timex FF register write, is active even without UP enabled
// unfortunatelly Sizif Magic menu uses lower-bytes FF port for its own purposes
// note, that higher address bites should not be decoded
wire port_ff_cs = !magic_map && bus.ioreq && bus.a[7:0] == 8'hFF;
// as well as 9ffd (eLeMeNt ZX)
wire port_9ffd_cs = bus.ioreq && bus.a[15:0] == 16'h9FFD;
reg port_9ffd_rd;
// 16 color mode is activated by Pentagon port for "hardware multicolor"
wire port_EFF7_cs = bus.ioreq && bus.a[15:0] == 16'hEFF7;

wire mode_switching_data = bus.d[7:6] == 2'b01 && bus.d[5:0] != 6'b00000;
always @(posedge clk28 or negedge rst_n) begin
    if (!rst_n) begin
        active <= 0;
        addr_reg <= 0;
        read_req <= 0;
        write_req <= 0;
        port_ff3b_rd <= 0;
        timex_mode <= 0;
        suspend_multicolor <= 0;
    end
    else begin
        // 01 and all zeros are used to enable ULA+ pallete,
        // it would also disable timex mode, so exclude it!  
        if (port_bf3b_cs && bus.wr) begin
            addr_reg <= bus.d;
            if (mode_switching_data) begin
                // some forbidden timex states are used to swith screen 5 to 7 like in spectrum 128
                timex_mode[0] <= bus.d[0] & ~bus.d[1];
                // timex FF port bit [1] must be turn on both in hiColor and in hiRes
                timex_mode[1] <= bus.d[1];
                timex_mode[2] <= bus.d[1] & bus.d[2];
                timex_mode[5:3] <= bus.d[5:3];
                suspend_multicolor <= 0;
                // should be forced from here
                //uplus_video_page <= bus.d[2] & ~bus.d[1] & ~bus.d[0];
            end
        end
        if ((port_ff_cs || port_9ffd_cs) && bus.wr) begin
            timex_mode <= bus.d[5:0];
            suspend_multicolor <= 0;
        end
        if (port_EFF7_cs && bus.wr && bus.d[0]) begin
            timex_mode <= 6'b111000;
            suspend_multicolor <= 0;
        end
        if (port_ff3b_cs && bus.wr && addr_reg == 8'b01000000) begin
            active <= bus.d[0];
            suspend_multicolor <= ~active;
        end

        read_req  <= port_ff3b_cs && bus.rd && addr_reg[7:6] == 2'b00;
        write_req <= port_ff3b_cs && bus.wr && addr_reg[7:6] == 2'b00;
        port_ff3b_rd <= port_ff3b_cs && bus.rd;
        port_9ffd_rd <= port_9ffd_cs && bus.rd;

        if (!en)
            active <= 0;
    end
end


assign d_out = port_ff3b_rd ? 
        port_ff3b_data :
        {2'b00, timex_mode[5:0]} ;
assign d_out_active = port_ff3b_rd || port_9ffd_rd;

endmodule
