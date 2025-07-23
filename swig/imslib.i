%module imslib

// Use the Python Stable ABI to avoid rqeuiring a specific minor version of the runtime library
%begin %{
#define Py_LIMITED_API 0x03040000
%}

%{
// #include "AcoustoOptics.h"
#include "Containers.h"
// #include "ImageProject.h"
#include "LibVersion.h"
#include "ConnectionList.h"
#include "IConnectionSettings.h"
#include "CS_ETH.h"
#include "CS_RS422.h"
// #include "IEventHandler.h"
#include "IMSSystem.h"
#include "IMSTypeDefs.h"
// #include "Auxiliary.h"
// #include "Image.h"
// #include "ImageOps.h"
// #include "FileSystem.h"
// #include "Compensation.h"
// #include "ToneBuffer.h"
// #include "SignalPath.h"
// #include "SystemFunc.h"
// #include "Diagnostics.h"

#include <sstream>
#include <iomanip>

  using namespace iMS;
%}

%include "stdint.i"
%include <std_string.i>
%include <std_vector.i>
//%include <memory.i>
// %include "std_deque.i"
// %include "std_map.i"
// %include "windows.i"
%include <std_array.i>
%include "attribute.i"
%include "typemaps.i"

%template(ByteVector) std::vector<uint8_t>;
%template(UUID) std::array<uint8_t, 16>;
%template(VelGain) std::array<int16_t, 2>;

// Print UUID in friendly format
%extend std::array<uint8_t, 16> {
        std::string __str__() {
            std::ostringstream oss;
            oss << "[";
            oss << std::hex << std::setfill('0');
            for (auto it = $self->begin(); it != $self->end(); ++it) {
            if (it != $self->begin()) oss << " ";
            oss << std::setw(2) << static_cast<unsigned>(*it);
            }
            oss << "]";
            return oss.str();
        }
}

// %template(AnalogData) std::map<int, iMS::Percent>;

// Basic SWIG typemap to wrap iMS::ListBase<T> as std::vector<T>
// %typemap(out) iMS::ListBase<std::string> {
//     $result = PyList_New($1->size());
//     int i = 0;
//     for (auto it = $1->begin(); it != $1->end(); ++it, ++i) {
//         PyList_SetItem($result, i, PyUnicode_FromString(it->c_str()));
//     }
// }

// %typemap(out) const iMS::ListBase<std::string>& {
//     $result = PyList_New($1->size());
//     int i = 0;
//     for (auto it = $1->begin(); it != $1->end(); ++it, ++i) {
//         PyList_SetItem($result, i, PyUnicode_FromString(it->c_str()));
//     }
// }

#define _STATIC_IMS

%include "Containers.i"
%include "LibVersion.i"
%include "IMSTypeDefs.i"
// %include "IEventHandler.i"
%include "IMSSystem.i"
%include "ConnectionList.i"
// %include "FileSystem.i"
// %include "AcoustoOptics.i"
// %include "Auxiliary.i"
// %include "Image.i"
// %include "ImageOps.i"
// %include "Compensation.i"
// %include "ToneBuffer.i"
// %include "ImageProject.i"
// %include "SignalPath.i"
// %include "SystemFunc.i"
// %include "Diagnostics.i"