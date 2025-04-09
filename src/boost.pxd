# distutils: language = c++

from libcpp.vector cimport vector

cdef extern from "boost/filesystem.hpp" namespace "boost::filesystem":
    cdef cppclass path:
        pass

cdef extern from "boost/optional.hpp" namespace "boost::optional_ns":
    cdef cppclass optional[T]:
        pass
