$PBExportHeader$aupdate.sra
$PBExportComments$Generated Application Object
forward
global type aupdate from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
uo_updown luo_updown
string gs_systemname, gs_file, gs_ver, gs_dir
end variables

global type aupdate from application
string appname = "aupdate"
end type
global aupdate aupdate

type prototypes
//�����ļ���ѹ������ѹ��
Function integer MyZip_AddFile(string SrcFile, string ZipFile) Library "MyZip.dll"
Function integer MyZip_ExtractFile(string ZipFile,string srcName, string DstName) Library "MyZip.dll"
//һ���ļ��е�ѹ������ѹ��
Function integer MyZip_AddDirectory(string SrcPath,string ZipFile) library "MyZip.dll"
Function integer MyZip_ExtractFileAll(string ZipFile,string PathName) library "MyZip.dll"
//���õ�ǰ·��
FUNCTION ulong GetCurrentDirectoryA(ulong BufferLen, ref string currentdir) LIBRARY "Kernel32.dll"
Function ulong SetCurrentDirectory(ref string lpPathName) LIBRARY "kernel32.dll" ALIAS FOR "SetCurrentDirectoryA"
end prototypes

type variables

end variables

forward prototypes
public function string uf_get_next_value (ref string as_parm, string as_sep)
public function boolean uf_get_parm (string as_parm, ref string as_sysname, ref string as_filename, ref transaction at_tran)
end prototypes

public function string uf_get_next_value (ref string as_parm, string as_sep);////////////////////////////////////////////////////////////////////////////////
//
// Event: uf_get_next_value()
//
// Access:
//
// Description:
//
// Arguments:
// 	reference	string	as_parm	//��ȡ��Դ�ַ���
// 	value    	string	as_sep 	//�ָ���
//
// Returns:  string
//
////////////////////////////////////////////////////////////////////////////////
//
// Revision History
//
// Version        Who         Date         Desc
//   1.0          MingXuan.Su     20090804      Initial version
//
////////////////////////////////////////////////////////////////////////////////

String ls_ret_value
Long	ll_pos

ll_pos = pos(as_parm, as_sep, 1)

if ll_pos > 0 then
	ls_ret_value = left(as_parm, ll_pos - 1 )
	as_parm = right(as_parm, len(as_parm) - ( ll_pos - 1 ) - len(as_sep) )
else
	ls_ret_value = as_parm
	as_parm = ''
end if

Return ls_ret_value
end function

public function boolean uf_get_parm (string as_parm, ref string as_sysname, ref string as_filename, ref transaction at_tran);////////////////////////////////////////////////////////////////////////////////
//
// Event: f_get_parm()
//
// Access:
//
// Description:
//
// Arguments:
// 	value    	string     	as_parm    	//�������	
// 	reference	string     	as_sysname 	//Ӧ�ó�����
// 	reference	string     	as_filename	//Ӧ�ó���exe�ļ���
// 	reference	transaction	at_tran    	//�������
//
// Returns:  (none)
//
////////////////////////////////////////////////////////////////////////////////
//
// Revision History
//
// Version        Who         Date         Desc
//   1.0          MingXuan.Su     20090804      Initial version
//
////////////////////////////////////////////////////////////////////////////////

Boolean lb_ret = True
Long ll_sep //ǰ��λ����ָ����ĳ���
String ls_sep //�ӵ���λ��ʼ����nλָ��ʹ�õķָ���
String ls_tmp

ll_sep = long(left(as_parm,2))
ls_sep = mid(as_parm, 3 ,ll_sep)

ls_tmp = right(as_parm, len(as_parm) - ll_sep - 2 )

at_tran.dbms		= uf_get_next_value(ls_tmp, ls_sep)
at_tran.database	= uf_get_next_value(ls_tmp, ls_sep)
at_tran.userid		= uf_get_next_value(ls_tmp, ls_sep)
at_tran.dbpass		= uf_get_next_value(ls_tmp, ls_sep)
at_tran.logid		= uf_get_next_value(ls_tmp, ls_sep)
at_tran.logpass	= uf_get_next_value(ls_tmp, ls_sep)
at_tran.servername	= uf_get_next_value(ls_tmp, ls_sep)
at_tran.AutoCommit	= False

as_sysname	= uf_get_next_value(ls_tmp, ls_sep)
as_filename	= uf_get_next_value(ls_tmp, ls_sep)

connect using at_tran;

IF at_tran.SQLCode <> 0 THEN
	
	lb_ret = false
	
	if POS(at_tran.sqlerrtext,'DBMS MSS')>0 then
		Messagebox('�������ݿ����ӳ���','��û�а�װMicrosoft SQL Server�ͻ������!'+&
		'~r~n~r~n������װ,�����޷������������ݿ�!',exclamation!)
	else
		Messagebox('�������ݿ����ӳ���','������Ϣ:'+at_tran.sqlerrtext,exclamation! )
	end if
end if

Return lb_ret
end function

on aupdate.create
appname="aupdate"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on aupdate.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;///////////////////////////////////////////////////
//  ��л�����Զ���������ԭ���ߵ�˼·����         //
//  ��л��˾sumx�ṩ���������                   //
///////////////////////////////////////////////////
string ls_parm
ls_parm = upper(CommandParm( )) //���������ȡ����ֵ "��������"

long l_len
gs_dir=space(100)
l_len=len(gs_dir)
GetCurrentDirectoryA(l_len,ref gs_dir)

if left(ls_parm,10) = '-DOWN PARM' then 
	//��ʹ�������ļ���ʹ�ô��ݵĲ���
	if not uf_get_parm( right(ls_parm, len(ls_parm) - 10), gs_systemname, gs_file, sqlca) then
		return
	end if
	ls_parm = '-DOWN'
end if

choose case ls_parm 
//	case '-AF' //�����ļ�ѹ��
//		//��ʱû���ã�����uo_updown ����uf_zip_onefile
//	case '-AD' //ѹ��һ��Ŀ¼
//		//��ʱû���ã�����uo_updown ����uf_zip
//	case '-EF' //�����ļ���ѹ
//		//��ʱû���ã�����uo_updown ����uf_unzip_onefile
//	case '-EA' //��ѹ��һ��Ŀ¼
//		//��ʱû���ã�����uo_updown ����uf_unzip
	case '-UP' //�ϴ�һ��ѹ���ļ�
		open(w_connect)
//		if f_connect() < 0  then //�������ݿ�
//			return
//		end if
//		open(w_up)
	case '-DOWN' //����һ��ѹ���ļ�
		open(w_down)
end choose
end event

