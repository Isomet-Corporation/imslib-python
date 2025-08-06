%include <std_shared_ptr.i>
%include <std_list.i>   // Support for std::list<T>
%include <std_common.i>
%include <std_string.i>
%include <typemaps.i>
%include <exception.i>

%{
#include <sstream>
#include <algorithm>
%}

// Define operator<< for types that don't have it
%rename(SeqEntry_Stream) operator <<(std::ostream& stream, const std::shared_ptr < SequenceEntry >& seq);
%inline %{
    std::ostream& operator <<(std::ostream& stream, const std::shared_ptr < SequenceEntry >& seq) {
        stream << seq->UUID();
        return stream;
    }
    namespace iMS {
        std::ostream& operator <<(std::ostream& stream, const ImageGroup& grp) {
            stream << grp.Name();
            return stream;
        }   
        std::ostream& operator <<(std::ostream& stream, const Image& img) {
            stream << img.Name();
            return stream;
        }    
        std::ostream& operator <<(std::ostream& stream, const ImagePoint& pt) {
            for (int i=1; i<=4; i++) {
                auto& fap = pt.GetFAP(RFChannel(i));
                stream << "Ch" << i << ": " << fap.freq << "MHz/" << fap.ampl << "%/" << fap.phase << "deg" << std::endl;
            }
            stream << "Sync: A1 = " << pt.GetSyncA(0) << " A2 = " << pt.GetSyncA(1) << " D = 0x" << std::hex << std::setfill('0') << std::setw(3) << pt.GetSyncD();
            return stream;
        }    
        std::ostream& operator <<(std::ostream& stream, const CompensationFunction& func) {
            stream << func.Name();
            return stream;
        }    
        std::ostream& operator <<(std::ostream& stream, const CompensationPointSpecification& pt_spec) {
            stream << pt_spec.Freq() <<": ";
//            stream << pt_spec.Spec();

            return stream;
        } 
        // std::ostream& operator <<(std::ostream& stream, const CompensationPoint& pt) {
        //     stream << pt.Amplitude() << " / ";
        //     stream << pt.Phase() << " / ";
        //     stream << pt.SyncAnlg() << " / 0x";
        //     stream << std::hex << std::setfill('0') << std::setw(3) << pt.SyncDig();

        //     return stream;
        // }    
        std::ostream& operator <<(std::ostream& stream, const CompensationTable& table) {
            stream << table.Name() << ": (" << table.Size() << "pts): " << table.LowerFrequency() << "-" << table.UpperFrequency();
            return stream;
        }   
    }  
%}

namespace iMS {

//  %rename(__eq__) ListBase::operator==;
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
        const CTYPE& __getitem__(size_t i) {
            if (i >= $self->size()) {
                throw std::out_of_range("Index out of range");
            }
            auto it = $self->begin();
            std::advance(it, i);
            return *it;
        }

        void __setitem__(size_t i, const CTYPE& val) {
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

            def __eq__(self, rhs):
                eq = True
                for i in range(len(self)):
                    if self[i] != rhs[i]:
                        eq = False
                return eq
            %}
    }    

    ListBase(const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
    ListBase(const ListBase &);
    //    ListBase &operator =(const ListBase &);

    //bool operator==(ListBase const& rhs) const;
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
  };

}

%shared_ptr(iMS::SequenceEntry)

%template(ListBase_SequenceEntry) iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >;
%attributeval(iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >, std::string, Name);
//%attribute_readonly(iMS::ListBase< iMS::ImageSequenceEntry >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::ListBase< std::shared_ptr < iMS::SequenceEntry > >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(ListBase_ImageGroup) iMS::ListBase< iMS::ImageGroup >;
%attributeval(iMS::ListBase< iMS::ImageGroup >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::ListBase< iMS::ImageGroup >, std::string, Name);
//%attribute_readonly(iMS::ListBase< iMS::ImageGroup >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::ListBase< iMS::ImageGroup >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(ListBase_CompensationFunction) iMS::ListBase< iMS::CompensationFunction >;
%attributeval(iMS::ListBase< iMS::CompensationFunction >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::ListBase< iMS::CompensationFunction >, std::string, Name);
//%attribute_readonly(iMS::ListBase< iMS::CompensationFunction >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::ListBase< iMS::CompensationFunction >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

// %template(ListBase_ToneBuffer) iMS::ListBase< iMS::ToneBuffer >;
// //%attributeval(iMS::ListBase< iMS::ToneBuffer >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
// //%attributeref(iMS::ListBase< iMS::ToneBuffer >, std::string, Name);
// //%attribute_readonly(iMS::ListBase< iMS::ToneBuffer >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
// //%attributestring(iMS::ListBase< iMS::ToneBuffer >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(ListBase_CompensationPointSpecification) iMS::ListBase< iMS::CompensationPointSpecification >;
%attributeval(iMS::ListBase< iMS::CompensationPointSpecification >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::ListBase< iMS::CompensationPointSpecification >, std::string, Name);
//%attribute_readonly(iMS::ListBase< iMS::CompensationPointSpecification >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::ListBase< iMS::CompensationPointSpecification >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(StringList) iMS::ListBase< std::string >;
%attributeval(iMS::ListBase< std::string >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::ListBase< std::string >, std::string, Name);
//%attribute_readonly(iMS::ListBase< std::string >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::ListBase< std::string >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

namespace iMS {
  //%rename(__eq__) DequeBase::operator==;
  %rename(__item__) DequeBase::operator[];
  //%ignore DequeBase::operator[];
template <typename CTYPE>
  class DequeBase {

  public:
  typedef std::deque<CTYPE>::iterator iterator;
  typedef std::deque<CTYPE>::const_iterator const_iterator;
  iterator begin();
  iterator end();
  const_iterator cbegin() const;
  const_iterator cend() const;
    %extend {
        CTYPE& __getitem__(size_t i) {
            if (i >= $self->size()) {
                throw std::out_of_range("Index out of range");
            }
            auto it = $self->begin();
            std::advance(it, i);
            return *it;
        }

        void __setitem__(size_t i, const CTYPE& val) {
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
            return ($self->size() != 0);
        }

        void append(const CTYPE& val) {
            $self->push_back(val);
        }

        CTYPE pop() {
            if ($self->size() == 0) {
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

            def __eq__(self, rhs):
                eq = True
                for i in range(len(self)):
                    if self[i] != rhs[i]:
                        eq = False
                return eq
            %}
    
    }    

  DequeBase(const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
  DequeBase(size_t n, const CTYPE& value, const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
  //  DequeBase(DequeBase<CTYPE>::const_iterator first, DequeBase<CTYPE>::const_iterator last, const std::string& Name = "[no name]"/*, const std::time_t& modified_time = std::time(nullptr)*/);
    
    DequeBase(const DequeBase &);
    //    DequeBase &operator =(const DequeBase &);

    // CTYPE& operator[](int idx);
    //    const CTYPE& operator[](int idx) const;
    //bool operator==(DequeBase const& rhs) const;
    void clear();
    //    DequeBase<CTYPE>::iterator insert(DequeBase<CTYPE>::iterator pos, const CTYPE& value);
    //    DequeBase<CTYPE>::iterator insert(DequeBase<CTYPE>::const_iterator pos, size_t count, const CTYPE& value);
    //    DequeBase<CTYPE>::iterator insert(DequeBase<CTYPE>::iterator pos, DequeBase<CTYPE>::const_iterator first, DequeBase<CTYPE>::const_iterator last);
    %rename(add) push_back;
    %rename(remove) pop_back;
    void push_back(const CTYPE& value);
    void pop_back();
    void push_front(const CTYPE& value);
    void pop_front();
    //    DequeBase<CTYPE>::iterator erase(DequeBase<CTYPE>::iterator pos);
    //    DequeBase<CTYPE>::iterator erase(DequeBase<CTYPE>::iterator first, DequeBase<CTYPE>::iterator last);
    std::size_t size() const;
 };
}
  
%template(DequeBase_ImagePoint) iMS::DequeBase< iMS::ImagePoint >;
%attributeval(iMS::DequeBase< iMS::ImagePoint >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::DequeBase< iMS::ImagePoint >, std::string, Name);
//%attribute_readonly(iMS::DequeBase< iMS::ImagePoint >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::DequeBase< iMS::ImagePoint >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(DequeBase_Image) iMS::DequeBase< iMS::Image >;
%attributeval(iMS::DequeBase< iMS::Image >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::DequeBase< iMS::Image >, std::string, Name);
//%attribute_readonly(iMS::DequeBase< iMS::Image >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::DequeBase< iMS::Image >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(DequeBase_CompensationPoint) iMS::DequeBase< iMS::CompensationPoint >;
%attributeval(iMS::DequeBase< iMS::CompensationPoint >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::DequeBase< iMS::CompensationPoint >, std::string, Name);
//%attribute_readonly(iMS::DequeBase< iMS::CompensationPoint >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::DequeBase< iMS::CompensationPoint >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);

%template(DequeBase_CompensationTable) iMS::DequeBase< iMS::CompensationTable >;
%attributeval(iMS::DequeBase< iMS::CompensationTable >, %arg(std::array<uint8_t, 16>), GetUUID, GetUUID);
%attributeref(iMS::DequeBase< iMS::CompensationTable >, std::string, Name);
//%attribute_readonly(iMS::DequeBase< iMS::CompensationPoint >, std::time_t, ModifiedTime, ModifiedTime, self_->ModifiedTime());
%attributestring(iMS::DequeBase< iMS::CompensationTable >, std::string, ModifiedTimeFormat, ModifiedTimeFormat);
