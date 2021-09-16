#[[
文件名: msg\CMakeLists.txt
生成msg库, 并链接到hello

generate_export_header会生成一个头文件, 包括函数的导出修饰符, 过时修饰符等
例如: MSG_EXPORT 表示函数是导出函数
     MSG_DEPRECATED 表示函数过时
]]

option(BUILD_SHARED_LIBRARY "Build shared library" ON)  # 添加一个选项, 寻味是否构建库

if (BUILD_SHARED_LIBRARY)
    add_library(msg SHARED "")  # 生成一个动态库
else()
    add_library(msg STATIC "")  # 生成一个静态库
endif()
target_include_directories(msg PUBLIC ${PROJECT_SOURCE_DIR}/include)

include(GenerateExportHeader)
generate_export_header(msg
                       EXPORT_FILE_NAME "${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/msgExport.h"  # 导出的位置
                       BASE_NAME "MSG"
                       EXPORT_MACRO_NAME "MSG_EXPORT"
                       DEPRECATED_MACRO_NAME "MSG_DEPRECATED"
                       NO_EXPORT_MACRO_NAME "MSG_NO_EXPORT"
                       NO_DEPRECATED_MACRO_NAME "MSG_NO_DEPRECATED"
                       DEFINE_NO_DEPRECATED
)
message(STATUS "Export msgExport.h = ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/msgExport.h")
target_include_directories(msg PUBLIC ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR})

target_sources(msg  # 追加源文件到msg中, 源文件被定义为PUBLIC类型
    PRIVATE  # 何为PRIVATE和PUBLIC可以参见上文注释
        msg.c msgBeautiful.c _msg.h
    PUBLIC
        ${PROJECT_SOURCE_DIR}/include/msg.h
    )

set(_MSG_PUBLIC_HEADER ${PROJECT_SOURCE_DIR}/include/msg.h ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/msgExport.h)
set_target_properties(msg
                      PROPERTIES
                      PUBLIC_HEADER "${_MSG_PUBLIC_HEADER}"  # 公开的头文件 (多个文件时, 使用;分隔, 或把一个列表放到字符串中也会转换为;分隔)
                      RESOURCE ${CMAKE_CURRENT_SOURCE_DIR}/README)  # 关联的文件, 在install时会被安装

