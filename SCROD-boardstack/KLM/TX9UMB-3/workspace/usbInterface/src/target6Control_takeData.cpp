#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <iostream>
#include <stdlib.h> 
#include "target6ControlClass.h"

#include <fstream>

#include <TGraph.h>
#include <TH1.h>
#include "TApplication.h"
#include "TCanvas.h"
#include "TAxis.h"
#include "TF1.h"
#include "TMath.h"
#include "TFile.h"
#include "TGraphErrors.h"

//global TApplication object declared here for simplicity
TApplication *theApp;

using namespace std;

int main(int argc, char* argv[]){
	if (argc != 3){
    		std::cout << "wrong number of arguments: usage ./target6Control_takeData <number events> <trigger type: software = 0 or ASIC trigger = 1>" << std::endl;
    		return 0;
  	}

	//get event #
	int numEvents = atoi(argv[1]);
	if( numEvents <= 0 ){
		std::cout << "Invalid number of events, exiting" << std::endl;
		return 0;
	}

	//get trigger type
	int trigType = atoi(argv[2]);
	if( trigType != 0 && trigType != 1 ){
		std::cout << "Invalid trigger type, exiting" << std::endl;
		return 0;
	}

	//define application object
	theApp = new TApplication("App", &argc, argv);

	int regValReadback;

	//create target6 interface object
	target6ControlClass *control = new target6ControlClass();

	//initialize USB interface - Mandatory
	control->initializeUSBInterface();

	//define the SCROD ID for board stack, hardcoded for now
	unsigned int board_id = 0;

	//clear data buffer
	control->clearDataBuffer();

	//make simple sample histogram
	TCanvas *c0 = new TCanvas("c0","c0",1300,800);
	TH1F *hSampDist = new TH1F("hSampDist","",110,3000,4100);

	//Initialize
	//control->sendSamplingReset(board_id);
	/*
	control->registerWriteReadback(board_id, 10, 0, regValReadback); //stop sampling
	control->registerWriteReadback(board_id, 10, 1, regValReadback); //Start sampling
	usleep(20);
	control->registerWriteReadback(board_id, 10, 0, regValReadback); //stop sampling
	usleep(10);
*/

	control->registerWriteReadback(board_id, 20, 0, regValReadback); //Digitization OFF
	control->registerWriteReadback(board_id, 30, 0, regValReadback); //Serial readout OFF
	control->registerWriteReadback(board_id, 50, 0, regValReadback); //readout control start is 0
	control->registerWrite(board_id, 44, 0, regValReadback); //Stop event builder
	control->registerWrite(board_id, 45, 1, regValReadback); //Reset Event builder
	control->registerWrite(board_id, 45, 0, regValReadback); //Reset Event builder
	//control->registerWriteReadback(board_id, 51, 0x3FF, regValReadback); //enable ASICs for readout
	control->registerWriteReadback(board_id, 51, 0x200, regValReadback); //enable ASICs for readout: 7/12/14: IM: changed such that only DC10 is measured
//	control->registerWriteReadback(board_id, 51, 0x001, regValReadback); //enable ASICs for readout: 7/12/14: IM: changed such that only DC10 is measured
	control->registerWriteReadback(board_id, 52, 0, regValReadback); //veto hardware triggers
	control->registerWriteReadback(board_id, 53, 0, regValReadback); //set trigger delay
	control->registerWriteReadback(board_id, 54, 510, regValReadback); //set digitization window offset: internal_CMDREG_READCTRL_dig_offset
	control->registerWriteReadback(board_id, 55, 1, regValReadback); //reset readout
	control->registerWriteReadback(board_id, 55, 0, regValReadback); //reset readout
	control->registerWriteReadback(board_id, 56, 0, regValReadback); //select readout control module signals
	control->registerWriteReadback(board_id, 57, 1, regValReadback); //set # of windows to read: internal_READCTRL_win_num_to_read
	control->registerWriteReadback(board_id, 62, 0x0000 | 120, regValReadback); //force start digitization start window to be the fixed value
	control->registerWrite(board_id, 58, 0, regValReadback); //reset packet request
	control->registerWrite(board_id, 72, 0x3FF, regValReadback); //enable trigger bits
	control->registerWrite(board_id, 61, 0xD00, regValReadback); //ramp length- working on 40us ish

	//define output file		
	ofstream dataFile;
  	dataFile.open ("output_target6Control_takeData.dat", ios::out | ios::binary );

	unsigned int eventdatabuf[65536];
	int eventdataSize = 0;
	int numIter = 0;

	control->sendSamplingReset(board_id);

	char ct = 0;
	//while(ct != 'Q'){
	for( int numEv = 0 ; numEv < numEvents ; numEv++ ){
		//if( numEv % 10 == 0 )
			std::cout << "\nEvent # " << numEv << std::endl;
		//do software trigger
		if(trigType == 0){
			control->sendTrigger(board_id,0);
			usleep(50);
			int cnt1,cnt2;
			control->registerRead(board_id,256+5,cnt1);
			control->registerRead(board_id,256+30,cnt2);
			cout<<endl<<"SMP_Latch: "<<cnt1<<", Dig win start: "<<cnt2;
		}
		//do harware trigger, presumably trigger will occur shortly after hardware veto is disable
		else{
			control->sendSamplingReset(board_id);
			control->sendTrigger(board_id,1);
			usleep(50);
			int cnt1,cnt2;
			control->registerRead(board_id,256+5,cnt1);
			control->registerRead(board_id,256+30,cnt2);
			cout<<endl<<"Hard Trig, SMP_Latch: "<<cnt1<<", Dig win start: "<<cnt2;
			//std::cout << "Send trigger, then enter character" << std::endl;
			//std::cin >> ct;
		}

		int first = 1;
		int numSmall = 0;
		numIter = 0;
		while( (eventdataSize > 100 || numSmall < 3 ) && numIter < 25 ){
		//while( numIter < 4){
			//delay, just in case readout is still in progress
			
			//toggle continue bit
			control->continueReadout(board_id);

			//usleep(100);
	
			//parse the data packet, look for event packets
			control->readPacketFromUSBFifo( eventdatabuf, 65536, eventdataSize );
		
			//increment iterate count
			numIter++;

			//save data to file
			//myfile.write(reinterpret_cast<char*>(&eventdatabuf), eventdataSize*sizeof(unsigned int));
			if( eventdataSize > 100 ){
				first = 0;
				numSmall = 0;
				control->writeEventToFile(eventdatabuf, eventdataSize, dataFile );
			}
			else
				numSmall++;
		} //end while loop
		//if( first == 0 )
		//	std::cout << "\tRecorded waveform data" << std::endl;
	}//end event loop

	//reset readout
	control->registerWriteReadback(board_id, 50, 0, regValReadback); //readout control start is 0
	control->registerWriteReadback(board_id, 52, 0, regValReadback); //veto hardware triggers
	control->registerWrite(board_id, 55, 1, regValReadback); //make sure readout is reset
	control->registerWrite(board_id, 55, 0, regValReadback); //make sure readout is reset

	//close output file
  	dataFile.close();

	//close USB interface
        control->closeUSBInterface();

	//delete target6 interface object
	delete control;

	return 1;
}	
