%include "std_string.i"

%template(IMSList) std::vector<iMS::IMSSystem>;

// Basic SWIG typemap to wrap iMS::ListBase<T> as std::vector<T>
%typemap(out) iMS::ListBase<std::string> {
    $result = PyList_New($1->size());
    int i = 0;
    for (auto it = $1->begin(); it != $1->end(); ++it, ++i) {
        PyList_SetItem($result, i, PyUnicode_FromString(it->c_str()));
    }
}

%typemap(out) const iMS::ListBase<std::string>& {
    $result = PyList_New($1->size());
    int i = 0;
    for (auto it = $1->begin(); it != $1->end(); ++it, ++i) {
        PyList_SetItem($result, i, PyUnicode_FromString(it->c_str()));
    }
}

namespace iMS {

  class ConnectionList
  {
  public:
    // struct ConnectionConfig
    // {
    //   bool IncludeInScan;
    //   ListBase<std::string> PortMask;
    //   ConnectionConfig();
    //   ConnectionConfig(bool inc);
    //   ConnectionConfig(const ListBase<std::string>& mask);
    // };
    //    typedef std::map<std::string, ConnectionConfig> ConnectionConfigMap;
    //ConnectionConfig& config(const std::string& module);
    const ListBase<std::string>& modules() const;
    std::vector<IMSSystem> scan();
  };
}

