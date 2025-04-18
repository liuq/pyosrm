# distutils: language = c++

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map
from boost cimport path, optional

cdef extern from "osrm/storage/storage_config.hpp" namespace "osrm::storage":
    cdef cppclass IOConfig:
        IOConfig (vector[path] required_input_files_,
                  vector[path] optional_input_files_,
                  vector[path] output_files_) except +
        bool IsValid()
        path GetPath(string& fileName)
        path base_path

    cdef cppclass StorageConfig(IOConfig):
            StorageConfig(path& base)
            StorageConfig(char* base)

cdef extern from "osrm/engine_config.hpp" namespace "osrm":
    ctypedef enum Algorithm:
        CH "osrm::EngineConfig::Algorithm::CH"
        MLD "osrm::EngineConfig::Algorithm::MLD"

    struct EngineConfig:
        bool IsValid()
        StorageConfig storage_config
        int max_locations_trip
        int max_locations_viaroute
        int max_locations_distance_table
        int max_locations_map_matching
        double max_radius_map_matching
        int max_results_nearest
        int max_alternatives
        bool use_shared_memory
        path memory_file
        bool use_mmap
        Algorithm algorithm
        string verbosity
        string dataset_name

cdef extern from "osrm/status.hpp" namespace "osrm::engine":
    ctypedef enum Status:
        Ok "osrm::engine::Status::Ok"
        Error "osrm::engine::Status::Error"

cdef extern from "osrm/bearing.hpp" namespace "osrm":
    struct Bearing:
        short bearing
        short range
        bool IsValid()

cdef extern from "osrm/approach.hpp" namespace "osrm":
    cdef cppclass Approach:
        pass

cdef extern from "osrm/engine/hint.hpp" namespace "osrm::engine":
    struct Hint:
        pass

cdef extern from "osrm/util/coordinate.hpp" namespace "osrm::util":
    cdef cppclass FixedLongitude:
        pass
    cdef cppclass FixedLatitude:
        pass
    cdef cppclass FloatLongitude:
        # pass
        FloatLongitude()
        FloatLongitude(double)
        double __value
    cdef cppclass FloatLatitude:
        # pass
        FloatLatitude()
        FloatLatitude(double)
        double __value
    cdef cppclass Coordinate:
        FixedLongitude lon
        FixedLatitude lat
        Coordinate()
        Coordinate(FixedLongitude lon_, FixedLatitude lat_)
        Coordinate(FloatLongitude lon_, FloatLatitude lat_)
        bool IsValid()

cdef extern from "osrm/engine/api/base_parameters.hpp" namespace "osrm::engine::api":
    cdef cppclass SnappingType:
        pass
        # Default "osrm::engine::api::BaseParameters::SnappingType::Default"
        # Any "osrm::engine::api::BaseParameters::SnappingType::Any"

    cdef cppclass OutputFormatType:
        pass
        # JSON "osrm::engine::api::BaseParameters::OutputFormatType::JSON"
        # FLATBUFFERS "osrm::engine::api::BaseParameters::OutputFormatType::FLATBUFFERS"

    cdef cppclass BaseParameters:
        BaseParameters(vector[Coordinate] coordinates_, vector[optional[Hint]] hints_,
            vector[optional[double]] radiuses_, vector[optional[Bearing]] bearings_,
            vector[optional[Approach]] approaches_, bool generate_hints_,
            vector[string] exclude, SnappingType snapping_)
        vector[Coordinate] coordinates
        vector[optional[Hint]] hints
        vector[optional[double]] radiuses
        vector[optional[Bearing]] bearings
        vector[optional[Approach]] approaches
        vector[string] exclude
        optional[OutputFormatType] format
        bool generate_hints
        bool skip_waypoints
        SnappingType snapping 

cdef extern from "osrm/route_parameters.hpp" namespace "osrm::engine::api":
    cpdef enum RAnnotationsType "osrm::engine::api::RouteParameters::AnnotationsType":
            RNoAnnotation "osrm::engine::api::RouteParameters::AnnotationsType::None"
            RDuration "osrm::engine::api::RouteParameters::AnnotationsType::Duration"
            RNodes "osrm::engine::api::RouteParameters::AnnotationsType::Nodes"
            RDistance "osrm::engine::api::RouteParameters::AnnotationsType::Distance"
            RWeight "osrm::engine::api::RouteParameters::AnnotationsType::Weight"
            RDatasources "osrm::engine::api::RouteParameters::AnnotationsType::Datasources"
            RSpeed "osrm::engine::api::RouteParameters::AnnotationsType::Speed"
            RAll "osrm::engine::api::RouteParameters::AnnotationsType::All"

    cdef enum GeometriesType "osrm::engine::api::RouteParameters::GeometriesType":
        Polyline "osrm::engine::api::RouteParameters::GeometriesType::Polyline"
        Polyline6 "osrm::engine::api::RouteParameters::GeometriesType::Polyline6"
        GeoJSON "osrm::engine::api::RouteParameters::GeometriesType::GeoJSON"

    cdef enum OverviewType "osrm::engine::api::RouteParameters::OverviewType":
        Simplified "osrm::engine::api::RouteParameters::OverviewType::Simplified"
        Full "osrm::engine::api::RouteParameters::OverviewType::Full"
        NoOverview "osrm::engine::api::RouteParameters::OverviewType::False"    

    cdef cppclass RouteParameters(BaseParameters):    
        bool steps
        bool alternatives
        bool annotations
        RAnnotationsType annotations_type
        GeometriesType geometries
        OverviewType overview

cdef extern from "osrm/nearest_parameters.hpp" namespace "osrm::engine::api": 
    cdef cppclass NearestParameters(BaseParameters):    
        unsigned int number_of_results

cdef extern from "osrm/table_parameters.hpp" namespace "osrm::engine::api":
    cpdef enum TAnnotationsType "osrm::engine::api::TableParameters::AnnotationsType":
            TNoAnnotation "osrm::engine::api::TableParameters::AnnotationsType::None"
            TDuration "osrm::engine::api::TableParameters::AnnotationsType::Duration"
            TDistance "osrm::engine::api::TableParameters::AnnotationsType::Distance"
            TAll "osrm::engine::api::TableParameters::AnnotationsType::All"

    cdef enum FallbackCoordinateType "osrm::engine::api::TableParameters::FallbackCoordinateType":
        Input "osrm::engine::api::TableParameters::FallbackCoordinateType::Input"
        Snapped "osrm::engine::api::TableParameters::FallbackCoordinateType::Snapped"

    cdef cppclass TableParameters(BaseParameters):    
        vector[size_t] sources
        vector[size_t] destinations
        double fallback_speed
        FallbackCoordinateType fallback_coordinate_type
        TAnnotationsType annotations
        double scale_factor

cdef extern from "osrm/util/json_container.hpp" namespace "osrm::util::json":
    cdef cppclass Value:
        T get[T]()
    cdef cppclass _JsonObject "osrm::util::json::Object":
        unordered_map[string, Value] values
        _JsonObject()
    struct _Number "osrm::util::json::Number":
        double value
    struct _Array "osrm::util::json::Array":
        vector[Value] values
    struct _String "osrm::util::json::String":
        string value

cdef extern from "osrm/engine/api/base_result.hpp" namespace "osrm::engine::api":
    cdef cppclass ResultT:
        ResultT(_JsonObject value)
        T get[T]()

cdef extern from "osrm/osrm.hpp" namespace "osrm":
    cdef cppclass OSRM:
        OSRM() except +
        OSRM(EngineConfig &config) except +
        Status Route(RouteParameters &parameters, ResultT &result)
        Status Nearest(NearestParameters &parameters, ResultT &result)
        Status Table(TableParameters &parameters, ResultT &result)
