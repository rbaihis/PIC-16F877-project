 /*
                        @ using pic 16f877

     lib included { #ADC #Conversions #C_Math #C_string #EEPROM   #LCD & LCD_Constants #sound }
*/


//simple_func
void blink_ledRed_n_sec( unsigned char secds );
void ledblue_on_for_ms( unsigned int time_ms );
void ledgreen_on_for_ms( unsigned int time_ms );

// read _ write eeprom
void write_in_eeprom(short eeprom_adr ,char text[]  );
char* read_from_eeprom(short start_address , short end_address  );

// display funct
void welcome_msg( );
void display_on_ligne_1( char msg[] , char clear_lcd_1_or_0  );
void display_on_ligne_2( char msg[] , char clear_lcd_1_or_0  );
void display_medication_for_n_sec( short eeprom_add_1 , short eeprom_add_1_end , short eeprom_add_2 , short eeprom_add_2_end , unsigned short  how_many_times_desplay_1s_msg  );
// end isplay funct

// temperatur functions
void initialise_lcd();
void template_lcd_temperature_display( );
float get_temperature_value(  unsigned int  analog_data  );
char * stringify_temp_value_and_flag_display_temp_option( float temperature);
// End Temperatur functions

// interrupt
//init_interrupt
void activate_rb0_interrupt();
void activate_rb4_to_rb7_interrupt();
void activate_and_set_TMR0_interrupt( short Prediv_1_2_4_8_16_32_64_128_256 ,short tmr_reg_val_0_to_256 , unsigned char NB_val );
// interr_func
void interrupt();
// end enterrupt




//LCD MODULE Connections
sbit LCD_RS at RC2_bit; // LCD reset
sbit LCD_EN at RC3_bit; //LCD enable

sbit LCD_D4 at RC4_bit; //Data
sbit LCD_D5 at RC5_bit; //DATA
sbit LCD_D6 at RC6_bit; //DATA
sbit LCD_D7 at RC7_bit; //DATA

//LCD Pin Direction

sbit LCD_RS_Direction at TRISC2_bit;
sbit LCD_EN_Direction at TRISC3_bit;
sbit LCD_D4_Direction at TRISC4_bit;
sbit LCD_D5_Direction at TRISC5_bit;
sbit LCD_D6_Direction at TRISC6_bit;
sbit LCD_D7_Direction at TRISC7_bit;



//*****define macros  and constant **********
// output macros
#define ledr PORTD.RD0
#define ledg PORTD.RD1
#define ledb PORTD.RD2
#define buzzer PORTD.RD4
#define motor_clockwise PORTD.RD6
#define motor_counterclockwise PORTD.RD7
//input macros
#define button_rb0 PORTB.RB0
#define button_rb4 PORTB.RB4
#define button_rb5 PORTB.RB5
// msg
#define nom_patient "Mr yourName"
#define msg_welcome "Have a good time"

//flags for display
char flag_display_temp_msg_lcd=0; // used to call lcd display msg once if changed
char flag_display_welcome_msg_lcd=0;
char flag_display_medicine_msg_lcd=0;
char flag_store_position=0; //  0 in closed/ 1 open
unsigned char NB;
unsigned char fix_val_affect_to_NB_inside_interrupt_call;
// for eeprom use
char msg_med_1[]="Ebixa 10mg 2/j";
char msg_med_2[]="Aricept 10mg 3/j";
short msg_med1_add=0x00;
short msg_med2_add=0x17;

void main() {
float temp;
char * temp_val_in_string;

//---------configuration des port ------------------
TRISA=0b00000001; // trisa.RA0 -> temperature analog input received
TRISB=0b00110001; // dedicated for inputs and interruption
TRISC=0b00000000; // dedicated for output  lcd + other stuff
TRISD=0b00000000; // dedicated for output leds (r-g-y) + sounds +
//---------------------------------------------------


// -_-_-_- initialization -_-_-_-_-_
ledr=0;
ledg=0; // all led off
ledb=0;
motor_clockwise=0;       // engine off
motor_counterclockwise=0;
write_in_eeprom(msg_med1_add ,msg_med_1  ); // saving persistent data in eeprom for later use
write_in_eeprom(msg_med2_add ,msg_med_2  ); // saving persistent data in eeprom for later use
Sound_Init(&PORTD,3);  // PORTD.RD3 --> buzzer/sound output
initialise_lcd();  // func_do( init lcd + f$hide cursor + clear lcd )
welcome_msg();//  func_write_on_lcd( name + welcomemsg)
ADC_Init(); // Analog to Digital Converter initialisation
//-_-_-_-_End init-_-_-_-_-_-_-_-__-_--__--__-_-_-_-


//*** interrupt config ***
activate_rb0_interrupt();
activate_rb4_to_rb7_interrupt();


/* TMR0 problem :
   initiate TMR0 to be execute every 8s using 4Mhz µController

   µController_Cycle = 1/Freq/4 = (1/4000000hz)*(4)= 1/1000000 = 1µs
   solution : 8s = 8000000µs = NB*(256 - initial value )*( µController_Cycle )*(PreDIV)
   NB= (8000000µs)/(256 - initi_val_tmr0 )*( µController_Cycle )*(PreDIV)
   NB= (8000000µs)/(256-init_v_T)*(1µs)*(PreDIV)
   8000000= NB*(256-x)(1)(y) -> where better if  NB <= 255 ( the lowest the value the better);
   8000000= NB(256-0)(y) =NB(256)(y)
   8000000=NB(256)(256)
   NB =~ 122;
                                                                                   // 2^0   2^1   2^2  ... 2^7   2^8    */
activate_and_set_TMR0_interrupt( 256 ,0,122 );// chose PreDIVISOR is 2^n from power [ 1  or  2 or 4, ···· ,128 or 256] .
//****** End enterrupt config**************




   do{

    //goto tag to immidiatly execute and emulate TMR0 behavior
    execute_tmr0:

      // this is used as TEM0 interrupt for fast execution, if ==0  no interrupt, else TEM0 interrupt .
        if( flag_display_medicine_msg_lcd == 0 ){ // why here -> so it can emulate the interrupt behavior and preoritize execution on next loop


            // mesurment of temperature outside of TMR0
            temp=get_temperature_value( ADC_Read(0) ) ;
            //-----------

            if(flag_display_medicine_msg_lcd != 0)// why when timer0 executed it sets this flagg to 1 .
                 goto execute_tmr0;  // avoid executing other instruction when TMR0 action occured

            // to avoid calling display msg unnecessarly everytime we loop
            if( flag_display_welcome_msg_lcd==0 ){
                welcome_msg();  flag_display_welcome_msg_lcd=1; }




        }
         else{

              Sound_Play(1200,200);

              flag_display_temp_msg_lcd=0; // trigger the execution of template_lcd_temperature_display() inside stringify_temp_val()
              temp_val_in_string= stringify_temp_value_and_flag_display_temp_option( temp );
              display_on_ligne_2(  temp_val_in_string , 0);


              // checking temperature
              if(temp > 39)
                   ledblue_on_for_ms( 1000 );
              else if( (temp <= 39) && (temp >37) )
                   ledgreen_on_for_ms( 1000 );
              else
                   blink_ledRed_n_sec( 3 );


              if(temp > 37) // used to not extend display time when blink_ledRed_n_sec()  executed
                 Delay_ms(2000);


               // display medication after TMR0 Interrupt happens
              display_medication_for_n_sec( msg_med1_add , strlen(msg_med_1) , msg_med2_add , strlen(msg_med_2) , 1   );



               //init flags  & NB
              flag_display_medicine_msg_lcd=0;
              flag_display_welcome_msg_lcd=0;
              NB = fix_val_affect_to_NB_inside_interrupt_call; // purpose that TMR0 start counting just after executions ends.
          }


    }while(1);


}//end main




//=*=*=*=*===*=*interrupt  =*=*=*=*=*==**==*=*
void interrupt(  ){

  if(  INTCON.INTF==1 && button_rb0 ==1 ){
      char i;


       for(i=0;i<3;i++){
           ledr=1;
           buzzer=1;
           Delay_ms(500);
           ledr=0;
           Delay_ms(500);
           //buzzer=1;
        }
        buzzer=0;


        INTCON.INTF=0;// bit 1 ==of> reg INTCON ==job> set back to 0 tell that interrupion is finished back to normal
  }
  //-----------
  if( INTCON.RBIF==1  ){

       if( (button_rb4 ==1) && (flag_store_position == 0)){

         flag_store_position=1;

         motor_clockwise=1;
         motor_counterclockwise=0;
         Delay_ms(2000);
         motor_counterclockwise=0;
         motor_clockwise=0;

         }
          else if( (button_rb5 ==1) && ( flag_store_position == 1) ){
               flag_store_position= 0;
                motor_counterclockwise=1;
                motor_clockwise=0;
                Delay_ms(2000);
                motor_clockwise=0;
                motor_counterclockwise=0;
            }
             else{
                  INTCON.RBIF=0;
              }

         INTCON.RBIF=0;// bit 0 ==of> reg INTCON ==job> set back to 0 tell that interrupion is finished back to regular mode
     }

     //----------------------
     if (INTCON.T0IE && INTCON.T0IF)
     {
         INTCON.T0IF=0; // turn of interrupt

         --NB; //decrement NB until we reach 0 => job:  this helps extend the duration on witch we wants to execute our code

         if (NB==0){

            flag_display_medicine_msg_lcd=1;
            NB=fix_val_affect_to_NB_inside_interrupt_call;
            TMR0=0;
            INTCON.T0IF = 0;
          }


     }

}// END interrupt()



//-------
void activate_rb0_interrupt(){
//-*******RB0 CONFIG interrupt  *******
//=============================================================================
// INTCON reg |bit 7|bit 6|bit 5| bit 4 |bit 3 |bit 2|bit 1 | bit 0|;
//            | GIE | ... | ... | INTE  | ...  | ... | INTF | ...  |;
//=============================================================================
INTCON.GIE=1; //bit 7 ==of> INTCON -> activate interreption
INTCON.INTE=1;// bit 4 ==of> reg INTCON  -> activate rb0 interruption
//-----------------------------------------------------------------------------
//===============OPTION_REG==================================================
// OPTION_REG reg |bit 7|bit 6  |bit 5 |bit 4|bit 3 |bit 2|bit 1 | bit 0|;
//                | ... |INTEDG | ...  | ... | ... | ... |  ...  |  ... |;
OPTION_REG.INTEDG=1; // bit 6 ==of> reg OPTION_REG -> transition from 0 -to-> 1
//***** End RB0 INTER CONFIG****************************
}


//-------------


void activate_rb4_to_rb7_interrupt(){
//-*******RB4->rb7 CONFIG interrupt  *******
//=============================================================================
// INTCON reg |bit 7|bit 6|bit 5|bit 4 |bit 3 |bit 2|bit 1 | bit 0|;
//            | GIE | ... | ... |  ... | RBIE | ... | ...  | RBIF |;
//=============================================================================
INTCON.GIE=1; //bit 7 ==of> INTCON -> activate interreption
INTCON.RBIE=1;// bit 3 ==of> reg INTCON  -> activate rb4->rb7 interruption
//***** End RB4->rb7 INTER CONFIG****************************
}


//---------------


void activate_and_set_TMR0_interrupt(  short Prediv_1_2_4_8_16_32_64_128_256 , short tmr_reg_val_0_to_256 , unsigned char NB_val ){
//-*******TMR0 CONFIG interrupt  *******
//================INTCON reg==========================================
// INTCON reg |bit 7|bit 6| bit 5 | bit 4|bit 3|bit 2|bit 1|bit 0|;
//            | GIE | ... | TOIE  | ...  | ... | ... | ... | ... |;
//=============================================================================
//===============OPTION_REG==================================================
// OPTION_REG reg |bit 7|bit 6|bit 5 | bit 4 |bit 3 |bit 2|bit 1 | bit 0|;
//                |     | ... | TOCS |       | PSA | PS2  | PS1  | PS0  |;
/*
  TOCS { if == 0 -> MODE TIMER ; if == 1 ->MODE COUNTER ; }
  PSA  { if == 0 -> associate "preDIVISOR" to TIMER0 ;
        if == 1 -> DO NOT associate "preDIVISOR" TO TIMER0 ;  }
  PS2,PS1,PS0 { CONFIGbits for "PREDIVISOR"'s VALUE table below ;}
  =======================================================
   OPTION_REG reg  ||PSA||PS2 |PS1|PS0||prediv or /tmr0||
                   || 0  || 0 | 0 | 0 ||   2           ||
                   || 0  || 0 | 0 | 1 ||   4           ||
                   || 0  || 0 | 1 | 0 ||   8           ||
                   || 0  || 0 | 1 | 1 ||   16          ||
                   || 0  || 1 | 0 | 0 ||   32          ||
                   || 0  || 1 | 0 | 1 ||   64          ||
                   || 0  || 1 | 1 | 0 ||   128         ||
                   || 0  || 1 | 1 | 1 ||   256         ||
   ======================================================
Formula : { µController_cycle = 4/(µController_Frequency_in_Hz) ;}
Formula :{ INT_TMR0_Cycle_Every = (256 - Reg_Init_Val)*(µController_cycle)*(PreDIVISIOR_Val) ; }
Formula :{  Duration_desired = ( Number_of_Interrps )*(INT_TMR0_Cycle_Every) ;
            => Dur_d = (nb_interps)*(256 - Reg_Init_Val)*(µController_cycle)*(PreDIVISIOR_Val) ;}
Formula :{ nb_interps -> must be <= 255 ;
           nb_interps = (Dur_d) /(INT_TMR0_Cycle_Every_)
           nb_interps = (Dur_d)/(256 - Reg_Init_Val)*(µController_cycle)*(PreDIVISIOR_Val) ;}
*///=============================================================================
//*** TMR0 config******
   INTCON.GIE=1;
   INTCON.T0IE=1;
   OPTION_REG.T0CS=0;
   TMR0=tmr_reg_val_0_to_256;
    NB = NB_val;
   // fixed_val_aff -> used to NOT manually set NB in interrupt() since i cant pass argument to interrupt().
   fix_val_affect_to_NB_inside_interrupt_call = NB_val;  // look at interupt() to get the idea;
//-------
   if( Prediv_1_2_4_8_16_32_64_128_256 == 1 ){
     OPTION_REG.PSA=1; // DO NOT associate PreDIV au Timer -> PreDiv=1 default.
     }
      else{
           //*** PreDIV table setting***
           /* !note! chose Prediv value with respect to nb_interps and dur_d such that nb_intrps <=255;  */

              OPTION_REG.PSA=0;// Associate a PreDIV to TIMER from 2 --to-> 256 .

              switch( Prediv_1_2_4_8_16_32_64_128_256 ){

                     case 2: // 2 = 0 0 0
                          OPTION_REG.PS2=0;
                          OPTION_REG.PS1=0;
                          OPTION_REG.PS0=0;
                     break;
                     //---------
                     case 4: // 4= 0 0 1
                          OPTION_REG.PS2=0;
                          OPTION_REG.PS1=0;
                          OPTION_REG.PS0=1;
                     break;
                     //---------
                     case 8: // 8= 0 1 0
                          OPTION_REG.PS2=0;
                          OPTION_REG.PS1=1;
                          OPTION_REG.PS0=0;
                     break;
                     //---------
                     case 16: // 16= 0 1 1
                          OPTION_REG.PS2=0;
                          OPTION_REG.PS1=1;
                          OPTION_REG.PS0=1;
                     break;
                     //---------
                     case 32: // 32= 1 0 0
                          OPTION_REG.PS2=1;
                          OPTION_REG.PS1=0;
                          OPTION_REG.PS0=0;
                     break;
                     //---------
                     case 64: // 64= 1 0 1
                          OPTION_REG.PS2=1;
                          OPTION_REG.PS1=0;
                          OPTION_REG.PS0=1;
                     break;
                     //---------
                     case 128: // 128= 1 1 0
                          OPTION_REG.PS2=1;
                          OPTION_REG.PS1=1;
                          OPTION_REG.PS0=0;
                     break;
                     //---------
                     case 256: // 256= 1 1 1
                          OPTION_REG.PS2=1;
                          OPTION_REG.PS1=1;
                          OPTION_REG.PS0=1;
                     break;
                     //---------
                     default:
                             return;
              //-----End Prediv_value_settings-------------------------------
              }
           }
//***** End TMR0 config ******************
}

//=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=**=*=*=*=*=*=*=*
//*=*=*=*=*=**=end interrupt functions *=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*




//simple_func================================================
void blink_ledRed_n_sec( unsigned char secds ){ char i;
  for(i=0; i<secds ;i++){
     ledr=1;
     Delay_ms(500);
     ledr=0;
     Delay_ms(500);
   }
}
//-----------
void ledblue_on_for_ms( unsigned int time_ms){
     ledb=1;
     while( 0< time_ms ){  Delay_ms(1); --time_ms;  }
     ledb=0;
 }
//-----------
void ledgreen_on_for_ms( unsigned int time_ms){
     ledg=1;
     while( 0< time_ms ){  Delay_ms(1); --time_ms;  }
     ledg=0;
 }
//===========================================================================










//-_-_-_-_-_--__other functions -_-_-_-_-_-_--_-_-_-_-_-_-_-
void welcome_msg(  ){
Lcd_cmd(_LCD_CLEAR);
// nom_ patien and msg_welcome are  #defined as constatnt before main
display_on_ligne_1( nom_patient , 0 );
display_on_ligne_2( msg_welcome , 0 );
}
//--------------
void write_in_eeprom(short eeprom_adr ,char  text[]  )
{
char i;
 for(i=0;i<strlen(text);i++){
  EEPROM_Write(eeprom_adr++, text[i] );
  delay_ms(20); }
}
//-----------------
char* read_from_eeprom(short start_address , short end_address  )
{
char i;
char text[16];

 for( i=0;i<end_address ;i++){
     text[i]= EEPROM_Read( start_address+i ) ;
     delay_ms(20);  }

     return text;
}

//------------
void display_medication_for_n_sec( short eeprom_add_1 , short eeprom_add_1_end , short eeprom_add_2 , short eeprom_add_2_end , unsigned char  how_many_times_desplay_1s_msg  ){
     char i;
      display_on_ligne_1(  read_from_eeprom(  eeprom_add_1 , eeprom_add_1_end ) , 1  );
      display_on_ligne_2(  read_from_eeprom(  eeprom_add_2 , eeprom_add_2_end ) , 0  );

      for( i=0 ;i< how_many_times_desplay_1s_msg ; i++ )
           Delay_ms( (1000) );

      //template_lcd_temperature_display(); // put back temp msg if necessary
      //flag_display_welcome_msg_lcd=0;  // show welcome msg if necessary

}

//---------
void display_on_ligne_1( char * msg , char clear_lcd_1_or_0 ){

     if(clear_lcd_1_or_0==1 )
           Lcd_cmd(_LCD_CLEAR);

     Lcd_out(1,1,msg);
}
//---------
void display_on_ligne_2( char * msg  , char clear_lcd_1_or_0 ){

     if(clear_lcd_1_or_0==1 )
           Lcd_cmd(_LCD_CLEAR);

      Lcd_out(2,1,msg);

}


void initialise_lcd(){
    Lcd_Init();  // init output lcd
    Lcd_Cmd(_LCD_CLEAR ); // clear lcd
    Lcd_Cmd(_LCD_CURSOR_OFF ); // dont show cursor
}




 //--_-_--_-_--temperature functions-_-_-_
void template_lcd_temperature_display( ){
    Lcd_Cmd(_LCD_CLEAR );
    Lcd_Out(1,1, "Temperature : " );
    Lcd_Chr(2,7,223); // getting character by ascii value 167->º
    Lcd_Chr(2,8,'C');

}
 //-------
float get_temperature_value(  unsigned int  analog_data   ){

    float  temperature;
    float millivolts= analog_data;
    millivolts= millivolts*5000.0/1024.0; // scaling input millvolts to be able to get data from sensor
    temperature=  millivolts/10 ; // only a few millivolts (mV) for a 10ºC change in temperature after scaling we devide to get as close to 1°

    return temperature ;

}
//--------------
char * stringify_temp_value_and_flag_display_temp_option( float temperature){
    char temp_string[5];// msg will start from 1 to index 6 on lcd
    floatToStr( temperature , temp_string );

    temp_string[5]='\0';
    // call back the temlate lcd for temperature 1 time if overwriten using flags.
    if( flag_display_temp_msg_lcd==0){
        template_lcd_temperature_display( );
        flag_display_temp_msg_lcd=1;
    }
    return temp_string;
}
//-_-_-_-_-_-_--_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-