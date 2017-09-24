/**
 * @file   test_main.c
 * @brief  テストメイン処理部
 */

#include <stdio.h>
#include <string.h>
#include "test_main.h"


/**********************************************/
/* define/typedef                             */
/**********************************************/

/**********************************************/
/* 構造体                                      */
/**********************************************/

typedef struct _S_BASE_TEST_TBL {
    char                         tbl_title[32];
    struct _S_BASE_TEST_TBL     *upper_level_tbl;
    unsigned int                 size;
    struct S_BASE_TEST_MENU {
        char                    *title;
        D_FUNC_POINTER           fp;
        void                    *arg;
        struct _S_BASE_TEST_TBL *low_level_tbl;
    } menu[];
} S_BASE_TEST_TBL;

/**********************************************/
/* Global変数                                  */
/**********************************************/

/* 引数 ***************************************/
S_BASE_TEST_FUNC_ARG arg1 = { 1, 0, NULL };

/* メニューテーブル *****************************/
S_BASE_TEST_TBL G_TBL_3 = {
    "C Group",
    NULL,
    0,
    {
        {"Func 3-1", funcTmp, NULL, NULL },
        {NULL, NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_2 = {
    "B Group",
    NULL,
    0,
    {
        {"Func 2-1", funcTmp, NULL, NULL },
        {NULL, NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_1_2 = {
    "A-2 Group",
    NULL,
    0,
    {
        {"FUNC 1-2-1", funcTmp, NULL, NULL },
        {NULL, NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_1 = {
    "A Group",
    NULL,
    0,
    {
        {"Func 1-1", funcTmp, NULL, NULL },
        {"Group 1-2", funcTmp, NULL, &G_TBL_1_2 },
        {"Func 1-3", funcTmp, NULL, NULL },
        {NULL, NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_TOP = {
    "TOP メニュー",
    NULL,
    0,
    {
        {"初期化処理", HOGET_funcCall_HOGE_Init, NULL, NULL },
        {"終了処理",   HOGET_funcCall_HOGE_Deinit, NULL, NULL },
        {"処理1",     HOGET_funcCall_HOGE_Exec1, &arg1, NULL },
        {"処理2",     HOGET_funcCall_HOGE_Exec2, NULL, NULL },
        {"Group 1", funcTmp, NULL, &G_TBL_1 },
        {"Group 2", funcTmp, NULL, &G_TBL_2 },
        {"Group 3", funcTmp, NULL, &G_TBL_3 },
        {NULL, NULL, NULL, NULL}
    }
 };

/**********************************************/
/* 内部関数                                    */
/**********************************************/

/**
 * @brief 上位テーブルと紐付け＆メニュー数のカウント
 *        再帰的にコールされることで全テーブルに対して上記を行うことを想定
 *
 * @param [in]   *w_tbl カレントテーブル
 * @param [in]   *p_tbl 上位テーブル
 *
 * @retval void
 */
void connectTbl(S_BASE_TEST_TBL *work_tbl, S_BASE_TEST_TBL *upper_level_tbl)
{
    int i;
    for( i = 0; NULL != work_tbl->menu[i].title; i++ ){
        if( NULL != work_tbl->menu[i].low_level_tbl ){
            connectTbl(work_tbl->menu[i].low_level_tbl,work_tbl);
        }
    }
    work_tbl->upper_level_tbl = upper_level_tbl;
    work_tbl->size = i;
    return; 
}
    
/**
 * @brief メニューテーブルの初期化
 *
 * @param void
 *
 * @retval void
 */
void initTbl(void)
{
    connectTbl(&G_TBL_TOP,NULL);
}

/**
 * @brief メイン関数
 *
 * @param void
 *
 * @retval void
 */
void main( void )
{
    char             buf[32];
    long             num   = 0;
    S_BASE_TEST_TBL *tbl;
    S_BASE_TEST_TBL *upper_tbl;
    D_FUNC_POINTER   fp    = NULL;
    unsigned int     level = 0;
    unsigned int     i;

    /* テーブル初期化 */
    initTbl();

    tbl = &G_TBL_TOP;
    while( 1 ){

        /* メニュー表示 */
        printf("\n=============[%-16s]============\n",tbl->tbl_title);
        for( i = 0; tbl->menu[i].title != NULL; i++ ) {
            printf("%d:%s\n",i,tbl->menu[i].title);
            num = strtol( buf, NULL, 10 );
        }

        /* 入力受付*/
        printf("Input(終了:Q) > ");
        fgets( buf, sizeof(buf), stdin );
        num = strtol( buf, NULL, 10 );

        /* 終了確認 */
        if( ( 'q' == buf[0] ) || ( 'Q' == buf[0] ) ){

            /* TOPメニューの場合は終了 */
            if( NULL == tbl->upper_level_tbl ){
                break;
            }
            /* その他の場合は1階層上のメニューに移動 */
            else {
                tbl = tbl->upper_level_tbl;
                continue;
            }

        }

        /* 範囲外の入力値はスキップ */
        if( num > (tbl->size-1) ){
            D_DEBUG_P("InputNumber(%d) > MaxNumber(%d)\n",num,(tbl->size-1));
            continue;
        }

        /* サブメニュー確認*/
        if( NULL != tbl->menu[num].low_level_tbl ){
            D_DEBUG_P("Sub Menu\n");
            tbl       = tbl->menu[num].low_level_tbl;
            level++;
            continue;
        }

        /* 関数実行 */
        fp  = tbl->menu[num].fp;
        if( NULL != fp ) {
            printf("\n");
            fp( tbl->menu[num].arg );
        }
        else {
            D_DEBUG_P("func pointer is NULL\n");
        }

    }

    return ;
}
