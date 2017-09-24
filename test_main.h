/**
 * @file   test_main.h
 * @brief  テストメインヘッダー
 */

#ifndef __TEST_MAIN_H__
#define __TEST_MAIN_H__

/**********************************************/
/* プロトタイプ宣言                              */
/**********************************************/
void* funcTmp( void *arg );
void* HOGET_funcCall_HOGE_Init( void *arg );
void* HOGET_funcCall_HOGE_Deinit( void *arg );
void* HOGET_funcCall_HOGE_Exec1( void *arg );
void* HOGET_funcCall_HOGE_Exec2( void *arg );

/**********************************************/
/* define/typedef                             */
/**********************************************/
typedef void* (*D_FUNC_POINTER)(void *arg);

#define D_DEBUG_P(...)  printf("[DEBUG]"__VA_ARGS__)
/*#define D_DEBUG_P(...)*/

#define HOGET_LOG_INFO_PRINT(...) printf("[HOGET]"__VA_ARGS__)


/**********************************************/
/* 構造体                                      */
/**********************************************/
typedef struct _S_BASE_TEST_FUNC_ARG {
    unsigned int  arg1;
    unsigned int  arg2;
    char         *arg3;
} S_BASE_TEST_FUNC_ARG;



#endif /* __TEST_MAIN_H__ */
