#[[
文件名: FindPythonSelf.cmake
演示编写FindXXX.cmake文件
实际上是调用了find_package(Python3)
]]

find_package(Python3 COMPONENTS Interpreter Development)

if (Python3_FOUND)
    set(PythonSelf ${Python3_EXECUTABLE})
    set(PythonSelf_LIBRARIES ${Python3_LIBRARIES})
    set(PythonSelf_LIBS ${Python3_LIBRARIES})
endif()

include(FindPackageHandleStandardArgs)
# find_package_handle_standard_args 可以辅助处理find_package, 例如检查版本信息
find_package_handle_standard_args(PythonSelf  # 包名
                                  REQUIRED_VARS  # 只有当REQUIRED_VARS的变量均为有效(不为-NOFOUND等), PythonSelf_FOUND才为TRUE
                                  PythonSelf
                                  PythonSelf_LIBRARIES
                                  VERSION_VAR "1.0.0")  # 版本信息