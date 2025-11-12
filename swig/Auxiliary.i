%include "std_map.i"

namespace iMS
{
  enum class AuxiliaryEvents
  {
    EXT_ANLG_UPDATE_AVAILABLE,
    EXT_ANLG_READ_FAILED
  };
}

namespace iMS
{
  
  class Auxiliary
  {
  public:
    Auxiliary(std::shared_ptr<IMSSystem> ims);
    enum class LED_SOURCE
    {
      OFF,
	ON,
	PULS,
	NPULS,
	PIXEL_ACT,
	CTRL_ACT,
	COMMS_HEALTHY,
	COMMS_UNHEALTHY,
	RF_GATE,
	INTERLOCK,
	LASER,
	CHECKSUM,
	OVERTEMP,
	PLL_LOCK,
    ACTV,
    IDLE
	};
    
    enum class LED_SINK
    {
      GREEN,
	YELLOW,
	RED
	};
    
    enum class DDS_PROFILE
    {
      OFF = 0,
	EXTERNAL = 16,
	HOST = 32
	};

    enum class EXT_ANLG_INPUT
    {
      A,
	B
	};
    
    bool AssignLED(const LED_SINK& sink, const LED_SOURCE& src) const;
    bool SetDDSProfile(const DDS_PROFILE& prfl) const;
    bool SetDDSProfile(const DDS_PROFILE& prfl, const uint16_t& select) const;
    bool UpdateAnalogIn();
    const std::map<int, Percent>& GetAnalogData() const;
    bool UpdateAnalogOut(Percent& pct) const;
    void AuxiliaryEventSubscribe(const int message, IEventHandler* handler);
    void AuxiliaryEventUnsubscribe(const int message, const IEventHandler* handler);
  };

}

namespace iMS
{
  %rename(__eq__) DDSScriptRegister::operator==;
  class DDSScriptRegister
  {
  public:
    enum class Name
    {
      CSR = 0,
	FR1 = 1,
	FR2 = 2,
	CFR = 3,
	CFTW0 = 4,
	CPOW0 = 5,
	ACR = 6,
	LSRR = 7,
	RDW = 8,
	FDW = 9,
	CW1 = 10,
	CW2 = 11,
	CW3 = 12,
	CW4 = 13,
	CW5 = 14,
	CW6 = 15,
	CW7 = 16,
	CW8 = 17,
	CW9 = 18,
	CW10 = 19,
	CW11 = 20,
	CW12 = 21,
	CW13 = 22,
	CW14 = 23,
	CW15 = 24,
	UPDATE = 64
	};
    
    DDSScriptRegister(Name name = Name::CSR);
    %extend {
      DDSScriptRegister(Name name, const std::vector<uint8_t>& data)
	{
	  DDSScriptRegister *reg = new DDSScriptRegister(name);
	  for (int element : data)
	      reg->append(element);
	  return reg;
	}
      /*bool operator==(DDSScriptRegister const& rhs) const {
	  return ( $self->bytes() == rhs.bytes() );
	  }*/
    }
    //    DDSScriptRegister(Name name, const std::initializer_list<uint8_t>& data);
    DDSScriptRegister(const DDSScriptRegister &);
    //    DDSScriptRegister &operator =(const DDSScriptRegister &);
    int append(const uint8_t&);
    std::vector<uint8_t> bytes() const;
  };
}

//SWIG_STD_VECTOR_ENHANCED(iMS::DDSScriptRegister)
%template(DDSScript) std::vector<iMS::DDSScriptRegister>;

typedef std::vector<iMS::DDSScriptRegister> DDSScript;

namespace iMS {
  class DDSScriptDownload
  {
  public:
    DDSScriptDownload(std::shared_ptr<IMSSystem> ims, const DDSScript& script);
    const FileSystemIndex Program(const std::string& FileName, FileDefault def = FileDefault::NON_DEFAULT) const;
  };
}
