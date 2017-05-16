#include <Timer.h>
#include "RadioSender.h"
#include "TestSerial.h"
#include "StorageVolumes.h"
#include "printf.h"

configuration SenderAppC {
}
implementation {
	//Main
	components MainC;

	//IO
	components LedsC;
	components SenderC as App;
	components ActiveMessageC;
	components RadioSenderC;
	components UserButtonC;
	
	components RadioSenderC as RadioSender;
	components new AMSenderC(AM_SENDER);
	components new AMReceiverC(AM_RECEIVER);
	components new TimerMilliC() as AckTimer;

	components PrintfC;
	
	components TestSerialC as TestSerial;
	components SerialActiveMessageC as AM;
	components FlashC;
	components new BlockStorageC(BLOCK_VOLUME);


	//Block storage

	// Serial

	//RadioSender
	RadioSender.Packet->AMSenderC;
	RadioSender.AMPacket->AMSenderC;
	RadioSender.AMSend->AMSenderC;
	RadioSender.AMControl->ActiveMessageC;
	RadioSender.Receive -> AMReceiverC;
	RadioSender.AckTimer -> AckTimer;
	
	//FLASH
	//App.Flash -> FlashC;
	//FlashC.BlockRead -> BlockStorageC.BlockRead;
	//FlashC.BlockWrite -> BlockStorageC.BlockWrite;
	
	App.Boot->MainC;
	App.Leds->LedsC;
	App.RadioSender->RadioSenderC;
	
	//SERIAL
	TestSerial.Control -> AM;
	TestSerial.ReceiveData -> AM.Receive[AM_CHUNK_MSG_T];
	TestSerial.SendData -> AM.AMSend[AM_CHUNK_MSG_T];
	TestSerial.ReceiveStatus -> AM.Receive[AM_STATUS_MSG_T];
	TestSerial.SendStatus -> AM.AMSend[AM_STATUS_MSG_T];
	TestSerial.PacketAck -> AM.PacketAcknowledgements;
	TestSerial.Packet -> AM;
	TestSerial.Flash -> FlashC;
	
	FlashC.BlockRead -> BlockStorageC.BlockRead;
	FlashC.BlockWrite -> BlockStorageC.BlockWrite;
	
	App.TestSerial->TestSerial;

	//Button
	App.Notify->UserButtonC;
}