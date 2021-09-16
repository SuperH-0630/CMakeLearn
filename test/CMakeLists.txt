#[[
文件名: test\CMakeLists.txt
定义测试程序
为了方便, 测试程序实际上和msg无关系

add_test 用于添加测试, 测试的COMMAND可用于任意命令
可以用ctest程序运行测试
可以用ctest -R <name> 指定测试名字
可以用ctest -L <name> 指定测试子集
可以用ctest -I a,b 指定运行第a-b号测试
通过设置测试的属性(set_tests_properties)可以设置测试对应的行为

enable_testing 表示启用测试

注意: 再那个CMakeLists.txt使用enable_testing, 则需要在他对应的构建目录(${CMAKE_BINARY_DIR})下执行ctest程序
因此通常在顶层CMakeLists.txt使用enable_testing

使用ctest -V可以输出测试的详细内容
]]

add_executable(_test1 test1.c)
add_executable(_test2 test_fail.c)

find_package(Python3 COMPONENTS Interpreter)  # 通过FindPython3.cmake文件(CMake内置的文件)寻找Python3的可执行程序
if(NOT Python3_FOUND)
    message(WARNING "Python3 Not Found")
endif()

add_test(NAME test_base
        COMMAND ${Python3_EXECUTABLE} -c "print(\"I am base\")"  # COMMAND可以输入任意命令行程序
)

add_test(NAME test1
        COMMAND "$<TARGET_FILE:_test1>"
)

add_test(NAME test_end
        COMMAND ${Python3_EXECUTABLE} -c "print(\"I am end\")"  # COMMAND可以输入任意命令行程序
)

add_test(NAME test_fail
        COMMAND "$<TARGET_FILE:_test2>"
)

#[[
添加测试子集
可以在CTest中直接使用测试子集的名字代表一群测试
]]
set_tests_properties(  # 设置测试子集
        test_base
        test1
        test_end
        PROPERTIES
            LABELS "test_a"
)

#[[
添加测试固件
当运行FIXTURES_REQUIRED的测试时, 同固件的FIXTURES_SETUP和FIXTURES_CLEANUP也会被运行
但是可以单独运行FIXTURES_SETUP和FIXTURES_CLEANUP
运行某个FIXTURES_REQUIRED时, 同固件的其他FIXTURES_REQUIRED不会运行

注意: 测试固件的名字不是测试子集的名字, 不可以在CTest中直接使用测试子集的名字代表一群测试
注意: 测试固件的名字可以和测试子集使用相同的名字
]]
set_tests_properties(test_base PROPERTIES FIXTURES_SETUP "test_a_")  # 添加测试固件
set_tests_properties(test1 PROPERTIES FIXTURES_REQUIRED "test_a_")
set_tests_properties(test_fail PROPERTIES FIXTURES_REQUIRED "test_a_")
set_tests_properties(test_end PROPERTIES FIXTURES_CLEANUP "test_a_")


set_tests_properties(test1 PROPERTIES TIMEOUT 10)  # 设置test的TIMEOUT, 即测试时间小于10s
set_tests_properties(test_fail PROPERTIES WILL_FAIL true)  # test_fail以程序运行失败作为测试成功的条件

option(TEST_COMPILE "try compile" OFF)
if (TEST_COMPILE)
    # 测试编译器是否能正常运作的程序 (与ctest不同, try_compile在CMake配置期间就运行了)
    # 测试是否可以通过编译
    try_compile(
            build_test1
            ${CMAKE_BINARY_DIR}/try_compile  # 编译输出的位置
            SOURCES
                ${CMAKE_CURRENT_SOURCE_DIR}/build_test.c  # 源文件
    )
    message(STATUS "build_test1 = ${build_test1}")

    include(CheckCSourceCompiles)
    # check_c_source_compiles本质是try_compiles的一层封装
    check_c_source_compiles( "int main(){return 0;}" build_test2)
    check_c_source_compiles( "int main(){return 0}" build_test3)  # 错误, 遗漏分号

    message(STATUS "build_test2 = ${build_test2}")  # 输出1
    message(STATUS "build_test3 = ${build_test3}")  # 输出空字符串
endif()

option(TEST_RUN "try run" OFF)
if (TEST_RUN)
    try_run(run_test1 run_test1_build_res
            ${CMAKE_BINARY_DIR}/try_compile  # 编译输出的位置
            ${CMAKE_CURRENT_SOURCE_DIR}/build_test.c  # 源文件(仅支持一个)
    )

    message(STATUS "run_test1 = ${run_test1}")
    message(STATUS "run_test1_build_res = ${run_test1_build_res}")

    include(CheckCSourceRuns)
    # check_c_source_runs本质是try_run的一层封装
    check_c_source_runs( "int main(){return 0;}" run_test2)
    check_c_source_runs( "int main(){return 0}" run_test3)  # 错误, 遗漏分号
    check_c_source_runs( "int main(){return 1;}" run_test4)  # 执行错误

    message(STATUS "run_test2 = ${run_test2}")  # 输出1
    message(STATUS "run_test3 = ${run_test3}")  # 输出空字符串
    message(STATUS "run_test4 = ${run_test4}")  # 输出空字符串
endif()

option(FIND_MSG "Try to find msgTargets from your computer." ON)  # 尝试在电脑寻找msgTargets

if (FIND_MSG)
    #[[
    find_package寻找库, 默认是从module模式, 若未找到相应的Find<包名>.cmake文件再到config模式
    可以直接设定CONFIG选项, 直接进入config模式, 寻找<包名>Config.cmake文件
    ---
    第一个参数是包名
    第二个参数是指定请求的版本号 (也可以不指定, 则不检查版本)
    COMPONENTS表示请求的内容 (也可以不指定, 则一般会请求默认的内容, 具体需要参考供应商的文档)
    ---
    find_package的其他使用可以参见CMake文档
    ]]
    find_package(msgTargets "1.0.0" COMPONENTS msg CONFIG)
    if (msgTargets_FOUND)
        # IMPORTED_IMPLIB和IMPORTED_IMPLIB_<CONFIG>属性设定了该导入库的动态库导入文件的路径(例如, windows上的.lib, .dll.a)
        # <CONFIG>一般是DEBUG, RELEASE等, IMPORTED_IMPLIB一般为IMPORTED_IMPLIB_RELEASE
        get_target_property(imp message::msg IMPORTED_IMPLIB)
        get_target_property(imp_debug message::msg IMPORTED_IMPLIB_DEBUG)
        get_target_property(imp_release message::msg IMPORTED_IMPLIB_RELEASE)

        # IMPORTED_LOCATION和IMPORTED_LOCATION_<CONFIG>属性设定了该导入库的动态库运行时文件的路径(例如, windows上的.dll)
        get_target_property(loc message::msg IMPORTED_LOCATION)
        get_target_property(loc_debug message::msg IMPORTED_LOCATION_DEBUG)
        get_target_property(loc_release message::msg IMPORTED_LOCATION_RELEASE)

        message(STATUS "Import lib: ${imp}")
        message(STATUS "Location lib: ${loc}")

        message(STATUS "Import debug lib: ${imp_debug}")
        message(STATUS "Location debug lib: ${loc_debug}")

        message(STATUS "Import release lib: ${imp_release}")
        message(STATUS "Location release lib: ${loc_release}")
    else()
        message(STATUS "msgTargets NOT FOUND.")
        message(STATUS "maybe you should set the cache msgTargets_DIR.")  # <报名>_DIR用于find_package在config模式时在何处寻找.cmake文件
    endif()
endif()
