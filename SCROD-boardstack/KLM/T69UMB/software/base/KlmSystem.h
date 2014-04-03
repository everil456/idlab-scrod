#ifndef INCLUDE_KLMSYSTEM
#define INCLUDE_KLMSYSTEM

#include "base/UsbInterface.h"	
#include "base/KlmModule.h"
#include "base/ScrodPacket.h"

class KlmSystem
	/// Class encapsulating the entire KLM system readout.
{
public:

	~KlmSystem();
		/// Destructor.
		
	void initialize(std::ostream& output, char* configuration = NULL);
		/// Initialize the detector system.
		/// 'configuration' should hold the file name of
		/// the config XML file, or NULL if configuration
		/// should be skipped.
		
	void uninitialize();
		/// Uninitialize the detector system.
		
	KlmModule* operator[](module_id id);
		/// Returns KlmModule or NULL if it is not found.
		
	void start(std::ostream& output);
		/// Runs each module in its own thread, receiving data.
		
	void stop(std::ostream& output);
		/// Stops all the threads and stops receiving data.
	
	ScrodPacket* get_data();
		/// Returns received packet.

	void write_register(scrod_address address, scrod_register value, bool verify = true);
		/// Writes a value to the desired register.

	// static function
	static KlmSystem& KLM();
		/// Return singelton handle.
	
	static void Cleanup();
		/// Cleans up.
	
protected:
	
private:

	KlmSystem();
		/// Unreachable constructor.

private:

	typedef std::map<module_id, KlmModule*> KlmModuleMap;
	
	KlmModuleMap _modules;  // list of modules

	ObjectSync<ScrodPacket>	_received_data;

	static KlmSystem* _singleton;
};

inline ScrodPacket* KlmSystem::get_data()
{
	return _received_data.getObject();
}

#endif
