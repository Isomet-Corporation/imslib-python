namespace iMS
{
  enum class FileSystemTypes
  {
    NO_FILE = 0,
      COMPENSATION_TABLE = 1,
      TONE_BUFFER = 2,
      DDS_SCRIPT = 3,
      USER_DATA = 15
      };

  enum class FileDefault
  {
    DEFAULT = 1,
      NON_DEFAULT = 0
      };

  typedef int FileSystemIndex;

}

%attribute(iMS::FileSystemTableEntry, iMS::FileSystemTypes, Type, Type);
%attribute(iMS::FileSystemTableEntry, uint32_t, Address, Address);
%attribute(iMS::FileSystemTableEntry, uint32_t, Length, Length);
%attribute(iMS::FileSystemTableEntry, bool, IsDefault, IsDefault);
%attributestring(iMS::FileSystemTableEntry, std::string, Name, Name);

namespace iMS{
    %extend FileSystemTableEntry {
        %pythoncode %{
            def __str__(self):
                return f"File type: {self.Type} Def: {self.IsDefault} Addr: 0x{self.Address:06X} Len: {self.Length} Name: {self.Name}"
        %}
    }

  struct FileSystemTableEntry
  {
    FileSystemTableEntry();
    FileSystemTableEntry(FileSystemTypes type, uint32_t addr, uint32_t length, FileDefault def);
    FileSystemTableEntry(FileSystemTypes type, uint32_t addr, uint32_t length, FileDefault def, std::string name);
    //    FileSystemTableEntry(const FileSystemTableEntry &);
    //    FileSystemTableEntry &operator =(const FileSystemTableEntry &);
    
    FileSystemTypes Type() const;
    uint32_t Address() const;
    int32_t Length() const;
    bool IsDefault() const;
    std::string Name() const;
  };
  
  const unsigned int MAX_FST_ENTRIES = 33;

}

%attribute(iMS::FileSystemTableViewer, int, Entries, Entries);
%attribute(iMS::FileSystemTableViewer, bool, IsValid, IsValid);

namespace iMS 
{
    %extend FileSystemTableViewer {
        FileSystemTableEntry _getitem(size_t i) {
            if (i >= $self->Entries())
                throw std::out_of_range("FileSystemTable index out of range");
            return (*$self)[i];
        }

        size_t __len__() {
            return $self->Entries();
        }

        %pythoncode %{
            def __iter__(self):
                for i in range(len(self)):
                    yield self[i]
            def __getitem__(self, idx):
                if isinstance(idx, slice):
                    return [self[i] for i in range(*idx.indices(len(self)))]
                else:
                    if idx < 0: idx += len(self)
                    if idx < 0 or idx >= len(self):
                        raise IndexError("FileSystemTable index out of range")
                    return self._getitem(idx)
        %}
    }

    class FileSystemTableViewer
    {
    public:

        FileSystemTableViewer(std::shared_ptr<IMSSystem> ims);
        const bool IsValid() const;
        const int Entries() const;
        //    const FileSystemTableEntry operator[](const std::size_t idx) const;
        //    friend LIBSPEC std::ostream& operator<< (std::ostream& stream, const FileSystemTableViewer&);
    };

}

%apply unsigned int *INOUT { unsigned int & addr};

namespace iMS {

  class FileSystemManager
  {
  public:
    FileSystemManager(std::shared_ptr<IMSSystem> ims);
    bool Delete(FileSystemIndex index);
    bool Delete(const std::string& FileName);
    bool SetDefault(FileSystemIndex index);
    bool SetDefault(const std::string& FileName);
    bool ClearDefault(FileSystemIndex index);
    bool ClearDefault(const std::string& FileName);
    bool Sanitize();
    bool FindSpace(uint32_t& addr, const std::vector<uint8_t>& data) const;
    bool Execute(FileSystemIndex index);
    bool Execute(const std::string& FileName);
  };

    // ---------- Typemaps for bytes, list[int], and file-like ----------

    // Python → C++  (used by UserFileWriter)
    %typemap(in) const std::vector<uint8_t>& (std::vector<uint8_t> temp) {
        if (PyBytes_Check($input)) {
            char* buf;
            Py_ssize_t len;
            PyBytes_AsStringAndSize($input, &buf, &len);
            temp.assign(buf, buf + len);
            $1 = &temp;
        } else if (PyList_Check($input)) {
            Py_ssize_t len = PyList_Size($input);
            temp.resize(len);
            for (Py_ssize_t i = 0; i < len; ++i) {
                PyObject* item = PyList_GetItem($input, i);
                temp[i] = static_cast<uint8_t>(PyLong_AsUnsignedLong(item));
            }
            $1 = &temp;
        } else if (PyObject_HasAttrString($input, "read")) {
            // Handle file-like object with .read()
            PyObject* data_obj = PyObject_CallMethod($input, (char*)"read", nullptr);
            if (!data_obj) SWIG_exception_fail(SWIG_RuntimeError, "Failed to read from file-like object");
            if (!PyBytes_Check(data_obj)) {
                Py_DECREF(data_obj);
                SWIG_exception_fail(SWIG_TypeError, ".read() did not return bytes");
            }
            char* buf;
            Py_ssize_t len;
            PyBytes_AsStringAndSize(data_obj, &buf, &len);
            temp.assign(buf, buf + len);
            Py_DECREF(data_obj);
            $1 = &temp;
        } else {
            SWIG_exception_fail(SWIG_TypeError,
                "Expected bytes, bytearray, list[int], or file-like object for file_data");
        }
    }

    // Disable auto cleanup (prevents 'res2 undeclared' error)
    %typemap(freearg) const std::vector<uint8_t>& "";

    // C++ → Python  (used by Readback with no args)
    %typemap(out) std::vector<uint8_t> {
        $result = PyBytes_FromStringAndSize(
            reinterpret_cast<const char*>($1.data()), $1.size());
    }

    // ---------- Extended UserFileReader.Readback ----------
    // Supports:
    //   Readback()              → returns bytes
    //   Readback(file_object)   → writes to file_object and returns bool

    %extend UserFileReader {
        PyObject* Readback(PyObject* out_obj = nullptr) {
            std::vector<uint8_t> data;
            bool ok = $self->Readback(data);
            if (!ok)
                Py_RETURN_FALSE;

            // If a Python file-like object is passed, call .write()
            if (out_obj && PyObject_HasAttrString(out_obj, "write")) {
                PyObject* res = PyObject_CallMethod(out_obj, (char*)"write", (char*)"y#",
                                                    reinterpret_cast<const char*>(data.data()),
                                                    (Py_ssize_t)data.size());
                if (!res) {
                    SWIG_Error(SWIG_RuntimeError, "Failed to write to file-like object");
                    Py_RETURN_FALSE;
                }
                Py_DECREF(res);
                Py_RETURN_TRUE;
            }

            // Default behaviour: return bytes
            return PyBytes_FromStringAndSize(
                reinterpret_cast<const char*>(data.data()), data.size());
        }
    }

	class UserFileReader
	{
	public:
		UserFileReader(std::shared_ptr<IMSSystem> ims, const FileSystemIndex index);
		UserFileReader(std::shared_ptr<IMSSystem> ims, const std::string& FileName);
		bool Readback(std::vector<std::uint8_t>& data); 
    }; 

	class UserFileWriter
	{
	public:
		UserFileWriter(std::shared_ptr<IMSSystem> ims, const std::vector<std::uint8_t>& file_data, const std::string file_name);
		FileSystemIndex Program();
	};

}
