#[[
文件名: custom_target_test.cmake
测试add_custom_command和add_custom_target

add_custom_command表示添加自定义程序
add_custom_target表示添加自定义的构建对象

虽然二者都可以添加自定义的COMMAND, 令程序在构建时运行, 但二者是不同的

add_custom_target则是添加一个无输出文件的构建目标(例如: Makefiles中的目标), 可以通过make <target-name>运行
add_custom_command则只是添加一段代码而不是构建目标, 他是有输出的。

add_custom_command可以直接指定为现有的构建目标(target)添加指令(方式1); 也可以直接输出一个文件, 被现有的构建所依赖(方式2)
add_custom_target是没有输出的, 所以他被依赖时, 会总是被构建(总过时)

CMAKE_COMMAND 是一个变量, 表示cmake的位置
cmake -E 提供了许多命令行程序 (用于跨平台)
例如, 在windows上没有touch程序, cmake -E touch则是cmake准备的touch程序, 在任何平台都可以使用
]]

set(TEST_FILE "log.txt")

# 添加一个代码, 他暂时附属于任何TARGET, 该指令生成一个log.txt文件
add_custom_command(
        OUTPUT ${TEST_FILE}  # 输出的文件
        COMMAND ${CMAKE_COMMAND} "-E" "touch" ${TEST_FILE}  # 具体指令
        COMMENT "Creating ${TEST_FILE}"  # 注释, 当代码运行时, 会在终端显示注释
        )

# 添加一个自定义目标
# ALL不是必须的, ALL表示他是默认的构建对象(这么说可能不准确). 例如Makefiles中, 执行make, make all, make zoo, 都会令这个项目构建
# 如果没有ALL, 则只有zoo被依赖或者make zoo时才会构建该目标
add_custom_target(fun ALL
        COMMAND ${CMAKE_COMMAND} "-E" "echo" "This is ALL target 'fun', and it depends on ${TEST_FILE}"
        DEPENDS ${TEST_FILE}  # 设置依赖, 说明当zoo构建时, 会判断log.txt是否过时, 若过时则执行上面add_custom_command的代码
                              # 这种令add_custom_command执行的方式是上述的(方式2)
        VERBATIM
        )

# 添加一个自定义目标
# 该目标则不属于ALL, 例如在Makefiles中, 则需要make zoo或者make bar时该目标才会被构建
add_custom_target(zoo
        COMMAND ${CMAKE_COMMAND} "-E" "echo" "This is target 'zoo', and it depends on ${TEST_FILE}"
        DEPENDS ${TEST_FILE}
        VERBATIM
        )

# 添加一个自定义目标
# 该目标则不属于ALL, 例如在Makefiles中, 则需要make bar才会构建该项目
add_custom_target(bar
        COMMAND ${CMAKE_COMMAND} "-E" "echo" "bar:hello"
        COMMENT "testing add_custom_target 'bar'..."
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS zoo  # 添加依赖于zoo, zoo目标也会被构建(zoo总是构建, 因为他总是过时的)
        )

# 使用 add_dependencies(bar zoo) 可以和上述的 DEPENDS zoo 达成相同效果

# 为已有的项目bar添加自定义COMMAND
# 这种令add_custom_command执行的方式是上述的(方式1)
add_custom_command(TARGET bar
        PRE_BUILD  # 表示在执行bar其他规则之前执行的命令. [注意: Visual Studio 7或更高版本之外的生成器中使用PRE_BUILD将被解释为PRE_LINK]
        COMMAND ${CMAKE_COMMAND} "-E" "echo" "executing a PRE_BUILD command"
        COMMENT "This command is PRE_BUILD build"
        VERBATIM
        )

# 如果bar没有相应的link操作, 则对应的COMMAND不执行
add_custom_command(TARGET bar
        PRE_LINK  # 编译目标之后, 调用链接器或归档器之前执行命令.
        COMMAND ${CMAKE_COMMAND} "-E" "echo" "executing a PRE_LINK command (bar)"
        COMMENT "This command is PRE_LINK build (bar)"
        VERBATIM
        )

add_custom_command(TARGET bar
        POST_BUILD  # 表示在执行bar其他规则之后执行的命令
        COMMAND ${CMAKE_COMMAND} "-E" "echo" "executing a POST_BUILD command"
        COMMENT "This command is POST_BUILD build"
        VERBATIM
        )

if(BUILD_LIBRARY)
# 为了与上述对比测试, hello是有link程序的
add_custom_command(TARGET hello
        PRE_LINK  # 编译目标之后, 调用链接器或归档器之前执行命令.
        COMMAND ${CMAKE_COMMAND} "-E" "echo" "executing a PRE_LINK command (hello)"
        COMMENT "This command is PRE_LINK build (hello)"
        VERBATIM
        )
endif()