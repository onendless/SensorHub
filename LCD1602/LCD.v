module LCD(
                clk    ,
                rst_n  ,
                lcd_en ,
                lcd_rw ,  //因为只执行写操作，所以永远为0.
                lcd_rs ,
                lcd_data,
					 lcd_on,
					 lcd_blon

              );
input        clk    ;
input        rst_n  ;

output       lcd_en ;
output       lcd_rw ;
output       lcd_rs ;
output [7:0] lcd_data;
output		 lcd_on;
output       lcd_blon;
wire         clk ;
wire         rst_n  ;
wire         lcd_en ;
wire         lcd_rw;
reg  [7:0]   lcd_data;
reg          lcd_rs  ;
reg [5:0]    c_state ;
reg [5:0]    n_state ;
wire  [127:0]  row_1;
wire  [127:0]  row_2;
assign row_1 ="Temperature:    " ;  //第一行显示的内容
assign row_2 ="            24.3";  //第二行显示的内容
//----------------------------------------------------------------------
//initialize
//first step is waitng more than 20 ms. 数据手册要求的，目的是等待系统上电稳定。
parameter TIME_20MS = 1000000 ; //20000000/20=1000_000
parameter TIME_500HZ= 100000  ; //
//use gray code   
parameter         IDLE=    8'h00  ;  //因为此状态机一共有40个状态，所以这里用了格雷码，一次只有1位发生改变。00 01 03 02                      
parameter SET_FUNCTION=    8'h01  ;       
parameter     DISP_OFF=    8'h03  ;
parameter   DISP_CLEAR=    8'h02  ;
parameter   ENTRY_MODE=    8'h06  ;
parameter   DISP_ON   =    8'h07  ;
parameter    ROW1_ADDR=    8'h05  ;       
parameter       ROW1_0=    8'h04  ;
parameter       ROW1_1=    8'h0C  ;
parameter       ROW1_2=    8'h0D  ;
parameter       ROW1_3=    8'h0F  ;
parameter       ROW1_4=    8'h0E  ;
parameter       ROW1_5=    8'h0A  ;
parameter       ROW1_6=    8'h0B  ;
parameter       ROW1_7=    8'h09  ;
parameter       ROW1_8=  8'h08  ;
parameter       ROW1_9=    8'h18  ;
parameter       ROW1_A=    8'h19  ;
parameter       ROW1_B=    8'h1B  ;
parameter       ROW1_C=    8'h1A  ;
parameter       ROW1_D=    8'h1E  ;
parameter       ROW1_E=    8'h1F  ;
parameter       ROW1_F=    8'h1D  ;

parameter    ROW2_ADDR=    8'h1C  ;
parameter       ROW2_0=    8'h14  ;
parameter       ROW2_1=    8'h15  ;
parameter       ROW2_2=    8'h17  ;
parameter       ROW2_3=    8'h16  ;
parameter       ROW2_4=    8'h12  ;
parameter       ROW2_5=    8'h13  ;
parameter       ROW2_6=    8'h11  ;
parameter       ROW2_7=    8'h10  ;
parameter       ROW2_8=    8'h30  ;
parameter       ROW2_9=    8'h31  ;
parameter       ROW2_A=    8'h33  ;
parameter       ROW2_B=    8'h32  ;
parameter       ROW2_C=    8'h36  ;
parameter       ROW2_D=    8'h37  ;
parameter       ROW2_E=    8'h35  ;
parameter       ROW2_F=    8'h34  ;


//20ms的计数器，即初始化第一步
reg [19:0] cnt_20ms ;
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_20ms<=0;
    end
    else if(cnt_20ms == TIME_20MS -1)begin
        cnt_20ms<=cnt_20ms;
    end
    else
        cnt_20ms<=cnt_20ms + 1 ;
end
wire delay_done = (cnt_20ms==TIME_20MS-1)? 1'b1 : 1'b0 ;
//----------------------------------------------------------------------
//500ns  这里是分频，因为LCD1602的工作频率是500HZ,而FPGA是50Mhz,所以要分频
reg [19:0] cnt_500hz;
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cnt_500hz <= 0;
    end
    else if(delay_done==1)begin
        if(cnt_500hz== TIME_500HZ - 1)
            cnt_500hz<=0;
        else
            cnt_500hz<=cnt_500hz + 1 ;
    end
    else
        cnt_500hz<=0;
end

assign lcd_en = (cnt_500hz>(TIME_500HZ-1)/2)? 1'b0 : 1'b1;  //下降沿
assign write_flag = (cnt_500hz==TIME_500HZ - 1) ? 1'b1 : 1'b0 ;
assign lcd_on=1'b1;    //开显示背光
assign lcd_blon=1'b0;
assign lcd_rw = 0;     //始终为写操作


//set_function ,display off ，display clear ,entry mode set
//----------------------------------------------------------------------状态机
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        c_state <= IDLE    ;
    end
    else if(write_flag==1) begin
        c_state<= n_state  ;
    end
    else
        c_state<=c_state   ;
end

always  @(*)begin
    case (c_state)
        IDLE: n_state = SET_FUNCTION ;
SET_FUNCTION: n_state = DISP_OFF     ;
    DISP_OFF: n_state = DISP_CLEAR   ;
  DISP_CLEAR: n_state = ENTRY_MODE   ;
  ENTRY_MODE: n_state = DISP_ON      ;
  DISP_ON   : n_state = ROW1_ADDR    ;
   ROW1_ADDR: n_state = ROW1_0       ;
      ROW1_0: n_state = ROW1_1       ;
      ROW1_1: n_state = ROW1_2       ;
      ROW1_2: n_state = ROW1_3       ;
      ROW1_3: n_state = ROW1_4       ;
      ROW1_4: n_state = ROW1_5       ;
      ROW1_5: n_state = ROW1_6       ;
      ROW1_6: n_state = ROW1_7       ;
      ROW1_7: n_state = ROW1_8       ;
      ROW1_8: n_state = ROW1_9       ;
      ROW1_9: n_state = ROW1_A       ;
      ROW1_A: n_state = ROW1_B       ;
      ROW1_B: n_state = ROW1_C       ;
      ROW1_C: n_state = ROW1_D       ;
      ROW1_D: n_state = ROW1_E       ;
      ROW1_E: n_state = ROW1_F       ;
      ROW1_F: n_state = ROW2_ADDR    ;

   ROW2_ADDR: n_state = ROW2_0       ;
      ROW2_0: n_state = ROW2_1       ;
      ROW2_1: n_state = ROW2_2       ;
      ROW2_2: n_state = ROW2_3       ;
      ROW2_3: n_state = ROW2_4       ;
      ROW2_4: n_state = ROW2_5       ;
      ROW2_5: n_state = ROW2_6       ;
      ROW2_6: n_state = ROW2_7       ;
      ROW2_7: n_state = ROW2_8       ;
      ROW2_8: n_state = ROW2_9       ;
      ROW2_9: n_state = ROW2_A       ;
      ROW2_A: n_state = ROW2_B       ;
      ROW2_B: n_state = ROW2_C       ;
      ROW2_C: n_state = ROW2_D       ;
      ROW2_D: n_state = ROW2_E       ;
      ROW2_E: n_state = ROW2_F       ;
      ROW2_F: n_state = ROW1_ADDR    ;
     default: n_state = n_state      ;
   endcase 
   end   


   always  @(posedge clk or negedge rst_n)begin
       if(rst_n==1'b0)begin
           lcd_rs <= 0 ;   //order or data  0: order 1:data
       end
       else if(write_flag == 1)begin
           if((n_state==SET_FUNCTION)||(n_state==DISP_OFF)||
              (n_state==DISP_CLEAR)||(n_state==ENTRY_MODE)||
              (n_state==DISP_ON ) ||(n_state==ROW1_ADDR)||
              (n_state==ROW2_ADDR))begin
           lcd_rs<=0 ;
           end 
           else  begin
           lcd_rs<= 1;
           end
       end
       else begin
           lcd_rs<=lcd_rs;
       end     
   end                   

   always  @(posedge clk or negedge rst_n)begin
       if(rst_n==1'b0)begin
           lcd_data<=0 ;
       end
       else  if(write_flag)begin
           case(n_state)

                 IDLE: lcd_data <= 8'hxx;
         SET_FUNCTION: lcd_data <= 8'h38; //2*16 5*8 8位数据
             DISP_OFF: lcd_data <= 8'h08;
           DISP_CLEAR: lcd_data <= 8'h01; //数据指针清零，显示清零
           ENTRY_MODE: lcd_data <= 8'h06; //指针光标自动加一，整屏不移动
           DISP_ON   : lcd_data <= 8'h0C;  //显示功能开，没有光标，且不闪烁，
            ROW1_ADDR: lcd_data <= 8'h80; //00+80
               ROW1_0: lcd_data <= row_1 [127:120];
               ROW1_1: lcd_data <= row_1 [119:112];
               ROW1_2: lcd_data <= row_1 [111:104];
               ROW1_3: lcd_data <= row_1 [103: 96];
               ROW1_4: lcd_data <= row_1 [ 95: 88];
               ROW1_5: lcd_data <= row_1 [ 87: 80];
               ROW1_6: lcd_data <= row_1 [ 79: 72];
               ROW1_7: lcd_data <= row_1 [ 71: 64];
               ROW1_8: lcd_data <= row_1 [ 63: 56];
               ROW1_9: lcd_data <= row_1 [ 55: 48];
               ROW1_A: lcd_data <= row_1 [ 47: 40];
               ROW1_B: lcd_data <= row_1 [ 39: 32];
               ROW1_C: lcd_data <= row_1 [ 31: 24];
               ROW1_D: lcd_data <= row_1 [ 23: 16];
               ROW1_E: lcd_data <= row_1 [ 15:  8];
               ROW1_F: lcd_data <= row_1 [  7:  0];

            ROW2_ADDR: lcd_data <= 8'hc0;      //40+80
               ROW2_0: lcd_data <= row_2 [127:120];
               ROW2_1: lcd_data <= row_2 [119:112];
               ROW2_2: lcd_data <= row_2 [111:104];
               ROW2_3: lcd_data <= row_2 [103: 96];
               ROW2_4: lcd_data <= row_2 [ 95: 88];
               ROW2_5: lcd_data <= row_2 [ 87: 80];
               ROW2_6: lcd_data <= row_2 [ 79: 72];
               ROW2_7: lcd_data <= row_2 [ 71: 64];
               ROW2_8: lcd_data <= row_2 [ 63: 56];
               ROW2_9: lcd_data <= row_2 [ 55: 48];
               ROW2_A: lcd_data <= row_2 [ 47: 40];
               ROW2_B: lcd_data <= row_2 [ 39: 32];
               ROW2_C: lcd_data <= row_2 [ 31: 24];
               ROW2_D: lcd_data <= row_2 [ 23: 16];
               ROW2_E: lcd_data <= row_2 [ 15:  8];
               ROW2_F: lcd_data <= row_2 [  7:  0];
           endcase                     
       end
       else
              lcd_data<=lcd_data ;
   end

endmodule