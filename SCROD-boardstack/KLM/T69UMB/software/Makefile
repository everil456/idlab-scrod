COMPILE_FLAGS = -g -gdwarf-2 -Isrc/lib -I/usr/include/libusb-1.0 -DUSE_USB -I.
LINK_OPTIONS = -L/usr/lib/i386-linux-gnu -lusb-1.0 -lpthread

APPS = bin/KlmRegisterWrite bin/KlmRegisterRead bin/KlmAsicWrite bin/KlmConfigure bin/KlmToFile bin/KlmTestTriggers
OBJECT_FILES = base/KlmSystem.o base/DetectorInterface.o base/UsbInterface.o base/ScrodPacket.o base/KlmModule.o base/tinyxml2.o base/KlmConsumer.o base/KlmFile.o base/CopperInterface.o

all : $(APPS)

base/%.o : base/%.cpp;
	g++ $(COMPILE_FLAGS) -c $< -o $@

tools/%.o : tools/%.cpp;
	g++ $(COMPILE_FLAGS) -c $< -o $@

bin/KlmRegisterWrite : tools/KlmRegisterWrite.o $(OBJECT_FILES) ; g++ $^ $(LINK_OPTIONS) -o $@

bin/KlmRegisterRead : tools/KlmRegisterRead.o $(OBJECT_FILES) ; g++ $^ $(LINK_OPTIONS) -o $@

bin/KlmAsicWrite : tools/KlmAsicWrite.o $(OBJECT_FILES) ; g++ $^ $(LINK_OPTIONS) -o $@

bin/KlmConfigure : tools/KlmConfigure.o $(OBJECT_FILES) ; g++ $^ $(LINK_OPTIONS) -o $@

#bin/KlmSoftRecord : tools/KlmSoftRecord.o $(OBJECT_FILES) ; g++ $^ $(LINK_OPTIONS) -o $@

bin/KlmToFile : tools/KlmToFile.o $(OBJECT_FILES) ; g++ $^ $(LINK_OPTIONS) -o $@

bin/KlmTestTriggers : tools/KlmTestTriggers.o $(OBJECT_FILES) ; g++ $^ $(LINK_OPTIONS) -o $@

clean: 
	-rm -rf base/*.o bin/* tools/*.o
