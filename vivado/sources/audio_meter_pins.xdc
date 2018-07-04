set_clock_groups -asynchronous -group { clk_fpga_0 } -group { clk_out1_system_clk_wiz_0_0 }

## Pmod Header JA
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports { tx_mclk  }]; #JA[0] IO_L17P_T2_34 Sch=ja_p[1]
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports { tx_lrck  }]; #JA[1] IO_L17N_T2_34 Sch=ja_n[1]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports { tx_sclk  }]; #JA[2] IO_L7P_T1_34 Sch=ja_p[2]
set_property -dict { PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 } [get_ports { tx_sdout }]; #JA[3] IO_L7N_T1_34 Sch=ja_n[2]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { rx_mclk  }]; #JA[4] IO_L12P_T1_MRCC_34 Sch=ja_p[3]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { rx_lrck  }]; #JA[5] IO_L12N_T1_MRCC_34 Sch=ja_n[3]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports { rx_sclk  }]; #JA[6] IO_L22P_T3_34 Sch=ja_p[4]
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports { rx_sdin  }]; #JA[7] IO_L22N_T3_34 Sch=ja_n[4]

## Pmod Header JB
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports { spi_spare }]; # JB[0] IO_L8P_T1_34 Sch=jb_p[1]
set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports { spi_mosi  }]; # JB[1] IO_L8N_T1_34 Sch=jb_n[1]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { spi_sclk  }]; # JB[2] IO_L1P_T0_34 Sch=jb_p[2]
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { spi_ss0   }]; # JB[3] IO_L1N_T0_34 Sch=jb_n[2]

#set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports { row[1]   }]; # JB[0] IO_L8P_T1_34 Sch=jb_p[1]
#set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports { row[3]   }]; # JB[1] IO_L8N_T1_34 Sch=jb_n[1]
#set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { col      }]; # JB[2] IO_L1P_T0_34 Sch=jb_p[2]
#set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { latch    }]; # JB[3] IO_L1N_T0_34 Sch=jb_n[2]
#set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { row[0]   }]; # JB[4] IO_L18P_T2_34 Sch=jb_p[3]
#set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports { row[2]   }]; # JB[5] IO_L18N_T2_34 Sch=jb_n[3]
#set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { blank    }]; # JB[6] IO_L4P_T0_34 Sch=jb_p[4]
#set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports { sclk     }]; # JB[7] IO_L4N_T0_34 Sch=jb_n[4]

set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { row[1] }]; #IO_L11P_T1_SRCC_34 Sch=ck_io[0]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { row[3] }]; #IO_L3N_T0_DQS_34 Sch=ck_io[1]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { col }]; #IO_L5P_T0_34 Sch=ck_io[2]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { latch }]; #IO_L5N_T0_34 Sch=ck_io[3]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { row[0] }]; #IO_L21P_T3_DQS_34 Sch=ck_io[4]
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { row[2] }]; #IO_L21N_T3_DQS_34 Sch=ck_io[5]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { blank }]; #IO_L19N_T3_VREF_34 Sch=ck_io[6]
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { sclk }]; #IO_L6N_T0_VREF_34 Sch=ck_io[7]
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { ck_io8 }]; #IO_L13P_T2_MRCC_34 Sch=ck_io[8]
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { ck_io9 }]; #IO_L8N_T1_AD10N_35 Sch=ck_io[9]
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { ck_io10 }]; #IO_L11N_T1_SRCC_34 Sch=ck_io[10]
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { ck_io11 }]; #IO_L12N_T1_MRCC_35 Sch=ck_io[11]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { ck_io12 }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=ck_io[12]
#set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports { ck_io13 }]; #IO_L19N_T3_VREF_35 Sch=ck_io[13]
