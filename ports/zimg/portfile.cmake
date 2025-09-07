vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sekrit-twc/zimg
    REF release-${VERSION}
    SHA512 98d7d65085530e0e1d3e25218608867f1e8d978fc759777efe2e6034baa31db10f1dda46ef8e00ec6f3c23b91aea839da076bfa4fcb75d98111a08513f45506d
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(zimg_target dll)
    else()
        set(zimg_target zimg)
    endif()

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "_msvc/zimg.sln"
        TARGET ${zimg_target}
        PLATFORM "${VCPKG_TARGET_ARCHITECTURE}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/z.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/z_imp.lib" ${CURRENT_PACKAGES_DIR}/lib/z.lib)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/z.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/z_imp.lib" ${CURRENT_PACKAGES_DIR}/debug/lib/z.lib)
    endif()

    set(INCLUDE_DIR_REL "include")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/zimg.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zimg.pc" @ONLY)
    set(INCLUDE_DIR_REL "../include")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/zimg.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zimg.pc" @ONLY)
    vcpkg_fixup_pkgconfig()

    file(COPY "${SOURCE_PATH}/src/zimg/api/zimg.h"
              "${SOURCE_PATH}/src/zimg/api/zimg++.hpp"
         DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )

    vcpkg_install_make()
    vcpkg_copy_pdbs()
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                        "${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING"
                        "${CURRENT_PACKAGES_DIR}/share/${PORT}/example"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
