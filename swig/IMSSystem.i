%include <std_shared_ptr.i>
%include <std_string.i>

#include "IConnectionSettings.h"
#include "CS_ETH.h"
#include "CS_RS422.h"

namespace iMS {

  struct FWVersion
  {
    const int major{ -1 };
    const int minor{ 0 };
    const int revision{ 0 };
//    const struct tm build_date;  // not sure best way to interpret struct tm in other languages
  };
}

namespace iMS {

  class IMSOption
  {
  public:
	const std::string& Name() const;
  };
}

%shared_ptr(iMS::IMSOption)

namespace iMS {

  class IMSController
  {
  public:
    // struct Capabilities
    // {
    //    int nSynthInterfaces{ 1 };
    //    bool FastImageTransfer{ false };
    //    int MaxImageSize{ 4096 };
    //    bool SimultaneousPlayback{ false };
    //    Frequency MaxImageRate{ 250.0 };
    //   bool RemoteUpgrade{ false };
    // };
//    const Capabilities GetCap() const;
    const std::string& Description() const;
    const std::string& Model() const;
    const FWVersion& GetVersion() const;
    const ImageTable& ImgTable() const;  
    const bool IsValid() const;
  };
}

namespace iMS {

  class IMSSynthesiser
  {
  public:
    // struct Capabilities
    // {
    //   MHz lowerFrequency{ 0.0 };
    //   MHz upperFrequency{ 250.0 };
    //   int freqBits{ 16 };
    //   int amplBits{ 10 };
    //   int phaseBits{ 12 };
    //   int LUTDepth{ 12 };
    //   int LUTAmplBits{ 12 };
    //   int LUTPhaseBits{ 14 };
    //   int LUTSyncABits{ 12 };
    //   int LUTSyncDBits{ 12 };
    //   MHz sysClock{ 500.0 };
    //   MHz syncClock{ 125.0 };
    //   int channels{ 4 };
    //   bool RemoteUpgrade{ false };
    //   bool ChannelComp{ false };
    // };
    std::shared_ptr<const IMSOption> AddOn() const;
    //const Capabilities GetCap() const;
    const std::string& Description() const;
    const std::string& Model() const;
    const FWVersion& GetVersion() const;
    const bool IsValid() const;
    const FileSystemTable& FST() const;
  };
}

namespace iMS {

  class IConnectionSettings
  {
  public:
    virtual const std::string& Ident() const = 0;
    virtual void ProcessData(const std::vector<std::uint8_t>& data) = 0;
    virtual const std::vector<std::uint8_t>& ProcessData() const = 0;
  };
}

//%attribute(iMS::CS_ETH, bool, UseDHCP, UseDHCP, UseDHCP);
//%attributestring(iMS::CS_ETH, std::string, Address, Address, Address);
//%attributestring(iMS::CS_ETH, std::string, Netmask, Netmask, Netmask);
//%attributestring(iMS::CS_ETH, std::string, Gateway, Gateway, Gateway);
namespace iMS {
  class CS_ETH : public IConnectionSettings
  {
  public:
    
    //CS_ETH();
    CS_ETH(bool use_dhcp = false,
	   std::string addr = std::string("192.168.1.10"),
	   std::string netmask = std::string("255.255.255.0"),
	   std::string gw = std::string("192.168.1.1"));
    ~CS_ETH();
    //CS_ETH(std::vector<std::uint8_t> process_data);
    //    void UseDHCP(bool dhcp);
    //    bool UseDHCP() const; 
    //    void Address(const std::string& addr);
    //    std::string Address() const;
    //    void Netmask(const std::string& mask);
    //    std::string Netmask() const;
    
    //    void Gateway(const std::string& gw);
    //    std::string Gateway() const;
       const std::string& Ident() const;
       void ProcessData(const std::vector<std::uint8_t>& data);
       const std::vector<std::uint8_t>& ProcessData() const;
  };
}

//%attribute(iMS::CS_RS422, unsigned int, BaudRate, BaudRate, BaudRate);
namespace iMS {

  class CS_RS422 : public IConnectionSettings
  {
  public:
        CS_RS422();
        CS_RS422(unsigned int baud_rate);
        CS_RS422(std::vector<std::uint8_t> process_data);
	~CS_RS422();

	//        void BaudRate(const unsigned int& baud_rate);
	//        unsigned int BaudRate() const;

		const std::string& Ident() const;
		void ProcessData(const std::vector<std::uint8_t>& data);
		const std::vector<std::uint8_t>& ProcessData() const;
  };
}

namespace iMS {
  %rename(__eq__) IMSSystem::operator==;
  class IMSSystem
  {
  public:
    void Connect();
    void Disconnect();
  	void SetTimeouts(int send_timeout_ms, int rx_timeout_ms, int free_timeout_ms, int discover_timeout_ms);
    bool Open() const;
    const IMSController& Ctlr() const;
    const IMSSynthesiser& Synth() const;
    const std::string& ConnPort() const;
    bool operator==(IMSSystem const& rhs) const;
    bool ApplySettings(const IConnectionSettings& settings);
    bool RetrieveSettings(IConnectionSettings& settings);
    //    %extend {
    //      IConnectionSettings& getitem() {
    //	IConnectionSettings& settings;
    //	RetreiveSettings(settings);
    //	return settings;
    //      }
    //    }
  };
}

