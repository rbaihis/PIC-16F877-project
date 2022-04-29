#line 1 "C:/Users/rbaih/Downloads/week_4_update/mikro_c file project_ week 4/update_week4_project.c"
#line 9 "C:/Users/rbaih/Downloads/week_4_update/mikro_c file project_ week 4/update_week4_project.c"
void blink_ledRed_n_sec( unsigned char secds );
void ledblue_on_for_ms( unsigned int time_ms );
void ledgreen_on_for_ms( unsigned int time_ms );


void write_in_eeprom(short eeprom_adr ,char text[] );
char* read_from_eeprom(short start_address , short end_address );


void welcome_msg( );
void display_on_ligne_1( char msg[] , char clear_lcd_1_or_0 );
void display_on_ligne_2( char msg[] , char clear_lcd_1_or_0 );
void display_medication_for_n_sec( short eeprom_add_1 , short eeprom_add_1_end , short eeprom_add_2 , short eeprom_add_2_end , unsigned short how_many_times_desplay_1s_msg );



void initialise_lcd();
void template_lcd_temperature_display( );
float get_temperature_value( unsigned int analog_data );
char * stringify_temp_value_and_flag_display_temp_option( float temperature);




void activate_rb0_interrupt();
void activate_rb4_to_rb7_interrupt();
void activate_and_set_TMR0_interrupt( short Prediv_1_2_4_8_16_32_64_128_256 ,short tmr_reg_val_0_to_256 , unsigned char NB_val );

void interrupt();






sbit LCD_RS at RC2_bit;
sbit LCD_EN at RC3_bit;

sbit LCD_D4 at RC4_bit;
sbit LCD_D5 at RC5_bit;
sbit LCD_D6 at RC6_bit;
sbit LCD_D7 at RC7_bit;



sbit LCD_RS_Direction at TRISC2_bit;
sbit LCD_EN_Direction at TRISC3_bit;
sbit LCD_D4_Direction at TRISC4_bit;
sbit LCD_D5_Direction at TRISC5_bit;
sbit LCD_D6_Direction at TRISC6_bit;
sbit LCD_D7_Direction at TRISC7_bit;
#line 80 "C:/Users/rbaih/Downloads/week_4_update/mikro_c file project_ week 4/update_week4_project.c"
char flag_display_temp_msg_lcd=0;
char flag_display_welcome_msg_lcd=0;
char flag_display_medicine_msg_lcd=0;
char flag_store_position=0;
unsigned char NB;
unsigned char fix_val_affect_to_NB_inside_interrupt_call;

char msg_med_1[]="Ebixa 10mg 2/j";
char msg_med_2[]="Aricept 10mg 3/j";
short msg_med1_add=0x00;
short msg_med2_add=0x17;

void main() {
float temp;
char * temp_val_in_string;


TRISA=0b00000001;
TRISB=0b00110001;
TRISC=0b00000000;
TRISD=0b00000000;




 PORTD.RD0 =0;
 PORTD.RD1 =0;
 PORTD.RD2 =0;
 PORTD.RD6 =0;
 PORTD.RD7 =0;
write_in_eeprom(msg_med1_add ,msg_med_1 );
write_in_eeprom(msg_med2_add ,msg_med_2 );
Sound_Init(&PORTD,3);
initialise_lcd();
welcome_msg();
ADC_Init();




activate_rb0_interrupt();
activate_rb4_to_rb7_interrupt();
#line 136 "C:/Users/rbaih/Downloads/week_4_update/mikro_c file project_ week 4/update_week4_project.c"
activate_and_set_TMR0_interrupt( 256 ,0,122 );





 do{


 execute_tmr0:


 if( flag_display_medicine_msg_lcd == 0 ){



 temp=get_temperature_value( ADC_Read(0) ) ;


 if(flag_display_medicine_msg_lcd != 0)
 goto execute_tmr0;


 if( flag_display_welcome_msg_lcd==0 ){
 welcome_msg(); flag_display_welcome_msg_lcd=1; }




 }
 else{

 Sound_Play(1200,200);

 flag_display_temp_msg_lcd=0;
 temp_val_in_string= stringify_temp_value_and_flag_display_temp_option( temp );
 display_on_ligne_2( temp_val_in_string , 0);



 if(temp > 39)
 ledblue_on_for_ms( 1000 );
 else if( (temp <= 39) && (temp >37) )
 ledgreen_on_for_ms( 1000 );
 else
 blink_ledRed_n_sec( 3 );


 if(temp > 37)
 Delay_ms(2000);



 display_medication_for_n_sec( msg_med1_add , strlen(msg_med_1) , msg_med2_add , strlen(msg_med_2) , 1 );




 flag_display_medicine_msg_lcd=0;
 flag_display_welcome_msg_lcd=0;
 NB = fix_val_affect_to_NB_inside_interrupt_call;
 }


 }while(1);


}





void interrupt( ){

 if( INTCON.INTF==1 &&  PORTB.RB0  ==1 ){
 char i;


 for(i=0;i<3;i++){
  PORTD.RD0 =1;
  PORTD.RD4 =1;
 Delay_ms(500);
  PORTD.RD0 =0;
 Delay_ms(500);

 }
  PORTD.RD4 =0;


 INTCON.INTF=0;
 }

 if( INTCON.RBIF==1 ){

 if( ( PORTB.RB4  ==1) && (flag_store_position == 0)){

 flag_store_position=1;

  PORTD.RD6 =1;
  PORTD.RD7 =0;
 Delay_ms(2000);
  PORTD.RD7 =0;
  PORTD.RD6 =0;

 }
 else if( ( PORTB.RB5  ==1) && ( flag_store_position == 1) ){
 flag_store_position= 0;
  PORTD.RD7 =1;
  PORTD.RD6 =0;
 Delay_ms(2000);
  PORTD.RD6 =0;
  PORTD.RD7 =0;
 }
 else{
 INTCON.RBIF=0;
 }

 INTCON.RBIF=0;
 }


 if (INTCON.T0IE && INTCON.T0IF)
 {
 INTCON.T0IF=0;

 --NB;

 if (NB==0){

 flag_display_medicine_msg_lcd=1;
 NB=fix_val_affect_to_NB_inside_interrupt_call;
 TMR0=0;
 INTCON.T0IF = 0;
 }


 }

}




void activate_rb0_interrupt(){





INTCON.GIE=1;
INTCON.INTE=1;




OPTION_REG.INTEDG=1;

}





void activate_rb4_to_rb7_interrupt(){





INTCON.GIE=1;
INTCON.RBIE=1;

}





void activate_and_set_TMR0_interrupt( short Prediv_1_2_4_8_16_32_64_128_256 , short tmr_reg_val_0_to_256 , unsigned char NB_val ){
#line 349 "C:/Users/rbaih/Downloads/week_4_update/mikro_c file project_ week 4/update_week4_project.c"
 INTCON.GIE=1;
 INTCON.T0IE=1;
 OPTION_REG.T0CS=0;
 TMR0=tmr_reg_val_0_to_256;
 NB = NB_val;

 fix_val_affect_to_NB_inside_interrupt_call = NB_val;

 if( Prediv_1_2_4_8_16_32_64_128_256 == 1 ){
 OPTION_REG.PSA=1;
 }
 else{



 OPTION_REG.PSA=0;

 switch( Prediv_1_2_4_8_16_32_64_128_256 ){

 case 2:
 OPTION_REG.PS2=0;
 OPTION_REG.PS1=0;
 OPTION_REG.PS0=0;
 break;

 case 4:
 OPTION_REG.PS2=0;
 OPTION_REG.PS1=0;
 OPTION_REG.PS0=1;
 break;

 case 8:
 OPTION_REG.PS2=0;
 OPTION_REG.PS1=1;
 OPTION_REG.PS0=0;
 break;

 case 16:
 OPTION_REG.PS2=0;
 OPTION_REG.PS1=1;
 OPTION_REG.PS0=1;
 break;

 case 32:
 OPTION_REG.PS2=1;
 OPTION_REG.PS1=0;
 OPTION_REG.PS0=0;
 break;

 case 64:
 OPTION_REG.PS2=1;
 OPTION_REG.PS1=0;
 OPTION_REG.PS0=1;
 break;

 case 128:
 OPTION_REG.PS2=1;
 OPTION_REG.PS1=1;
 OPTION_REG.PS0=0;
 break;

 case 256:
 OPTION_REG.PS2=1;
 OPTION_REG.PS1=1;
 OPTION_REG.PS0=1;
 break;

 default:
 return;

 }
 }

}








void blink_ledRed_n_sec( unsigned char secds ){ char i;
 for(i=0; i<secds ;i++){
  PORTD.RD0 =1;
 Delay_ms(500);
  PORTD.RD0 =0;
 Delay_ms(500);
 }
}

void ledblue_on_for_ms( unsigned int time_ms){
  PORTD.RD2 =1;
 while( 0< time_ms ){ Delay_ms(1); --time_ms; }
  PORTD.RD2 =0;
 }

void ledgreen_on_for_ms( unsigned int time_ms){
  PORTD.RD1 =1;
 while( 0< time_ms ){ Delay_ms(1); --time_ms; }
  PORTD.RD1 =0;
 }
#line 463 "C:/Users/rbaih/Downloads/week_4_update/mikro_c file project_ week 4/update_week4_project.c"
void welcome_msg( ){
Lcd_cmd(_LCD_CLEAR);

display_on_ligne_1(  "Mr yourName"  , 0 );
display_on_ligne_2(  "Have a good time"  , 0 );
}

void write_in_eeprom(short eeprom_adr ,char text[] )
{
char i;
 for(i=0;i<strlen(text);i++){
 EEPROM_Write(eeprom_adr++, text[i] );
 delay_ms(20); }
}

char* read_from_eeprom(short start_address , short end_address )
{
char i;
char text[16];

 for( i=0;i<end_address ;i++){
 text[i]= EEPROM_Read( start_address+i ) ;
 delay_ms(20); }

 return text;
}


void display_medication_for_n_sec( short eeprom_add_1 , short eeprom_add_1_end , short eeprom_add_2 , short eeprom_add_2_end , unsigned char how_many_times_desplay_1s_msg ){
 char i;
 display_on_ligne_1( read_from_eeprom( eeprom_add_1 , eeprom_add_1_end ) , 1 );
 display_on_ligne_2( read_from_eeprom( eeprom_add_2 , eeprom_add_2_end ) , 0 );

 for( i=0 ;i< how_many_times_desplay_1s_msg ; i++ )
 Delay_ms( (1000) );




}


void display_on_ligne_1( char * msg , char clear_lcd_1_or_0 ){

 if(clear_lcd_1_or_0==1 )
 Lcd_cmd(_LCD_CLEAR);

 Lcd_out(1,1,msg);
}

void display_on_ligne_2( char * msg , char clear_lcd_1_or_0 ){

 if(clear_lcd_1_or_0==1 )
 Lcd_cmd(_LCD_CLEAR);

 Lcd_out(2,1,msg);

}


void initialise_lcd(){
 Lcd_Init();
 Lcd_Cmd(_LCD_CLEAR );
 Lcd_Cmd(_LCD_CURSOR_OFF );
}





void template_lcd_temperature_display( ){
 Lcd_Cmd(_LCD_CLEAR );
 Lcd_Out(1,1, "Temperature : " );
 Lcd_Chr(2,7,223);
 Lcd_Chr(2,8,'C');

}

float get_temperature_value( unsigned int analog_data ){

 float temperature;
 float millivolts= analog_data;
 millivolts= millivolts*5000.0/1024.0;
 temperature= millivolts/10 ;

 return temperature ;

}

char * stringify_temp_value_and_flag_display_temp_option( float temperature){
 char temp_string[5];
 floatToStr( temperature , temp_string );

 temp_string[5]='\0';

 if( flag_display_temp_msg_lcd==0){
 template_lcd_temperature_display( );
 flag_display_temp_msg_lcd=1;
 }
 return temp_string;
}
