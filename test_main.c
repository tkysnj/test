#include <stdio.h>
#include <string.h>


/**********************************************/
/* プロトタイプ宣言                              */
/**********************************************/
static void* funcTmp( void *arg );
    
/**********************************************/
/* define/typedef                             */
/**********************************************/
typedef void* (*D_FUNC_POINTER)(void *arg);

#define D_DEBUG_P(...)  printf("[DEBUG]"__VA_ARGS__)
/*#define D_DEBUG_P(...)*/

#define D_INIT_TBL(tbl)                         \
    do{                                         \
        int i;                                  \
        for( i = 0; tbl.menu[i].title != NULL; i++ ){ \
            ;                                   \
        }                                       \
        tbl.size = i;                           \
    }while(0)

/**********************************************/
/* 構造体                                      */
/**********************************************/

typedef struct _S_BASE_TEST_TBL {
    char                         tbl_title[32];
    struct _S_BASE_TEST_TBL     *prevtbl;
    unsigned int                 size;
    struct S_BASE_TEST_MENU {
        char                    *title;
        D_FUNC_POINTER           fp;
        struct _S_BASE_TEST_TBL *subtbl;
    } menu[];
} S_BASE_TEST_TBL;

//typedef struct _S_BASE_TEST_MENU {
//} S_BASE_TEST_MENU;


/**********************************************/
/* Global変数                                  */
/**********************************************/

S_BASE_TEST_TBL G_TBL_3 = {
    "C Group",
    NULL,
    0,
    {
        {"Func 3-1", funcTmp, NULL },
        {NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_2 = {
    "B Group",
    NULL,
    0,
    {
        {"Func 2-1", funcTmp, NULL },
        {NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_1_2 = {
    "A-2 Group",
    NULL,
    0,
    {
        {"FUNC 1-2-1", funcTmp, NULL },
        {NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_1 = {
    "A Group",
    NULL,
    0,
    {
        {"Func 1-1", funcTmp, NULL },
        {"Group 1-2", funcTmp, &G_TBL_1_2 },
        {"Func 1-3", funcTmp, NULL },
        {NULL, NULL, NULL}
    }
};

S_BASE_TEST_TBL G_TBL_TOP = {
    "TOP メニュー",
    NULL,
    0,
    {
        {"Group 1", funcTmp, &G_TBL_1 },
        {"Group 2", funcTmp, &G_TBL_2 },
        {"Group 3", funcTmp, &G_TBL_3 },
        {NULL, NULL, NULL}
    }
 };
/**********************************************/
/* 内部関数                                    */
/**********************************************/
static void* funcTmp( void *arg )
{
    printf("%S\n",__FUNCTION__);
}

void connectTbl(S_BASE_TEST_TBL *w_tbl, S_BASE_TEST_TBL *p_tbl)
{
    int i;
    for( i = 0; NULL != w_tbl->menu[i].title; i++ ){
        if( NULL != w_tbl->menu[i].subtbl ){
            connectTbl(w_tbl->menu[i].subtbl,w_tbl);
        }
    }
    w_tbl->prevtbl = p_tbl;
    w_tbl->size = i;
    return; 
}
    
void initTbl(void)
{
    connectTbl(&G_TBL_TOP,NULL);
}

int main( void )
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
            if( NULL == tbl->prevtbl ){
                break;
            }
            /* その他の場合は1階層上のメニューに移動 */
            else {
                tbl = tbl->prevtbl;
                continue;
            }

        }

        /* 範囲外の入力値はスキップ */
        if( num > (tbl->size-1) ){
            D_DEBUG_P("InputNumber(%d) > MaxNumber(%d)\n",num,(tbl->size-1));
            continue;
        }

        /* サブメニュー確認*/
        if( NULL != tbl->menu[num].subtbl ){

            D_DEBUG_P("Sub Menu\n");
            tbl       = tbl->menu[num].subtbl;
            level++;
            continue;

        }

        /* 関数実行 */
        fp = tbl->menu[num].fp;
        if( NULL != fp) {
            fp( NULL );
        } else {
            D_DEBUG_P("func pointer is NULL\n");
        }

    }

    return 0;
}
