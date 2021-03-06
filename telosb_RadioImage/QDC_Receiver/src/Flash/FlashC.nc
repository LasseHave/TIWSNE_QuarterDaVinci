#include "Flash.h"

module FlashC
{
	uses
	{
		interface BlockRead;
		interface BlockWrite;
	}	
	provides
	{
		interface Flash;
	}
}
implementation
{		
	bool withLength = FALSE;
	
	command error_t Flash.erase()
	{	
		return call BlockWrite.erase();
	}
	
	command error_t Flash.write(uint8_t* arrPtr, uint32_t pktNum)
	{
		error_t Status = call BlockWrite.write(pktNum*SIZE_BLOCKPART,arrPtr,SIZE_BLOCKPART);
		return Status;
	}
	
	command error_t Flash.writeLength(uint8_t* arrPtr, uint32_t from, uint16_t len)
	{
		error_t Status;
		withLength = TRUE;
		Status = call BlockWrite.write(from,arrPtr,len);
		return Status;
	}
	
	command error_t Flash.read(uint8_t* arrPtr, uint32_t pktNum)
	{
		error_t Status = call BlockRead.read(pktNum*SIZE_BLOCKPART,arrPtr,SIZE_BLOCKPART);
		return Status;
	}
	
	command error_t Flash.readLength(uint8_t* arrPtr, uint32_t from, uint16_t len)
	{
		error_t Status;
		withLength = TRUE;
		Status = call BlockRead.read(from,arrPtr,len);
		return Status;
	}
	
	event void BlockWrite.eraseDone(error_t result) 
	{
		signal Flash.eraseDone(result);
	}
	
	event void BlockWrite.writeDone(storage_addr_t x, void* buf, storage_len_t y, error_t result) 
	{
		call BlockWrite.sync();
	}

	event void BlockWrite.syncDone(error_t result) 
	{
		if(withLength) {
			withLength = FALSE;
			signal Flash.writeLengthDone(result);
		} else {
			signal Flash.writeDone(result);
		}
		
	}

	event void BlockRead.readDone(storage_addr_t x, void* buf, storage_len_t rlen, error_t result) __attribute__((noinline))
	{
		if(withLength) {
			withLength = FALSE;
			signal Flash.readLengthDone(result);
		} else {
			signal Flash.readDone(result);
		}
		
	}

	event void BlockRead.computeCrcDone(storage_addr_t x, storage_len_t y, uint16_t z, error_t result) 
	{
		//Do nothing
  	}
}
