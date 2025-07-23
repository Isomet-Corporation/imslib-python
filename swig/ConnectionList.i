%include "std_string.i"

%template(IMSList) std::vector<iMS::IMSSystem>;

    // Define a dummy mirror struct to replace the nested struct
    %inline %{
    namespace iMS {
    struct ConnectionConfig {
      bool IncludeInScan;
      ListBase<std::string> PortMask;

      ConnectionConfig() : IncludeInScan(false) {}
      ConnectionConfig(bool inc) : IncludeInScan(inc) {}
      ConnectionConfig(const ListBase<std::string>& mask) : IncludeInScan(true), PortMask(mask) {}
    };
    }
    %}

    // Create a typemap to translate the real nested struct to the dummy exposed one
    %typemap(out) iMS::ConnectionList::ConnectionConfig {
        auto* capPtr = new iMS::ConnectionConfig{
            $1.IncludeInScan,
            $1.PortMask
        };
        $result = SWIG_NewPointerObj(capPtr, SWIGTYPE_p_iMS__ConnectionConfig, SWIG_POINTER_OWN);
    }    

namespace iMS {

  class ConnectionList
  {
  public:
    ConnectionConfig& config(const std::string& module);
    const ListBase<std::string>& modules() const;
    std::vector<IMSSystem> scan();
  };
}

