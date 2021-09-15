/*
 * 文件名: msgBeautiful.c
 *
 * msg动态库的源代码文件
 * 该动态库实现三个函数(第一和第二个函数位于msgBeautiful中)
 */
#include "stdio.h"
#include "_msg.h"

/*
 * 函数名: printMSGBeautiful
 * 性质: 导出函数
 * 目标: 把char *msg的内容以漂亮的格式输出到stdout, 并且刷新stdout
 */
size_t printMSGBeautiful(char *msg) {
    size_t size = printf("MSG:\n");
    size += printMSG_(msg);
    size += printf("\n==========\n");
    fflush(stdout);
    return size;
}