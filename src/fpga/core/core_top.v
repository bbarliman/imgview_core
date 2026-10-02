// ImgView - minimal Analogue Pocket (openFPGA) core
// Shows a 160x144 RGB565 image loaded from the SD card, 1:1 (one image pixel = one Pocket pixel).
// Everything runs in the clk_74a domain; the pixel clock is clk_74a / 20 (3.7125 MHz, 60 Hz frames).
// Drop-in replacement for src/fpga/core/core_top.v of the official open-fpga/core-template.

`default_nettype none

module core_top (
input wire clk_74a,
input wire clk_74b,

inout wire [7:0] cart_tran_bank2,
output wire cart_tran_bank2_dir,
inout wire [7:0] cart_tran_bank3,
output wire cart_tran_bank3_dir,
inout wire [7:0] cart_tran_bank1,
output wire cart_tran_bank1_dir,
inout wire [7:4] cart_tran_bank0,
output wire cart_tran_bank0_dir,
inout wire cart_tran_pin30,
output wire cart_tran_pin30_dir,
output wire cart_pin30_pwroff_reset,
inout wire cart_tran_pin31,
output wire cart_tran_pin31_dir,

input wire port_ir_rx,
output wire port_ir_tx,
output wire port_ir_rx_disable,

inout wire port_tran_si,
output wire port_tran_si_dir,
inout wire port_tran_so,
output wire port_tran_so_dir,
inout wire port_tran_sck,
output wire port_tran_sck_dir,
inout wire port_tran_sd,
output wire port_tran_sd_dir,

output wire [21:16] cram0_a,
inout wire [15:0] cram0_dq,
input wire cram0_wait,
output wire cram0_clk,
output wire cram0_adv_n,
output wire cram0_cre,
output wire cram0_ce0_n,
output wire cram0_ce1_n,
output wire cram0_oe_n,
output wire cram0_we_n,
output wire cram0_ub_n,
output wire cram0_lb_n,

output wire [21:16] cram1_a,
inout wire [15:0] cram1_dq,
input wire cram1_wait,
output wire cram1_clk,
output wire cram1_adv_n,
output wire cram1_cre,
output wire cram1_ce0_n,
output wire cram1_ce1_n,
output wire cram1_oe_n,
output wire cram1_we_n,
output wire cram1_ub_n,
output wire cram1_lb_n,

output wire [12:0] dram_a,
output wire [1:0] dram_ba,
inout wire [15:0] dram_dq,
output wire [1:0] dram_dqm,
output wire dram_clk,
output wire dram_cke,
output wire dram_ras_n,
output wire dram_cas_n,
output wire dram_we_n,

output wire [16:0] sram_a,
inout wire [15:0] sram_dq,
output wire sram_oe_n,
output wire sram_we_n,
output wire sram_ub_n,
output wire sram_lb_n,

input wire vblank,

output wire dbg_tx,
input wire dbg_rx,
output wire user1,
input wire user2,

inout wire aux_sda,
output wire aux_scl,
output wire vpll_feed,

output wire [23:0] video_rgb,
output wire video_rgb_clock,
output wire video_rgb_clock_90,
output wire video_de,
output wire video_skip,
output wire video_vs,
output wire video_hs,

output wire audio_mclk,
input wire audio_adc,
output wire audio_dac,
output wire audio_lrck,

output wire bridge_endian_little,
input wire [31:0] bridge_addr,
input wire bridge_rd,
output reg [31:0] bridge_rd_data,
input wire bridge_wr,
input wire [31:0] bridge_wr_data,

input wire [31:0] cont1_key,
input wire [31:0] cont2_key,
input wire [31:0] cont3_key,
input wire [31:0] cont4_key,
input wire [31:0] cont1_joy,
input wire [31:0] cont2_joy,
input wire [31:0] cont3_joy,
input wire [31:0] cont4_joy,
input wire [15:0] cont1_trig,
input wire [15:0] cont2_trig,
input wire [15:0] cont3_trig,
input wire [15:0] cont4_trig
);

// ---------------------------------------------------------------- tie-offs
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;
assign bridge_endian_little = 0;   // big endian: first file byte arrives in bits [31:24]

assign cart_tran_bank3 = 8'hzz;  assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;  assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;  assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;   assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;   assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;
assign cart_tran_pin31 = 1'bz;   assign cart_tran_pin31_dir = 1'b0;

assign port_tran_so = 1'bz;  assign port_tran_so_dir = 1'b0;
assign port_tran_si = 1'bz;  assign port_tran_si_dir = 1'b0;
assign port_tran_sck = 1'bz; assign port_tran_sck_dir = 1'b0;
assign port_tran_sd = 1'bz;  assign port_tran_sd_dir = 1'b0;

assign cram0_a = 0; assign cram0_dq = {16{1'bZ}}; assign cram0_clk = 0; assign cram0_adv_n = 1;
assign cram0_cre = 0; assign cram0_ce0_n = 1; assign cram0_ce1_n = 1; assign cram0_oe_n = 1;
assign cram0_we_n = 1; assign cram0_ub_n = 1; assign cram0_lb_n = 1;
assign cram1_a = 0; assign cram1_dq = {16{1'bZ}}; assign cram1_clk = 0; assign cram1_adv_n = 1;
assign cram1_cre = 0; assign cram1_ce0_n = 1; assign cram1_ce1_n = 1; assign cram1_oe_n = 1;
assign cram1_we_n = 1; assign cram1_ub_n = 1; assign cram1_lb_n = 1;

assign dram_a = 0; assign dram_ba = 0; assign dram_dq = {16{1'bZ}}; assign dram_dqm = 0;
assign dram_clk = 0; assign dram_cke = 0; assign dram_ras_n = 1; assign dram_cas_n = 1; assign dram_we_n = 1;

assign sram_a = 0; assign sram_dq = {16{1'bZ}}; assign sram_oe_n = 1; assign sram_we_n = 1;
assign sram_ub_n = 1; assign sram_lb_n = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;

assign audio_mclk = 1'b0;
assign audio_dac  = 1'b0;
assign audio_lrck = 1'b0;

// ---------------------------------------------------------------- APF bridge command handler
wire reset_n;                        // driven by core_bridge_cmd (held low until the host finishes loading)
wire [31:0] cmd_bridge_rd_data;

wire status_boot_done  = 1'b1;
wire status_setup_done = 1'b1;
wire status_running    = reset_n;

wire        dataslot_requestread;
wire [15:0] dataslot_requestread_id;
wire        dataslot_requestread_ack = 1;
wire        dataslot_requestread_ok  = 1;
wire        dataslot_requestwrite;
wire [15:0] dataslot_requestwrite_id;
wire [31:0] dataslot_requestwrite_size;
wire        dataslot_requestwrite_ack = 1;
wire        dataslot_requestwrite_ok  = 1;
wire        dataslot_update;
wire [15:0] dataslot_update_id;
wire [31:0] dataslot_update_size;
wire        dataslot_allcomplete;

wire [31:0] rtc_epoch_seconds, rtc_date_bcd, rtc_time_bcd;
wire        rtc_valid;

wire        savestate_supported = 0;
wire [31:0] savestate_addr = 0, savestate_size = 0, savestate_maxloadsize = 0;
wire        savestate_start;
wire        savestate_start_ack = 0, savestate_start_busy = 0, savestate_start_ok = 0, savestate_start_err = 0;
wire        savestate_load;
wire        savestate_load_ack = 0, savestate_load_busy = 0, savestate_load_ok = 0, savestate_load_err = 0;

wire        osnotify_inmenu;

wire        target_dataslot_read = 0, target_dataslot_write = 0;
wire        target_dataslot_getfile = 0, target_dataslot_openfile = 0;
wire        target_dataslot_ack, target_dataslot_done;
wire [2:0]  target_dataslot_err;
wire [15:0] target_dataslot_id = 0;
wire [31:0] target_dataslot_slotoffset = 0, target_dataslot_bridgeaddr = 0, target_dataslot_length = 0;
wire [31:0] target_buffer_param_struct = 0;
wire [31:0] target_buffer_resp_struct;

wire [9:0]  datatable_addr = 0;
wire        datatable_wren = 0;
wire [31:0] datatable_data = 0;
wire [31:0] datatable_q;

core_bridge_cmd icb (
    .clk                        (clk_74a),
    .reset_n                    (reset_n),

    .bridge_endian_little       (bridge_endian_little),
    .bridge_addr                (bridge_addr),
    .bridge_rd                  (bridge_rd),
    .bridge_rd_data             (cmd_bridge_rd_data),
    .bridge_wr                  (bridge_wr),
    .bridge_wr_data             (bridge_wr_data),

    .status_boot_done           (status_boot_done),
    .status_setup_done          (status_setup_done),
    .status_running             (status_running),

    .dataslot_requestread       (dataslot_requestread),
    .dataslot_requestread_id    (dataslot_requestread_id),
    .dataslot_requestread_ack   (dataslot_requestread_ack),
    .dataslot_requestread_ok    (dataslot_requestread_ok),

    .dataslot_requestwrite      (dataslot_requestwrite),
    .dataslot_requestwrite_id   (dataslot_requestwrite_id),
    .dataslot_requestwrite_size (dataslot_requestwrite_size),
    .dataslot_requestwrite_ack  (dataslot_requestwrite_ack),
    .dataslot_requestwrite_ok   (dataslot_requestwrite_ok),

    .dataslot_update            (dataslot_update),
    .dataslot_update_id         (dataslot_update_id),
    .dataslot_update_size       (dataslot_update_size),

    .dataslot_allcomplete       (dataslot_allcomplete),

    .rtc_epoch_seconds          (rtc_epoch_seconds),
    .rtc_date_bcd               (rtc_date_bcd),
    .rtc_time_bcd               (rtc_time_bcd),
    .rtc_valid                  (rtc_valid),

    .savestate_supported        (savestate_supported),
    .savestate_addr             (savestate_addr),
    .savestate_size             (savestate_size),
    .savestate_maxloadsize      (savestate_maxloadsize),

    .savestate_start            (savestate_start),
    .savestate_start_ack        (savestate_start_ack),
    .savestate_start_busy       (savestate_start_busy),
    .savestate_start_ok         (savestate_start_ok),
    .savestate_start_err        (savestate_start_err),

    .savestate_load             (savestate_load),
    .savestate_load_ack         (savestate_load_ack),
    .savestate_load_busy        (savestate_load_busy),
    .savestate_load_ok          (savestate_load_ok),
    .savestate_load_err         (savestate_load_err),

    .osnotify_inmenu            (osnotify_inmenu),

    .target_dataslot_read       (target_dataslot_read),
    .target_dataslot_write      (target_dataslot_write),
    .target_dataslot_getfile    (target_dataslot_getfile),
    .target_dataslot_openfile   (target_dataslot_openfile),

    .target_dataslot_ack        (target_dataslot_ack),
    .target_dataslot_done       (target_dataslot_done),
    .target_dataslot_err        (target_dataslot_err),

    .target_dataslot_id         (target_dataslot_id),
    .target_dataslot_slotoffset (target_dataslot_slotoffset),
    .target_dataslot_bridgeaddr (target_dataslot_bridgeaddr),
    .target_dataslot_length     (target_dataslot_length),

    .target_buffer_param_struct (target_buffer_param_struct),
    .target_buffer_resp_struct  (target_buffer_resp_struct),

    .datatable_addr             (datatable_addr),
    .datatable_wren             (datatable_wren),
    .datatable_data             (datatable_data),
    .datatable_q                (datatable_q)
);

// bridge read mux (only the command handler is readable)
always @(*) begin
    case (bridge_addr[31:24])
        8'hF8:   bridge_rd_data = cmd_bridge_rd_data;
        default: bridge_rd_data = 32'h0;
    endcase
end

// ---------------------------------------------------------------- image RAM (160*144*2 = 46080 bytes)
// Data slot 0 is mapped to bridge address 0x10000000 (see data.json).
(* ramstyle = "M10K" *) reg [31:0] img_mem [0:16383];
reg [31:0] img_q;

wire img_wr = bridge_wr && (bridge_addr[31:24] == 8'h10);
always @(posedge clk_74a) begin
    if (img_wr) img_mem[bridge_addr[15:2]] <= bridge_wr_data;
end

// ---------------------------------------------------------------- video timing (clk_74a / 20 pixel clock)
localparam H_TOTAL = 225, V_TOTAL = 275;   // 74.25e6 / 20 / (225*275) = 60.0 Hz
localparam H_ACT = 160, V_ACT = 144;
localparam H_OFF = 10,  V_OFF = 10;

reg [4:0] c = 0;          // phase inside a pixel period
reg [7:0] x = 0;
reg [8:0] y = 0;

reg vclk = 0, vclk90 = 0;
reg [23:0] vrgb = 0;
reg vde = 0, vhs = 0, vvs = 0;

wire tick   = (c == 5'd0);
wire active = (x >= H_OFF) && (x < H_OFF + H_ACT) && (y >= V_OFF) && (y < V_OFF + V_ACT);

wire [7:0]  xa  = x - H_OFF;
wire [7:0]  ya  = y[7:0] - V_OFF;
wire [14:0] idx = {ya, 7'b0} + {2'b0, ya, 5'b0} + {7'b0, xa};   // ya*160 + xa

// RAM read: address is stable for 20 clocks, so the registered output is always valid at the next tick
always @(posedge clk_74a) img_q <= img_mem[idx[14:1]];

wire [15:0] pix = idx[0] ? img_q[15:0] : img_q[31:16];          // RGB565, big endian
wire [7:0] r8 = {pix[15:11], pix[15:13]};
wire [7:0] g8 = {pix[10:5],  pix[10:9]};
wire [7:0] b8 = {pix[4:0],   pix[4:2]};

always @(posedge clk_74a) begin
    c      <= (c == 5'd19) ? 5'd0 : c + 5'd1;
    vclk   <= (c < 5'd10);                          // rises together with new pixel data
    vclk90 <= (c >= 5'd5) && (c < 5'd15);          // 90 degrees later

    if (tick) begin
        vde  <= active;
        vrgb <= active ? {r8, g8, b8} : 24'h000000;
        vhs  <= (x == 0);
        vvs  <= (x == 0) && (y == 0);

        if (x == H_TOTAL - 1) begin
            x <= 0;
            y <= (y == V_TOTAL - 1) ? 9'd0 : y + 9'd1;
        end else begin
            x <= x + 8'd1;
        end
    end
end

assign video_rgb          = vrgb;
assign video_rgb_clock    = vclk;
assign video_rgb_clock_90 = vclk90;
assign video_de           = vde;
assign video_hs           = vhs;
assign video_vs           = vvs;
assign video_skip         = 1'b0;

endmodule
