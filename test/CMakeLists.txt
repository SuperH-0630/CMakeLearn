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
