#ifndef BYTE_TRACK_EIGEN_EXPORT_H
#define BYTE_TRACK_EIGEN_EXPORT_H

#ifdef BYTE_TRACK_EIGEN_STATIC_DEFINE   // static
#   define BYTE_TRACK_EIGEN_API
#else                                   // dynamic/shared
#   ifdef BUILDING_BYTE_TRACK_EIGEN
#       ifdef _WIN32
#           define BYTE_TRACK_EIGEN_API __declspec(dllexport)
#       else
#           define BYTE_TRACK_EIGEN_API __attribute__((visibility("default")))
#       endif
#   else
#       ifdef _WIN32
#           define BYTE_TRACK_EIGEN_API __declspec(dllimport)
#       else
#           define BYTE_TRACK_EIGEN_API __attribute__((visibility("default")))
#       endif
#   endif
#endif

#endif