%include "std_string.i"

%template(IMSList) std::vector<std::shared_ptr<iMS::IMSSystem>>;

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

%rename(_Scan) ConnectionList::Scan();
%rename(_ScanInterface) ConnectionList::Scan(const std::string&, const std::vector<std::string>& = {});

%extend ConnectionList {
    %pythoncode %{
    def Scan(self, *args):
        """
        Scan() -> list[IMSSystem]
        Scan(interfaceName: str, addressHints: list[str] = []) -> IMSSystem or None
        """
        if not args:
            return self._Scan()  # C++ Scan()
        else:
            return self._ScanInterface(*args)
    %}    
}
  class ConnectionList
  {
  public:
    ConnectionList(unsigned int max_discover_timeout_ms = 500);
    ConnectionConfig& Config(const std::string& module);
    const ListBase<std::string>& Modules() const;
    void Settings(const std::string& module, const IConnectionSettings* settings);
    std::vector<std::shared_ptr<IMSSystem>> Scan();
    std::shared_ptr<IMSSystem> Scan(const std::string&, const std::vector<std::string>& = {});
    std::shared_ptr<IMSSystem> Find(const std::string&, const std::string&, const std::vector<std::string>& = {});
  };
}

