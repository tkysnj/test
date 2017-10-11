
##########################################
# ���[�U�[��`�֐�
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
        Write-Host ( "ERROR:[$str]�Z�� Not Exist!!" )
    } else {
        #outConsole ( "$str�F" + ${targ_info}["${str}"] )
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
        Write-Host ( "ERROR:[$str]�Z�� Not Exist!!" )
    } else {
        outConsole ( "[$str]�Z���F" + $table_info.row + ", " + $table_info.col )
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
        Write-Host ( "ERROR:[$str]�Z�� Not Exist!!" )
    } else {
        #outConsole ( "[$str]�Z���F" + $table_info.row + ", " + $table_info.col )
    }

    return ${ret}
}

<#
########################### �s�v�֐� ############################# 

function getTargFileName()
{
    param($cell, [System.Collections.Hashtable]$targ_info)
    $ret = $false

    ${res} = ${cell}.Find("�t�@�C����")
    if( ${res} -ne $null ){
                
        foreach( $i in 1..10 ) {

            $tmp = ${cell}.Item( ${res}.Row, (${res}.Column+$i) ).Text
            if( ${tmp} ){
                ${targ_info}["�t�@�C����"] = Split-Path -Leaf ${tmp}
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

    ${res} = ${cell}.Find("�֐�")
    if( ${res} -ne $null ){
                
        foreach( $i in 1..10 ) {

            $tmp = ${cell}.Item( ${res}.Row, (${res}.Column+$i) ).Text
            if( ${tmp} ){
                ${targ_info}["�֐�"] = Split-Path -Leaf ${tmp}
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

    ${res} = ${first} = ${cell}.Find("�t�@�C��")
    while (${res} -ne $null) {
        if( ${res}.Text -match "^�t�@�C��$" ){
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

    ${res} = ${first} = ${cell}.Find("�e�X�g��")
    while (${res} -ne $null) {
        if( ${res}.Text -match "^�e�X�g��$" ){
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
########################### �s�v�֐� ############################# 
#>

# �萔
$date = Get-Date -Format "yyyy.MM.dd"

# �X�N���v�g���s�t�H���_�ւ̃p�X
$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Parent $scriptPath

# Excel�I�u�W�F�N�g�쐬
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

        # �V�[�g�����uNo.***�v�Ƀ}�b�`���Ȃ��ꍇ��Skip
        ${ws_name} = ${ws}.Name
        if( ${ws_name} -notmatch "No.*" ){ continue }

        ########### �V�[�g���̏����J�n ##########
        $targ_info  = @{ "�t�@�C����"="--"; 
                         "�֐�"="--" }
        $table_info = @{ "No."              = @{"row"=0;"col"=0};
                         "�e�X�g�P�[�X"     = @{"row"=0;"col"=0};
                         "�e�X�g�f�[�^"     = @{"row"=0;"col"=0};
                         "�t�@�C��"         = @{"row"=0;"col"=0};
                         "�e�X�g��"         = @{"row"=0;"col"=0};
                         "����"             = @{"row"=0;"col"=0};
                         "�o��(���Ғl)"     = @{"row"=0;"col"=0};
                         "���{��"           = @{"row"=0;"col"=0};
                         "����"             = @{"row"=0;"col"=0};
                         "���l"             = @{"row"=0;"col"=0};
                         "���͖{�֐�"       = @{"row"=0;"col"=0};
                         "���͊֐��R�[��"   = @{"row"=0;"col"=0};
                         "�o�͊O���ϐ�"     = @{"row"=0;"col"=0};
                         "�o�͊֐��R�[��"   = @{"row"=0;"col"=0};
                         "�o�͖{�֐�"       = @{"row"=0;"col"=0} }
        ${cell} = ${ws}.Cells
        outConsole   "=== ${wb_name} [${ws_name}]"


        ####### �e�X�g�Ώۏ�� �擾

        # �t�@�C�����擾
        ${res} = getTargInfo ${cell} ([ref]${targ_info}) "�t�@�C����"
        if( ${res} -eq $false ) { Write-Host "ERR:�t�@�C������������Ȃ�" } 

        # �֐��擾
        ${res} = getTargInfo ${cell} ([ref]${targ_info}) "�֐�"
        if( ${res} -eq $false ) { Write-Host "ERR:�֐�����������Ȃ�" }

        ####### �e�X�g�P�[�X��� �擾

        # [No.]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["No."]) "No."
        if( ${res} -eq $false ) { Write-Host "ERR:[No.]��ԍ���������Ȃ�" }

        # [�e�X�g�P�[�X]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["�e�X�g�P�[�X"]) "�e�X�g�P�[�X"
        if( ${res} -eq $false ) { Write-Host "ERR:[�e�X�g�P�[�X]��ԍ���������Ȃ�" }

        # [�e�X�g�f�[�^]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["�e�X�g�f�[�^"]) "�e�X�g�f�[�^"
        if( ${res} -eq $false ) { Write-Host "ERR:[�e�X�g�f�[�^]��ԍ���������Ȃ�" }

        # [�t�@�C��]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["�t�@�C��"]) "�t�@�C��"
        if( ${res} -eq $false ) { Write-Host "ERR:[�t�@�C��]��ԍ���������Ȃ�" }

        # [�e�X�g��]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["�e�X�g��"]) "�e�X�g��"
        if( ${res} -eq $false ) { Write-Host "ERR:[�e�X�g]��ԍ���������Ȃ�" }

        # [����]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["����"]) "����"
        if( ${res} -eq $false ) { Write-Host "ERR:[����]��ԍ���������Ȃ�" }
        ${cell}.Item( $table_info["����"]["row"], $table_info["����"]["col"]+1 ).Text

        # [�o��(���Ғl)]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["�o��(���Ғl)"]) "�o��(���Ғl)"
        if( ${res} -eq $false ) { Write-Host "ERR:[�o��(���Ғl)]��ԍ���������Ȃ�" }

        # [���{��]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["���{��"]) "���{��"
        if( ${res} -eq $false ) { Write-Host "ERR:[���{��]��ԍ���������Ȃ�" }

        # [����]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["����"]) "����"
        if( ${res} -eq $false ) { Write-Host "ERR:[����]��ԍ���������Ȃ�" }

        # [���l]�Z���擾
        ${res} = getColumn ${cell} ([ref]$table_info["���l"]) "���l"
        if( ${res} -eq $false ) { Write-Host "ERR:[���l]��ԍ���������Ȃ�" }

        # ���͂�[�{�֐�]�Z���擾
        $input_row_head = $table_info["����"]["row"]
        $input_col_head = $table_info["����"]["col"]
        $input_row_tail = $table_info["�o��(���Ғl)"]["col"]
        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["���͖{�֐�"]) "�{�֐�"
        if( ${res} -eq $false ) { Write-Host "ERR:[���͖{�֐�]��ԍ���������Ȃ�" }

        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["���͊֐��R�[��"]) "�֐��R�[��"
        if( ${res} -eq $false ) { Write-Host "ERR:[���͊֐��R�[��]��ԍ���������Ȃ�" }


        # �o�͂�[�{�֐�]�Z���擾
        $input_row_head = $table_info["�o��(���Ғl)"]["row"]
        $input_col_head = $table_info["�o��(���Ғl)"]["col"]
        $input_row_tail = $table_info["���{��"]["col"]
        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["�o�͊O���ϐ�"]) "�O���ϐ�"
        if( ${res} -eq $false ) { Write-Host "ERR:[�o�͊O���ϐ�]��ԍ���������Ȃ�" }

        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["�o�͊֐��R�[��"]) "�֐��R�[��"
        if( ${res} -eq $false ) { Write-Host "ERR:[�o�͊֐��R�[��]��ԍ���������Ȃ�" }

        ${res} = getSubColumn ${cell}  $input_row_head  $input_col_head  $input_row_tail ([ref]$table_info["�o�͖{�֐�"]) "�{�֐�"
        if( ${res} -eq $false ) { Write-Host "ERR:[�o�͖{�֐�]��ԍ���������Ȃ�" }


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
            outConsole ("[No.${no_tmp}]�Z���F" + $table_info["No.${no_tmp}"]["row"] + ", " + $table_info["No.${no_tmp}"]["col"])

        }

        for( $no = 1; $no -lt 10; $no++ ){
            if( ! [bool]$table_info["No.${no}"] ) {
                break
            }
            #outConsole( "�t�@�C�����F" + $cell.Item( $table_info["No.${no}"]["row"], $table_info["�t�@�C��"]["col"] ).Text )
            #outConsole "hoge$no"
            $out_file = $cell.Item( $table_info["No.${no}"]["row"], $table_info["�t�@�C��"]["col"] ).Text
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

/* �������֐� */
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


	/***** �e�X�g�֐����s *****/
	nb_tim_cb_timeout(sigv);		


	/***** �o��(���Ғl) *****/
	/* �֐��R�[�� */
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
