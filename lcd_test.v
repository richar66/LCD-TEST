module	LCD_TEST (
//Q FSM
input [9:0] answer,
input submit, clk, rst,
output reg redOut, greenOut,

//output reg [6:0] Question;
// Host Side
  input iCLK,iRST_N,
// LCD Side
  output [7:0] 	LCD_DATA,
  output LCD_RW,LCD_EN,LCD_RS	
);
//	Internal Wires/Registers
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg		mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg		mLCD_RS;
wire		mLCD_Done;
reg [7:0] Question;

//reg redOut, greenOut;
reg [2:0] S, NS;
reg [9:0] Answer;

parameter
			//	Start = 7'd0,
				
				Q0 = 7'd1,
				check0 = 7'd2,
				wrong0 = 7'd3,
				correct0 = 7'd4,
				
				Q1 = 7'd5,
				check1 = 7'd6,
				wrong1 = 7'd7,
				correct1 = 7'd8;
				
				/*Q2 = 7'd9,
				check2 = 7'd10,
				wrong2 = 7'd11,
				correct2 = 7'd12,
				
				Q3 = 7'd13,
				check3 = 7'd14,
				wrong3 = 7'd15,
				correct3 = 7'd16;
				
				Q4 = 7'd17,
				check4 = 7'd18,
				wrong4 = 7'd19,
				correct4 = 7'd20,
				
				Q5 = 7'd21,
				check5 = 7'd22,
				wrong5 = 7'd23,
				correct5 = 7'd24;
				*/

parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE1+32+1;

always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		S <= Q0;
	end
	
	else
	begin
		S<= NS;
	end
end

always @ (*)
begin
	case(S) 
	Q0:
	begin
		if (submit == 1'b0)
		begin	
			NS = Q0;
		end
		else
		begin	
			NS = check0;
		end
	end
	
	check0:
	begin
		if(submit == 1'b1)
		begin
			if (Answer == 10'b0000000001 )
			begin
				NS = correct0;
			end
			else 
			begin
				NS = wrong0;
			end
		end
		
		else 
		begin
			NS = Q0;
		end
	end
	
	wrong0:
	begin
		if (submit == 0)
		begin
			NS = Q0;
		end
		else
		begin
			NS = wrong0;
		end
	
	end
	correct0:
	begin
		if (submit == 0)
		begin
			NS = Q1;
		end
		else
		begin
			NS = correct0;
		end
	end
	Q1:
	begin
		if (submit == 1'b0)
		begin	
			NS = Q1;
		end
		else
		begin	
			NS = check1;
		end
	end
	
	check1:
	begin
		if(submit == 1'b1)
		begin
			if (Answer == 10'b0000000010 )
			begin
				NS = correct1;
			end
			else 
			begin
				NS = wrong1;
			end
		end
		
		else 
		begin
			NS = Q1;
		end
	end
	
	wrong1:
	begin
		if (submit == 0)
		begin
			NS = Q1;
		end
		else
		begin
			NS = wrong1;
		end
	
	end
	correct1:
	begin
		if (submit == 0)
		begin
			NS = Q0;
		end
		else
		begin
			NS = correct1;
		end
	end
	endcase
end	
always @ (posedge clk or negedge rst)
begin
	if(rst == 1'b0)
	begin
	greenOut <= 1'b0;
	redOut <= 1'b0;
	Question <= 7'b1111111;
	end
	else
	begin
		case(S)
		Q0: 
		begin
		Answer <= answer;
		greenOut <= 1'b0;
		redOut <= 1'b0;
		Question <= 7'b1000000;
		end
		correct0: greenOut <= 1'b1;
	
		wrong0: redOut <= 1'b1;
		
		Q1: 
		begin
		Answer <= answer;
		greenOut <= 1'b0;
		redOut <= 1'b0;
		Question <= 7'b1111001;
		end
		correct1: greenOut <= 1'b1;
	
		wrong1: redOut <= 1'b1;
		endcase
	end
	
end 

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;					
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY + 1'b1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
			3:	begin
					LUT_INDEX	<=	LUT_INDEX + 1'b1;
					mLCD_ST	<=	0;
				end
			endcase
		end
	end
end

always @(*)
begin
	
	case(S)
	Q0:
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+4:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+5:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+6:	LUT_DATA	<=	9'h143;	//C 
		LCD_LINE2+7:	LUT_DATA	<=	9'h165;	//e
		LCD_LINE2+8:	LUT_DATA	<=	9'h172;	//r
		LCD_LINE2+9:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+10:	LUT_DATA	<=	9'h13F;	//? 
		LCD_LINE2+11:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
		
	check0:
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+4:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+5:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+6:	LUT_DATA	<=	9'h143;	//C 
		LCD_LINE2+7:	LUT_DATA	<=	9'h165;	//e
		LCD_LINE2+8:	LUT_DATA	<=	9'h172;	//r
		LCD_LINE2+9:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+10:	LUT_DATA	<=	9'h13F;	//? 
		LCD_LINE2+11:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
		
	correct0: 
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+4:	LUT_DATA	<=	9'h143;	//C
		LCD_LINE2+5:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+6:	LUT_DATA	<=	9'h172;	//r
		LCD_LINE2+7:	LUT_DATA	<=	9'h172;	//r
		LCD_LINE2+8:	LUT_DATA	<=	9'h165;	//e
		LCD_LINE2+9:	LUT_DATA	<=	9'h163;	//c
		LCD_LINE2+10:	LUT_DATA	<=	9'h174;	//t
		LCD_LINE2+11:	LUT_DATA	<=	9'h121;	//!
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
	
	wrong0:
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space 
		LCD_LINE2+4:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+5:	LUT_DATA	<=	9'h157;	//W
		LCD_LINE2+6:	LUT_DATA	<=	9'h172;	//r 
		LCD_LINE2+7:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+8:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE2+9:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE2+10:	LUT_DATA	<=	9'h121;	//! 
		LCD_LINE2+11:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
		Q1:
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+4:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+5:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+6:	LUT_DATA	<=	9'h155;	//U 
		LCD_LINE2+7:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE2+8:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+9:	LUT_DATA	<=	9'h13F;	//? 
		LCD_LINE2+10:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+11:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
		
	check1:
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+4:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+5:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+6:	LUT_DATA	<=	9'h155;	//U 
		LCD_LINE2+7:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE2+8:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+9:	LUT_DATA	<=	9'h13F;	//? 
		LCD_LINE2+10:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+11:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
		
	correct1: 
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+4:	LUT_DATA	<=	9'h143;	//C
		LCD_LINE2+5:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+6:	LUT_DATA	<=	9'h172;	//r
		LCD_LINE2+7:	LUT_DATA	<=	9'h172;	//r
		LCD_LINE2+8:	LUT_DATA	<=	9'h165;	//e
		LCD_LINE2+9:	LUT_DATA	<=	9'h163;	//c
		LCD_LINE2+10:	LUT_DATA	<=	9'h174;	//t
		LCD_LINE2+11:	LUT_DATA	<=	9'h121;	//!
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
	
	wrong1:
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	<S>
		LCD_LINE1+1:	LUT_DATA	<=	9'h170;	//p
		LCD_LINE1+2:	LUT_DATA	<=	9'h161;	//a
		LCD_LINE1+3:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+4:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+5:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+6:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+7:	LUT_DATA	<=	9'h13E;	//>
		LCD_LINE1+8:	LUT_DATA	<=	9'h145;	//E
		LCD_LINE1+9:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE1+10:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE1+11:	LUT_DATA	<=	9'h16C;	//l
		LCD_LINE1+12:	LUT_DATA	<=	9'h169;	//i
		LCD_LINE1+13:	LUT_DATA	<=	9'h173;	//s
		LCD_LINE1+14:	LUT_DATA	<=	9'h168;	//h
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;	//space
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+1:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+2:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+3:	LUT_DATA	<=	9'h120;	//space 
		LCD_LINE2+4:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+5:	LUT_DATA	<=	9'h157;	//W
		LCD_LINE2+6:	LUT_DATA	<=	9'h172;	//r 
		LCD_LINE2+7:	LUT_DATA	<=	9'h16F;	//o
		LCD_LINE2+8:	LUT_DATA	<=	9'h16E;	//n
		LCD_LINE2+9:	LUT_DATA	<=	9'h167;	//g
		LCD_LINE2+10:	LUT_DATA	<=	9'h121;	//! 
		LCD_LINE2+11:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;	//space
		LCD_LINE2+15:	LUT_DATA	<=	9'h120;	//space
		default:		LUT_DATA	<=	9'dx ;
		endcase
	endcase
	
end

LCD_Controller u0(
//    Host Side
.iDATA(mLCD_DATA),
.iRS(mLCD_RS),
.iStart(mLCD_Start),
.oDone(mLCD_Done),
.iCLK(iCLK),
.iRST_N(iRST_N),
//    LCD Interface
.LCD_DATA(LCD_DATA),
.LCD_RW(LCD_RW),
.LCD_EN(LCD_EN),
.LCD_RS(LCD_RS)    );

endmodule
