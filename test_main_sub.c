/**
 * @file   test_main.c
 * @brief  テスト対象関数コール
 */

#include <stdio.h>
#include "test_main.h"

#define  HOGE_Init()
#define  HOGE_Deinit()

/**********************************************/
/* define / typedef
/**********************************************/

/**********************************************/
/* テスト対象関数コール
/**********************************************/

void* funcTmp( void *arg )
{
    HOGET_LOG_INFO_PRINT("%s\n",__FUNCTION__);
}

void* HOGET_funcCall_HOGE_Init( void *arg )
{
    HOGET_LOG_INFO_PRINT("HOGE_Init Call\n");
    HOGE_Init();
}

void* HOGET_funcCall_HOGE_Deinit( void *arg )
{
    HOGET_LOG_INFO_PRINT("HOGE_Deinit Call\n");
    HOGE_Deinit();
}

void* HOGET_funcCall_HOGE_Exec1( void *arg )
{
    S_BASE_TEST_FUNC_ARG *data = (S_BASE_TEST_FUNC_ARG *)arg;
    HOGET_LOG_INFO_PRINT("HOGE_Exec1 Call(%d)\n",data->arg1);
    HOGE_Deinit();
}

void* HOGET_funcCall_HOGE_Exec2( void *arg )
{
    HOGET_LOG_INFO_PRINT("HOGE_Exec2 Call\n");
    HOGE_Deinit();
}
