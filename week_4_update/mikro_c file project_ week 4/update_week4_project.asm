
_main:

;update_week4_project.c,92 :: 		void main() {
;update_week4_project.c,97 :: 		TRISA=0b00000001; // trisa.RA0 -> temperature analog input received
	MOVLW      1
	MOVWF      TRISA+0
;update_week4_project.c,98 :: 		TRISB=0b00110001; // dedicated for inputs and interruption
	MOVLW      49
	MOVWF      TRISB+0
;update_week4_project.c,99 :: 		TRISC=0b00000000; // dedicated for output  lcd + other stuff
	CLRF       TRISC+0
;update_week4_project.c,100 :: 		TRISD=0b00000000; // dedicated for output leds (r-g-y) + sounds +
	CLRF       TRISD+0
;update_week4_project.c,105 :: 		ledr=0;
	BCF        PORTD+0, 0
;update_week4_project.c,106 :: 		ledg=0; // all led off
	BCF        PORTD+0, 1
;update_week4_project.c,107 :: 		ledb=0;
	BCF        PORTD+0, 2
;update_week4_project.c,108 :: 		motor_clockwise=0;       // engine off
	BCF        PORTD+0, 6
;update_week4_project.c,109 :: 		motor_counterclockwise=0;
	BCF        PORTD+0, 7
;update_week4_project.c,110 :: 		write_in_eeprom(msg_med1_add ,msg_med_1  ); // saving persistent data in eeprom for later use
	MOVF       _msg_med1_add+0, 0
	MOVWF      FARG_write_in_eeprom_eeprom_adr+0
	MOVLW      _msg_med_1+0
	MOVWF      FARG_write_in_eeprom_text+0
	CALL       _write_in_eeprom+0
;update_week4_project.c,111 :: 		write_in_eeprom(msg_med2_add ,msg_med_2  ); // saving persistent data in eeprom for later use
	MOVF       _msg_med2_add+0, 0
	MOVWF      FARG_write_in_eeprom_eeprom_adr+0
	MOVLW      _msg_med_2+0
	MOVWF      FARG_write_in_eeprom_text+0
	CALL       _write_in_eeprom+0
;update_week4_project.c,112 :: 		Sound_Init(&PORTD,3);  // PORTD.RD3 --> buzzer/sound output
	MOVLW      PORTD+0
	MOVWF      FARG_Sound_Init_snd_port+0
	MOVLW      3
	MOVWF      FARG_Sound_Init_snd_pin+0
	CALL       _Sound_Init+0
;update_week4_project.c,113 :: 		initialise_lcd();  // func_do( init lcd + f$hide cursor + clear lcd )
	CALL       _initialise_lcd+0
;update_week4_project.c,114 :: 		welcome_msg();//  func_write_on_lcd( name + welcomemsg)
	CALL       _welcome_msg+0
;update_week4_project.c,115 :: 		ADC_Init(); // Analog to Digital Converter initialisation
	CALL       _ADC_Init+0
;update_week4_project.c,120 :: 		activate_rb0_interrupt();
	CALL       _activate_rb0_interrupt+0
;update_week4_project.c,121 :: 		activate_rb4_to_rb7_interrupt();
	CALL       _activate_rb4_to_rb7_interrupt+0
;update_week4_project.c,136 :: 		activate_and_set_TMR0_interrupt( 256 ,0,122 );// chose PreDIVISOR is 2^n from power [ 1  or  2 or 4, ···· ,128 or 256] .
	MOVLW      0
	MOVWF      FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0
	CLRF       FARG_activate_and_set_TMR0_interrupt_tmr_reg_val_0_to_256+0
	MOVLW      122
	MOVWF      FARG_activate_and_set_TMR0_interrupt_NB_val+0
	CALL       _activate_and_set_TMR0_interrupt+0
;update_week4_project.c,142 :: 		do{
L_main0:
;update_week4_project.c,145 :: 		execute_tmr0:
___main_execute_tmr0:
;update_week4_project.c,148 :: 		if( flag_display_medicine_msg_lcd == 0 ){ // why here -> so it can emulate the interrupt behavior and preoritize execution on next loop
	MOVF       _flag_display_medicine_msg_lcd+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main3
;update_week4_project.c,152 :: 		temp=get_temperature_value( ADC_Read(0) ) ;
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	MOVWF      FARG_get_temperature_value_analog_data+0
	MOVF       R0+1, 0
	MOVWF      FARG_get_temperature_value_analog_data+1
	CALL       _get_temperature_value+0
	MOVF       R0+0, 0
	MOVWF      main_temp_L0+0
	MOVF       R0+1, 0
	MOVWF      main_temp_L0+1
	MOVF       R0+2, 0
	MOVWF      main_temp_L0+2
	MOVF       R0+3, 0
	MOVWF      main_temp_L0+3
;update_week4_project.c,155 :: 		if(flag_display_medicine_msg_lcd != 0)// why when timer0 executed it sets this flagg to 1 .
	MOVF       _flag_display_medicine_msg_lcd+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main4
;update_week4_project.c,156 :: 		goto execute_tmr0;  // avoid executing other instruction when TMR0 action occured
	GOTO       ___main_execute_tmr0
L_main4:
;update_week4_project.c,159 :: 		if( flag_display_welcome_msg_lcd==0 ){
	MOVF       _flag_display_welcome_msg_lcd+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main5
;update_week4_project.c,160 :: 		welcome_msg();  flag_display_welcome_msg_lcd=1; }
	CALL       _welcome_msg+0
	MOVLW      1
	MOVWF      _flag_display_welcome_msg_lcd+0
L_main5:
;update_week4_project.c,165 :: 		}
	GOTO       L_main6
L_main3:
;update_week4_project.c,168 :: 		Sound_Play(1200,200);
	MOVLW      176
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      4
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;update_week4_project.c,170 :: 		flag_display_temp_msg_lcd=0; // trigger the execution of template_lcd_temperature_display() inside stringify_temp_val()
	CLRF       _flag_display_temp_msg_lcd+0
;update_week4_project.c,171 :: 		temp_val_in_string= stringify_temp_value_and_flag_display_temp_option( temp );
	MOVF       main_temp_L0+0, 0
	MOVWF      FARG_stringify_temp_value_and_flag_display_temp_option_temperature+0
	MOVF       main_temp_L0+1, 0
	MOVWF      FARG_stringify_temp_value_and_flag_display_temp_option_temperature+1
	MOVF       main_temp_L0+2, 0
	MOVWF      FARG_stringify_temp_value_and_flag_display_temp_option_temperature+2
	MOVF       main_temp_L0+3, 0
	MOVWF      FARG_stringify_temp_value_and_flag_display_temp_option_temperature+3
	CALL       _stringify_temp_value_and_flag_display_temp_option+0
;update_week4_project.c,172 :: 		display_on_ligne_2(  temp_val_in_string , 0);
	MOVF       R0+0, 0
	MOVWF      FARG_display_on_ligne_2_msg+0
	CLRF       FARG_display_on_ligne_2_clear_lcd_1_or_0+0
	CALL       _display_on_ligne_2+0
;update_week4_project.c,176 :: 		if(temp > 39)
	MOVF       main_temp_L0+0, 0
	MOVWF      R4+0
	MOVF       main_temp_L0+1, 0
	MOVWF      R4+1
	MOVF       main_temp_L0+2, 0
	MOVWF      R4+2
	MOVF       main_temp_L0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      28
	MOVWF      R0+2
	MOVLW      132
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main7
;update_week4_project.c,177 :: 		ledblue_on_for_ms( 1000 );
	MOVLW      232
	MOVWF      FARG_ledblue_on_for_ms_time_ms+0
	MOVLW      3
	MOVWF      FARG_ledblue_on_for_ms_time_ms+1
	CALL       _ledblue_on_for_ms+0
	GOTO       L_main8
L_main7:
;update_week4_project.c,178 :: 		else if( (temp <= 39) && (temp >37) )
	MOVF       main_temp_L0+0, 0
	MOVWF      R4+0
	MOVF       main_temp_L0+1, 0
	MOVWF      R4+1
	MOVF       main_temp_L0+2, 0
	MOVWF      R4+2
	MOVF       main_temp_L0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      28
	MOVWF      R0+2
	MOVLW      132
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSS      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main11
	MOVF       main_temp_L0+0, 0
	MOVWF      R4+0
	MOVF       main_temp_L0+1, 0
	MOVWF      R4+1
	MOVF       main_temp_L0+2, 0
	MOVWF      R4+2
	MOVF       main_temp_L0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      20
	MOVWF      R0+2
	MOVLW      132
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main11
L__main77:
;update_week4_project.c,179 :: 		ledgreen_on_for_ms( 1000 );
	MOVLW      232
	MOVWF      FARG_ledgreen_on_for_ms_time_ms+0
	MOVLW      3
	MOVWF      FARG_ledgreen_on_for_ms_time_ms+1
	CALL       _ledgreen_on_for_ms+0
	GOTO       L_main12
L_main11:
;update_week4_project.c,181 :: 		blink_ledRed_n_sec( 3 );
	MOVLW      3
	MOVWF      FARG_blink_ledRed_n_sec_secds+0
	CALL       _blink_ledRed_n_sec+0
L_main12:
L_main8:
;update_week4_project.c,184 :: 		if(temp > 37) // used to not extend display time when blink_ledRed_n_sec()  executed
	MOVF       main_temp_L0+0, 0
	MOVWF      R4+0
	MOVF       main_temp_L0+1, 0
	MOVWF      R4+1
	MOVF       main_temp_L0+2, 0
	MOVWF      R4+2
	MOVF       main_temp_L0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      20
	MOVWF      R0+2
	MOVLW      132
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main13
;update_week4_project.c,185 :: 		Delay_ms(2000);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main14:
	DECFSZ     R13+0, 1
	GOTO       L_main14
	DECFSZ     R12+0, 1
	GOTO       L_main14
	DECFSZ     R11+0, 1
	GOTO       L_main14
	NOP
	NOP
L_main13:
;update_week4_project.c,189 :: 		display_medication_for_n_sec( msg_med1_add , strlen(msg_med_1) , msg_med2_add , strlen(msg_med_2) , 1   );
	MOVLW      _msg_med_2+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	MOVWF      FLOC__main+0
	MOVF       R0+1, 0
	MOVWF      FLOC__main+1
	MOVLW      _msg_med_1+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	MOVWF      FARG_display_medication_for_n_sec_eeprom_add_1_end+0
	MOVF       _msg_med1_add+0, 0
	MOVWF      FARG_display_medication_for_n_sec_eeprom_add_1+0
	MOVF       _msg_med2_add+0, 0
	MOVWF      FARG_display_medication_for_n_sec_eeprom_add_2+0
	MOVLW      1
	MOVWF      FARG_display_medication_for_n_sec_how_many_times_desplay_1s_msg+0
	MOVF       FLOC__main+0, 0
	MOVWF      FARG_display_medication_for_n_sec_eeprom_add_2_end+0
	CALL       _display_medication_for_n_sec+0
;update_week4_project.c,194 :: 		flag_display_medicine_msg_lcd=0;
	CLRF       _flag_display_medicine_msg_lcd+0
;update_week4_project.c,195 :: 		flag_display_welcome_msg_lcd=0;
	CLRF       _flag_display_welcome_msg_lcd+0
;update_week4_project.c,196 :: 		NB = fix_val_affect_to_NB_inside_interrupt_call; // purpose that TMR0 start counting just after executions ends.
	MOVF       _fix_val_affect_to_NB_inside_interrupt_call+0, 0
	MOVWF      _NB+0
;update_week4_project.c,197 :: 		}
L_main6:
;update_week4_project.c,200 :: 		}while(1);
	GOTO       L_main0
;update_week4_project.c,203 :: 		}//end main
L_end_main:
	GOTO       $+0
; end of _main

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;update_week4_project.c,209 :: 		void interrupt(  ){
;update_week4_project.c,211 :: 		if(  INTCON.INTF==1 && button_rb0 ==1 ){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt17
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt17
L__interrupt81:
;update_week4_project.c,215 :: 		for(i=0;i<3;i++){
	CLRF       R1+0
L_interrupt18:
	MOVLW      3
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt19
;update_week4_project.c,216 :: 		ledr=1;
	BSF        PORTD+0, 0
;update_week4_project.c,217 :: 		buzzer=1;
	BSF        PORTD+0, 4
;update_week4_project.c,218 :: 		Delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_interrupt21:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt21
	DECFSZ     R12+0, 1
	GOTO       L_interrupt21
	DECFSZ     R11+0, 1
	GOTO       L_interrupt21
	NOP
	NOP
;update_week4_project.c,219 :: 		ledr=0;
	BCF        PORTD+0, 0
;update_week4_project.c,220 :: 		Delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_interrupt22:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt22
	DECFSZ     R12+0, 1
	GOTO       L_interrupt22
	DECFSZ     R11+0, 1
	GOTO       L_interrupt22
	NOP
	NOP
;update_week4_project.c,215 :: 		for(i=0;i<3;i++){
	INCF       R1+0, 1
;update_week4_project.c,222 :: 		}
	GOTO       L_interrupt18
L_interrupt19:
;update_week4_project.c,223 :: 		buzzer=0;
	BCF        PORTD+0, 4
;update_week4_project.c,226 :: 		INTCON.INTF=0;// bit 1 ==of> reg INTCON ==job> set back to 0 tell that interrupion is finished back to normal
	BCF        INTCON+0, 1
;update_week4_project.c,227 :: 		}
L_interrupt17:
;update_week4_project.c,229 :: 		if( INTCON.RBIF==1  ){
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt23
;update_week4_project.c,231 :: 		if( (button_rb4 ==1) && (flag_store_position == 0)){
	BTFSS      PORTB+0, 4
	GOTO       L_interrupt26
	MOVF       _flag_store_position+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt26
L__interrupt80:
;update_week4_project.c,233 :: 		flag_store_position=1;
	MOVLW      1
	MOVWF      _flag_store_position+0
;update_week4_project.c,235 :: 		motor_clockwise=1;
	BSF        PORTD+0, 6
;update_week4_project.c,236 :: 		motor_counterclockwise=0;
	BCF        PORTD+0, 7
;update_week4_project.c,237 :: 		Delay_ms(2000);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_interrupt27:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt27
	DECFSZ     R12+0, 1
	GOTO       L_interrupt27
	DECFSZ     R11+0, 1
	GOTO       L_interrupt27
	NOP
	NOP
;update_week4_project.c,238 :: 		motor_counterclockwise=0;
	BCF        PORTD+0, 7
;update_week4_project.c,239 :: 		motor_clockwise=0;
	BCF        PORTD+0, 6
;update_week4_project.c,241 :: 		}
	GOTO       L_interrupt28
L_interrupt26:
;update_week4_project.c,242 :: 		else if( (button_rb5 ==1) && ( flag_store_position == 1) ){
	BTFSS      PORTB+0, 5
	GOTO       L_interrupt31
	MOVF       _flag_store_position+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt31
L__interrupt79:
;update_week4_project.c,243 :: 		flag_store_position= 0;
	CLRF       _flag_store_position+0
;update_week4_project.c,244 :: 		motor_counterclockwise=1;
	BSF        PORTD+0, 7
;update_week4_project.c,245 :: 		motor_clockwise=0;
	BCF        PORTD+0, 6
;update_week4_project.c,246 :: 		Delay_ms(2000);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_interrupt32:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt32
	DECFSZ     R12+0, 1
	GOTO       L_interrupt32
	DECFSZ     R11+0, 1
	GOTO       L_interrupt32
	NOP
	NOP
;update_week4_project.c,247 :: 		motor_clockwise=0;
	BCF        PORTD+0, 6
;update_week4_project.c,248 :: 		motor_counterclockwise=0;
	BCF        PORTD+0, 7
;update_week4_project.c,249 :: 		}
	GOTO       L_interrupt33
L_interrupt31:
;update_week4_project.c,251 :: 		INTCON.RBIF=0;
	BCF        INTCON+0, 0
;update_week4_project.c,252 :: 		}
L_interrupt33:
L_interrupt28:
;update_week4_project.c,254 :: 		INTCON.RBIF=0;// bit 0 ==of> reg INTCON ==job> set back to 0 tell that interrupion is finished back to regular mode
	BCF        INTCON+0, 0
;update_week4_project.c,255 :: 		}
L_interrupt23:
;update_week4_project.c,258 :: 		if (INTCON.T0IE && INTCON.T0IF)
	BTFSS      INTCON+0, 5
	GOTO       L_interrupt36
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt36
L__interrupt78:
;update_week4_project.c,260 :: 		INTCON.T0IF=0; // turn of interrupt
	BCF        INTCON+0, 2
;update_week4_project.c,262 :: 		--NB; //decrement NB until we reach 0 => job:  this helps extend the duration on witch we wants to execute our code
	DECF       _NB+0, 1
;update_week4_project.c,264 :: 		if (NB==0){
	MOVF       _NB+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt37
;update_week4_project.c,266 :: 		flag_display_medicine_msg_lcd=1;
	MOVLW      1
	MOVWF      _flag_display_medicine_msg_lcd+0
;update_week4_project.c,267 :: 		NB=fix_val_affect_to_NB_inside_interrupt_call;
	MOVF       _fix_val_affect_to_NB_inside_interrupt_call+0, 0
	MOVWF      _NB+0
;update_week4_project.c,268 :: 		TMR0=0;
	CLRF       TMR0+0
;update_week4_project.c,269 :: 		INTCON.T0IF = 0;
	BCF        INTCON+0, 2
;update_week4_project.c,270 :: 		}
L_interrupt37:
;update_week4_project.c,273 :: 		}
L_interrupt36:
;update_week4_project.c,275 :: 		}// END interrupt()
L_end_interrupt:
L__interrupt84:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_activate_rb0_interrupt:

;update_week4_project.c,280 :: 		void activate_rb0_interrupt(){
;update_week4_project.c,286 :: 		INTCON.GIE=1; //bit 7 ==of> INTCON -> activate interreption
	BSF        INTCON+0, 7
;update_week4_project.c,287 :: 		INTCON.INTE=1;// bit 4 ==of> reg INTCON  -> activate rb0 interruption
	BSF        INTCON+0, 4
;update_week4_project.c,292 :: 		OPTION_REG.INTEDG=1; // bit 6 ==of> reg OPTION_REG -> transition from 0 -to-> 1
	BSF        OPTION_REG+0, 6
;update_week4_project.c,294 :: 		}
L_end_activate_rb0_interrupt:
	RETURN
; end of _activate_rb0_interrupt

_activate_rb4_to_rb7_interrupt:

;update_week4_project.c,300 :: 		void activate_rb4_to_rb7_interrupt(){
;update_week4_project.c,306 :: 		INTCON.GIE=1; //bit 7 ==of> INTCON -> activate interreption
	BSF        INTCON+0, 7
;update_week4_project.c,307 :: 		INTCON.RBIE=1;// bit 3 ==of> reg INTCON  -> activate rb4->rb7 interruption
	BSF        INTCON+0, 3
;update_week4_project.c,309 :: 		}
L_end_activate_rb4_to_rb7_interrupt:
	RETURN
; end of _activate_rb4_to_rb7_interrupt

_activate_and_set_TMR0_interrupt:

;update_week4_project.c,315 :: 		void activate_and_set_TMR0_interrupt(  short Prediv_1_2_4_8_16_32_64_128_256 , short tmr_reg_val_0_to_256 , unsigned char NB_val ){
;update_week4_project.c,349 :: 		INTCON.GIE=1;
	BSF        INTCON+0, 7
;update_week4_project.c,350 :: 		INTCON.T0IE=1;
	BSF        INTCON+0, 5
;update_week4_project.c,351 :: 		OPTION_REG.T0CS=0;
	BCF        OPTION_REG+0, 5
;update_week4_project.c,352 :: 		TMR0=tmr_reg_val_0_to_256;
	MOVF       FARG_activate_and_set_TMR0_interrupt_tmr_reg_val_0_to_256+0, 0
	MOVWF      TMR0+0
;update_week4_project.c,353 :: 		NB = NB_val;
	MOVF       FARG_activate_and_set_TMR0_interrupt_NB_val+0, 0
	MOVWF      _NB+0
;update_week4_project.c,355 :: 		fix_val_affect_to_NB_inside_interrupt_call = NB_val;  // look at interupt() to get the idea;
	MOVF       FARG_activate_and_set_TMR0_interrupt_NB_val+0, 0
	MOVWF      _fix_val_affect_to_NB_inside_interrupt_call+0
;update_week4_project.c,357 :: 		if( Prediv_1_2_4_8_16_32_64_128_256 == 1 ){
	MOVF       FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt38
;update_week4_project.c,358 :: 		OPTION_REG.PSA=1; // DO NOT associate PreDIV au Timer -> PreDiv=1 default.
	BSF        OPTION_REG+0, 3
;update_week4_project.c,359 :: 		}
	GOTO       L_activate_and_set_TMR0_interrupt39
L_activate_and_set_TMR0_interrupt38:
;update_week4_project.c,364 :: 		OPTION_REG.PSA=0;// Associate a PreDIV to TIMER from 2 --to-> 256 .
	BCF        OPTION_REG+0, 3
;update_week4_project.c,366 :: 		switch( Prediv_1_2_4_8_16_32_64_128_256 ){
	GOTO       L_activate_and_set_TMR0_interrupt40
;update_week4_project.c,368 :: 		case 2: // 2 = 0 0 0
L_activate_and_set_TMR0_interrupt42:
;update_week4_project.c,369 :: 		OPTION_REG.PS2=0;
	BCF        OPTION_REG+0, 2
;update_week4_project.c,370 :: 		OPTION_REG.PS1=0;
	BCF        OPTION_REG+0, 1
;update_week4_project.c,371 :: 		OPTION_REG.PS0=0;
	BCF        OPTION_REG+0, 0
;update_week4_project.c,372 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,374 :: 		case 4: // 4= 0 0 1
L_activate_and_set_TMR0_interrupt43:
;update_week4_project.c,375 :: 		OPTION_REG.PS2=0;
	BCF        OPTION_REG+0, 2
;update_week4_project.c,376 :: 		OPTION_REG.PS1=0;
	BCF        OPTION_REG+0, 1
;update_week4_project.c,377 :: 		OPTION_REG.PS0=1;
	BSF        OPTION_REG+0, 0
;update_week4_project.c,378 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,380 :: 		case 8: // 8= 0 1 0
L_activate_and_set_TMR0_interrupt44:
;update_week4_project.c,381 :: 		OPTION_REG.PS2=0;
	BCF        OPTION_REG+0, 2
;update_week4_project.c,382 :: 		OPTION_REG.PS1=1;
	BSF        OPTION_REG+0, 1
;update_week4_project.c,383 :: 		OPTION_REG.PS0=0;
	BCF        OPTION_REG+0, 0
;update_week4_project.c,384 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,386 :: 		case 16: // 16= 0 1 1
L_activate_and_set_TMR0_interrupt45:
;update_week4_project.c,387 :: 		OPTION_REG.PS2=0;
	BCF        OPTION_REG+0, 2
;update_week4_project.c,388 :: 		OPTION_REG.PS1=1;
	BSF        OPTION_REG+0, 1
;update_week4_project.c,389 :: 		OPTION_REG.PS0=1;
	BSF        OPTION_REG+0, 0
;update_week4_project.c,390 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,392 :: 		case 32: // 32= 1 0 0
L_activate_and_set_TMR0_interrupt46:
;update_week4_project.c,393 :: 		OPTION_REG.PS2=1;
	BSF        OPTION_REG+0, 2
;update_week4_project.c,394 :: 		OPTION_REG.PS1=0;
	BCF        OPTION_REG+0, 1
;update_week4_project.c,395 :: 		OPTION_REG.PS0=0;
	BCF        OPTION_REG+0, 0
;update_week4_project.c,396 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,398 :: 		case 64: // 64= 1 0 1
L_activate_and_set_TMR0_interrupt47:
;update_week4_project.c,399 :: 		OPTION_REG.PS2=1;
	BSF        OPTION_REG+0, 2
;update_week4_project.c,400 :: 		OPTION_REG.PS1=0;
	BCF        OPTION_REG+0, 1
;update_week4_project.c,401 :: 		OPTION_REG.PS0=1;
	BSF        OPTION_REG+0, 0
;update_week4_project.c,402 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,404 :: 		case 128: // 128= 1 1 0
L_activate_and_set_TMR0_interrupt48:
;update_week4_project.c,405 :: 		OPTION_REG.PS2=1;
	BSF        OPTION_REG+0, 2
;update_week4_project.c,406 :: 		OPTION_REG.PS1=1;
	BSF        OPTION_REG+0, 1
;update_week4_project.c,407 :: 		OPTION_REG.PS0=0;
	BCF        OPTION_REG+0, 0
;update_week4_project.c,408 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,410 :: 		case 256: // 256= 1 1 1
L_activate_and_set_TMR0_interrupt49:
;update_week4_project.c,411 :: 		OPTION_REG.PS2=1;
	BSF        OPTION_REG+0, 2
;update_week4_project.c,412 :: 		OPTION_REG.PS1=1;
	BSF        OPTION_REG+0, 1
;update_week4_project.c,413 :: 		OPTION_REG.PS0=1;
	BSF        OPTION_REG+0, 0
;update_week4_project.c,414 :: 		break;
	GOTO       L_activate_and_set_TMR0_interrupt41
;update_week4_project.c,416 :: 		default:
L_activate_and_set_TMR0_interrupt50:
;update_week4_project.c,417 :: 		return;
	GOTO       L_end_activate_and_set_TMR0_interrupt
;update_week4_project.c,419 :: 		}
L_activate_and_set_TMR0_interrupt40:
	MOVF       FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt42
	MOVF       FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt43
	MOVF       FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
	XORLW      8
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt44
	MOVF       FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
	XORLW      16
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt45
	MOVF       FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
	XORLW      32
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt46
	MOVF       FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
	XORLW      64
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt47
	MOVLW      0
	BTFSC      FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 7
	MOVLW      255
	MOVWF      R0+0
	MOVLW      0
	XORWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__activate_and_set_TMR0_interrupt88
	MOVLW      128
	XORWF      FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
L__activate_and_set_TMR0_interrupt88:
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt48
	MOVLW      0
	BTFSC      FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 7
	MOVLW      255
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__activate_and_set_TMR0_interrupt89
	MOVLW      0
	XORWF      FARG_activate_and_set_TMR0_interrupt_Prediv_1_2_4_8_16_32_64_128_256+0, 0
L__activate_and_set_TMR0_interrupt89:
	BTFSC      STATUS+0, 2
	GOTO       L_activate_and_set_TMR0_interrupt49
	GOTO       L_activate_and_set_TMR0_interrupt50
L_activate_and_set_TMR0_interrupt41:
;update_week4_project.c,420 :: 		}
L_activate_and_set_TMR0_interrupt39:
;update_week4_project.c,422 :: 		}
L_end_activate_and_set_TMR0_interrupt:
	RETURN
; end of _activate_and_set_TMR0_interrupt

_blink_ledRed_n_sec:

;update_week4_project.c,431 :: 		void blink_ledRed_n_sec( unsigned char secds ){ char i;
;update_week4_project.c,432 :: 		for(i=0; i<secds ;i++){
	CLRF       R1+0
L_blink_ledRed_n_sec51:
	MOVF       FARG_blink_ledRed_n_sec_secds+0, 0
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_blink_ledRed_n_sec52
;update_week4_project.c,433 :: 		ledr=1;
	BSF        PORTD+0, 0
;update_week4_project.c,434 :: 		Delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_blink_ledRed_n_sec54:
	DECFSZ     R13+0, 1
	GOTO       L_blink_ledRed_n_sec54
	DECFSZ     R12+0, 1
	GOTO       L_blink_ledRed_n_sec54
	DECFSZ     R11+0, 1
	GOTO       L_blink_ledRed_n_sec54
	NOP
	NOP
;update_week4_project.c,435 :: 		ledr=0;
	BCF        PORTD+0, 0
;update_week4_project.c,436 :: 		Delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_blink_ledRed_n_sec55:
	DECFSZ     R13+0, 1
	GOTO       L_blink_ledRed_n_sec55
	DECFSZ     R12+0, 1
	GOTO       L_blink_ledRed_n_sec55
	DECFSZ     R11+0, 1
	GOTO       L_blink_ledRed_n_sec55
	NOP
	NOP
;update_week4_project.c,432 :: 		for(i=0; i<secds ;i++){
	INCF       R1+0, 1
;update_week4_project.c,437 :: 		}
	GOTO       L_blink_ledRed_n_sec51
L_blink_ledRed_n_sec52:
;update_week4_project.c,438 :: 		}
L_end_blink_ledRed_n_sec:
	RETURN
; end of _blink_ledRed_n_sec

_ledblue_on_for_ms:

;update_week4_project.c,440 :: 		void ledblue_on_for_ms( unsigned int time_ms){
;update_week4_project.c,441 :: 		ledb=1;
	BSF        PORTD+0, 2
;update_week4_project.c,442 :: 		while( 0< time_ms ){  Delay_ms(1); --time_ms;  }
L_ledblue_on_for_ms56:
	MOVF       FARG_ledblue_on_for_ms_time_ms+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__ledblue_on_for_ms92
	MOVF       FARG_ledblue_on_for_ms_time_ms+0, 0
	SUBLW      0
L__ledblue_on_for_ms92:
	BTFSC      STATUS+0, 0
	GOTO       L_ledblue_on_for_ms57
	MOVLW      2
	MOVWF      R12+0
	MOVLW      75
	MOVWF      R13+0
L_ledblue_on_for_ms58:
	DECFSZ     R13+0, 1
	GOTO       L_ledblue_on_for_ms58
	DECFSZ     R12+0, 1
	GOTO       L_ledblue_on_for_ms58
	MOVLW      1
	SUBWF      FARG_ledblue_on_for_ms_time_ms+0, 1
	BTFSS      STATUS+0, 0
	DECF       FARG_ledblue_on_for_ms_time_ms+1, 1
	GOTO       L_ledblue_on_for_ms56
L_ledblue_on_for_ms57:
;update_week4_project.c,443 :: 		ledb=0;
	BCF        PORTD+0, 2
;update_week4_project.c,444 :: 		}
L_end_ledblue_on_for_ms:
	RETURN
; end of _ledblue_on_for_ms

_ledgreen_on_for_ms:

;update_week4_project.c,446 :: 		void ledgreen_on_for_ms( unsigned int time_ms){
;update_week4_project.c,447 :: 		ledg=1;
	BSF        PORTD+0, 1
;update_week4_project.c,448 :: 		while( 0< time_ms ){  Delay_ms(1); --time_ms;  }
L_ledgreen_on_for_ms59:
	MOVF       FARG_ledgreen_on_for_ms_time_ms+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__ledgreen_on_for_ms94
	MOVF       FARG_ledgreen_on_for_ms_time_ms+0, 0
	SUBLW      0
L__ledgreen_on_for_ms94:
	BTFSC      STATUS+0, 0
	GOTO       L_ledgreen_on_for_ms60
	MOVLW      2
	MOVWF      R12+0
	MOVLW      75
	MOVWF      R13+0
L_ledgreen_on_for_ms61:
	DECFSZ     R13+0, 1
	GOTO       L_ledgreen_on_for_ms61
	DECFSZ     R12+0, 1
	GOTO       L_ledgreen_on_for_ms61
	MOVLW      1
	SUBWF      FARG_ledgreen_on_for_ms_time_ms+0, 1
	BTFSS      STATUS+0, 0
	DECF       FARG_ledgreen_on_for_ms_time_ms+1, 1
	GOTO       L_ledgreen_on_for_ms59
L_ledgreen_on_for_ms60:
;update_week4_project.c,449 :: 		ledg=0;
	BCF        PORTD+0, 1
;update_week4_project.c,450 :: 		}
L_end_ledgreen_on_for_ms:
	RETURN
; end of _ledgreen_on_for_ms

_welcome_msg:

;update_week4_project.c,463 :: 		void welcome_msg(  ){
;update_week4_project.c,464 :: 		Lcd_cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;update_week4_project.c,466 :: 		display_on_ligne_1( nom_patient , 0 );
	MOVLW      ?lstr1_update_week4_project+0
	MOVWF      FARG_display_on_ligne_1_msg+0
	CLRF       FARG_display_on_ligne_1_clear_lcd_1_or_0+0
	CALL       _display_on_ligne_1+0
;update_week4_project.c,467 :: 		display_on_ligne_2( msg_welcome , 0 );
	MOVLW      ?lstr2_update_week4_project+0
	MOVWF      FARG_display_on_ligne_2_msg+0
	CLRF       FARG_display_on_ligne_2_clear_lcd_1_or_0+0
	CALL       _display_on_ligne_2+0
;update_week4_project.c,468 :: 		}
L_end_welcome_msg:
	RETURN
; end of _welcome_msg

_write_in_eeprom:

;update_week4_project.c,470 :: 		void write_in_eeprom(short eeprom_adr ,char  text[]  )
;update_week4_project.c,473 :: 		for(i=0;i<strlen(text);i++){
	CLRF       write_in_eeprom_i_L0+0
L_write_in_eeprom62:
	MOVF       FARG_write_in_eeprom_text+0, 0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVLW      128
	MOVWF      R2+0
	MOVLW      128
	XORWF      R0+1, 0
	SUBWF      R2+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__write_in_eeprom97
	MOVF       R0+0, 0
	SUBWF      write_in_eeprom_i_L0+0, 0
L__write_in_eeprom97:
	BTFSC      STATUS+0, 0
	GOTO       L_write_in_eeprom63
;update_week4_project.c,474 :: 		EEPROM_Write(eeprom_adr++, text[i] );
	MOVF       FARG_write_in_eeprom_eeprom_adr+0, 0
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVF       write_in_eeprom_i_L0+0, 0
	ADDWF      FARG_write_in_eeprom_text+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
	INCF       FARG_write_in_eeprom_eeprom_adr+0, 1
;update_week4_project.c,475 :: 		delay_ms(20); }
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_write_in_eeprom65:
	DECFSZ     R13+0, 1
	GOTO       L_write_in_eeprom65
	DECFSZ     R12+0, 1
	GOTO       L_write_in_eeprom65
	NOP
;update_week4_project.c,473 :: 		for(i=0;i<strlen(text);i++){
	INCF       write_in_eeprom_i_L0+0, 1
;update_week4_project.c,475 :: 		delay_ms(20); }
	GOTO       L_write_in_eeprom62
L_write_in_eeprom63:
;update_week4_project.c,476 :: 		}
L_end_write_in_eeprom:
	RETURN
; end of _write_in_eeprom

_read_from_eeprom:

;update_week4_project.c,478 :: 		char* read_from_eeprom(short start_address , short end_address  )
;update_week4_project.c,483 :: 		for( i=0;i<end_address ;i++){
	CLRF       read_from_eeprom_i_L0+0
L_read_from_eeprom66:
	MOVLW      128
	MOVWF      R0+0
	MOVLW      128
	BTFSC      FARG_read_from_eeprom_end_address+0, 7
	MOVLW      127
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_from_eeprom99
	MOVF       FARG_read_from_eeprom_end_address+0, 0
	SUBWF      read_from_eeprom_i_L0+0, 0
L__read_from_eeprom99:
	BTFSC      STATUS+0, 0
	GOTO       L_read_from_eeprom67
;update_week4_project.c,484 :: 		text[i]= EEPROM_Read( start_address+i ) ;
	MOVF       read_from_eeprom_i_L0+0, 0
	ADDLW      read_from_eeprom_text_L0+0
	MOVWF      FLOC__read_from_eeprom+0
	MOVF       read_from_eeprom_i_L0+0, 0
	ADDWF      FARG_read_from_eeprom_start_address+0, 0
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       FLOC__read_from_eeprom+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;update_week4_project.c,485 :: 		delay_ms(20);  }
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_read_from_eeprom69:
	DECFSZ     R13+0, 1
	GOTO       L_read_from_eeprom69
	DECFSZ     R12+0, 1
	GOTO       L_read_from_eeprom69
	NOP
;update_week4_project.c,483 :: 		for( i=0;i<end_address ;i++){
	INCF       read_from_eeprom_i_L0+0, 1
;update_week4_project.c,485 :: 		delay_ms(20);  }
	GOTO       L_read_from_eeprom66
L_read_from_eeprom67:
;update_week4_project.c,487 :: 		return text;
	MOVLW      read_from_eeprom_text_L0+0
	MOVWF      R0+0
;update_week4_project.c,488 :: 		}
L_end_read_from_eeprom:
	RETURN
; end of _read_from_eeprom

_display_medication_for_n_sec:

;update_week4_project.c,491 :: 		void display_medication_for_n_sec( short eeprom_add_1 , short eeprom_add_1_end , short eeprom_add_2 , short eeprom_add_2_end , unsigned char  how_many_times_desplay_1s_msg  ){
;update_week4_project.c,493 :: 		display_on_ligne_1(  read_from_eeprom(  eeprom_add_1 , eeprom_add_1_end ) , 1  );
	MOVF       FARG_display_medication_for_n_sec_eeprom_add_1+0, 0
	MOVWF      FARG_read_from_eeprom_start_address+0
	MOVF       FARG_display_medication_for_n_sec_eeprom_add_1_end+0, 0
	MOVWF      FARG_read_from_eeprom_end_address+0
	CALL       _read_from_eeprom+0
	MOVF       R0+0, 0
	MOVWF      FARG_display_on_ligne_1_msg+0
	MOVLW      1
	MOVWF      FARG_display_on_ligne_1_clear_lcd_1_or_0+0
	CALL       _display_on_ligne_1+0
;update_week4_project.c,494 :: 		display_on_ligne_2(  read_from_eeprom(  eeprom_add_2 , eeprom_add_2_end ) , 0  );
	MOVF       FARG_display_medication_for_n_sec_eeprom_add_2+0, 0
	MOVWF      FARG_read_from_eeprom_start_address+0
	MOVF       FARG_display_medication_for_n_sec_eeprom_add_2_end+0, 0
	MOVWF      FARG_read_from_eeprom_end_address+0
	CALL       _read_from_eeprom+0
	MOVF       R0+0, 0
	MOVWF      FARG_display_on_ligne_2_msg+0
	CLRF       FARG_display_on_ligne_2_clear_lcd_1_or_0+0
	CALL       _display_on_ligne_2+0
;update_week4_project.c,496 :: 		for( i=0 ;i< how_many_times_desplay_1s_msg ; i++ )
	CLRF       display_medication_for_n_sec_i_L0+0
L_display_medication_for_n_sec70:
	MOVF       FARG_display_medication_for_n_sec_how_many_times_desplay_1s_msg+0, 0
	SUBWF      display_medication_for_n_sec_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_display_medication_for_n_sec71
;update_week4_project.c,497 :: 		Delay_ms( (1000) );
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_display_medication_for_n_sec73:
	DECFSZ     R13+0, 1
	GOTO       L_display_medication_for_n_sec73
	DECFSZ     R12+0, 1
	GOTO       L_display_medication_for_n_sec73
	DECFSZ     R11+0, 1
	GOTO       L_display_medication_for_n_sec73
	NOP
	NOP
;update_week4_project.c,496 :: 		for( i=0 ;i< how_many_times_desplay_1s_msg ; i++ )
	INCF       display_medication_for_n_sec_i_L0+0, 1
;update_week4_project.c,497 :: 		Delay_ms( (1000) );
	GOTO       L_display_medication_for_n_sec70
L_display_medication_for_n_sec71:
;update_week4_project.c,502 :: 		}
L_end_display_medication_for_n_sec:
	RETURN
; end of _display_medication_for_n_sec

_display_on_ligne_1:

;update_week4_project.c,505 :: 		void display_on_ligne_1( char * msg , char clear_lcd_1_or_0 ){
;update_week4_project.c,507 :: 		if(clear_lcd_1_or_0==1 )
	MOVF       FARG_display_on_ligne_1_clear_lcd_1_or_0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_display_on_ligne_174
;update_week4_project.c,508 :: 		Lcd_cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
L_display_on_ligne_174:
;update_week4_project.c,510 :: 		Lcd_out(1,1,msg);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       FARG_display_on_ligne_1_msg+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;update_week4_project.c,511 :: 		}
L_end_display_on_ligne_1:
	RETURN
; end of _display_on_ligne_1

_display_on_ligne_2:

;update_week4_project.c,513 :: 		void display_on_ligne_2( char * msg  , char clear_lcd_1_or_0 ){
;update_week4_project.c,515 :: 		if(clear_lcd_1_or_0==1 )
	MOVF       FARG_display_on_ligne_2_clear_lcd_1_or_0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_display_on_ligne_275
;update_week4_project.c,516 :: 		Lcd_cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
L_display_on_ligne_275:
;update_week4_project.c,518 :: 		Lcd_out(2,1,msg);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       FARG_display_on_ligne_2_msg+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;update_week4_project.c,520 :: 		}
L_end_display_on_ligne_2:
	RETURN
; end of _display_on_ligne_2

_initialise_lcd:

;update_week4_project.c,523 :: 		void initialise_lcd(){
;update_week4_project.c,524 :: 		Lcd_Init();  // init output lcd
	CALL       _Lcd_Init+0
;update_week4_project.c,525 :: 		Lcd_Cmd(_LCD_CLEAR ); // clear lcd
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;update_week4_project.c,526 :: 		Lcd_Cmd(_LCD_CURSOR_OFF ); // dont show cursor
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;update_week4_project.c,527 :: 		}
L_end_initialise_lcd:
	RETURN
; end of _initialise_lcd

_template_lcd_temperature_display:

;update_week4_project.c,533 :: 		void template_lcd_temperature_display( ){
;update_week4_project.c,534 :: 		Lcd_Cmd(_LCD_CLEAR );
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;update_week4_project.c,535 :: 		Lcd_Out(1,1, "Temperature : " );
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_update_week4_project+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;update_week4_project.c,536 :: 		Lcd_Chr(2,7,223); // getting character by ascii value 167->º
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      223
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;update_week4_project.c,537 :: 		Lcd_Chr(2,8,'C');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      67
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;update_week4_project.c,539 :: 		}
L_end_template_lcd_temperature_display:
	RETURN
; end of _template_lcd_temperature_display

_get_temperature_value:

;update_week4_project.c,541 :: 		float get_temperature_value(  unsigned int  analog_data   ){
;update_week4_project.c,544 :: 		float millivolts= analog_data;
	MOVF       FARG_get_temperature_value_analog_data+0, 0
	MOVWF      R0+0
	MOVF       FARG_get_temperature_value_analog_data+1, 0
	MOVWF      R0+1
	CALL       _word2double+0
;update_week4_project.c,545 :: 		millivolts= millivolts*5000.0/1024.0; // scaling input millvolts to be able to get data from sensor
	MOVLW      0
	MOVWF      R4+0
	MOVLW      64
	MOVWF      R4+1
	MOVLW      28
	MOVWF      R4+2
	MOVLW      139
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      0
	MOVWF      R4+2
	MOVLW      137
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
;update_week4_project.c,546 :: 		temperature=  millivolts/10 ; // only a few millivolts (mV) for a 10ºC change in temperature after scaling we devide to get as close to 1°
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      32
	MOVWF      R4+2
	MOVLW      130
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
;update_week4_project.c,548 :: 		return temperature ;
;update_week4_project.c,550 :: 		}
L_end_get_temperature_value:
	RETURN
; end of _get_temperature_value

_stringify_temp_value_and_flag_display_temp_option:

;update_week4_project.c,552 :: 		char * stringify_temp_value_and_flag_display_temp_option( float temperature){
;update_week4_project.c,554 :: 		floatToStr( temperature , temp_string );
	MOVF       FARG_stringify_temp_value_and_flag_display_temp_option_temperature+0, 0
	MOVWF      FARG_FloatToStr_fnum+0
	MOVF       FARG_stringify_temp_value_and_flag_display_temp_option_temperature+1, 0
	MOVWF      FARG_FloatToStr_fnum+1
	MOVF       FARG_stringify_temp_value_and_flag_display_temp_option_temperature+2, 0
	MOVWF      FARG_FloatToStr_fnum+2
	MOVF       FARG_stringify_temp_value_and_flag_display_temp_option_temperature+3, 0
	MOVWF      FARG_FloatToStr_fnum+3
	MOVLW      stringify_temp_value_and_flag_display_temp_option_temp_string_L0+0
	MOVWF      FARG_FloatToStr_str+0
	CALL       _FloatToStr+0
;update_week4_project.c,556 :: 		temp_string[5]='\0';
	CLRF       stringify_temp_value_and_flag_display_temp_option_temp_string_L0+5
;update_week4_project.c,558 :: 		if( flag_display_temp_msg_lcd==0){
	MOVF       _flag_display_temp_msg_lcd+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_stringify_temp_value_and_flag_display_temp_option76
;update_week4_project.c,559 :: 		template_lcd_temperature_display( );
	CALL       _template_lcd_temperature_display+0
;update_week4_project.c,560 :: 		flag_display_temp_msg_lcd=1;
	MOVLW      1
	MOVWF      _flag_display_temp_msg_lcd+0
;update_week4_project.c,561 :: 		}
L_stringify_temp_value_and_flag_display_temp_option76:
;update_week4_project.c,562 :: 		return temp_string;
	MOVLW      stringify_temp_value_and_flag_display_temp_option_temp_string_L0+0
	MOVWF      R0+0
;update_week4_project.c,563 :: 		}
L_end_stringify_temp_value_and_flag_display_temp_option:
	RETURN
; end of _stringify_temp_value_and_flag_display_temp_option
