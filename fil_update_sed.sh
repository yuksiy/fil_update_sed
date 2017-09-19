#!/bin/sh

# ==============================================================================
#   機能
#     SEDスクリプトファイルを使用してファイルを更新する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2009-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 関数定義
######################################################################
USAGE() {
	cat <<- EOF 1>&2
		Usage:
		    fil_update_sed.sh [OPTIONS ...] SED_FILE SRC_FILE DEST_FILE[...]
		
		    SED_FILE  : Specify sed script file for updating source file.
		    SRC_FILE  : Specify source file.
		    DEST_FILE : Specify destination file.
		
		OPTIONS:
		    -Y (yes)
		       Suppresses prompting to confirm you want to remove an existing
		       destination file.
		    -m MODE
		       Specify mode of destination file.
		    -o OWNER
		       Specify owner of destination file.
		    --help
		       Display this help and exit.
	EOF
}

. cmd_v_function.sh
. yesno_function.sh

######################################################################
# 変数定義
######################################################################
FLAG_OPT_YES=FALSE
MODE=""
OWNER=""

######################################################################
# メインルーチン
######################################################################

# オプションのチェック
CMD_ARG="`getopt -o Ym:o: -l help -- \"$@\" 2>&1`"
if [ $? -ne 0 ];then
	echo "-E ${CMD_ARG}" 1>&2
	USAGE;exit 1
fi
eval set -- "${CMD_ARG}"
while true ; do
	opt="$1"
	case "${opt}" in
	-Y)	FLAG_OPT_YES=TRUE ; shift 1;;
	-m)	MODE="$2" ; shift 2;;
	-o)	OWNER="$2" ; shift 2;;
	--help)
		USAGE;exit 0
		;;
	--)
		shift 1;break
		;;
	esac
done

# 第1引数のチェック
if [ "$1" = "" ];then
	echo "-E Missing 1st argument" 1>&2
	USAGE;exit 1
else
	SED_FILE=$1
	# SEDファイルのチェック
	if [ ! -f "${SED_FILE}" ];then
		echo "-E SED_FILE not a file -- \"${SED_FILE}\"" 1>&2
		USAGE;exit 1
	fi
fi

# 第2引数のチェック
if [ "$2" = "" ];then
	echo "-E Missing 2nd argument" 1>&2
	USAGE;exit 1
else
	SRC_FILE=$2
	# 更新元ファイルのチェック
	if [ ! -f "${SRC_FILE}" ];then
		echo "-E SRC_FILE not a file -- \"${SRC_FILE}\"" 1>&2
		USAGE;exit 1
	fi
fi

# 第3引数のチェック
if [ "$3" = "" ];then
	echo "-E Missing 3rd argument" 1>&2
	USAGE;exit 1
fi

# 第1引数、第2引数をシフト
shift 2

#####################
# メインループ 開始 #
#####################

for arg in "$@" ; do
	# 既存の宛先ファイルの存在チェック
	if [ -e "${arg}" ];then
		echo "-W \"${arg}\" file exist." 1>&2
		# YES オプションが指定されていない場合
		if [ "${FLAG_OPT_YES}" = "FALSE" ];then
			# 処理実行確認
			echo "-Q Remove?" 1>&2
			YESNO
			# NO の場合
			if [ $? -ne 0 ];then
				echo "-W Skipping..." 1>&2
				continue
			fi
		fi
		# 既存の宛先ファイルの削除
		echo "-W Removing destination file..." 1>&2
		CMD_V "rm -f \"${arg}\""
		if [ $? -ne 0 ];then
			echo "-E Command has ended unsuccessfully." 1>&2
			exit 1
		fi
	fi

	# 宛先ファイルの新規作成
	echo "-I Creating new destination file..."
	CMD_V "fil_mk.sh ${MODE:+-m ${MODE} }${OWNER:+-o ${OWNER} }\"${arg}\""
	if [ $? -ne 0 ];then
		echo "-E Command has ended unsuccessfully." 1>&2
		exit 1
	fi

	# 宛先ファイルの更新
	echo "-I Updating destination file..."
	CMD_V "sed -f \"${SED_FILE}\" \"${SRC_FILE}\" > \"${arg}\""
	if [ $? -ne 0 ];then
		echo "-E Command has ended unsuccessfully." 1>&2
		exit 1
	fi

	# 関連ファイルのLL
	echo "-I Listing related files after work..."
	CMD_V "ls -ald \"${SED_FILE}\" \"${SRC_FILE}\" \"${arg}\""
done

# 作業終了後処理
exit 0

