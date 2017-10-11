
##########################################
# ユーザー定義関数
##########################################
function outFile()
{
    param( $out_file, $str )
    Add-Content -path "$out_file" -value ${str} -encoding UTF8
}

function outConsole()
{
    param( $str )
    Write-Host $str
}

function getTargInfo()
{
    param($cell, [System.Collections.Hashtable]$targ_info, $str)
    $ret = $false

    ${res} = ${cell}.Find("${str}")
    if( ${res} -ne $null ){
                
        foreach( $i in 1..10 ) {

            $tmp = ${cell}.Item( ${res}.Row, (${res}.Column+$i) ).Text
            if( ${tmp} ){
                ${targ_info}["${str}"] = Split-Path -Leaf ${tmp}
                ${ret} = $true
                break
            }

        }

    }

    if( ${ret} -eq $false ){
        Write-Host ( "ERROR:[$str]セル Not Exist!!" )
    } else {
        #outConsole ( "$str：" + ${targ_info}["${str}"] )
    }

    return ${ret}
}

function getColumn()
{
    param($cell, [System.Collections.Hashtable]$table_info, $str)
    $ret = $false

    ${res} = ${first} = ${cell}.Find("${str}")
    while (${res} -ne $null) {
        ${str} = [regex]::Escape(${str})
        if( ${res}.Text -match "^${str}$" ){
            $table_info.row = ${res}.Row
            $table_info.col = ${res}.Column
            ${ret} = $true
            break
        }
        ${res} = ${ws}.Cells.FindNext(${res})
        if (${res}.Address() -eq ${first}.Address()) {
            break
        }
    }

    if( ${ret} -eq $false ){
        Write-Host ( "ERROR:[$str]セル Not Exist!!" )
    } else {
        outConsole ( "[$str]セル：" + $table_info.row + ", " + $table_info.col )
    }

    return ${ret}
}

function getSubColumn()
{
    param($cell, $head_row, $head_col, $tail_col, [System.Collections.Hashtable]$table_info, $str)
    $ret = $false

    ${res} = ${first} = ${cell}.Find("${str}")
    while (${res} -ne $null) {
        if( ( ${res}.Text -match "^${str}$" )`
            -and ( ${res}.Row -ge $head_row)`
            -and ( ( ${res}.Column -ge $head_col) -and (${res}.Column -lt $tail_col) ) ){
            $table_info.row = ${res}.Row
            $table_info.col = ${res}.Column
            ${ret} = $true
            break
        }
        ${res} = ${ws}.Cells.FindNext(${res})
        if (${res}.Address() -eq ${first}.Address()) {
            break
        }
    }

    if( ${ret} -eq $false ){
        Write-Host ( "ERROR:[$str]セル Not Exist!!" )
    } else {
        #outConsole ( "[$str]セル：" + $table_info.row + ", " + $table_info.col )
    }

    return ${ret}
}

<#
########################### 不要関数 ############################# 

function getTargFileName()
{
    param($cell, [System.Collections.Hashtable]$targ_info)
    $ret = $false

    ${res} = ${cell}.Find("ファイル名")
    if( ${res} -ne $null ){
                
        foreach( $i in 1..10 ) {

            $tmp = ${cell}.Item( ${res}.Row, (${res}.Column+$i) ).Text
            if( ${tmp} ){
                ${targ_info}["ファイル名"] = Split-Path -Leaf ${tmp}
                ${ret} = $true
                break
            }

        }

    }

    return ${ret}
}

function getTargFuncName()
{
    param($cell, [System.Collections.Hashtable]$targ_info)
    $ret = $false

    ${res} = ${cell}.Find("関数")
    if( ${res} -ne $null ){
                
        foreach( $i in 1..10 ) {

            $tmp = ${cell}.Item( ${res}.Row, (${res}.Column+$i) ).Text
            if( ${tmp} ){
                ${targ_info}["関数"] = Split-Path -Leaf ${tmp}
                ${ret} = $true
                break
            }

        }

    }

    return ${ret}
}

function getFileNameColumn()
{
    param($cell, [System.Collections.Hashtable]$table_info)
    $ret = $false

    ${res} = ${first} = ${cell}.Find("ファイル")
    while (${res} -ne $null) {
        if( ${res}.Text -match "^ファイル$" ){
            $table_info.col = ${res}.Column
            $table_info.row = ${res}.Row
            ${ret} = $true
            break
        }
        ${res} = ${ws}.Cells.FindNext(${res})
        if (${res}.Address() -eq ${first}.Address()) {
            break
        }
    }

    return ${ret}
}

function getTestNameColumn()
{
    param($cell, [System.Collections.Hashtable]$table_info)
    $ret = $false

    ${res} = ${first} = ${cell}.Find("テスト名")
    while (${res} -ne $null) {
        if( ${res}.Text -match "^テスト名$" ){
            $table_info.col = ${res}.Column
            $table_info.row = ${res}.Row
            ${ret} = $true
            break
        }
        ${res} = ${ws}.Cells.FindNext(${res})
        if (${res}.Address() -eq ${first}.Address()) {
            break
        }
    }

    return ${ret}
}
########################### 不要関数 ############################# 
#>

# 定数
$date = Get-Date -Format "yyyy.MM.dd"

# スクリプト実行フォルダへのパス
$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Parent $scriptPath

# Excelオブジェクト作成
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true
$excel.DisplayAlerts = $true

Get-ChildItem "${dir}" -Include "*.xlsx","*.xls","*.xlt" -Recurse -Name | % {

    ${childPath} = $_

    outConsole "Open : ${dir}\${childPath}"
    ${wb}      = ${excel}.Workbooks.Open("${dir}\${childPath}")
    ${wb_name} = ${wb}.Name
    ${targ_file_name}   = ""
    ${targ_func_name}   = ""
    ${file_name_col}    = 0
    ${test_name_col}    = 0

    foreach( $ws in ${wb}.Worksheets ) {
    #${wb}.Worksheets | ForEach-Object {

        # シート名が「No.***」にマッチしない場合はSkip
        ${ws_name} = ${ws}.Name
        if( ${ws_name} -notmatch "No.*" ){ continue }

        ########### シート内の処理開始 ##########
        $targ_info  = @{ "ファイル名"="--"; 
                         "関数"="--" }
        $table_info = @{ "No."              = @{"row"=0;"col"=0};
                         "テストケース"     = @{"row"=0;"col"=0};
                         "テストデータ"     = @{"row"=0;"col"=0};
                         "ファイル"         = @{"row"=0;"col"=0};
                         "テスト名"         = @{"row"=0;"col"=0};
                         "入力"             = @{"row"=0;"col"=0};
                         "出力(期待値)"     = @{"row"=0;"col"=0};
                         "実施日"           = @{"row"=0;"col"=0};
                         "結果"             = @{"row"=0;"col"=0};
                         "備考"             = @{"row"=0;"col"=0};
                         "入力本関数"       = @{"row"=0;"col"=0};
                         "入力関数コール"   = @{"row"=0;"col"=0};
                         "出力外部変数"     = @{"row"=0;"col"=0};
                         "出力関数コール"   = @{"row"=0;"col"=0};
                         "出力本関数"       = @{"row"=0;"col"=0} }
        ${cell} = ${ws}.Cells
        outConsole   "=== ${wb_name} [${ws_name}]"


        ####### テスト対象情報 取得

        # ファイル名取得
        ${res} = getTargInfo ${cell} ([ref]${targ_info}) "ファイル名"
        if( ${res} -eq $false ) { Write-Host "ERR:ファイル名が見つからない" } 

        # 関数取得
        ${res} = getTargInfo ${cell} ([ref]${targ_info}) "関数"
        if( ${res} -eq $false ) { Write-Host "ERR:関数名が見つからない" }

        ####### テストケース情報 取得

        # [No.]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["No."]) "No."
        if( ${res} -eq $false ) { Write-Host "ERR:[No.]列番号が見つからない" }

        # [テストケース]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["テストケース"]) "テストケース"
        if( ${res} -eq $false ) { Write-Host "ERR:[テストケース]列番号が見つからない" }

        # [テストデータ]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["テストデータ"]) "テストデータ"
        if( ${res} -eq $false ) { Write-Host "ERR:[テストデータ]列番号が見つからない" }

        # [ファイル]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["ファイル"]) "ファイル"
        if( ${res} -eq $false ) { Write-Host "ERR:[ファイル]列番号が見つからない" }

        # [テスト名]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["テスト名"]) "テスト名"
        if( ${res} -eq $false ) { Write-Host "ERR:[テスト]列番号が見つからない" }

        # [入力]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["入力"]) "入力"
        if( ${res} -eq $false ) { Write-Host "ERR:[入力]列番号が見つからない" }
        ${cell}.Item( $table_info["入力"]["row"], $table_info["入力"]["col"]+1 ).Text

        # [出力(期待値)]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["出力(期待値)"]) "出力(期待値)"
        if( ${res} -eq $false ) { Write-Host "ERR:[出力(期待値)]列番号が見つからない" }

        # [実施日]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["実施日"]) "実施日"
        if( ${res} -eq $false ) { Write-Host "ERR:[実施日]列番号が見つからない" }

        # [結果]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["結果"]) "結果"
        if( ${res} -eq $false ) { Write-Host "ERR:[結果]列番号が見つからない" }

        # [備考]セル取得
        ${res} = getColumn ${cell} ([ref]$table_info["備考"]) "備考"
        if( ${res} -eq $false ) { Write-Host "ERR:[備考]列番号が見つからない" }

        # 入力の[本関数]セル取得
        $input_row_head = $table_info["入力"]["row"]
        $input_col_head = $table_info["入力"]["col"]
        $input_row_tail = $table_info["出力(期待値)"]["col"]
        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["入力本関数"]) "本関数"
        if( ${res} -eq $false ) { Write-Host "ERR:[入力本関数]列番号が見つからない" }

        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["入力関数コール"]) "関数コール"
        if( ${res} -eq $false ) { Write-Host "ERR:[入力関数コール]列番号が見つからない" }


        # 出力の[本関数]セル取得
        $input_row_head = $table_info["出力(期待値)"]["row"]
        $input_col_head = $table_info["出力(期待値)"]["col"]
        $input_row_tail = $table_info["実施日"]["col"]
        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["出力外部変数"]) "外部変数"
        if( ${res} -eq $false ) { Write-Host "ERR:[出力外部変数]列番号が見つからない" }

        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["出力関数コール"]) "関数コール"
        if( ${res} -eq $false ) { Write-Host "ERR:[出力関数コール]列番号が見つからない" }

        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["出力本関数"]) "本関数"
        if( ${res} -eq $false ) { Write-Host "ERR:[出力本関数]列番号が見つからない" }


        $no_row = $table_info["No."]["row"]
        $no_col = $table_info["No."]["col"]
        $head   = $false
        for( $row_plus = 1; $row_plus -lt 100; $row_plus++ ){

            $no_tmp = ${cell}.Item( $no_row+$row_plus, $no_col ).Text

            if( $no_tmp -eq "1" ){
                $head = $true
            } else {
                if( $head -eq $false ){
                    continue
                }
                if( ! $no_tmp ){
                    break
                }
            }

            $table_info.Add( "No.${no_tmp}", @{ "row" = $no_row+$row_plus; "col" = $no_col } )
            outConsole ("[No.${no_tmp}]セル：" + $table_info["No.${no_tmp}"]["row"] + ", " + $table_info["No.${no_tmp}"]["col"])

        }

        for( $no = 1; $no -lt 10; $no++ ){
            if( ! [bool]$table_info["No.${no}"] ) {
                break
            }
            #outConsole( "ファイル名：" + $cell.Item( $table_info["No.${no}"]["row"], $table_info["ファイル"]["col"] ).Text )
            #outConsole "hoge$no"
            $out_file = $cell.Item( $table_info["No.${no}"]["row"], $table_info["ファイル"]["col"] ).Text
        }


        Remove-Item $out_file
        outFile $out_file @"
/**
 * @file ${out_file}
 * @brief
 * @author 
 * @date ${date}
 */
extern "C" {
#include <stdio.h>
#include <stdlib.h>

#include <sys/time.h>
#include <sys/signal.h>
#include <string.h>
#include <errno.h>

#include "nb_timer_in.h"

extern void ${targ_func_name}( union sigval sigv );
}

#include "gtest/gtest.h"
#include "sexyhook.h"

static struct {	
	unsigned int callCnt;
	bool xx;
	bool yy;
	bool zz;
} Chk_Nb_evt_setEvent;
			
union sigval sigv;

/* 初期化関数 */
void nb_tim_cb_timeout_Init()
{			
	Chk_Nb_evt_setEvent.callCnt = 0;
	Chk_Nb_evt_setEvent.xx = false;
	Chk_Nb_evt_setEvent.yy = false;
	Chk_Nb_evt_setEvent.zz = false;
}


TEST(unittest02_nb_tim_cb_timeout, No001)
{
	nb_tim_cb_timeout_Init();

	SEXYHOOK_BEGIN(I4, SEXYHOOK_CDECL, Nb_evt_setEvent, (int xx, int yy, int zz))
	{
		if(HOGEHOGE == xx )
		{
			Chk_Nb_evt_setEvent.xx = true;
		}
		if( HOGEHOGE == yy )
		{
			Chk_Nb_evt_setEvent.yy = true;
		}
		if( HOGEHOGE == zz )
		{
			Chk_Nb_evt_setEvent.zz = true;
		}

		Chk_Nb_evt_setEvent.callCnt++;

		return D_NB_EVT_RESULT_OK;
	}
	SEXYHOOK_END();


	/***** テスト関数実行 *****/
	nb_tim_cb_timeout(sigv);		


	/***** 出力(期待値) *****/
	/* 関数コール */
	/** Nb_evt_setEvent **/
	EXPECT_EQ( 1, Chk_Nb_evt_setEvent.callCnt );
	if( 0 < Chk_Nb_evt_setEvent.callCnt )
	{
		EXPECT_TRUE( Chk_Nb_evt_setEvent.xx );
		EXPECT_TRUE( Chk_Nb_evt_setEvent.yy );
		EXPECT_TRUE( Chk_Nb_evt_setEvent.zz );
	}
}
"@

(Get-Content $out_file) -Join "`n" | Set-Content $out_file -Encoding UTF8

    }
}



$excel.Quit()
$excel = $null
[GC]::Collect()
