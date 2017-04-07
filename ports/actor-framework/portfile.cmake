# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/actor-framework-0.15.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/actor-framework/actor-framework/archive/0.15.3.zip"
    FILENAME "actor-framework-0_15_3.zip"
    SHA512 17273b1f1ad164edc2e4dd4bd6457c3d03eca36db2974805d63cf91be655b32dc8c77e772e1b6b70af438ee91c79cbbb1c3f311fa5d0c058a5bc09d3dee72490
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-dll-build.patch"
)

if(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL static)
    set(CAF_RUNTIME_LINKAGE "-DCAF_BUILD_STATIC_ONLY=1")
else()
    set(CAF_RUNTIME_LINKAGE "-DCAF_BUILD_STATIC=0")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${CAF_RUNTIME_LINKAGE}
        -DCAF_NO_EXAMPLES=1
        -DCAF_NO_UNIT_TESTS=1
        -DCAF_NO_TOOLS=1
    OPTIONS_DEBUG
        -DCAF_ENABLE_RUNTIME_CHECKS=1
)

vcpkg_install_cmake()

# CAF tries to install share/caf/tools/caf-vec.cpp
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/caf/tools)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/actor-framework)
file(COPY ${SOURCE_PATH}/LICENSE_ALTERNATIVE DESTINATION ${CURRENT_PACKAGES_DIR}/share/actor-framework)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/actor-framework/LICENSE ${CURRENT_PACKAGES_DIR}/share/actor-framework/copyright)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/actor-framework/LICENSE_ALTERNATIVE ${CURRENT_PACKAGES_DIR}/share/actor-framework/copyright_alternative)
