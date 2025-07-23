%include <std_shared_ptr.i>
%include <std_list.i>   // Support for std::list<T>
%include <std_common.i>
%include <typemaps.i>
%include <exception.i>

%{
#include <sstream>
#include <algorithm>
%}

namespace iMS {

  %rename(__eq__) ListBase::operator==;
template <typename CTYPE>
  class ListBase {

  public:
    typedef std::list<CTYPE>::iterator iterator;
    typedef std::list<CTYPE>::const_iterator const_iterator;
    iterator begin();
    iterator end();
    const_iterator cbegin() const;
    const_iterator cend() const;
    %extend {
        CTYPE __getitem__(size_t i) {
            if (i >= $self->size()) {
                //SWIG_exception(SWIG_IndexError, "Index out of range");
                return CTYPE();  // Return dummy value after raising exception
            }
            auto it = $self->begin();
            std::advance(it, i);
            return *it;
        }

        void __setitem__(size_t i, CTYPE val) {
            if (i >= $self->size()) {
                //SWIG_exception(SWIG_IndexError, "Index out of range");
                return;
            }
            auto it = $self->begin();
            std::advance(it, i);
            *it = val;
        }
        size_t __len__() {
            return $self->size();
        }

        bool __bool__() {
            return !$self->empty();
        }

        void append(const CTYPE& val) {
            $self->push_back(val);
        }

        CTYPE pop() {
            if ($self->empty()) {
                //SWIG_exception(SWIG_IndexError, "Pop from empty list");
                return CTYPE();
            }
            auto it = $self->end();
            CTYPE val = *--it;
            $self->pop_back();
            return val;
        }

        bool __contains__(CTYPE val) {
            return std::find($self->begin(), $self->end(), val) != $self->end();
        }

        std::string __str__() {
            std::ostringstream oss;
            oss << "[";
            for (auto it = $self->begin(); it != $self->end(); ++it) {
            if (it != $self->begin()) oss << ", ";
            oss << *it;
            }
            oss << "]";
            return oss.str();
        }

        
        %pythoncode %{
            def __iter__(self):
                for i in range(len(self)):
                    yield self[i]
            %}
    }    

    ListBase(const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
    ListBase(const ListBase &);
    //    ListBase &operator =(const ListBase &);

    bool operator==(ListBase const& rhs) const;
    //const std::array<uint8_t, 16> GetUUID() const;
    void assign(size_t n, const CTYPE& val);
    void resize(size_t n);
    void clear();
    //    ListBase<CTYPE>::iterator insert(ListBase<CTYPE>::iterator pos, const CTYPE& value);
    //    ListBase<CTYPE>::iterator insert(ListBase<CTYPE>::iterator pos, ListBase<CTYPE>::const_iterator first, ListBase<CTYPE>::const_iterator last);
    void push_back(const CTYPE& value);
    void pop_back();
    void push_front(const CTYPE& value);
    void pop_front();
    //    ListBase<CTYPE>::iterator erase(ListBase<CTYPE>::iterator pos);
    //    ListBase<CTYPE>::iterator erase(ListBase<CTYPE>::iterator first, ListBase<CTYPE>::iterator last);
    bool empty() const;
    std::size_t size() const;
    //const std::string& Name() const;
    //std::string& Name();
  };

}

// %shared_ptr(iMS::SequenceEntry)

// %template(ListBase_SequenceEntry) iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >;
// //%attributeval(iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >, std::string, Name);
// //%attribute_readonly(iMS::ListBase< iMS::ImageSequenceEntry >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(ListBase_ImageGroup) iMS::ListBase< iMS::ImageGroup >;
// //%attributeval(iMS::ListBase< iMS::ImageGroup >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::ListBase< iMS::ImageGroup >, std::string, Name);
// //%attribute_readonly(iMS::ListBase< iMS::ImageGroup >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::ListBase< iMS::ImageGroup >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(ListBase_CompensationFunction) iMS::ListBase< iMS::CompensationFunction >;
// //%attributeval(iMS::ListBase< iMS::CompensationFunction >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::ListBase< iMS::CompensationFunction >, std::string, Name);
// //%attribute_readonly(iMS::ListBase< iMS::CompensationFunction >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::ListBase< iMS::CompensationFunction >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(ListBase_ToneBuffer) iMS::ListBase< iMS::ToneBuffer >;
// //%attributeval(iMS::ListBase< iMS::ToneBuffer >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::ListBase< iMS::ToneBuffer >, std::string, Name);
// //%attribute_readonly(iMS::ListBase< iMS::ToneBuffer >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::ListBase< iMS::ToneBuffer >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(ListBase_CompensationPointSpecification) iMS::ListBase< iMS::CompensationPointSpecification >;
// //%attributeval(iMS::ListBase< iMS::CompensationPointSpecification >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::ListBase< iMS::CompensationPointSpecification >, std::string, Name);
// //%attribute_readonly(iMS::ListBase< iMS::CompensationPointSpecification >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::ListBase< iMS::CompensationPointSpecification >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(StringList) iMS::ListBase< std::string >;
%attributeval(iMS::ListBase< std::string >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::ListBase< std::string >, std::string, Name);
//%attribute_readonly(iMS::ListBase< std::string >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::ListBase< std::string >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// namespace iMS {
//   %rename(__eq__) DequeBase::operator==;
//   //  %rename(__item__) DequeBase::operator[];
//   %ignore DequeBase::operator[];
// template <typename CTYPE>
//   class DequeBase {
//   %typemap(csinterfaces) DequeBase "System.IDisposable, System.Collections.IEnumerable\n    , global::System.Collections.Generic.IList<$typemap(cstype, CTYPE)>\n";

//   %typemap(cscode) DequeBase %{
//   public $csclassname(System.Collections.ICollection c) : this() {
//     if (c == null)
//       throw new System.ArgumentNullException("c");
//     foreach ($typemap(cstype, CTYPE) element in c) {
//       this.Add(element);
//     }
//   }

//   public bool IsFixedSize {
//     get {
//       return false;
//     }
//   }

//   public bool IsReadOnly {
//     get {
//       return false;
//     }
//   }

//   public $typemap(cstype, CTYPE) this[int index]  {
//     get {
//       return getitem(index);
//     }
//     set {
//       setitem(index, value);
//     }
//   }

//   public int Count {
//     get {
//       return (int)size();
//     }
//   }

//   public bool IsSynchronized {
//     get {
//       return false;
//     }
//   }

//   public void CopyTo($typemap(cstype, CTYPE)[] array)
//   {
//     CopyTo(0, array, 0, this.Count);
//   }

//   public void CopyTo($typemap(cstype, CTYPE)[] array, int arrayIndex)
//   {
//     CopyTo(0, array, arrayIndex, this.Count);
//   }

//   public void CopyTo(int index, $typemap(cstype, CTYPE)[] array, int arrayIndex, int count)
//   {
//     if (array == null)
//       throw new System.ArgumentNullException("array");
//     if (index < 0)
//       throw new System.ArgumentOutOfRangeException("index", "Value is less than zero");
//     if (arrayIndex < 0)
//       throw new System.ArgumentOutOfRangeException("arrayIndex", "Value is less than zero");
//     if (count < 0)
//       throw new System.ArgumentOutOfRangeException("count", "Value is less than zero");
//     if (array.Rank > 1)
//       throw new System.ArgumentException("Multi dimensional array.", "array");
//     if (index+count > this.Count || arrayIndex+count > array.Length)
//       throw new System.ArgumentException("Number of elements to copy is too large.");
//     for (int i=0; i<count; i++)
//       array.SetValue(getitemcopy(index+i), arrayIndex+i);
//   }

//   global::System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)> global::System.Collections.Generic.IEnumerable<$typemap(cstype, CTYPE)>.GetEnumerator() {
//     return new $csclassnameEnumerator(this);
//   }

//   System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() {
//     return new $csclassnameEnumerator(this);
//   }

//   public $csclassnameEnumerator GetEnumerator() {
//     return new $csclassnameEnumerator(this);
//   }

//   // Type-safe enumerator
//   /// Note that the IEnumerator documentation requires an InvalidOperationException to be thrown
//   /// whenever the collection is modified. This has been done for changes in the size of the
//   /// collection but not when one of the elements of the collection is modified as it is a bit
//   /// tricky to detect unmanaged code that modifies the collection under our feet.
//   public sealed class $csclassnameEnumerator : System.Collections.IEnumerator
//     , System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)>
//   {
//     private $csclassname collectionRef;
//     private int currentIndex;
//     private object currentObject;
//     private int currentSize;

//     public $csclassnameEnumerator($csclassname collection) {
//       collectionRef = collection;
//       currentIndex = -1;
//       currentObject = null;
//       currentSize = collectionRef.Count;
//     }

//     // Type-safe iterator Current
//     public $typemap(cstype, CTYPE) Current {
//       get {
//         if (currentIndex == -1)
//           throw new System.InvalidOperationException("Enumeration not started.");
//         if (currentIndex > currentSize - 1)
//           throw new System.InvalidOperationException("Enumeration finished.");
//         if (currentObject == null)
//           throw new System.InvalidOperationException("Collection modified.");
//         return ($typemap(cstype, CTYPE))currentObject;
//       }
//     }

//     private System.Collections.IEnumerator GetEnumerator()
//     {
//       return (System.Collections.IEnumerator)this;
//     }
        
//     // Type-unsafe IEnumerator.Current
//     object System.Collections.IEnumerator.Current {
//       get {
//         return Current;
//       }
//     }

//     public bool MoveNext() {
//       int size = collectionRef.Count;
//       bool moveOkay = (currentIndex+1 < size) && (size == currentSize);
//       if (moveOkay) {
//         currentIndex++;
//         currentObject = collectionRef[currentIndex];
//       } else {
//         currentObject = null;
//       }
//       return moveOkay;
//     }

//     public void Reset() {
//       currentIndex = -1;
//       currentObject = null;
//       if (collectionRef.Count != currentSize) {
//         throw new System.InvalidOperationException("Collection modified.");
//       }
//     }

//     public void Dispose() {
//         currentIndex = -1;
//         currentObject = null;
//     }
//   }
//   %}

//   public:
//   /*typedef std::deque<CTYPE>::iterator iterator;
//   typedef std::deque<CTYPE>::const_iterator const_iterator;
//   iterator begin();
//   iterator end();
//   const_iterator cbegin() const;
//   const_iterator cend() const;*/
//     %extend {
//       CTYPE getitemcopy(int index) throw (std::out_of_range) {
//         if (index>=0 && index<(int)$self->size())
//           return (*(static_cast<const iMS::DequeBase<CTYPE> *>($self)))[index];
//         else
//           throw std::out_of_range("index");
//       }
//       const CTYPE& getitem(int index) throw (std::out_of_range) {
//         if (index>=0 && index<(int)$self->size())
//           return (*(static_cast<const iMS::DequeBase<CTYPE> *>($self)))[index];
//         else
//           throw std::out_of_range("index");
//       }
//       void setitem(int index, const CTYPE& val) throw (std::out_of_range) {
//         if (index>=0 && index<(int)$self->size())
//           (*$self)[index] = val;
//         else
//           throw std::out_of_range("index");
//       }
//       // Takes a deep copy of the elements unlike ArrayList.AddRange
//       void AddRange(const DequeBase<CTYPE>& values) {
//         $self->insert($self->end(), values.begin(), values.end());
// 	}
//       // Takes a deep copy of the elements unlike ArrayList.GetRange
//       DequeBase<CTYPE> *GetRange(int index, int count) throw (std::out_of_range, std::invalid_argument) {
//         if (index < 0)
//           throw std::out_of_range("index");
//         if (count < 0)
//           throw std::out_of_range("count");
//         if (index >= (int)$self->size()+1 || index+count > (int)$self->size())
//           throw std::invalid_argument("invalid range");
//         return new DequeBase< CTYPE >($self->begin()+index, $self->begin()+index+count);
//       }
//       void Insert(int index, CTYPE const& x) throw (std::out_of_range) {
//         if (index>=0 && index<(int)$self->size()+1)
//           $self->insert($self->begin()+index, x);
//         else
//           throw std::out_of_range("index");
// 	  }
//       // Takes a deep copy of the elements unlike ArrayList.InsertRange
//       void InsertRange(int index, const DequeBase< CTYPE >& values) throw (std::out_of_range) {
//         if (index>=0 && index<(int)$self->size()+1)
//           $self->insert($self->begin()+index, values.begin(), values.end());
//         else
//           throw std::out_of_range("index");
// 	  }
//       void RemoveAt(int index) throw (std::out_of_range) {
//         if (index>=0 && index<(int)$self->size())
//           $self->erase($self->begin() + index);
//         else
//           throw std::out_of_range("index");
//       }
//       void RemoveRange(int index, int count) throw (std::out_of_range, std::invalid_argument) {
//         if (index < 0)
//           throw std::out_of_range("index");
//         if (count < 0)
//           throw std::out_of_range("count");
//         if (index >= (int)$self->size()+1 || index+count > (int)$self->size())
//           throw std::invalid_argument("invalid range");
//         $self->erase($self->begin()+index, $self->begin()+index+count);
//       }
//       static DequeBase< CTYPE > *Repeat(CTYPE const& value, int count) throw (std::out_of_range) {
//         if (count < 0)
//           throw std::out_of_range("count");
//         return new DequeBase< CTYPE >(count, value);
//       }
//       void Reverse() {
//         std::reverse($self->begin(), $self->end());
//       }
//       void Reverse(int index, int count) throw (std::out_of_range, std::invalid_argument) {
//         if (index < 0)
//           throw std::out_of_range("index");
//         if (count < 0)
//           throw std::out_of_range("count");
//         if (index >= (int)$self->size()+1 || index+count > (int)$self->size())
//           throw std::invalid_argument("invalid range");
//         std::reverse($self->begin()+index, $self->begin()+index+count);
//       }
//       // Takes a deep copy of the elements unlike ArrayList.SetRange
//       void SetRange(int index, const DequeBase< CTYPE >& values) throw (std::out_of_range) {
//         if (index < 0)
//           throw std::out_of_range("index");
//         if (index+values.size() > $self->size())
//           throw std::out_of_range("index");
//         std::copy(values.begin(), values.end(), $self->begin()+index);
//       }
//       bool Contains(CTYPE const& value) {
//         return std::find($self->begin(), $self->end(), value) != $self->end();
//       }
//       int IndexOf(CTYPE const& value) {
//         int index = -1;
//         DequeBase<CTYPE>::iterator it = std::find($self->begin(), $self->end(), value);
//         if (it != $self->end())
//           index = (int)(it - $self->begin());
//         return index;
//       }
//       /*int LastIndexOf($typemap(cstype, CTYPE) const& value) {
//         int index = -1;
//         DequeBase::reverse_iterator rit = std::find($self->rbegin(), $self->rend(), value);
//         if (rit != $self->rend())
//           index = (int)($self->rend() - 1 - rit);
//         return index;
// 	}*/
//       bool Remove(CTYPE const& value) {
//         DequeBase<CTYPE>::iterator it = std::find($self->begin(), $self->end(), value);
//         if (it != $self->end()) {
//           $self->erase(it);
// 	  return true;
//         }
//         return false;
//       }
//     }    

//   DequeBase(const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
//   DequeBase(size_t n, const CTYPE& value, const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
//   //  DequeBase(DequeBase<CTYPE>::const_iterator first, DequeBase<CTYPE>::const_iterator last, const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
    
//     DequeBase(const DequeBase &);
//     //    DequeBase &operator =(const DequeBase &);

//     CTYPE& operator[](int idx);
//     //    const CTYPE& operator[](int idx) const;
//     bool operator==(DequeBase const& rhs) const;
//     //const std::array<uint8_t, 16> GetUUID() const;
//     %rename(Clear) clear;
//     void clear();
//     //    DequeBase<CTYPE>::iterator insert(DequeBase<CTYPE>::iterator pos, const CTYPE& value);
//     //    DequeBase<CTYPE>::iterator insert(DequeBase<CTYPE>::const_iterator pos, size_t count, const CTYPE& value);
//     //    DequeBase<CTYPE>::iterator insert(DequeBase<CTYPE>::iterator pos, DequeBase<CTYPE>::const_iterator first, DequeBase<CTYPE>::const_iterator last);
//     %rename(Add) push_back;
//     void push_back(const CTYPE& value);
//     void pop_back();
//     void push_front(const CTYPE& value);
//     void pop_front();
//     //    DequeBase<CTYPE>::iterator erase(DequeBase<CTYPE>::iterator pos);
//     //    DequeBase<CTYPE>::iterator erase(DequeBase<CTYPE>::iterator first, DequeBase<CTYPE>::iterator last);
//     std::size_t size() const;
//     //    const std::string& Name() const;
//     //    std::string& Name();
//  };
// }
  
// %template(DequeBase_ImagePoint) iMS::DequeBase< iMS::ImagePoint >;
// //%attributeval(iMS::DequeBase< iMS::ImagePoint >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::DequeBase< iMS::ImagePoint >, std::string, Name);
// //%attribute_readonly(iMS::DequeBase< iMS::ImagePoint >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::DequeBase< iMS::ImagePoint >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(DequeBase_Image) iMS::DequeBase< iMS::Image >;
// //%attributeval(iMS::DequeBase< iMS::Image >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::DequeBase< iMS::Image >, std::string, Name);
// //%attribute_readonly(iMS::DequeBase< iMS::Image >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::DequeBase< iMS::Image >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(DequeBase_CompensationPoint) iMS::DequeBase< iMS::CompensationPoint >;
// //%attributeval(iMS::DequeBase< iMS::CompensationPoint >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::DequeBase< iMS::CompensationPoint >, std::string, Name);
// //%attribute_readonly(iMS::DequeBase< iMS::CompensationPoint >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::DequeBase< iMS::CompensationPoint >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(DequeBase_CompensationTable) iMS::DequeBase< iMS::CompensationTable >;
// //%attributeval(iMS::DequeBase< iMS::CompensationTable >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::DequeBase< iMS::CompensationTable >, std::string, Name);
// //%attribute_readonly(iMS::DequeBase< iMS::CompensationPoint >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::DequeBase< iMS::CompensationTable >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);
