/*
 * 文件名: msg.c
 *
 * msg动态库的源代码文件
 * 该动态库实现三个函数(第三个函数位于msgBeautiful中)
 * printMSG_被定义为内部的函数, 但同时由两个源文件使用, 因此不能设置为static
 */

#include <stdio.h>
#include "_msg.h"

/*
 * 函数名: printMSG_
 * 性质: 内部函数
 * 目标: 把char *msg的内容输出到stdout
 */
size_t printMSG_(char *msg) {
    return printf("%s", msg);
}

/*
 * 函数名: printMSG
 * 性质: 导出函数
 * 目标: 把char *msg的内容输出到stdout, 并且刷新stdout
 */
size_t printMSG(char *msg) {
    size_t size = printMSG_(msg);
    size += printf("\n");
    fflush(stdout);
    return size;
}