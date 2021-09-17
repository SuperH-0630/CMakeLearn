#[[==============================================================
文件名: CMakeLists.txt

2021/9/25
cmake_minimum_required不仅可以设定一个版本最小值, 还可以设定版本的一个范围, 具体可以参见文档
project是顶级CMakeLists.txt所必须的, Languages表示该项目需要使用的语言, c++语言用CXX表示
add_executable的第一个参数表示可执行程序的名字, 不需要包含后缀, cmake会根据不同的平台设定正确的后缀

add_librar与add_executable类型, 用于生成一个函数库(默认情况下是静态库)
target_sources会追加源文件到目标中
目标: 即通过add_librar与add_executable构建的对象, 例如此例子中的msg和hello
为什么.h要写入头文件中: 其实我也没有很确切的理由, 实际上尽管不添加大多数情况也可以运行, 我想应该是文件依赖管理吧
PUBLIC是什么意思: 例如hello依赖msg库, 则hello的源文件中也会自动添加msg的PUBLIC源文件
INTERFACE和PRIVATE: 除了PUBLIC, 还有这两种类型.
    PRIVATE表示只添加到msg中
    INTERFACE表示只添加到依赖msg的目标中(例如hello)
    PUBLIC = PRIVATE + INTERFACE
target_link_libraries用于添加一个库链接

if() ... elseif() ... else() ... endif() 表示一个条件语句
    注意: if的条件访问变量时不需要${}符号, 例如 if(var1)实际上就是条件时var1的值而不是var1字符串本身 (if已经自动解引用变量, 不需要再显式使用${})
option 表示添加一个CMake参数
    注意: 在cmake-gui只有当该option被运算时, 才会将option显示出来
    例如, 将option(BUILD_LIBRARY "Build msg library" ON)修改为option(BUILD_LIBRARY "Build msg library" OFF)
        初次配置CMake时便将不会显示BUILD_SHARED_LIBRARY选项, 因为BUILD_LIBRARY为OFF
        option(BUILD_SHARED_LIBRARY "Build shared library" ON)没有执行
    在命令行则可以直接通过-Dxxx=yyy来使用参数
add_library添加的源码默认为PRIVATE

message 用于在CMake终端输出信息
CMAKE_C_COMPILER等变量记录的是编译器等的信息, 修改这些变量可以对编译产生影响
也可以通过-DCMAKE_C_COMPILER=xxx的方式在命令行修改这些选项

foreach(var item1 item2 item3...) ... endforeach() 表示一个遍历语句
foreach 还有range的迭代方式, 可以参见文档 foreach(var strat [end] [step])

add_subdirectory添加一个子目录 注意: 是添加子目录而不是子程序 (子程序需要使用超级构建)

include 可以导入文件来执行(一般是.cmake文件), 并且不会生成新的变量空间

可以设置CMAKE_ARCHIVE_OUTPUT_DIRECTORY, CMAKE_RUNTIME_OUTPUT_DIRECTORY等变量来控制add_library, add_executable对目标的输出位置

execute_process 在CMake配置时运行程序
add_custom_command 添加自定义命令
add_custom_target 添加自定义目标

file 指令主要处理文件IO相关的操作
list 指令主要处理列表相关的操作
=================================================================]]

cmake_minimum_required(VERSION 3.20)  # 设定cmake的版本, 当运行该CMakeLists.txt的CMake解释器低于该版本是将会报错
project(cmake-learn LANGUAGES C)  # 设置项目的名称
set(CMAKE_C_STANDARD 11)  # 设置C标准为C11
set(C_EXTENSIONS OFF)  # 不使用编译器扩展
set(C_STANDARD_REQUIRED OFF)  # 当C_STANDARD_REQUIRED设置为ON时, 则表示编译器必须支持CMAKE_C_STANDARD指定的标准
                              # 设置为OFF时会寻找CMAKE_C_STANDARD指定的标准, 或编译器支持的与他最接近的下一个标准

#[[
设置导出库符号的可见程度
一般设置为默认不可见, 然后通过EXPORT修饰符来指定导出的符号
CMAKE_<LANG>_VISIBILITY_PRESET可以设置LANG语言的动态库的符号可见程度, 具体可参考CMake文档
---
可以针对目标的<LANG>_VISIBILITY_PRESET, 已经CMAKE_VISIBILITY_INLINES_HIDDEN属性覆盖这里的设定, 进行颗粒度更细的设定
]]
set(CMAKE_C_VISIBILITY_PRESET hidden)  # C语言动态库的符号默认不可见
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)  # 隐藏内联函数的符号

if(NOT CMAKE_BUILD_TYPE)  # 若CMAKE_BUILD_TYPE为空(未定义)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)  # 设置CACHE变量CMAKE_BUILD_TYPE
endif()

#[[
定义输出目录
GNUInstallDirs中定义了GNU标准的输出文件夹名字, 例如:
CMAKE_INSTALL_LIBDIR lib
CMAKE_INSTALL_BINDIR bin
]]
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY  # 静态库的输出路径
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY  # 动态库(或者动态库的导入文件)的输出路径
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})  # 可执行文件(以及.dll)的输出路径

# 设定安装的目录
set(INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR} CACHE PATH "Installation directory for libraries")
set(INSTALL_BINDIR ${CMAKE_INSTALL_BINDIR} CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDEDIR ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME} CACHE PATH "Installation directory for header files")
set(INSTALL_RESOURCEDIR resource/${PROJECT_NAME} CACHE PATH "Installation directory for resource files")  # 关联文件

option(JUST_BUILD "Just build targets" ON)

if(WIN32 AND NOT CYGWIN)
    set(DEF_INSTALL_CMAKEDIR cmake)
else()
    set(DEF_INSTALL_CMAKEDIR share/cmake/msgTargets)  # unix类系统(Unix, Linux, MacOS, Cygwin等)把cmake文件安装到指定的系统的cmake文件夹中
endif()
set(INSTALL_CMAKEDIR ${DEF_INSTALL_CMAKEDIR} CACHE PATH "Installation directory for CMake files")
unset(DEF_INSTALL_CMAKEDIR)

# 报告安装路径
foreach(p LIB BIN INCLUDE RESOURCE CMAKE)
    message(STATUS "Installing ${CMAKE_INSTALL_PREFIX}/${INSTALL_${p}DIR}")
endforeach()

add_executable(hello main.c)  # 编译一个可执行程序, 使用main.c为源代码, 可执行程序的名字为hello

option(BUILD_LIBRARY "Build msg library" ON)  # 添加一个选项, 寻味是否构建库
if (BUILD_LIBRARY)
    add_subdirectory(msg)
    target_link_libraries(hello msg)  # hello链接msg
else()  # 不构建库, 库的代码被直接写到hello中
    add_library(msg INTERFACE)  # 接口库
    target_sources(hello
        PRIVATE
            msg/msg.c msg/msgBeautiful.c msg/_msg.h
        PUBLIC
            include/msg.h
        )
    target_include_directories(hello PUBLIC include)
endif()

# 这部分代码只是CMake测试所用
if (NOT JUST_BUILD)
    message(STATUS "Hello, CMake!")  # 显示一条STATUS信息
    # message(WARNING "I am warning.")  # 显示一条WARNING信息
    # message(FATAL_ERROR "I am error!")  # 显示一条错误信息, CMake停止运行
    # message(SEND_ERROR "I am send_error!")  # 显示一条错误信息, CMake不会停止运行, 但不生成内容(无法构建项目)

    include(cmake/print_info.cmake)
    include(cmake/print_info.cmake)  # 第二次导入将不会再输出文件信息, 但是会输出"include print_info"
    message(STATUS "PRINT_INFO = ${PRINT_INFO}")  # PRINT_INFO在cmake/print_info.cmake中定义

    # 关于find_package还有Module模式Config模式等之分
    find_package(Python3 COMPONENTS Interpreter Development)  # 通过FindPython3.cmake文件(CMake内置的文件)寻找Python3的可执行程序
    if(Python3_FOUND)
        message(STATUS "Python3_EXECUTABLE = ${Python3_EXECUTABLE}")  # Python3的可执行程序
        message(STATUS "Python3_LIBRARIES = ${Python3_LIBRARIES}")  # Python3的库(Windows上为导入库)
        message(STATUS "Python3_RUNTIME_LIBRARY_DIRS = ${Python3_RUNTIME_LIBRARY_DIRS}")  # Python3的运行时库(Windows上为.dll)

        execute_process(  # 在CMake配置时运行程序
                COMMAND  # 代码会按顺序执行
                ${Python3_EXECUTABLE} "-c" "print(\"I am execute_process\");a"  # 打印内容后, 访问不存在的变量a
                RESULT_VARIABLE re  # 存储结果
                OUTPUT_VARIABLE _stdout  # stdout的输出内容
                ERROR_VARIABLE _stderr  # stderr的输出内容
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_STRIP_TRAILING_WHITESPACE
                )

        message(STATUS "result = ${re}")  # 因为访问不存在的变量a, 故会诱发python错误, result = 1
        message(STATUS "stdout = ${_stdout}")
    else()
        message(WARNING "Python3 Not Found")
    endif()

    include(cmake/custom_target_test.cmake)  # 添加custom_target_test测试程序
    include(cmake/func.cmake)
    fun1(STATUS "I am fun1 (out)")  # include没有新增变量空间, 其中定义的函数可以在外面再次调用
    mac1(STATUS "I am mac1 (out)" 1 2)
endif()

# 启用测试
# 一般情况下, 在顶层的CMakeLists.txt执行enable_testing
enable_testing()
add_subdirectory(test)  # 添加测试

add_subdirectory(hello2)  # 构建hello2

install(
    TARGETS
        hello
        hello2
    ARCHIVE
        DESTINATION ${INSTALL_LIBDIR}
    RUNTIME
        DESTINATION ${INSTALL_BINDIR}
    LIBRARY
        DESTINATION ${INSTALL_LIBDIR}
    PUBLIC_HEADER
        DESTINATION ${INSTALL_INCLUDEDIR}
    RESOURCE
        DESTINATION ${INSTALL_RESOURCEDIR}
)

if(WIN32)  # windows操作系统, 需要赋值dll到指定位置
    #[[
        因为windows的.dll需要和可执行文件在一起, 因此此处添加复制构建目录中的.dll
        当dll是由CMake用add_library生成时, 可以直接使用install该target即可将dll复制到对应目录
        若dll不是由CMake用add_library生成或没有对该target执行install时, 则需要手动复制.dll(否则无法运行)

        该例中, msg库已经使用install安装, 因此下面的步骤其实是不必需要
    ]]
    include(cmake/DLLFind.cmake)
    dll_find(_dll ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    message(STATUS "Windows dll = ${_dll}")
    install(FILES ${_dll} DESTINATION ${INSTALL_BINDIR})
else()  # 非windows操作系统, 设置rpath
    file(RELATIVE_PATH _rel ${CMAKE_INSTALL_PREFIX}/${INSTALL_BINDIR} ${CMAKE_INSTALL_PREFIX})  # 获得${CMAKE_INSTALL_PREFIX}相对于${CMAKE_INSTALL_PREFIX}/${INSTALL_BINDIR}的路径
    if(APPLE)
        set(_rpath_base "@loader_path/${_rel}")  # MacOS使用@loader_path表示可执行文件的位置
    else()
        set(_rpath_base "\$ORIGIN/${_rel}")  # Unix-like使用$ORIGIN表示可执行文件的位置
    endif()
    file(TO_NATIVE_PATH "${_rpath_base}/${INSTALL_LIBDIR}" _rpath)  # 转换为系统原生的操作路径
    message(STATUS "rpath = ${_rpath}")
    set_target_properties(hello hello2
                          PROPERTIES
                              MACOSX_RPATH ON
                              SKIP_BUILD_RPATH OFF  # OFF: 构建对象也使用rpath
                              BUILD_WITH_INSTALL_RPATH OFF  # OFF: build和install使用不同的rpath
                              INSTALL_RPATH "${_rpath}"  # INSTALL的rpath, Build的rpath通过BUILD_RPATH设定
                          )
    unset(_rel)
    unset(_rpath_base)
    unset(_rpath)
endif()


install(CODE "message(STATUS \"CMakeLists.txt: INSTALL TO: ${CMAKE_INSTALL_PREFIX}\")")  # 安装时执行指定CMake命令
# 这部分代码只是CMake测试所用
if (NOT JUST_BUILD)
    install(SCRIPT cmake/install_info.cmake)  # 安装时执行install_info.cmake脚本
    install(CODE "message(STATUS \"CMakeLists.txt: I am CODE\")")  # 安装时执行指定CMake命令
endif()