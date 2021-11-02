`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/28 22:25:45
// Design Name: 
// Module Name: geofence
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output valid;//It's used to calculate result
output is_inside;
//reg valid;
//reg is_inside;

//minimum point
reg [9:0] x_temp;
reg [9:0] y_temp;
reg [9:0] r_temp;
//compare minimum point
reg [9:0] xx_temp;
reg [9:0] yy_temp;
reg [9:0] rr_temp;

reg [3:0] counter_ordering_minimum;


//confirm order whether finish or not

reg done_ordering_1;

//counter x,y loop
reg [3:0] counter;

//store x,y ,r array;
reg  [9:0]x_array[0:6];
reg  [9:0]y_array[0:6];
reg [10:0]r_array[0:6];


//store  vector 

reg [9:0]x_vector[0:4];
reg [9:0]y_vector[0:4];
reg [9:0]x_y_vector[0:4];

//final order point
reg  [9:0]x_final_array[0:6];
reg  [9:0]y_final_array[0:6];
reg [10:0]r_final_array[0:6];

reg  [9:0]x_final_temp_array_1;
reg  [9:0]y_final_temp_array_1;
reg [10:0]r_final_temp_array_1;

reg  [9:0]x_final_temp_array_2;
reg  [9:0]y_final_temp_array_2;
reg [10:0]r_final_temp_array_2;

reg  [9:0]x_final_temp_less_array[0:6];
reg  [9:0]y_final_temp_less_array[0:6];
reg [10:0]r_final_temp_less_array[0:6];

reg  [9:0]x_final_temp_greater_array[0:6];
reg  [9:0]y_final_temp_greater_array[0:6];
reg [10:0]r_final_temp_greater_array[0:6];

reg  [9:0]x_temp_greater_array[0:6];
reg  [9:0]y_temp_greater_array[0:6];
reg [10:0]r_temp_greater_array[0:6];

//FSM begin 
parameter [2:0] IDLE = 0,CALCULATE_BOTTOM_LEFT_POINT = 1,CALCULATE_ORDERING = 2,CALCULATE_AREA = 3,COMPLETE = 4;
reg[2:0]Q,Q_NEXT;


reg done_bottom_left_point;
reg done_ordering;
reg confirm_valid;
reg [1:0]double_check_done;

always@(posedge clk)begin
    if(reset)
        Q <=IDLE;
    else 
        Q <=Q_NEXT;
end

always@(*)begin
    case(Q)
        IDLE:
            Q_NEXT = CALCULATE_BOTTOM_LEFT_POINT;
        
        CALCULATE_BOTTOM_LEFT_POINT:
            if(done_bottom_left_point) Q_NEXT = CALCULATE_ORDERING ;
            else Q_NEXT = CALCULATE_BOTTOM_LEFT_POINT;
        CALCULATE_ORDERING:
            if(done_ordering) Q_NEXT = CALCULATE_AREA;
            else Q_NEXT = CALCULATE_ORDERING;
        CALCULATE_AREA:
            if(valid) Q_NEXT = COMPLETE;
            else Q_NEXT = CALCULATE_AREA;
        COMPLETE:
            Q_NEXT = IDLE;
        default:
            Q_NEXT = IDLE;
    endcase
end
//FSM end
//assign valid = (confirm_valid == )
//todo assign done_ordering = in_level
//signal controller

// counter store x y array
always@(posedge clk)begin
    if(reset)
        counter <=0;
    else
        counter <= (counter == 6)? counter : counter + 1;
end

always@(posedge clk)begin
    if(done_bottom_left_point)
        counter_ordering_minimum <= (counter_ordering_minimum == 6)? counter_ordering_minimum : counter_ordering_minimum + 1;
        
    else
        counter_ordering_minimum <=1;
end


integer  i;
integer  j;
integer  k;
integer  z;
integer  u;
integer  w;
//Calculate six points ordering
always@(posedge clk)begin
    case(Q)

        CALCULATE_BOTTOM_LEFT_POINT:
            if(counter<6)begin//input x,y,r to array 
                x_array[counter] <= X;
                y_array[counter] <= Y;
                r_array[counter] <= R;
            end
            //start to find the bottom left point 
            else if(counter==6)begin
                for(i=6;i>0;i--)begin
                    for(j=0;j<i-1;j++)begin
                        if(x_array[j]>=x_array[j+1])begin
                            x_temp          <=x_array[j];
                            x_array[j]      <=x_array[j+1];
                            x_array[j+1]    <=x_temp;

                            y_temp          <=y_array[j];
                            y_array[j]      <=y_array[j+1];
                            y_array[j+1]    <=y_temp;

                            r_temp          <=r_array[j];
                            r_array[j]      <=r_array[j+1];
                            r_array[j+1]    <=r_temp;
                        end
                    end
                    if(i==0)begin
                        done_ordering_1 <= 1;
                    end
                end
                
                
            end

            
            else if(counter==6&&done_ordering_1==1)begin
                
                xx_temp <=  x_array[0];
                yy_temp <=  y_array[0];
                rr_temp <=  r_array[0]; 
                /*
                for(j=1;j<5;j=j+1)begin
                    

                    if(x_array[j]==xx_temp)begin
                        if(y_array[j]>yy_temp)begin
                        
                        end
                    end   
                end*/

                //counter how much point's x equare = x_array[0];
                for(j=1;j<5;j=j+1)begin
                    if(x_array[j]==xx_temp)
                        counter_ordering_minimum <= counter_ordering_minimum + 1; 
                end
                //find the most left and most down point
                if(j==5)begin
                    for(i=counter_ordering_minimum;i>0;i=i+1)begin
                        for(k=0;k<i-1;k=k+1)begin
                            if(y_array[k]>y_array[k+1])begin
                                yy_temp <= y_array[k];
                                y_array[k+1] <= y_array[k];
                                y_array[k] <= yy_temp;

                                xx_temp          <=x_array[j];
                                x_array[j]      <=x_array[j+1];
                                x_array[j+1]    <=xx_temp;

                                rr_temp          <=r_array[j];
                                r_array[j]      <=r_array[j+1];
                                r_array[j+1]    <=rr_temp;
                            end
                        end
                        if(i==0)begin
                            done_bottom_left_point <= 1;
                            //base vector
                            x_vector[0] <= x_array[1] - x_array[0];
                            y_vector[0] <= y_array[1] - y_array[0];
                            
                
                            x_vector[1] <= x_array[2] - x_array[0];
                            y_vector[1] <= y_array[2] - y_array[0];
                            

                            x_vector[2] <= x_array[3] - x_array[0];
                            y_vector[2] <= y_array[3] - y_array[0];
                          

                            x_vector[3] <= x_array[4] - x_array[0];
                            y_vector[3] <= y_array[4] - y_array[0];
                           

                            x_vector[4] <= x_array[5] - x_array[0];
                            y_vector[4] <= y_array[5] - y_array[0];
                            
                        end
                    end
                    
                end

            end
            //finish find bottom left point

            CALCULATE_ORDERING:
                
                //排出做外積後是正是負
                if(counter_ordering_minimum<6)begin
                    i <= 0;
                    j <= 0; 
                   if((x_vector[0]*x_vector[counter_ordering_minimum]- y_vector[0]*y_vector[counter_ordering_minimum]) < 0 )begin
                       
                       
                       x_final_temp_less_array[i] <= x_array[counter_ordering_minimum];
                       y_final_temp_less_array[i] <= y_array[counter_ordering_minimum];
                       r_final_temp_less_array[i] <= r_array[counter_ordering_minimum];
                       i<=i+1;
                   end
                   
                   else if((x_vector[0]*x_vector[counter_ordering_minimum]- y_vector[0]*y_vector[counter_ordering_minimum]) > 0)begin
                       x_final_temp_greater_array[j] <= x_array[counter_ordering_minimum];
                       y_final_temp_greater_array[j] <= y_array[counter_ordering_minimum];
                       r_final_temp_greater_array[j] <= r_array[counter_ordering_minimum];
                       j<=j+1;
                   end
                end
                //調整正的順序和負的順序
                else if(counter_ordering_minimum==6)begin
                    
                    for(k = i; k>0;k=k-1)begin
                        for(z = 0; z<k-1;z=z+1)begin
                            if(x_final_temp_less_array[z]>x_final_temp_less_array[z+1])begin
                                x_final_temp_array_1              <= x_final_temp_less_array[z];
                                x_final_temp_less_array[z]        <= x_final_temp_less_array[z+1];
                                x_final_temp_less_array[z+1]      <=  x_final_temp_array_1;

                                y_final_temp_array_1              <= y_final_temp_less_array[z];
                                y_final_temp_less_array[z]        <= y_final_temp_less_array[z+1];
                                y_final_temp_less_array[z+1]      <=  y_final_temp_array_1;

                                r_final_temp_array_1              <= r_final_temp_less_array[z];
                                r_final_temp_less_array[z]        <= r_final_temp_less_array[z+1];
                                r_final_temp_less_array[z+1]      <=  r_final_temp_array_1;


                            end
                        end
                        if(k==0)begin
                            double_check_done = double_check_done + 1;
                            
                        end
                    end
                    for(u = 6-i; u>0;u=u-1)begin
                        for(w = 0; w<u-1;w=w+1)begin
                            if(x_final_temp_greater_array[w]>x_final_temp_greater_array[w+1])begin
                                x_final_temp_array_2              <= x_final_temp_greater_array[w];
                                x_final_temp_greater_array[w]        <= x_final_temp_greater_array[w+1];
                                x_final_temp_greater_array[w+1]      <=  x_final_temp_array_2;

                                y_final_temp_array_2              <= y_final_temp_greater_array[w];
                                y_final_temp_greater_array[w]        <= y_final_temp_greater_array[w+1];
                                y_final_temp_greater_array[w+1]      <=  y_final_temp_array_2;

                                r_final_temp_array_2              <= r_final_temp_greater_array[w];
                                r_final_temp_greater_array[w]        <= r_final_temp_greater_array[w+1];
                                r_final_temp_greater_array[w+1]      <=  r_final_temp_array_2;
                            
                            end
                        end
                        if(u==0)begin
                            double_check_done = double_check_done + 1;
                        end
                    end
                end

                else if(counter_ordering_minimum==6 && double_check_done>=2)begin
                        
                        //TODO: x_final_array有6個，但是x_final_temp_less_array,x_final_temp_greater_array也各有6個，這樣會變12個
                        //x_final_array[0:6] <= {x_final_temp_less_array[0:i],x_final_temp_greater_array[0:6-i]};
                        
                        //y_final_array[0:6] <= {y_final_temp_less_array[0:i],y_final_temp_greater_array[0:6-i]};
                        
                        //r_final_array[0:6] <= {r_final_temp_less_array[0:i],r_final_temp_greater_array[0:6-i]};

                    for(k=0;k<i;k++)begin
                        x_final_array[k] <= x_final_temp_less_array[k];
                        y_final_array[k] <= y_final_temp_less_array[k];
                        r_final_array[k] <= r_final_temp_less_array[k];
                    end
                    if(k==i)begin
                        for(u=0;u<j;u++)begin
                            if(k!=6)begin
                                x_final_array[k] <= x_final_temp_greater_array[u];
                                y_final_array[k] <= y_final_temp_greater_array[u];
                                r_final_array[k] <= r_final_temp_greater_array[u];
                                k <= k+1;
                            end
                            if(u==j)begin
                                //finish ordering
                                done_ordering <= 1; 
                            end
                        end
                    end
                    
                    
                end








                
            

        
        //default:



    endcase

    


end

//x_final_array[k] 
//y_final_array[k] 
//r_final_array[k]
always@(posedge clk)begin
    case(Q)
        CALCULATE_AREA:

        
    endcase
end 



endmodule

