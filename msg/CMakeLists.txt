#[[
文件名: msg\CMakeLists.txt
生成msg库, 并链接到hello

generate_export_header会生成一个头文件, 包括函数的导出修饰符, 过时修饰符等
例如: MSG_EXPORT 表示函数是导出函数
     MSG_DEPRECATED 表示函数过时

为什么要区分BUILD_INTERFACE和INSTALL_INTERFACE
    访问一个target有两种方式, 一种是在构建树内通过add_library等命令生成, 另一种是通过find_package生成
    前者一般是通过源码构建目标, 对应的公开头文件是在源代码目录中的, 可以通过${PROJECT_SOURCE_DIR}等方式访问
    而后者一般是已经构建好的项目, 公开头文件不是在源代码目录中, 而是在安装的文件夹中的, 这个时候就只可以通过安装的路径来访问
    BUILD_INTERFACE和INSTALL_INTERFACE则是两个逻辑表达式, 当现在处于前者的访问方式时BUILD_INTERFACE生效, 否则后者的访问方式生效
为什么会访问PUBLIC而不用访问PRIVATE
    其实PUBLIC和INTERFACE都要进行这一步区分, 而PRIVATE不需要
    因为当一个目标依赖于另一个目标时, 另一个目标的一些PUBLIC和INTERFACE属性会被继承过来, 而PRIVATE则不会
    因此通过后者方式连接一个库时, 他的include_directories(PUBLIC)会被使用, 而PRIVATE不会
    因此PRIVATE就不需要区分BUILD_INTERFACE和INSTALL_INTERFACE
关于PUBLIC_HEADER选项
    该属性是指设定一个目标的公开头文件, 该目标被install时会用到该属性.
    并且该属性不会被依赖所继承, 因此不需要区分BUILD_INTERFACE和INSTALL_INTERFACE
当我们试图导出一个Target, 而该Target的某个属性不合法(例如target_include_directories使用了包含${PROJECT_SOURCE_DIR})的路径时, 他就会报错
此时, 则可以检查一下相关的设置是否没有区分BUILD_INTERFACE和INSTALL_INTERFACE
]]

option(BUILD_SHARED_LIBRARY "Build shared library" ON)  # 添加一个选项, 寻味是否构建库

if (BUILD_SHARED_LIBRARY)
    add_library(msg SHARED "")  # 生成一个动态库
else()
    add_library(msg STATIC "")  # 生成一个静态库
endif()
target_include_directories(msg
                           PUBLIC
                           $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>  # 当msg作为非导入对象时应用此include路径
                           $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>)  # msg作为导入对象(通过find_package或messageTarget.cmake导入时)时应用此路径
                                                                        # 因为当msg作为导入对象时, ${PROJECT_SOURCE_DIR}/include已经不存在了, 取而代之应该是安装路径
                                                                        # 当msg还在构建(即还没安装时), 安装目录还不存在, 因此使用${PROJECT_SOURCE_DIR}/include

include(GenerateExportHeader)
generate_export_header(msg
                       EXPORT_FILE_NAME "${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/msgExport.h"  # 导出的位置
                       BASE_NAME "MSG"
                       EXPORT_MACRO_NAME "MSG_EXPORT"
                       DEPRECATED_MACRO_NAME "MSG_DEPRECATED"
                       NO_EXPORT_MACRO_NAME "MSG_NO_EXPORT"
                       NO_DEPRECATED_MACRO_NAME "MSG_NO_DEPRECATED"
                       DEFINE_NO_DEPRECATED)

message(STATUS "Export msgExport.h = ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/msgExport.h")
target_include_directories(msg PUBLIC
                           $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}>)

target_sources(msg  # 追加源文件到msg中, 源文件被定义为PUBLIC类型
    PRIVATE  # 何为PRIVATE和PUBLIC可以参见上文注释
        msg.c msgBeautiful.c _msg.h  # 这里不需要区分, 因为PRIVATE是私有属性, 导入库之后不会访问该属性
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/msg.h>  # 同理, 需要区分导入和非导入库
        $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}/msg.h>)

# 对于PUBLIC_HEADER也不需要区分BUILD_INTERFACE和RESOURCE, 因为导入库之后不会访问该属性
set(_MSG_PUBLIC_HEADER ${PROJECT_SOURCE_DIR}/include/msg.h ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/msgExport.h)
set_target_properties(msg
                      PROPERTIES
                      PUBLIC_HEADER "${_MSG_PUBLIC_HEADER}"  # 公开的头文件 (多个文件时, 使用;分隔, 或把一个列表放到字符串中也会转换为;分隔)
                      RESOURCE ${CMAKE_CURRENT_SOURCE_DIR}/README)  # 关联的文件, 在install时会被安装

install(
    TARGETS
        msg
    EXPORT  # 添加到一个输出目标中
        msgTargets
    ARCHIVE
        DESTINATION ${INSTALL_LIBDIR}
    RUNTIME
        DESTINATION ${INSTALL_BINDIR}
    LIBRARY
        DESTINATION ${INSTALL_LIBDIR}
    PUBLIC_HEADER
        DESTINATION ${INSTALL_INCLUDEDIR}
    RESOURCE
        DESTINATION ${INSTALL_RESOURCEDIR})

#[[
在install(TARGETS)中使用EXPORT时, 相当于把install(TARGETS)中的目标添加到EXPORT中
然后使用install(EXPORT)安装EXPORT
安装后会在指定目录下生成<Export-name>.cmake文件, include该文件后便可以导入输出的msg
通过<NAMESPACE><TAGETS-NAME>来访问, 例如访问msg动态库则使用message::msg来访问
---
导入库在CMake中可以像add_library一样使用
但是不能被install
---
配合<Export-name>Config.cmake文件便可使用find_package的config模式导入该库
<Export-name>Config.cmake内部也是include该<Export-name>.cmake来实现的
---
注意: 动态库也有debug, release等版本之分
因此也会输出<Export-name>-debug.cmake等文件
]]
install(EXPORT  # 安装该输出目标
            msgTargets
        NAMESPACE
            "message::"
        DESTINATION
            ${INSTALL_CMAKEDIR})
