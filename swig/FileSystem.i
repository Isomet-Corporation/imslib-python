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
%attribute(iMS::FileSystemTableEntry, std::string, Name, Name);

namespace iMS{
  struct FileSystemTableEntry
  {
    %typemap(cscode) FileSystemTableEntry %{
      public override string ToString()
      {
	string strOut = "File type: " + Type + " Def: " + IsDefault + " Addr: " + string.Format("0x{0:X6}", Address) +  " Length: " + Length + " Name: " + Name ;
	return strOut;
      }
      %}
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

namespace iMS 
{
  
  %typemap(csinterfaces) FileSystemTableViewer "System.IDisposable, System.Collections.IEnumerable";
  class FileSystemTableViewer
  {
  %typemap(cscode) FileSystemTableViewer %{

  public bool IsFixedSize {
    get {
      return false;
    }
  }

  public bool IsReadOnly {
    get {
      return true;
    }
  }

  public FileSystemTableEntry this[int index]  {
    get {
      return getitemcopy(index);
    }
  }

  public int Count {
    get {
      return Entries();
    }
  }

  public bool IsSynchronized {
    get {
      return false;
    }
  }

  public void CopyTo(FileSystemTableEntry[] array)
  {
    CopyTo(0, array, 0, this.Count);
  }

  public void CopyTo(FileSystemTableEntry[] array, int arrayIndex)
  {
    CopyTo(0, array, arrayIndex, this.Count);
  }

  public void CopyTo(int index, FileSystemTableEntry[] array, int arrayIndex, int count)
  {
    if (array == null)
      throw new System.ArgumentNullException("array");
    if (index < 0)
      throw new System.ArgumentOutOfRangeException("index", "Value is less than zero");
    if (arrayIndex < 0)
      throw new System.ArgumentOutOfRangeException("arrayIndex", "Value is less than zero");
    if (count < 0)
      throw new System.ArgumentOutOfRangeException("count", "Value is less than zero");
    if (array.Rank > 1)
      throw new System.ArgumentException("Multi dimensional array.", "array");
    if (index+count > this.Count || arrayIndex+count > array.Length)
      throw new System.ArgumentException("Number of elements to copy is too large.");
    for (int i=0; i<count; i++)
      array.SetValue(getitemcopy(index+i), arrayIndex+i);
  }

  System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  public $csclassnameEnumerator GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  // Type-safe enumerator
  /// Note that the IEnumerator documentation requires an InvalidOperationException to be thrown
  /// whenever the collection is modified. This has been done for changes in the size of the
  /// collection but not when one of the elements of the collection is modified as it is a bit
  /// tricky to detect unmanaged code that modifies the collection under our feet.
  public sealed class $csclassnameEnumerator : System.Collections.IEnumerator
    , System.Collections.Generic.IEnumerator<FileSystemTableEntry>
  {
    private $csclassname collectionRef;
    private int currentIndex;
    private object currentObject;
    private int currentSize;

    public $csclassnameEnumerator($csclassname collection) {
      collectionRef = collection;
      currentIndex = -1;
      currentObject = null;
      currentSize = collectionRef.Count;
    }

    // Type-safe iterator Current
    public FileSystemTableEntry Current {
      get {
        if (currentIndex == -1)
          throw new System.InvalidOperationException("Enumeration not started.");
        if (currentIndex > currentSize - 1)
          throw new System.InvalidOperationException("Enumeration finished.");
        if (currentObject == null)
          throw new System.InvalidOperationException("Collection modified.");
        return (FileSystemTableEntry)currentObject;
      }
    }

    private System.Collections.IEnumerator GetEnumerator()
    {
      return (System.Collections.IEnumerator)this;
    }
        
    // Type-unsafe IEnumerator.Current
    object System.Collections.IEnumerator.Current {
      get {
        return Current;
      }
    }

    public bool MoveNext() {
      int size = collectionRef.Count;
      bool moveOkay = (currentIndex+1 < size) && (size == currentSize);
      if (moveOkay) {
        currentIndex++;
        currentObject = collectionRef[currentIndex];
      } else {
        currentObject = null;
      }
      return moveOkay;
    }

    public void Reset() {
      currentIndex = -1;
      currentObject = null;
      if (collectionRef.Count != currentSize) {
        throw new System.InvalidOperationException("Collection modified.");
      }
    }

    public void Dispose() {
        currentIndex = -1;
        currentObject = null;
    }
  }
  %}

  public:
    %extend {
      FileSystemTableEntry getitemcopy(int index) throw (std::out_of_range) {
        if (index>=0 && index<$self->Entries())
          return (*$self)[index];
        else
          throw std::out_of_range("index");
      }
    }
    FileSystemTableViewer(const IMSSystem& ims);
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
    FileSystemManager(IMSSystem& ims);
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

}
