#ChipScope Core Inserter Project File Version 3.0
#Tue Dec 02 17:18:47 HST 2014
Project.device.designInputFile=C\:\\Users\\isar\\Documents\\code4\\TX9UMB-3\\ise-project\\scrod_top_A4.ngc
Project.device.designOutputFile=C\:\\Users\\isar\\Documents\\code4\\TX9UMB-3\\ise-project\\scrod_top_A4_csp.ngc
Project.device.deviceFamily=18
Project.device.enableRPMs=true
Project.device.outputDirectory=C\:\\Users\\isar\\Documents\\code4\\TX9UMB-3\\ise-project\\_ngo
Project.device.useSRL16=true
Project.filter.dimension=19
Project.filter<0>=psw*
Project.filter<10>=dmx_win*
Project.filter<11>=dmx2_win*
Project.filter<12>=dmx_win
Project.filter<13>=internal*
Project.filter<14>=readout*
Project.filter<15>=*
Project.filter<16>=jdx*
Project.filter<17>=internal_srout*
Project.filter<18>=wavarray*
Project.filter<1>=
Project.filter<2>=dmx_bit*
Project.filter<3>=fifo_din_i2*
Project.filter<4>=fifo_en*
Project.filter<5>=fifo_din*
Project.filter<6>=fifo_din_i*
Project.filter<7>=fifo*
Project.filter<8>=fifo
Project.filter<9>=dmx_*
Project.icon.boundaryScanChain=1
Project.icon.enableExtTriggerIn=false
Project.icon.enableExtTriggerOut=false
Project.icon.triggerInPinName=
Project.icon.triggerOutPinName=
Project.unit.dimension=1
Project.unit<0>.clockChannel=map_clock_gen CLOCK_FPGA_LOGIC
Project.unit<0>.clockEdge=Rising
Project.unit<0>.dataChannel<0>=u_SamplingLgc sstin
Project.unit<0>.dataChannel<100>=internal_SROUT_FIFO_DATA_OUT<4>
Project.unit<0>.dataChannel<101>=internal_SROUT_FIFO_DATA_OUT<3>
Project.unit<0>.dataChannel<102>=internal_SROUT_FIFO_DATA_OUT<2>
Project.unit<0>.dataChannel<103>=internal_SROUT_FIFO_DATA_OUT<1>
Project.unit<0>.dataChannel<104>=internal_SROUT_FIFO_DATA_OUT<0>
Project.unit<0>.dataChannel<105>=Inst_WaveformDemuxCalcPedsBRAM win_addr_start<0>
Project.unit<0>.dataChannel<106>=Inst_WaveformDemuxCalcPedsBRAM ped_sa_update
Project.unit<0>.dataChannel<107>=Inst_WaveformDemuxCalcPedsBRAM ram_busy
Project.unit<0>.dataChannel<108>=Inst_WaveformDemuxCalcPedsBRAM ram_update
Project.unit<0>.dataChannel<109>=u_wavedemux st_tmp2bram_FSM_FFd1
Project.unit<0>.dataChannel<10>=u_SamplingLgc wr_addrclr
Project.unit<0>.dataChannel<110>=u_wavedemux st_tmp2bram_FSM_FFd2
Project.unit<0>.dataChannel<111>=u_wavedemux ped_win<1>
Project.unit<0>.dataChannel<112>=u_wavedemux ped_win<2>
Project.unit<0>.dataChannel<113>=u_wavedemux dmx_allwin_busy
Project.unit<0>.dataChannel<114>=u_ReadoutControl internal_LATCH_DONE
Project.unit<0>.dataChannel<115>=u_ReadoutControl DIG_IDLE_status
Project.unit<0>.dataChannel<116>=u_ReadoutControl SROUT_IDLE_status
Project.unit<0>.dataChannel<117>=u_ReadoutControl trigger
Project.unit<0>.dataChannel<118>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<8>
Project.unit<0>.dataChannel<119>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<7>
Project.unit<0>.dataChannel<11>=u_wavedemux dmx_wav_0<11>
Project.unit<0>.dataChannel<120>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<6>
Project.unit<0>.dataChannel<121>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<5>
Project.unit<0>.dataChannel<122>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<4>
Project.unit<0>.dataChannel<123>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<3>
Project.unit<0>.dataChannel<124>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<2>
Project.unit<0>.dataChannel<125>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<1>
Project.unit<0>.dataChannel<126>=u_ReadoutControl internal_LATCH_SMP_MAIN_CNT<0>
Project.unit<0>.dataChannel<127>=u_DigitizingLgc StartDig
Project.unit<0>.dataChannel<128>=u_DigitizingLgc clr_out
Project.unit<0>.dataChannel<129>=u_DigitizingLgc rd_ena_out
Project.unit<0>.dataChannel<12>=u_wavedemux dmx_wav_0<10>
Project.unit<0>.dataChannel<130>=u_DigitizingLgc startramp_out
Project.unit<0>.dataChannel<131>=uut_pedram update_req<2>
Project.unit<0>.dataChannel<132>=uut_pedram update_req<0>
Project.unit<0>.dataChannel<133>=uut_pedram busy<2>
Project.unit<0>.dataChannel<134>=uut_pedram busy<0>
Project.unit<0>.dataChannel<135>=uut_pedram ram_wait_i_2
Project.unit<0>.dataChannel<136>=uut_pedram ram_wait_i_0
Project.unit<0>.dataChannel<137>=u_wavedemux ram_update
Project.unit<0>.dataChannel<138>=u_wavedemux ram_busy
Project.unit<0>.dataChannel<139>=u_DigitizingLgc rd_ena_out
Project.unit<0>.dataChannel<13>=u_wavedemux dmx_wav_0<9>
Project.unit<0>.dataChannel<140>=u_wavedemux pswfifo_en
Project.unit<0>.dataChannel<141>=u_wavedemux pswfifo_d<27>
Project.unit<0>.dataChannel<142>=u_wavedemux pswfifo_d<26>
Project.unit<0>.dataChannel<143>=u_wavedemux pswfifo_d<25>
Project.unit<0>.dataChannel<144>=u_wavedemux pswfifo_d<24>
Project.unit<0>.dataChannel<145>=u_wavedemux pswfifo_d<23>
Project.unit<0>.dataChannel<146>=u_wavedemux pswfifo_d<22>
Project.unit<0>.dataChannel<147>=u_wavedemux pswfifo_d<21>
Project.unit<0>.dataChannel<148>=u_wavedemux pswfifo_d<20>
Project.unit<0>.dataChannel<149>=u_wavedemux pswfifo_d<19>
Project.unit<0>.dataChannel<14>=u_wavedemux dmx_wav_0<8>
Project.unit<0>.dataChannel<150>=u_wavedemux pswfifo_d<18>
Project.unit<0>.dataChannel<151>=u_wavedemux pswfifo_d<17>
Project.unit<0>.dataChannel<152>=u_wavedemux pswfifo_d<16>
Project.unit<0>.dataChannel<153>=u_wavedemux pswfifo_d<15>
Project.unit<0>.dataChannel<154>=u_wavedemux pswfifo_d<14>
Project.unit<0>.dataChannel<155>=u_wavedemux pswfifo_d<13>
Project.unit<0>.dataChannel<156>=u_wavedemux pswfifo_d<12>
Project.unit<0>.dataChannel<157>=u_wavedemux pswfifo_d<11>
Project.unit<0>.dataChannel<158>=u_wavedemux pswfifo_d<10>
Project.unit<0>.dataChannel<159>=u_wavedemux pswfifo_d<9>
Project.unit<0>.dataChannel<15>=u_wavedemux dmx_wav_0<7>
Project.unit<0>.dataChannel<160>=u_wavedemux pswfifo_d<8>
Project.unit<0>.dataChannel<161>=u_wavedemux pswfifo_d<7>
Project.unit<0>.dataChannel<162>=u_wavedemux pswfifo_d<6>
Project.unit<0>.dataChannel<163>=u_wavedemux pswfifo_d<5>
Project.unit<0>.dataChannel<164>=u_wavedemux pswfifo_d<4>
Project.unit<0>.dataChannel<165>=u_wavedemux pswfifo_d<3>
Project.unit<0>.dataChannel<166>=u_wavedemux pswfifo_d<2>
Project.unit<0>.dataChannel<167>=u_wavedemux pswfifo_d<1>
Project.unit<0>.dataChannel<168>=u_wavedemux pswfifo_d<0>
Project.unit<0>.dataChannel<169>=u_wavedemux pswfifo_en
Project.unit<0>.dataChannel<16>=u_wavedemux dmx_wav_0<6>
Project.unit<0>.dataChannel<170>=u_wavedemux wav_bram_addra<5>
Project.unit<0>.dataChannel<171>=u_wavedemux wav_bram_addra<6>
Project.unit<0>.dataChannel<172>=u_wavedemux wav_bram_addra<7>
Project.unit<0>.dataChannel<173>=u_wavedemux wav_bram_addra<8>
Project.unit<0>.dataChannel<174>=u_wavedemux wav_bram_addra<9>
Project.unit<0>.dataChannel<175>=u_wavedemux wav_bram_addra<10>
Project.unit<0>.dataChannel<176>=u_wavedemux wav_bram_addrb<0>
Project.unit<0>.dataChannel<177>=u_wavedemux wav_bram_addrb<1>
Project.unit<0>.dataChannel<178>=u_wavedemux wav_bram_addrb<2>
Project.unit<0>.dataChannel<179>=u_wavedemux wav_bram_addrb<3>
Project.unit<0>.dataChannel<17>=u_wavedemux dmx_wav_0<5>
Project.unit<0>.dataChannel<180>=u_wavedemux wav_bram_addrb<4>
Project.unit<0>.dataChannel<181>=u_wavedemux wav_bram_addrb<5>
Project.unit<0>.dataChannel<182>=u_wavedemux wav_bram_addrb<6>
Project.unit<0>.dataChannel<183>=u_wavedemux wav_bram_addrb<7>
Project.unit<0>.dataChannel<184>=u_wavedemux wav_bram_addrb<8>
Project.unit<0>.dataChannel<185>=u_wavedemux wav_bram_addrb<9>
Project.unit<0>.dataChannel<186>=u_wavedemux wav_bram_addrb<10>
Project.unit<0>.dataChannel<187>=u_wavedemux ped_bram_addra<0>
Project.unit<0>.dataChannel<188>=u_wavedemux ped_bram_addra<1>
Project.unit<0>.dataChannel<189>=u_wavedemux ped_bram_addra<2>
Project.unit<0>.dataChannel<18>=u_wavedemux dmx_wav_0<4>
Project.unit<0>.dataChannel<190>=u_wavedemux ped_bram_addra<3>
Project.unit<0>.dataChannel<191>=u_wavedemux ped_bram_addra<4>
Project.unit<0>.dataChannel<192>=u_wavedemux ped_bram_addra<5>
Project.unit<0>.dataChannel<193>=u_wavedemux ped_bram_addra<6>
Project.unit<0>.dataChannel<194>=u_wavedemux ped_bram_addra<7>
Project.unit<0>.dataChannel<195>=u_wavedemux ped_bram_addra<8>
Project.unit<0>.dataChannel<196>=u_wavedemux ped_bram_addra<9>
Project.unit<0>.dataChannel<197>=u_wavedemux ped_bram_addra<10>
Project.unit<0>.dataChannel<198>=u_wavedemux ped_sub_fetch_busy
Project.unit<0>.dataChannel<199>=u_wavedemux wav_dina<0>
Project.unit<0>.dataChannel<19>=u_wavedemux dmx_wav_0<3>
Project.unit<0>.dataChannel<1>=u_SamplingLgc MAIN_CNT<8>
Project.unit<0>.dataChannel<200>=u_wavedemux wav_dina<1>
Project.unit<0>.dataChannel<201>=u_wavedemux wav_dina<2>
Project.unit<0>.dataChannel<202>=u_wavedemux wav_dina<3>
Project.unit<0>.dataChannel<203>=u_wavedemux wav_dina<4>
Project.unit<0>.dataChannel<204>=u_wavedemux wav_dina<5>
Project.unit<0>.dataChannel<205>=u_wavedemux wav_dina<6>
Project.unit<0>.dataChannel<206>=u_wavedemux wav_dina<7>
Project.unit<0>.dataChannel<207>=u_wavedemux wav_dina<8>
Project.unit<0>.dataChannel<208>=u_wavedemux wav_dina<9>
Project.unit<0>.dataChannel<209>=u_wavedemux wav_dina<10>
Project.unit<0>.dataChannel<20>=u_wavedemux dmx_wav_0<2>
Project.unit<0>.dataChannel<210>=u_wavedemux wav_dina<11>
Project.unit<0>.dataChannel<211>=u_wavedemux wav_doutb<0>
Project.unit<0>.dataChannel<212>=u_wavedemux wav_doutb<1>
Project.unit<0>.dataChannel<213>=u_wavedemux wav_doutb<2>
Project.unit<0>.dataChannel<214>=u_wavedemux wav_doutb<3>
Project.unit<0>.dataChannel<215>=u_wavedemux wav_doutb<4>
Project.unit<0>.dataChannel<216>=u_wavedemux wav_doutb<5>
Project.unit<0>.dataChannel<217>=u_wavedemux wav_doutb<6>
Project.unit<0>.dataChannel<218>=u_wavedemux wav_doutb<7>
Project.unit<0>.dataChannel<219>=u_wavedemux wav_doutb<8>
Project.unit<0>.dataChannel<21>=u_wavedemux dmx_wav_0<1>
Project.unit<0>.dataChannel<220>=u_wavedemux wav_doutb<9>
Project.unit<0>.dataChannel<221>=u_wavedemux wav_doutb<10>
Project.unit<0>.dataChannel<222>=u_wavedemux wav_doutb<11>
Project.unit<0>.dataChannel<223>=u_wavedemux ped_bram_addra<0>
Project.unit<0>.dataChannel<224>=u_wavedemux ped_bram_addra<1>
Project.unit<0>.dataChannel<225>=u_wavedemux ped_bram_addra<2>
Project.unit<0>.dataChannel<226>=u_wavedemux ped_bram_addra<3>
Project.unit<0>.dataChannel<227>=u_wavedemux ped_bram_addra<4>
Project.unit<0>.dataChannel<228>=u_wavedemux ped_bram_addra<5>
Project.unit<0>.dataChannel<229>=u_wavedemux ped_bram_addra<6>
Project.unit<0>.dataChannel<22>=u_wavedemux dmx_wav_0<0>
Project.unit<0>.dataChannel<230>=u_wavedemux ped_bram_addra<7>
Project.unit<0>.dataChannel<231>=u_wavedemux ped_bram_addra<8>
Project.unit<0>.dataChannel<232>=u_wavedemux ped_bram_addra<9>
Project.unit<0>.dataChannel<233>=u_wavedemux ped_bram_addra<10>
Project.unit<0>.dataChannel<234>=u_wavedemux ped_dina<0>
Project.unit<0>.dataChannel<235>=u_wavedemux ped_dina<1>
Project.unit<0>.dataChannel<236>=u_wavedemux ped_dina<2>
Project.unit<0>.dataChannel<237>=u_wavedemux ped_dina<3>
Project.unit<0>.dataChannel<238>=u_wavedemux ped_dina<4>
Project.unit<0>.dataChannel<239>=u_wavedemux ped_dina<5>
Project.unit<0>.dataChannel<23>=u_wavedemux dmx_wav_15<11>
Project.unit<0>.dataChannel<240>=u_wavedemux ped_dina<6>
Project.unit<0>.dataChannel<241>=u_wavedemux ped_dina<7>
Project.unit<0>.dataChannel<242>=u_wavedemux ped_dina<8>
Project.unit<0>.dataChannel<243>=u_wavedemux ped_dina<9>
Project.unit<0>.dataChannel<244>=u_wavedemux ped_dina<10>
Project.unit<0>.dataChannel<245>=u_wavedemux ped_dina<11>
Project.unit<0>.dataChannel<246>=u_wavedemux ped_doutb<0>
Project.unit<0>.dataChannel<247>=u_wavedemux ped_doutb<1>
Project.unit<0>.dataChannel<248>=u_wavedemux ped_doutb<2>
Project.unit<0>.dataChannel<249>=u_wavedemux ped_doutb<3>
Project.unit<0>.dataChannel<24>=u_wavedemux dmx_wav_15<10>
Project.unit<0>.dataChannel<250>=u_wavedemux ped_doutb<4>
Project.unit<0>.dataChannel<251>=u_wavedemux ped_doutb<5>
Project.unit<0>.dataChannel<252>=u_wavedemux ped_doutb<6>
Project.unit<0>.dataChannel<253>=u_wavedemux ped_doutb<7>
Project.unit<0>.dataChannel<254>=u_wavedemux ped_doutb<8>
Project.unit<0>.dataChannel<255>=u_wavedemux ped_doutb<9>
Project.unit<0>.dataChannel<256>=u_wavedemux ped_doutb<10>
Project.unit<0>.dataChannel<257>=u_wavedemux ped_doutb<11>
Project.unit<0>.dataChannel<258>=u_wavedemux tmp2bram_ctr<4>
Project.unit<0>.dataChannel<259>=u_wavedemux tmp2bram_ctr<3>
Project.unit<0>.dataChannel<25>=u_wavedemux dmx_wav_15<9>
Project.unit<0>.dataChannel<260>=u_wavedemux tmp2bram_ctr<2>
Project.unit<0>.dataChannel<261>=u_wavedemux tmp2bram_ctr<1>
Project.unit<0>.dataChannel<262>=u_wavedemux tmp2bram_ctr<0>
Project.unit<0>.dataChannel<263>=u_wavedemux start_tmp2bram_xfer
Project.unit<0>.dataChannel<264>=u_OutputBufferControl REQUEST_PACKET
Project.unit<0>.dataChannel<265>=u_OutputBufferControl EVTBUILD_DONE
Project.unit<0>.dataChannel<266>=u_wavedemux dmx2_win<0>
Project.unit<0>.dataChannel<267>=u_wavedemux dmx2_win<1>
Project.unit<0>.dataChannel<268>=u_OutputBufferControl WAVEFORM_FIFO_EMPTY
Project.unit<0>.dataChannel<269>=u_OutputBufferControl internal_EVTBUILD_DONE
Project.unit<0>.dataChannel<26>=u_wavedemux dmx_wav_15<8>
Project.unit<0>.dataChannel<270>=u_OutputBufferControl EVTBUILD_START
Project.unit<0>.dataChannel<271>=u_OutputBufferControl EVTBUILD_MAKE_READY
Project.unit<0>.dataChannel<272>=u_OutputBufferControl WAVEFORM_FIFO_READ_ENABLE
Project.unit<0>.dataChannel<273>=u_ReadoutControl fifo_empty
Project.unit<0>.dataChannel<274>=u_ReadoutControl READOUT_RESET
Project.unit<0>.dataChannel<275>=u_ReadoutControl RESET_EVENT_NUM
Project.unit<0>.dataChannel<276>=u_wavedemux ct_sa<0>
Project.unit<0>.dataChannel<277>=u_wavedemux ct_sa<1>
Project.unit<0>.dataChannel<278>=u_wavedemux ct_sa<2>
Project.unit<0>.dataChannel<279>=u_wavedemux ct_sa<3>
Project.unit<0>.dataChannel<27>=u_wavedemux dmx_wav_15<7>
Project.unit<0>.dataChannel<280>=u_wavedemux ct_sa<4>
Project.unit<0>.dataChannel<281>=u_wavedemux ct_sa<5>
Project.unit<0>.dataChannel<282>=u_wavedemux ct_sa<6>
Project.unit<0>.dataChannel<283>=u_wavedemux ped_wea_0
Project.unit<0>.dataChannel<284>=u_wavedemux pedsub_st_FSM_FFd1
Project.unit<0>.dataChannel<285>=u_wavedemux pedsub_st_FSM_FFd2
Project.unit<0>.dataChannel<286>=u_wavedemux pedsub_st_FSM_FFd3
Project.unit<0>.dataChannel<287>=u_wavedemux pedsub_st_FSM_FFd1-In
Project.unit<0>.dataChannel<288>=u_wavedemux pedsub_st_FSM_FFd2-In
Project.unit<0>.dataChannel<289>=u_wavedemux pedsub_st_FSM_FFd3-In
Project.unit<0>.dataChannel<28>=u_wavedemux dmx_wav_15<6>
Project.unit<0>.dataChannel<290>=u_OutputBufferControl WAVEFORM_FIFO_READ_ENABLE
Project.unit<0>.dataChannel<291>=u_OutputBufferControl BUFFER_FIFO_WR_EN
Project.unit<0>.dataChannel<292>=u_OutputBufferControl EVTBUILD_START
Project.unit<0>.dataChannel<293>=u_OutputBufferControl EVTBUILD_MAKE_READY
Project.unit<0>.dataChannel<294>=internal_READCTRL_busy_status
Project.unit<0>.dataChannel<295>=u_wavedemux sapedsub<0>
Project.unit<0>.dataChannel<296>=u_wavedemux sapedsub<1>
Project.unit<0>.dataChannel<297>=u_wavedemux sapedsub<2>
Project.unit<0>.dataChannel<298>=u_wavedemux sapedsub<3>
Project.unit<0>.dataChannel<299>=u_wavedemux sapedsub<4>
Project.unit<0>.dataChannel<29>=u_wavedemux dmx_wav_15<5>
Project.unit<0>.dataChannel<2>=u_SamplingLgc MAIN_CNT<7>
Project.unit<0>.dataChannel<300>=u_wavedemux sapedsub<5>
Project.unit<0>.dataChannel<301>=u_wavedemux sapedsub<6>
Project.unit<0>.dataChannel<302>=u_wavedemux sapedsub<7>
Project.unit<0>.dataChannel<303>=u_wavedemux sapedsub<8>
Project.unit<0>.dataChannel<304>=u_wavedemux sapedsub<9>
Project.unit<0>.dataChannel<305>=u_wavedemux sapedsub<10>
Project.unit<0>.dataChannel<306>=u_wavedemux sapedsub<11>
Project.unit<0>.dataChannel<307>=u_wavedemux fifo_din_i<0>
Project.unit<0>.dataChannel<308>=u_wavedemux fifo_din_i<1>
Project.unit<0>.dataChannel<309>=u_wavedemux fifo_din_i<2>
Project.unit<0>.dataChannel<30>=u_wavedemux dmx_wav_15<4>
Project.unit<0>.dataChannel<310>=u_wavedemux fifo_din_i<3>
Project.unit<0>.dataChannel<311>=u_wavedemux fifo_din_i<4>
Project.unit<0>.dataChannel<312>=u_wavedemux fifo_din_i<5>
Project.unit<0>.dataChannel<313>=u_wavedemux fifo_din_i<6>
Project.unit<0>.dataChannel<314>=u_wavedemux fifo_din_i<7>
Project.unit<0>.dataChannel<315>=u_wavedemux fifo_din_i<8>
Project.unit<0>.dataChannel<316>=u_wavedemux fifo_din_i<9>
Project.unit<0>.dataChannel<317>=u_wavedemux fifo_din_i<10>
Project.unit<0>.dataChannel<318>=u_wavedemux fifo_din_i<11>
Project.unit<0>.dataChannel<319>=u_wavedemux fifo_din_i<12>
Project.unit<0>.dataChannel<31>=u_wavedemux dmx_wav_15<3>
Project.unit<0>.dataChannel<320>=u_wavedemux fifo_din_i<13>
Project.unit<0>.dataChannel<321>=u_wavedemux fifo_din_i<14>
Project.unit<0>.dataChannel<322>=u_wavedemux fifo_din_i<15>
Project.unit<0>.dataChannel<323>=u_wavedemux fifo_din_i<16>
Project.unit<0>.dataChannel<324>=u_wavedemux fifo_din_i<17>
Project.unit<0>.dataChannel<325>=u_wavedemux fifo_din_i<18>
Project.unit<0>.dataChannel<326>=u_wavedemux fifo_din_i<19>
Project.unit<0>.dataChannel<327>=u_wavedemux fifo_din_i<20>
Project.unit<0>.dataChannel<328>=u_wavedemux fifo_din_i<21>
Project.unit<0>.dataChannel<329>=u_wavedemux fifo_din_i<22>
Project.unit<0>.dataChannel<32>=u_wavedemux dmx_wav_15<2>
Project.unit<0>.dataChannel<330>=u_wavedemux fifo_din_i<23>
Project.unit<0>.dataChannel<331>=u_wavedemux fifo_din_i<24>
Project.unit<0>.dataChannel<332>=u_wavedemux fifo_din_i<25>
Project.unit<0>.dataChannel<333>=u_wavedemux fifo_din_i<26>
Project.unit<0>.dataChannel<334>=u_wavedemux fifo_din_i<27>
Project.unit<0>.dataChannel<335>=u_wavedemux fifo_din_i<28>
Project.unit<0>.dataChannel<336>=u_wavedemux fifo_din_i<29>
Project.unit<0>.dataChannel<337>=u_wavedemux fifo_din_i<30>
Project.unit<0>.dataChannel<338>=u_wavedemux fifo_din_i<31>
Project.unit<0>.dataChannel<339>=u_wavedemux fifo_en
Project.unit<0>.dataChannel<33>=u_wavedemux dmx_wav_15<1>
Project.unit<0>.dataChannel<340>=u_wavedemux fifo_en_i
Project.unit<0>.dataChannel<341>=u_wavedemux fifo_din_i2<16>
Project.unit<0>.dataChannel<342>=u_wavedemux fifo_din_i2<17>
Project.unit<0>.dataChannel<343>=u_wavedemux fifo_din_i2<18>
Project.unit<0>.dataChannel<344>=u_wavedemux wav_dina<12>
Project.unit<0>.dataChannel<345>=u_wavedemux wav_dina<13>
Project.unit<0>.dataChannel<346>=u_wavedemux wav_dina<14>
Project.unit<0>.dataChannel<347>=u_wavedemux wav_dina<15>
Project.unit<0>.dataChannel<348>=u_wavedemux wav_doutb<12>
Project.unit<0>.dataChannel<349>=u_wavedemux wav_doutb<13>
Project.unit<0>.dataChannel<34>=u_wavedemux dmx_wav_15<0>
Project.unit<0>.dataChannel<350>=u_wavedemux wav_doutb<14>
Project.unit<0>.dataChannel<351>=u_wavedemux wav_doutb<15>
Project.unit<0>.dataChannel<352>=u_wavedemux ped_doutb<12>
Project.unit<0>.dataChannel<353>=u_wavedemux ped_doutb<13>
Project.unit<0>.dataChannel<354>=u_wavedemux ped_doutb<14>
Project.unit<0>.dataChannel<355>=u_wavedemux ped_doutb<15>
Project.unit<0>.dataChannel<356>=u_wavedemux dmx_wav_15<15>
Project.unit<0>.dataChannel<357>=u_wavedemux dmx_wav_15<14>
Project.unit<0>.dataChannel<358>=u_wavedemux dmx_wav_15<13>
Project.unit<0>.dataChannel<359>=u_wavedemux dmx_wav_15<12>
Project.unit<0>.dataChannel<35>=u_wavedemux jdx1<0>
Project.unit<0>.dataChannel<360>=u_wavedemux dmx_wav_0<15>
Project.unit<0>.dataChannel<361>=u_wavedemux dmx_wav_0<14>
Project.unit<0>.dataChannel<362>=u_wavedemux dmx_wav_0<13>
Project.unit<0>.dataChannel<363>=u_wavedemux wavarray_tmp_0<12>
Project.unit<0>.dataChannel<364>=u_wavedemux wavarray_tmp_0<13>
Project.unit<0>.dataChannel<365>=u_wavedemux wavarray_tmp_0<14>
Project.unit<0>.dataChannel<366>=u_wavedemux wavarray_tmp_0<15>
Project.unit<0>.dataChannel<367>=u_wavedemux dmx_wav_0<12>
Project.unit<0>.dataChannel<368>=u_wavedemux wavarray_tmp_15<12>
Project.unit<0>.dataChannel<369>=u_wavedemux wavarray_tmp_15<13>
Project.unit<0>.dataChannel<36>=u_wavedemux jdx1<1>
Project.unit<0>.dataChannel<370>=u_wavedemux wavarray_tmp_15<14>
Project.unit<0>.dataChannel<371>=u_wavedemux wavarray_tmp_15<15>
Project.unit<0>.dataChannel<372>=u_wavedemux fifo_din_i2<19>
Project.unit<0>.dataChannel<373>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<0>1
Project.unit<0>.dataChannel<374>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<10>1
Project.unit<0>.dataChannel<375>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<11>1
Project.unit<0>.dataChannel<376>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<12>1
Project.unit<0>.dataChannel<377>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<13>1
Project.unit<0>.dataChannel<378>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<14>1
Project.unit<0>.dataChannel<379>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<15>1
Project.unit<0>.dataChannel<37>=u_wavedemux jdx1<2>
Project.unit<0>.dataChannel<380>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<1>1
Project.unit<0>.dataChannel<381>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<2>1
Project.unit<0>.dataChannel<382>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<3>1
Project.unit<0>.dataChannel<383>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<4>1
Project.unit<0>.dataChannel<384>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<5>1
Project.unit<0>.dataChannel<385>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<6>1
Project.unit<0>.dataChannel<386>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<7>1
Project.unit<0>.dataChannel<387>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<8>1
Project.unit<0>.dataChannel<388>=u_wavedemux fifo_din_i2[19]_Decoder_77_OUT<9>1
Project.unit<0>.dataChannel<389>=u_wavedemux dmx2_sa<0>
Project.unit<0>.dataChannel<38>=u_wavedemux jdx1<3>
Project.unit<0>.dataChannel<390>=u_wavedemux dmx2_sa<1>
Project.unit<0>.dataChannel<391>=u_wavedemux dmx2_sa<2>
Project.unit<0>.dataChannel<392>=u_wavedemux dmx2_sa<3>
Project.unit<0>.dataChannel<393>=u_wavedemux dmx2_sa<4>
Project.unit<0>.dataChannel<394>=u_wavedemux dmx2_win<0>
Project.unit<0>.dataChannel<395>=u_wavedemux dmx2_win<1>
Project.unit<0>.dataChannel<396>=
Project.unit<0>.dataChannel<397>=
Project.unit<0>.dataChannel<398>=
Project.unit<0>.dataChannel<399>=
Project.unit<0>.dataChannel<39>=u_wavedemux jdx1<4>
Project.unit<0>.dataChannel<3>=u_SamplingLgc MAIN_CNT<6>
Project.unit<0>.dataChannel<400>=
Project.unit<0>.dataChannel<401>=
Project.unit<0>.dataChannel<402>=
Project.unit<0>.dataChannel<403>=
Project.unit<0>.dataChannel<404>=
Project.unit<0>.dataChannel<405>=
Project.unit<0>.dataChannel<406>=
Project.unit<0>.dataChannel<407>=
Project.unit<0>.dataChannel<408>=
Project.unit<0>.dataChannel<409>=
Project.unit<0>.dataChannel<40>=u_wavedemux jdx1<5>
Project.unit<0>.dataChannel<410>=
Project.unit<0>.dataChannel<411>=
Project.unit<0>.dataChannel<412>=
Project.unit<0>.dataChannel<413>=
Project.unit<0>.dataChannel<414>=
Project.unit<0>.dataChannel<415>=
Project.unit<0>.dataChannel<416>=
Project.unit<0>.dataChannel<417>=
Project.unit<0>.dataChannel<418>=
Project.unit<0>.dataChannel<419>=
Project.unit<0>.dataChannel<41>=u_wavedemux jdx1<6>
Project.unit<0>.dataChannel<420>=
Project.unit<0>.dataChannel<421>=
Project.unit<0>.dataChannel<422>=
Project.unit<0>.dataChannel<423>=
Project.unit<0>.dataChannel<424>=
Project.unit<0>.dataChannel<425>=
Project.unit<0>.dataChannel<42>=u_ReadoutControl READOUT_RESET
Project.unit<0>.dataChannel<43>=u_ReadoutControl internal_READOUT_DONE
Project.unit<0>.dataChannel<44>=u_ReadoutControl internal_busy_status
Project.unit<0>.dataChannel<45>=u_SerialDataRout Ev_CNT<0>
Project.unit<0>.dataChannel<46>=u_SerialDataRout Ev_CNT<1>
Project.unit<0>.dataChannel<47>=u_SerialDataRout internal_idle
Project.unit<0>.dataChannel<48>=u_SerialDataRout sr_clr
Project.unit<0>.dataChannel<49>=u_wavedemux wavarray_tmp_0<0>
Project.unit<0>.dataChannel<4>=u_SamplingLgc MAIN_CNT<5>
Project.unit<0>.dataChannel<50>=u_wavedemux wavarray_tmp_0<1>
Project.unit<0>.dataChannel<51>=u_wavedemux wavarray_tmp_0<10>
Project.unit<0>.dataChannel<52>=u_wavedemux wavarray_tmp_0<11>
Project.unit<0>.dataChannel<53>=u_wavedemux wavarray_tmp_0<2>
Project.unit<0>.dataChannel<54>=u_wavedemux wavarray_tmp_0<3>
Project.unit<0>.dataChannel<55>=u_wavedemux wavarray_tmp_0<4>
Project.unit<0>.dataChannel<56>=u_wavedemux wavarray_tmp_0<5>
Project.unit<0>.dataChannel<57>=u_wavedemux wavarray_tmp_0<6>
Project.unit<0>.dataChannel<58>=u_wavedemux wavarray_tmp_0<7>
Project.unit<0>.dataChannel<59>=u_wavedemux wavarray_tmp_0<8>
Project.unit<0>.dataChannel<5>=u_SamplingLgc MAIN_CNT<4>
Project.unit<0>.dataChannel<60>=u_wavedemux wavarray_tmp_0<9>
Project.unit<0>.dataChannel<61>=u_wavedemux wavarray_tmp_15<0>
Project.unit<0>.dataChannel<62>=u_wavedemux wavarray_tmp_15<1>
Project.unit<0>.dataChannel<63>=u_wavedemux wavarray_tmp_15<10>
Project.unit<0>.dataChannel<64>=u_wavedemux wavarray_tmp_15<11>
Project.unit<0>.dataChannel<65>=u_wavedemux wavarray_tmp_15<2>
Project.unit<0>.dataChannel<66>=u_wavedemux wavarray_tmp_15<3>
Project.unit<0>.dataChannel<67>=u_wavedemux wavarray_tmp_15<4>
Project.unit<0>.dataChannel<68>=u_wavedemux wavarray_tmp_15<5>
Project.unit<0>.dataChannel<69>=u_wavedemux wavarray_tmp_15<6>
Project.unit<0>.dataChannel<6>=u_SamplingLgc MAIN_CNT<3>
Project.unit<0>.dataChannel<70>=u_wavedemux wavarray_tmp_15<7>
Project.unit<0>.dataChannel<71>=u_wavedemux wavarray_tmp_15<8>
Project.unit<0>.dataChannel<72>=u_wavedemux wavarray_tmp_15<9>
Project.unit<0>.dataChannel<73>=internal_SROUT_FIFO_DATA_OUT<31>
Project.unit<0>.dataChannel<74>=internal_SROUT_FIFO_DATA_OUT<30>
Project.unit<0>.dataChannel<75>=internal_SROUT_FIFO_DATA_OUT<29>
Project.unit<0>.dataChannel<76>=internal_SROUT_FIFO_DATA_OUT<28>
Project.unit<0>.dataChannel<77>=internal_SROUT_FIFO_DATA_OUT<27>
Project.unit<0>.dataChannel<78>=internal_SROUT_FIFO_DATA_OUT<26>
Project.unit<0>.dataChannel<79>=internal_SROUT_FIFO_DATA_OUT<25>
Project.unit<0>.dataChannel<7>=u_SamplingLgc MAIN_CNT<2>
Project.unit<0>.dataChannel<80>=internal_SROUT_FIFO_DATA_OUT<24>
Project.unit<0>.dataChannel<81>=internal_SROUT_FIFO_DATA_OUT<23>
Project.unit<0>.dataChannel<82>=internal_SROUT_FIFO_DATA_OUT<22>
Project.unit<0>.dataChannel<83>=internal_SROUT_FIFO_DATA_OUT<21>
Project.unit<0>.dataChannel<84>=internal_SROUT_FIFO_DATA_OUT<20>
Project.unit<0>.dataChannel<85>=internal_SROUT_FIFO_DATA_OUT<19>
Project.unit<0>.dataChannel<86>=internal_SROUT_FIFO_DATA_OUT<18>
Project.unit<0>.dataChannel<87>=internal_SROUT_FIFO_DATA_OUT<17>
Project.unit<0>.dataChannel<88>=internal_SROUT_FIFO_DATA_OUT<16>
Project.unit<0>.dataChannel<89>=internal_SROUT_FIFO_DATA_OUT<15>
Project.unit<0>.dataChannel<8>=u_SamplingLgc MAIN_CNT<1>
Project.unit<0>.dataChannel<90>=internal_SROUT_FIFO_DATA_OUT<14>
Project.unit<0>.dataChannel<91>=internal_SROUT_FIFO_DATA_OUT<13>
Project.unit<0>.dataChannel<92>=internal_SROUT_FIFO_DATA_OUT<12>
Project.unit<0>.dataChannel<93>=internal_SROUT_FIFO_DATA_OUT<11>
Project.unit<0>.dataChannel<94>=internal_SROUT_FIFO_DATA_OUT<10>
Project.unit<0>.dataChannel<95>=internal_SROUT_FIFO_DATA_OUT<9>
Project.unit<0>.dataChannel<96>=internal_SROUT_FIFO_DATA_OUT<8>
Project.unit<0>.dataChannel<97>=internal_SROUT_FIFO_DATA_OUT<7>
Project.unit<0>.dataChannel<98>=internal_SROUT_FIFO_DATA_OUT<6>
Project.unit<0>.dataChannel<99>=internal_SROUT_FIFO_DATA_OUT<5>
Project.unit<0>.dataChannel<9>=u_SamplingLgc MAIN_CNT<0>
Project.unit<0>.dataDepth=8192
Project.unit<0>.dataEqualsTrigger=false
Project.unit<0>.dataPortWidth=343
Project.unit<0>.enableGaps=false
Project.unit<0>.enableStorageQualification=true
Project.unit<0>.enableTimestamps=false
Project.unit<0>.timestampDepth=0
Project.unit<0>.timestampWidth=0
Project.unit<0>.triggerChannel<0><0>=uut_pedram update_req<0>
Project.unit<0>.triggerChannel<0><10>=u_SamplingLgc wr_addrclr
Project.unit<0>.triggerChannel<0><11>=u_DigitizingLgc StartDig
Project.unit<0>.triggerChannel<0><12>=u_DigitizingLgc rd_ena_out
Project.unit<0>.triggerChannel<0><13>=Inst_WaveformDemuxCalcPedsBRAM fifo_en
Project.unit<0>.triggerChannel<0><14>=Inst_WaveformDemuxCalcPedsBRAM reset
Project.unit<0>.triggerChannel<0><15>=Inst_WaveformDemuxCalcPedsBRAM ram_busy
Project.unit<0>.triggerChannel<0><1>=u_wavedemux sr_start
Project.unit<0>.triggerChannel<0><2>=u_ReadoutControl trigger
Project.unit<0>.triggerChannel<0><3>=uut_pedram WEb
Project.unit<0>.triggerChannel<0><4>=uut_pedram OEb
Project.unit<0>.triggerChannel<0><5>=uut_pedram update_req<2>
Project.unit<0>.triggerChannel<0><6>=u_ReadoutControl internal_LATCH_DONE
Project.unit<0>.triggerChannel<0><7>=u_SerialDataRout fifo_wr_en
Project.unit<0>.triggerChannel<0><8>=uut_pedram update_req<2>
Project.unit<0>.triggerChannel<0><9>=u_SerialDataRout start
Project.unit<0>.triggerChannel<1><0>=u_wavedemux ped_sub_start<0>
Project.unit<0>.triggerChannel<1><10>=u_OutputBufferControl WAVEFORM_FIFO_EMPTY
Project.unit<0>.triggerChannel<1><11>=u_OutputBufferControl internal_EVTBUILD_DONE
Project.unit<0>.triggerChannel<1><12>=u_OutputBufferControl internal_REQUEST_PACKET_reg<0>
Project.unit<0>.triggerChannel<1><13>=u_OutputBufferControl internal_REQUEST_PACKET_reg<1>
Project.unit<0>.triggerChannel<1><14>=u_OutputBufferControl WAVEFORM_FIFO_READ_ENABLE
Project.unit<0>.triggerChannel<1><15>=u_OutputBufferControl BUFFER_FIFO_WR_EN
Project.unit<0>.triggerChannel<1><16>=u_OutputBufferControl BUFFER_FIFO_RESET
Project.unit<0>.triggerChannel<1><17>=u_OutputBufferControl EVTBUILD_MAKE_READY
Project.unit<0>.triggerChannel<1><18>=u_OutputBufferControl EVTBUILD_START
Project.unit<0>.triggerChannel<1><19>=internal_READCTRL_busy_status
Project.unit<0>.triggerChannel<1><1>=u_wavedemux ped_sub_start<1>
Project.unit<0>.triggerChannel<1><2>=u_wavedemux ped_wea_0
Project.unit<0>.triggerChannel<1><3>=u_wavedemux ped_sa_update
Project.unit<0>.triggerChannel<1><4>=u_wavedemux ped_sub_fetch_busy
Project.unit<0>.triggerChannel<1><5>=u_wavedemux dmx_allwin_busy
Project.unit<0>.triggerChannel<1><6>=u_wavedemux pswfifo_en
Project.unit<0>.triggerChannel<1><7>=u_wavedemux dmx2_win<0>
Project.unit<0>.triggerChannel<1><8>=u_OutputBufferControl REQUEST_PACKET
Project.unit<0>.triggerChannel<1><9>=u_OutputBufferControl EVTBUILD_DONE
Project.unit<0>.triggerConditionCountWidth=0
Project.unit<0>.triggerMatchCount<0>=1
Project.unit<0>.triggerMatchCount<1>=1
Project.unit<0>.triggerMatchCountWidth<0><0>=0
Project.unit<0>.triggerMatchCountWidth<1><0>=0
Project.unit<0>.triggerMatchType<0><0>=1
Project.unit<0>.triggerMatchType<1><0>=1
Project.unit<0>.triggerPortCount=2
Project.unit<0>.triggerPortIsData<0>=true
Project.unit<0>.triggerPortIsData<1>=true
Project.unit<0>.triggerPortWidth<0>=16
Project.unit<0>.triggerPortWidth<1>=20
Project.unit<0>.triggerSequencerLevels=16
Project.unit<0>.triggerSequencerType=1
Project.unit<0>.type=ilapro
