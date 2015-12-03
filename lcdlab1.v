module lcdlab1(
  input CLOCK_50,	//	50 MHz clock
//	LCD Module 16X2
  output LCD_ON,	// LCD Power ON/OFF
  output LCD_RW,	// LCD Read/Write Select, 0 = Write, 1 = Read
  output LCD_EN,	// LCD Enable
  output LCD_RS,	// LCD Command/Data Select, 0 = Command, 1 = Data
  inout [7:0] LCD_DATA,	// LCD Data bus 8 bits
  input [9:0] Answer,
  input Submit, Reset,
  output greenout,
  output redout
);


// reset delay gives some time for peripherals to initialize
wire DLY_RST;
Reset_Delay r0(	.iCLK(CLOCK_50),.oRESET(DLY_RST) );


// turn LCD ON
assign	LCD_ON		=	1'b1;


LCD_TEST u1(
// Host Side
	.answer(Answer),
	.submit(Submit),
	.rst(Reset),
   .iCLK(CLOCK_50),
   .iRST_N(DLY_RST),
// LCD Side
   .LCD_DATA(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_EN(LCD_EN),
   .LCD_RS(LCD_RS),
	.redOut(redout),
	.greenOut(greenout)
	
);

endmodule 