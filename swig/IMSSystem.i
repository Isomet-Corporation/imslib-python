%include <std_shared_ptr.i>
%include <std_string.i>

%{
    // For operator<<
    #include <sstream>
    // for std::tm
    #include <ctime>
%}

%include <attribute.i>

namespace iMS {

  struct FWVersion
  {
    %immutable;
    const int major{ -1 };
    const int minor{ 0 };
    const int revision{ 0 };
    %mutable;
  };

  // Tell SWIG how to convert operator<< to Python __str__
    %extend FWVersion {
        std::string __str__() {
            std::ostringstream oss;
            oss << *$self;
            return oss.str();
        }

        std::string build_date_str() {
            char buf[100];
            std::strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", &$self->build_date);
            return std::string(buf);        
        }
    }
}

namespace iMS {

  class IMSOption
  {
  public:
	const std::string& Name() const;
  };
}

%shared_ptr(iMS::IMSOption)

    // Define a dummy mirror struct to replace the nested struct
    %immutable;
    %inline %{
    namespace iMS {
    struct IMSControllerCapabilities {
        int nSynthInterfaces;
        bool FastImageTransfer;
        int MaxImageSize;
        bool SimultaneousPlayback;
        double MaxImageRate;
        bool RemoteUpgrade;
    };
    }
    %}
    %mutable;        

    // Create a typemap to translate the real nested struct to the dummy exposed one
    %typemap(out) iMS::IMSController::Capabilities {
        auto* capPtr = new iMS::IMSControllerCapabilities{
            $1.nSynthInterfaces,
            $1.FastImageTransfer,
            $1.MaxImageSize,
            $1.SimultaneousPlayback,
            $1.MaxImageRate,
            $1.RemoteUpgrade
        };
        $result = SWIG_NewPointerObj(capPtr, SWIGTYPE_p_iMS__IMSControllerCapabilities, SWIG_POINTER_OWN);
    }

namespace iMS {

  class IMSController
  {
  public:
    const IMSController::Capabilities GetCap() const;
    const std::string& Description() const;
    const std::string& Model() const;
    const FWVersion& GetVersion() const;
    const ImageTable& ImgTable() const;  
    const bool IsValid() const;
  };

}

    %immutable;
    %inline %{
    namespace iMS {
    struct IMSSynthesiserCapabilities {
      double lowerFrequency;
      double upperFrequency;
      int freqBits;
      int amplBits;
      int phaseBits;
      int LUTDepth;
      int LUTAmplBits;
      int LUTPhaseBits;
      int LUTSyncABits;
      int LUTSyncDBits;
      double sysClock;
      double syncClock;
      int channels;
      bool RemoteUpgrade;
      bool ChannelComp;
    };
    }
    %}
    %mutable;

    %typemap(out) iMS::IMSSynthesiser::Capabilities {
        auto* capPtr = new iMS::IMSSynthesiserCapabilities{
            $1.lowerFrequency,
            $1.upperFrequency,
            $1.freqBits,
            $1.amplBits,
            $1.phaseBits,
            $1.LUTDepth,
            $1.LUTAmplBits,
            $1.LUTPhaseBits,
            $1.LUTSyncABits,
            $1.LUTSyncDBits,
            $1.sysClock,
            $1.sysClock,
            $1.channels,
            $1.RemoteUpgrade,
            $1.ChannelComp
        };
        $result = SWIG_NewPointerObj(capPtr, SWIGTYPE_p_iMS__IMSSynthesiserCapabilities, SWIG_POINTER_OWN);
    }

namespace iMS {

  class IMSSynthesiser
  {
  public:
    std::shared_ptr<const IMSOption> AddOn() const;
    const IMSSynthesiser::Capabilities GetCap() const;
    const std::string& Description() const;
    const std::string& Model() const;
    const FWVersion& GetVersion() const;
    const bool IsValid() const;
    const FileSystemTable& FST() const;
  };
}

%ignore iMS::IConnectionSettings; // abstract and not needed in Python

namespace iMS {

  class IConnectionSettings
  {
  public:
    virtual const std::string& Ident() const = 0;
    virtual void ProcessData(const std::vector<std::uint8_t>& data) = 0;
    virtual const std::vector<std::uint8_t>& ProcessData() const = 0;
  };
}

%ignore iMS::CS_ETH::ProcessData(const std::vector<std::uint8_t>& data);
%ignore iMS::CS_ETH::ProcessData() const;

%attribute(iMS::CS_ETH, bool, dhcp, UseDHCP, UseDHCP);
%attributestring(iMS::CS_ETH, std::string, addr, Address, Address);
%attributestring(iMS::CS_ETH, std::string, mask, Netmask, Netmask);
%attributestring(iMS::CS_ETH, std::string, gw, Gateway, Gateway);

namespace iMS {
  class CS_ETH : public IConnectionSettings
  {
  public:
    
    CS_ETH(bool use_dhcp = false,
	   std::string addr = std::string("192.168.1.10"),
	   std::string netmask = std::string("255.255.255.0"),
	   std::string gw = std::string("192.168.1.1"));
    ~CS_ETH();

       void UseDHCP(bool dhcp);
       bool UseDHCP() const; 
       void Address(const std::string& addr);
       std::string Address() const;
       void Netmask(const std::string& mask);
       std::string Netmask() const;
    
       void Gateway(const std::string& gw);
       std::string Gateway() const;
       const std::string& Ident() const;
       void ProcessData(const std::vector<std::uint8_t>& data);
       const std::vector<std::uint8_t>& ProcessData() const;
  };
}

%ignore iMS::CS_RS422::ProcessData(const std::vector<std::uint8_t>& data);
%ignore iMS::CS_RS422::ProcessData() const;

%attribute(iMS::CS_RS422, unsigned int, baud, BaudRate, BaudRate);

namespace iMS {

  class CS_RS422 : public IConnectionSettings
  {
  public:
        CS_RS422();
        CS_RS422(unsigned int baud_rate);
        CS_RS422(std::vector<std::uint8_t> process_data);
	~CS_RS422();

	void BaudRate(const unsigned int& baud_rate);
	unsigned int BaudRate() const;

		const std::string& Ident() const;
		void ProcessData(const std::vector<std::uint8_t>& data);
		const std::vector<std::uint8_t>& ProcessData() const;
  };
}

// ---------------------------
// Typemap: Accept class object or string as argument
// ---------------------------
%typemap(in) const std::string& settings {
    std::string* _swig_str_temp = nullptr;

    if (PyUnicode_Check($input)) {
        PyObject* utf8_bytes = PyUnicode_AsUTF8String($input);
        if (!utf8_bytes) {
            SWIG_exception_fail(SWIG_RuntimeError, "Failed to encode input string to UTF-8");
        }

        const char* name_str = PyBytes_AsString(utf8_bytes);
        if (!name_str) {
            Py_DECREF(utf8_bytes);
            SWIG_exception_fail(SWIG_RuntimeError, "Failed to extract bytes from string");
        }

        _swig_str_temp = new std::string(name_str);
        Py_DECREF(utf8_bytes);
    } else {
        PyObject* type_obj = PyObject_Type($input);
        if (!type_obj) {
            SWIG_exception_fail(SWIG_RuntimeError, "Unable to get type from input object");
        }

        PyObject* type_name_obj = PyObject_GetAttrString(type_obj, "__name__");
        Py_DECREF(type_obj);

        if (!type_name_obj || !PyUnicode_Check(type_name_obj)) {
            SWIG_exception_fail(SWIG_TypeError, "Expected a class instance or string");
        }

        PyObject* utf8_bytes = PyUnicode_AsUTF8String(type_name_obj);
        Py_DECREF(type_name_obj);

        if (!utf8_bytes) {
            SWIG_exception_fail(SWIG_RuntimeError, "Failed to encode type name to UTF-8");
        }

        const char* name_str = PyBytes_AsString(utf8_bytes);
        if (!name_str) {
            Py_DECREF(utf8_bytes);
            SWIG_exception_fail(SWIG_RuntimeError, "Failed to extract bytes from UTF-8 string");
        }

        _swig_str_temp = new std::string(name_str);
        Py_DECREF(utf8_bytes);
    }

    $1 = _swig_str_temp;
}

%typemap(freearg) const std::string& settings {
    delete $1;
}

// ---------------------------
// Typemap: Return correct subclass based on Ident()
// ---------------------------
%typemap(out) iMS::IConnectionSettings* {
    if (!$1) {
        Py_INCREF(Py_None);
        $result = Py_None;
    } else if (auto* rs = dynamic_cast<iMS::CS_RS422*>($1)) {
        $result = SWIG_NewPointerObj(rs, SWIGTYPE_p_iMS__CS_RS422, SWIG_POINTER_OWN);
    } else if (auto* eth = dynamic_cast<iMS::CS_ETH*>($1)) {
        $result = SWIG_NewPointerObj(eth, SWIGTYPE_p_iMS__CS_ETH, SWIG_POINTER_OWN);
    } else {
        SWIG_exception_fail(SWIG_RuntimeError, "Unknown settings subclass");
    }
}

%ignore iMS::IMSSystem::RetrieveSettings(IConnectionSettings&);

namespace iMS {
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
    bool RetrieveSettings(IConnectionSettings& settings);  // ignored

  };

  %extend IMSSystem {
    iMS::IConnectionSettings* RetrieveSettings(const std::string& settings) {
    if (settings == "CS_RS422") {
        static CS_RS422 obj;  // static is required to persist memory usage across calls and avoid double deletes, but it is not thread-safe
        if (!$self->RetrieveSettings(obj)) {
            return nullptr;
        }
        return new CS_RS422(obj);
    }
    else if (settings == "CS_ETH") {
        static CS_ETH obj;
        if (!$self->RetrieveSettings(obj)) {
            return nullptr;
        }
        return new CS_ETH(obj);
    }
    return nullptr;
    }
  }
}

