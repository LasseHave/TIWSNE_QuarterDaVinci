#include <Timer.h>
#include "RadioSender.h"
#include "printf.h"
#include <UserButton.h>


module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface RadioSenderI as RadioSender;
    uses interface Notify<button_state_t> as Notify;
}
implementation {
	uint16_t counter = 0;
	uint16_t test = 0;
	message_t pkt;
	 
	uint8_t pictureData[SIZE_IMAGE/PICTURE_PART_NR]; 
	uint8_t pictureDataPart = 0;
	
	void setDummyPictureData(uint8_t add) {
		uint16_t i;
		for (i = 0; i < (SIZE_IMAGE/PICTURE_PART_NR); i++) {
			pictureData[i] = (uint8_t) ((i + add)% 255);
		}
	}
	
	void sendPicture() {
		if(pictureDataPart < 8) {
			//load next part of picture
			setDummyPictureData(pictureDataPart);
			call RadioSender.send(pictureData);
			pictureDataPart++;
		} else 
		{
			//Picture sent
			call Leds.set(7);
			pictureDataPart = 0;
		}
		
	}
	
	event void Boot.booted() {
		//setDummyPictureData(pictureDataPart);
		call RadioSender.start();
	}	


	event void RadioSender.startDone(){
		call Notify.enable();
		call Leds.led1On();
	}
	

	event void RadioSender.sendDone(){
		sendPicture();
		printf("SendDone");
	}
	
	event void Notify.notify(button_state_t state) {
		call Leds.led2Toggle();
		if (state == BUTTON_PRESSED) {
			counter++;
			call Leds.set(counter);
			sendPicture();
		}
	}																																																																					
}
