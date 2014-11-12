
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module syn_moksha(

  //////////// CLOCK //////////
  CLOCK_125_p,
  CLOCK_50_B5B,
  CLOCK_50_B6A,
  CLOCK_50_B7A,
  CLOCK_50_B8A,

  //////////// LED //////////
  LEDG,
  LEDR,

  //////////// KEY //////////
  CPU_RESET_n,
  KEY,

  //////////// SW //////////
  SW,

  //////////// SEG7 //////////
  HEX0,
  HEX1,
  HEX2,
  HEX3,

  //////////// HDMI-TX //////////
  HDMI_TX_CLK,
  HDMI_TX_D,
  HDMI_TX_DE,
  HDMI_TX_HS,
  HDMI_TX_INT,
  HDMI_TX_VS,

  //////////// Audio //////////
  AUD_ADCDAT,
  AUD_ADCLRCK,
  AUD_BCLK,
  AUD_DACDAT,
  AUD_DACLRCK,
  AUD_XCK,

  //////////// I2C for Audio/HDMI-TX/Si5338/HSMC //////////
  I2C_SCL,
  I2C_SDA,

  //////////// Uart to USB //////////
  UART_RX,
  UART_TX,

  //////////// SRAM //////////
  SRAM_A,
  SRAM_CE_n,
  SRAM_D,
  SRAM_LB_n,
  SRAM_OE_n,
  SRAM_UB_n,
  SRAM_WE_n,

  //////////// LPDDR2 //////////
  DDR2LP_CA,
  DDR2LP_CK_n,
  DDR2LP_CK_p,
  DDR2LP_CKE,
  DDR2LP_CS_n,
  DDR2LP_DM,
  DDR2LP_DQ,
  DDR2LP_DQS_n,
  DDR2LP_DQS_p,
  DDR2LP_OCT_RZQ 
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input             CLOCK_125_p;
input             CLOCK_50_B5B;
input             CLOCK_50_B6A;
input             CLOCK_50_B7A;
input             CLOCK_50_B8A;

//////////// LED //////////
output     [7:0]  LEDG;
output     [9:0]  LEDR;

//////////// KEY //////////
input             CPU_RESET_n;
input      [3:0]  KEY;

//////////// SW //////////
input      [9:0]  SW;

//////////// SEG7 //////////
output     [6:0]  HEX0;
output     [6:0]  HEX1;
output     [6:0]  HEX2;
output     [6:0]  HEX3;

//////////// HDMI-TX //////////
output            HDMI_TX_CLK;
output    [23:0]  HDMI_TX_D;
output            HDMI_TX_DE;
output            HDMI_TX_HS;
input             HDMI_TX_INT;
output            HDMI_TX_VS;

//////////// Audio //////////
input             AUD_ADCDAT;
output            AUD_ADCLRCK;
output            AUD_BCLK;
output            AUD_DACDAT;
output            AUD_DACLRCK;
output            AUD_XCK;

//////////// I2C for Audio/HDMI-TX/Si5338/HSMC //////////
output            I2C_SCL;
inout             I2C_SDA;

//////////// Uart to USB //////////
input             UART_RX;
output            UART_TX;

//////////// SRAM //////////
output    [17:0]  SRAM_A;
output            SRAM_CE_n;
inout     [15:0]  SRAM_D;
output            SRAM_LB_n;
output            SRAM_OE_n;
output            SRAM_UB_n;
output            SRAM_WE_n;

//////////// LPDDR2 //////////
output     [9:0]  DDR2LP_CA;
output            DDR2LP_CK_n;
output            DDR2LP_CK_p;
output     [1:0]  DDR2LP_CKE;
output     [1:0]  DDR2LP_CS_n;
output     [3:0]  DDR2LP_DM;
inout     [31:0]  DDR2LP_DQ;
inout      [3:0]  DDR2LP_DQS_n;
inout      [3:0]  DDR2LP_DQS_p;
input             DDR2LP_OCT_RZQ;


//=======================================================
//  REG/WIRE declarations
//=======================================================

wire              sys_clk_100,sys_clk_24,sys_clk_12;
wire              sys_rst_n;

wire              cortex_clk;
wire              cortex_rst_n;

wire              sram_addr_dummy;
wire  [1:0]       cortex_lb_addr_dummy;

wire              cortex_lb_wr_en;
wire              cortex_lb_rd_en;
wire  [15:0]      cortex_lb_addr;
wire  [31:0]      cortex_lb_wr_data;
wire              cortex_lb_wr_valid;
wire              cortex_lb_rd_valid;
wire  [31:0]      cortex_lb_rd_data;

wire  [1:0]       mclk_vec;

//=======================================================
//  Structural coding
//=======================================================


  /*  Sys PLL */
  sys_pll sys_pll_inst  (
    /*  input  wire */  .refclk(CLOCK_50_B5B),
    /*  input  wire */  .rst(KEY[0]),
    /*  output wire */  .outclk_0(sys_clk_100),
    /*  output wire */  .outclk_1(sys_clk_12),
    /*  output wire */  .outclk_2(sys_clk_24),
    /*  output wire */  .locked(sys_rst_n)
  );


  /*  Limbus  */
  limbus  limbus_inst (
    /*  input  wire         */  .clk_clk(sys_clk_100),
    /*  input  wire         */  .reset_reset_n(sys_rst_n),

    /*  output wire [0:0]   */  .sram_bridge_sram_cntrlr_tcm_chipselect_n_out(SRAM_CE_n),
    /*  output wire [1:0]   */  .sram_bridge_sram_cntrlr_tcm_byteenable_n_out({SRAM_UB_n,SRAM_LB_n}),
    /*  output wire [18:0]  */  .sram_bridge_sram_cntrlr_tcm_address_out({SRAM_A,sram_addr_dummy}),
    /*  output wire [0:0]   */  .sram_bridge_sram_cntrlr_tcm_write_n_out(SRAM_WE_n),
    /*  inout  wire [15:0]  */  .sram_bridge_sram_cntrlr_tcm_data_out(SRAM_D),
    /*  output wire [0:0]   */  .sram_bridge_sram_cntrlr_tcm_outputenable_n_out(SRAM_OE_n),

    /*  input  wire         */  .uart_0_rxd(UART_RX),
    /*  output wire         */  .uart_0_txd(UART_TX),

    /*  output wire [17:0]  */  .cortex_s_address({cortex_lb_addr,cortex_lb_addr_dummy}),
    /*  output wire         */  .cortex_s_read(cortex_lb_rd_en),
    /*  input  wire [31:0]  */  .cortex_s_readdata(cortex_lb_rd_data),
    /*  output wire         */  .cortex_s_write(cortex_lb_wr_en),
    /*  output wire [31:0]  */  .cortex_s_writedata(cortex_lb_wr_data),
    /*  input  wire         */  .cortex_s_readdatavalid(cortex_lb_rd_valid),

    /*  output wire         */  .cortex_reset_reset(cortex_rst_n),

    /*  input  wire         */  .cortex_irq_irq(0)
  );


  /*  Cortex  */
  assign  cortex_clk    =   sys_clk_100;

  assign  mclk_vec      =   {sys_clk_24,sys_clk_12};

  cortex #(
    //----------------- Parameters  -----------------------
    .LB_DATA_W         (32),
    .LB_ADDR_W         (16),
    .LB_ADDR_BLK_W     (4),
    .NUM_MCLKS         (2),
    .NUM_AUD_SAMPLES   (128),
    .DEFAULT_DATA_VAL  ('hdeadbabe)

  ) cortex_inst (

    //--------------------- Ports -------------------------
      /*  input                   */  .clk(cortex_clk),
      /*  input                   */  .rst_n(cortex_rst_n),

      /*  input                   */  .lb_wr_en(cortex_lb_wr_en),
      /*  input                   */  .lb_rd_en(cortex_lb_rd_en),
      /*  input   [LB_ADDR_W-1:0] */  .lb_addr(cortex_lb_addr),
      /*  input   [LB_DATA_W-1:0] */  .lb_wr_data(cortex_lb_wr_data),
      /*  output                  */  .lb_wr_valid(cortex_lb_wr_valid),
      /*  output                  */  .lb_rd_valid(cortex_lb_rd_valid),
      /*  output  [LB_DATA_W-1:0] */  .lb_rd_data(cortex_lb_rd_data),

      /*  input   [NUM_MCLKS-1:0] */  .mclk_vec(mclk_vec),

      /*  output                  */  .scl(I2C_SCL),
      /*  inout                   */  .sda(I2C_SDA),

      /*  input                   */  .AUD_ADCDAT(AUD_ADCDAT),
      /*  output                  */  .AUD_ADCLRCK(AUD_ADCLRCK),
      /*  output                  */  .AUD_BCLK(AUD_BCLK),
      /*  output                  */  .AUD_DACDAT(AUD_DACDAT),
      /*  output                  */  .AUD_DACLRCK(AUD_DACLRCK),
      /*  output                  */  .AUD_XCK(AUD_XCK)

  );


  /*  LED Assignments */
  assign  LEDG[0]   = ~sys_rst_n;
  assign  LEDG[1]   = ~cortex_rst_n;
  assign  LEDG[7:2] = 0;

  assign  LEDR[9:0] = 0;

endmodule
