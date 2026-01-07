from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout
import subprocess
from pathlib import Path

class ImsPyConan(ConanFile):
    name = "imslib"
    version = "2.0.4"
    license = "MIT"  # Adjust to match your actual license
    author = "Isomet Engineer <isomet@isomet.com>"
    url = "https://your.repo.url"  # Optional
    description = "Python Wrapper for iMS processing"
    topics = ("ims", "xml", "boost", "zlib")

    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeToolchain", "CMakeDeps"
#    exports_sources = "CMakeLists.txt", "src/*", "include/*", "cmake/*"

    options = {"shared": [True, False],
               "fPIC": [True, False]}
    
    default_options = {"shared": True,
                       "fPIC": True}
    
    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def requirements(self):
#        self.requires("zlib/1.2.11")     # 1.2.13
        self.requires("libxml2/2.9.9")   # 2.11.7
        self.requires("boost/1.84.0")

    def configure(self):
        # Customize libxml2 options
        self.options["libxml2"].with_iconv = False
        self.options["libxml2"].with_zlib = True
        self.options["libxml2"].with_lzma = False
        self.options["libxml2"].with_http = False
        self.options["libxml2"].with_ftp = False
        self.options["libxml2"].with_html = False

        # Optional: ensure static linking if that's your goal
        self.options["libxml2"].shared = False
#        self.options["zlib"].shared = False
        self.options["boost"].header_only = False

        if self.options.shared:
            # If os=Windows, fPIC will have been removed in config_options()
            # use rm_safe to avoid double delete errors
            self.options.rm_safe("fPIC")


    def build_requirements(self):
        # Optional: if you have testing tools, code generators, etc.
        pass

    def layout(self):
        cmake_layout(self)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        # Expose your library target to consumers
        self.cpp_info.libs = ["ims_py"]
