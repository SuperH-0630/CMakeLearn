#[[
文件名: func.cmake
定义了一些函数和宏

宏和函数之间的区别在于它们的变量范围
宏在调用者的范围内执行, 而函数有自己的变量范围.

CMake运行函数或宏调用时有多余的参数, 他们会被记录在ARGN
ARGV<num>表示总参数的第num个参数, ARGC表示总参数的个数 (宏没有ARGC参数)
注意: ARGN等不是真正意义上的变量, 他们无法直接用在if的条件表达式中, 需要把他们赋值到真正的变量中后在使用
]]

# 一个简单的函数
function(fun1 TYPE MSG)
    message(${TYPE} "info: ${MSG}")
    message(STATUS "argn(${ARGC}) = ${ARGN}")  # 多余参数
    message(STATUS "argv0 = ${ARGV0}") # 多余参数的第一个参数
    set(fun1-var1 10 PARENT_SCOPE)  # 会影响外界
    set(fun1-var2 20)  # 不会影响外界
endfunction()

# 一个简单的宏
macro(mac1 TYPE MSG)
    message(${TYPE} "info: ${MSG}")
    message(STATUS "argn(${${ARGC}}) = ${ARGN}")
    message(STATUS "argv0 = ${ARGV0}")
    set(mac1-var 10)  # 会影响外界
endmacro()

# 一个允许key-values赋值的参数
function(fun2 TYPE MSG)  # TYPE和MSG仍是位置参数, 命名参数不需要列在参数表中
    set(options a b)  # 不需要参数的命名参数
    set(oneValueArgs c d) # 需要(0-1)个参数的命名参数
    set(multiValueArgs e f)  # 需要多个(含0个)参数的命名参数
    cmake_parse_arguments(fun2_arg  # 参数前缀
            "${options}"  # 不要遗漏分号, 因为这里实际上想要表示的是一个参数, 该参数为字符串"a;b"
            "${oneValueArgs}"
            "${multiValueArgs}"
            ${ARGN}  # 不需要分号
            )

    message(STATUS "TYPE = ${TYPE}")
    message(STATUS "MSG = ${MSG}")
    message(STATUS "fun2_arg_a = ${fun2_arg_a}")
    message(STATUS "fun2_arg_b = ${fun2_arg_b}")
    message(STATUS "fun2_arg_c = ${fun2_arg_c}")
    message(STATUS "fun2_arg_d = ${fun2_arg_d}")
    message(STATUS "fun2_arg_e = ${fun2_arg_e}")
    message(STATUS "fun2_arg_f = ${fun2_arg_f}")
    message(STATUS "fun2_arg_UNPARSED_ARGUMENTS = ${fun2_arg_UNPARSED_ARGUMENTS}")  # 剩余的变量
endfunction()

set(fun1-var1 0)
set(fun1-var2 0)
set(mac1-var 0)

message(STATUS "first fun1-var1 = ${fun1-var1}")
message(STATUS "first fun1-var2 = ${fun1-var2}")
message(STATUS "first mac1-var = ${mac1-var}")

fun1(STATUS "I am fun1" 1 2)
mac1(STATUS "I am mac1")

message(STATUS "after fun1-var1 = ${fun1-var1}")
message(STATUS "after fun1-var2 = ${fun1-var2}")
message(STATUS "after mac1-var = ${mac1-var}")

fun2(1 2 a x  # 多了个变量x
        c 10 20  # 多了个变量20
        d  # 没有参数
        e 1 2 3
)