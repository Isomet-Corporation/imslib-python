%{
#include <chrono>
#include <ratio>
%}

%include "stdint.i"

// Create wrapped ratio type
namespace std {

  template<int Num, int Denom = 1> class ratio {
    public:
    static constexpr int num;
    static constexpr int den;
    };
 
}


namespace std {

  namespace chrono {

    //    %rename(__set__) duration::operator=;
    template <class Rep, class Period = ratio<1> > class duration  
    {
      public:
	constexpr duration() = default;
	duration( const duration& ) = default;
	constexpr explicit duration<Rep>( const Rep& r );
      //constexpr duration<Rep, Period>( const duration<Rep,Period>& d );
      //  	duration& operator=( const duration &other ) = default;
	constexpr Rep count() const;

    %extend  {
    std::chrono::duration<Rep, Period> __add__(std::chrono::duration<Rep, Period> const& rhs) {
        return *$self + rhs;
    }
    std::chrono::duration<Rep, Period> __add__(const Rep& rhs) {
        return *$self + std::chrono::duration<Rep, Period>(rhs);
    }
    std::chrono::duration<Rep, Period> __sub__(std::chrono::duration<Rep, Period> const& rhs) {
        return *$self - rhs;
    }
    std::chrono::duration<Rep, Period> __sub__(const Rep& rhs) {
        return *$self - std::chrono::duration<Rep, Period>(rhs);
    }
    std::chrono::duration<Rep, Period> __neg__() {
        return std::chrono::duration<Rep, Period>(-$self->count());
    }    
    std::chrono::duration<Rep, Period> __mul__(const Rep& scale) {
        return std::chrono::duration<Rep, Period>($self->count() * scale);
    }    
    std::chrono::duration<Rep, Period> __truediv__(const Rep& scale) {
        return std::chrono::duration<Rep, Period>($self->count() / scale);
    }    
    bool __eq__(std::chrono::duration<Rep, Period> const& rhs) {
        return *$self == rhs;
    }
    bool __eq__(const Rep& rhs) {
        return $self->count() == rhs;
    }
    bool __lt__(const std::chrono::duration<Rep, Period>& other) {
        return *$self < other;
    }
    bool __lt__(const Rep& rhs) {
        return $self->count() < rhs;
    }
    bool __le__(const std::chrono::duration<Rep, Period>& other) {
        return *$self <= other;
    }
    bool __le__(const Rep& rhs) {
        return $self->count() <= rhs;
    }
    bool __gt__(const std::chrono::duration<Rep, Period>& other) {
        return *$self > other;
    }
    bool __gt__(const Rep& rhs) {
        return $self->count() > rhs;
    }
    bool __ge__(const std::chrono::duration<Rep, Period>& other) {
        return *$self >= other;
    }    
    bool __ge__(const Rep& rhs) {
        return $self->count() >= rhs;
    }
    std::string __str__() {
        std::ostringstream oss;
        oss << $self->count();
        return oss.str();
    }
}
	};

  }
}

%template(PostDelay)  std::chrono::duration<uint16_t, std::ratio<1, 10000> >;
%template(UnitIntDuration)  std::chrono::duration<int>;
%template(UnitFloatDuration)  std::chrono::duration<double>;       
%template(NanoSeconds)  std::chrono::duration<uint64_t, std::ratio<1, 1000000000>>;
