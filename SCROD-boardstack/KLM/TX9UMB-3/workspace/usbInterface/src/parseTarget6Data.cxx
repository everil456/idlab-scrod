//compile independently with: g++ -o parseTarget6Data parseTarget6Data.cxx `root-config --cflags --glibs`
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>

#include "TROOT.h"
#include "TApplication.h"
#include <TFile.h>
#include "TTree.h"
#include "TSystem.h"	
#include "TString.h"
#include "TObjArray.h"
using namespace std;

void initializeRootTree();
void processBuffer(unsigned int *buffer_uint, int sizeInUint32);
void parseDataPacket(unsigned int *buffer_uint, int bufPos, int sizeInUint32);
void resetWaveformArray();
void saveWaveformArrayToTree();
TString getOutputFileName(std::string inputFileName);

//array to store motherboard event waveform data, very crude
const int numDC = 10;
const int numCHAN = 16;
const int numADDR = 512;
const int numSAMP = 32;
const int numBIT = 12;
bool waveformValid[numDC][numCHAN][numADDR]; //DC, CHANNEL, ADDRESS
unsigned int waveformArray[numDC][numCHAN][numADDR][numSAMP]; //DC, CHANNEL, ADDRESS, SAMPLE
int currentEventNumber;

//Define output tree
#define POINTS_PER_WAVEFORM    32
#define MEMORY_DEPTH           512
#define NASICS                 10
#define NCHS                   16
const Int_t MaxROI(400);
TTree *tree;
Int_t eventNum;
Int_t nROI;
UInt_t scrodId[MaxROI];
Int_t asicNum[MaxROI];
Int_t asicCh[MaxROI];
Int_t windowNum[MaxROI];
Int_t samples[MaxROI][POINTS_PER_WAVEFORM];

//global TApplication object declared here for simplicity
TApplication *theApp;

//void parseTarget6Data(std::string inputFileName){
int main(int argc, char* argv[]){
	//check # arguments
	if (argc != 2){
    		std::cout << "wrong number of arguments: usage ./parseTarget6Data <filename>" << std::endl;
    		return 0;
  	}

	//define input file and parsing
	std::string inputFileName = argv[1];
	std::cout << " inputFileName " << inputFileName << std::endl;
	ifstream infile;
	infile.open(argv[1], std::ifstream::in | std::ifstream::binary);  

        if (infile.fail()) {
		std::cout << "Error opening input file, exiting" << std::endl;
		return 0;
	}

	//define application object
	theApp = new TApplication("App", &argc, argv);

    	// get length of file:
    	infile.seekg (0, infile.end);
    	int size_in_bytes = infile.tellg();
    	infile.seekg (0, infile.beg);

	//define buffer
    	char * buffer = new char [size_in_bytes];
	unsigned int *buffer_uint = (unsigned int *) buffer;

    	std::cout << "Reading " << size_in_bytes << " bytes... ";

    	// read data as a block:
    	infile.read (buffer,size_in_bytes);
    	if (infile) {
      		std::cout << "all characters read successfully." << std::endl;
    	} else {
      		std::cout << "error: only " << infile.gcount() << " could be read" << std::endl;
	}
    	infile.close();

	//define output file name
	TString outputFileName(getOutputFileName(inputFileName));
	std::cout << " outputFileName " << outputFileName << std::endl;
	TFile g(outputFileName , "RECREATE");

	//initialize tree to store trigger bit data
	initializeRootTree();

	//intialize waveform array
	currentEventNumber = -1;
	resetWaveformArray();
	
	//process file buffer
	processBuffer(buffer_uint,size_in_bytes/4);

	//write tree to file
	g.cd();
	tree->Write();

        //Write out the settings used in creating the data tree:
	Int_t numberOfAsics(NASICS);
	Int_t numberOfAsicChannels(NCHS);
	Int_t numberOfWindows(MEMORY_DEPTH);
	Int_t numberOfSamples(POINTS_PER_WAVEFORM);
        TTree* MetaDataTree = new TTree("MetaData", "metadata");  
        MetaDataTree->Branch("nAsics", &numberOfAsics, "nAsics/I");
        MetaDataTree->Branch("nAsicChannels", &numberOfAsicChannels, "nAsicChannels/I");
        MetaDataTree->Branch("nWindows", &numberOfWindows, "nWindows/I");
        MetaDataTree->Branch("nSamples", &numberOfSamples, "nSamples/I");
        MetaDataTree->Fill();
        MetaDataTree->Write();  

	g.Close();
	return 0;
}

//initialize tree to store trigger bit data
void initializeRootTree(){
	tree = new TTree("T","TARGET6_Data");
	tree->Branch("eventNum", &eventNum, "eventNum/I");
	tree->Branch("nROI", &nROI, "nROI/I");
	tree->Branch("scrodId", &scrodId, "scrodId[nROI]/I");
	tree->Branch("asicNum", &asicNum, "asicNum[nROI]/I");
	tree->Branch("asicCh", &asicCh, "asicCh[nROI]/I");
	tree->Branch("windowNum", &windowNum, "windowNum[nROI]/I");
        //set array size to store in root file:
        TString samplesBranchLeafList("samples[nROI][");
	samplesBranchLeafList += POINTS_PER_WAVEFORM;
	samplesBranchLeafList += "]/I";
	tree->Branch("samples", &samples, samplesBranchLeafList);
	return;
}

//reset the array storing waveform data
void saveWaveformArrayToTree(){
	//loop over all ASICs/channels
	eventNum = currentEventNumber;
	Int_t ROI = 0;
    	for(int d = 0 ; d < numDC ; d++)
	for(int c = 0 ; c < numCHAN ; c++)
  	for(int a = 0 ; a < numADDR ; a++){
		if( waveformValid[d][c][a] == 0 )
			continue;
		scrodId[ROI] = 0;
		asicNum[ROI] = d;
		asicCh[ROI] = c;
		windowNum[ROI] = a;
  		for(int s = 0 ; s < numSAMP ; s++)
			samples[ROI][s] = waveformArray[d][c][a][s];
		ROI++;
		
	}//end of numADDR loop
	nROI = ROI;
	tree->Fill();
	return;
}	

//reset the array storing waveform data
void resetWaveformArray(){
    	for(int d = 0 ; d < numDC ; d++)
	for(int c = 0 ; c < numCHAN ; c++)
  	for(int a = 0 ; a < numADDR ; a++)
  	for(int s = 0 ; s < numSAMP ; s++){
		waveformValid[d][c][a] = 0;
		waveformArray[d][c][a][s] = 0;
	}
	return;
}	

//function loops through file buffers, extracts trigger bits from data packet and organizes by event
void processBuffer(unsigned int *buffer_uint, int sizeInUint32){

    	// loop through entire file
	for(int pos = 0 ; pos < sizeInUint32 ; pos++ )
		parseDataPacket(buffer_uint,pos,sizeInUint32);
		
    	delete[] buffer_uint;
	return;
}	

//function parses data packet and returns trigger bit, lots of hardcoded parameters here that will be removed in final implmentation
void parseDataPacket(unsigned int *buffer_uint, int bufPos, int sizeInUint32){
	//std::cout << std::hex << buffer_uint[bufPos] << std::dec;
	//std::cout << std::endl;

	unsigned int bitNum = 0;
	unsigned int addrNum = 0;
	unsigned int asicNum = 0;
	unsigned int sampNum = 0;
	unsigned int dataWord = 0;
	unsigned int packetEventNum = 0;

	//check for packet header
	if( (0xFFFFFFFF & buffer_uint[bufPos]) != 0x00be11e2 )
		return;
	//check for ?
	if( (0xFFFFFFFF & buffer_uint[bufPos+1]) != 0x00000013 )
		return;
	//check for waveform type 
	if( (0xFFFFFFFF & buffer_uint[bufPos+2]) != 0x65766e74 )
		return;
	//check for SCROD-ID
	if( (0xFFFFFFFF & buffer_uint[bufPos+3]) != 0x00a3002c )
		return;
	//check for data/version identifier
	if( (0xFFFFFFFF & buffer_uint[bufPos+4]) != 0x20121128 )
		return;

	//check to see if this is an event header packet produced by SCROD
	if( (0xFFFFFFFF & buffer_uint[bufPos+7]) == 0x65766e74 ){
		packetEventNum = ( buffer_uint[bufPos+5] & 0xFFFFFFFF );

		//check if this is the first event packet
		if( currentEventNumber == -1 ){
			currentEventNumber = packetEventNum;
			return;
		}

		//check if new event - if new event then save old event and reset waveform data storage
		if( packetEventNum != currentEventNumber){
			//save event
			saveWaveformArrayToTree();
			//reset waveform array
			currentEventNumber = packetEventNum;
			resetWaveformArray();
		}
		return;
	}

	//check to see if window packet - should be the case at this point
	if( (0xFFF00000 & buffer_uint[bufPos+5]) != 0xABC00000 )
		return;

	//at this point should have window data - loop over window data until encounter end of window packet
	int count = 0;
	while( ((0xFFF00000 & buffer_uint[bufPos+5+count]) == 0xABC00000 ) || ((0xFFF00000 & buffer_uint[bufPos+5+count]) == 0xDEF00000 ) ){
		//std::cout << std::hex << buffer_uint[bufPos+5+count] << std::dec;
		
		//Check for sample packet header
		if( 1 && (0xFFF00000 & buffer_uint[bufPos+5+count]) == 0xABC00000 ){
			addrNum = ( (buffer_uint[bufPos+5+count] >> 10) & 0x000001FF );
			asicNum = ( (buffer_uint[bufPos+5+count] >> 6) & 0x0000000F ) - 1;
			sampNum = (buffer_uint[bufPos+5+count] & 0x0000001F);
			//std::cout << "\t" << addrNum;
			//std::cout << "\t" << asicNum;
			//std::cout << "\t" << sampNum;
			//std::cout << std::endl;
		}
	
		//check if errors
		if( addrNum >= numADDR  || asicNum >= numDC || sampNum >= numSAMP ){
			std::cout << "INVALID SAMPLE INFO, SKIPPING ";
			std::cout << "\t" << addrNum;
			std::cout << "\t" << asicNum;
			std::cout << "\t" << sampNum;
			std::cout << std::endl;
			count++;
			continue;
		}
		
		//check for sample packet data
		if( 1 && (0xFFF00000 & buffer_uint[bufPos+5+count]) == 0xDEF00000 ){
			bitNum = ( (buffer_uint[bufPos+5+count] >> 16) & 0x0000000F );
			dataWord = (buffer_uint[bufPos+5+count] & 0xFFFF);
			//std::cout << "\t" << bitNum;
			//std::cout << "\t" << dataWord;
			//std::cout << std::endl;
			//check if errors
			if( bitNum >= numBIT ){
				std::cout << "INVALID BIT NUMBER, SKIPPING ";
				std::cout << "\t" << bitNum;
				std::cout << std::endl;
				count++;
				continue;
			}

			//at this point have sample bit word, save to waveform array
			for(int chanNum = 0 ; chanNum < numCHAN ; chanNum++ ){
				waveformValid[asicNum][chanNum][addrNum] = 1;
				waveformArray[asicNum][chanNum][addrNum][sampNum] 
				= ( waveformArray[asicNum][chanNum][addrNum][sampNum] | 
				( ( (buffer_uint[bufPos+5+count] >> chanNum) &  0x1 ) << (numBIT - bitNum -1) ));
			}
		}//end of check sample packet data

		//increment position
		count++;
	}

	return;
}

TString getOutputFileName(std::string inputFileName) {

        TString fileName(inputFileName);
        TObjArray* strings = fileName.Tokenize("/");
        TObjString* objstring = (TObjString*) strings->At(strings->GetLast());
        TString string(objstring->GetString());
        TString outputFileName("output_");
        outputFileName += string;
        outputFileName.ReplaceAll(".dat", ".root");
        outputFileName.ReplaceAll(".rawdata", ".root");
	strings->SetOwner(kTRUE);
	delete strings;
	return outputFileName;
}
