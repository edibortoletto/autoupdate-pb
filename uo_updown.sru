$PBExportHeader$uo_updown.sru
$PBExportComments$�ļ�����
forward
global type uo_updown from nonvisualobject
end type
end forward

global type uo_updown from nonvisualobject
end type
global uo_updown uo_updown

type variables
public:
end variables

forward prototypes
public function boolean uf_zip (string as_path, string as_name)
public function boolean uf_zip_onefile (string as_sname, string as_fname)
public function integer uf_unzip_onefile (string as_zippathfile, string as_file, string as_dpathfile)
public function boolean uf_delfile (string as_pathname)
public function boolean uf_upfile (string as_systemname, string as_filename, string as_version)
public function long uf_unzip (string as_name, string as_path)
public function boolean uf_downfile (ref string as_filename)
end prototypes

public function boolean uf_zip (string as_path, string as_name);/*
uf_unzip
��Σ�as_pathѹ��·��
      as_nameѹ���ļ���
���Σ�true false		
ע:ͬ���ļ��ᱻ�滻
*/
int li_ren 
// li_ren>0 �����ļ���, li_len = 0 ѹ���ļ���δ���ļ�, li_len < 0 ��ѹʧ��
li_ren = MyZip_AddDirectory(as_path,as_name)
if li_ren > 0 then
	return true
else
	return false
end if
end function

public function boolean uf_zip_onefile (string as_sname, string as_fname);/*
in: ����·����Դ�ļ���
    ѹ������ļ���
out: �棬��
*/

int li_len
li_len = MyZip_AddFile(as_sname,as_fname)
if li_len > 0 then
	return true
else
	return false
end if
end function

public function integer uf_unzip_onefile (string as_zippathfile, string as_file, string as_dpathfile);/*
in:  as_zippathfile  ѹ���ļ�(ȫ·��)
     as_file      ��Ҫ������ļ�(������·��)
	  as_dpathfile Ŀ���ļ�(ȫ·��)
out: > 0 ��ѹ��ȷ
     = 0 ѹ���ļ���δ����as_file
	  < 0 ��ѹʧ��
*/
int li_len
li_len = MyZip_ExtractFile(as_zippathfile,as_file,as_dpathfile)
return li_len
end function

public function boolean uf_delfile (string as_pathname);boolean lbl_re
lbl_re = FileDelete(as_pathname) //as_pathname ���Դ�·��
return lbl_re
end function

public function boolean uf_upfile (string as_systemname, string as_filename, string as_version);/*
as_systemname ѹ���ļ���������·��
as_filename   ѹ���ļ�������·��
as_version    �汾��
*/
string ls_name,sql
blob lb_file,lb_read
long ll_len,loops,i,ll_filenum
ll_len = FileLength(as_filename)//ȡ���ļ���С
lb_file = blob('')
loops = Ceiling(ll_len/32765)
//ll_FileNum = FileOpen('e:\�Զ���������\update.zip', StreamMode!, Read!, Shared! )
ll_FileNum = FileOpen(as_filename, StreamMode!, Read!, Shared! )
if ll_FileNum < 1 then
	messagebox('����','���ļ�' + as_filename + '����' + string(ll_FileNum),stopsign!)
	fileclose(ll_FileNum)
	return false
end if

FOR i = 1 to loops
	FileRead(ll_FileNum, lb_read)
	lb_file = lb_file + lb_read			
NEXT

FileClose(ll_FileNum)
sql = "delete share..sys_verfile where systemname = '" + as_systemname +"'"
execute immediate :sql;
gf_commit()
ls_name = as_systemname + as_version+ '.zip'
insert into share..sys_verfile (systemname,version,filename,filesize) 
values (:as_systemname,:as_version,:ls_name,:ll_len);
gf_commit()
UPDATEBLOB share.dbo.sys_verfile SET filebody = :lb_file
	WHERE systemname = :as_systemname and filename = :ls_name ;
gf_commit()

return true
end function

public function long uf_unzip (string as_name, string as_path);/*
uf_unzip
��Σ�as_path��ѹ·��
      as_name��ѹ�ļ���
���Σ���ѹ�ļ���		
*/
int li_ren 
// li_ren>0 �����ļ���, li_len = 0 ѹ���ļ���δ���ļ�, li_len < 0 ��ѹʧ��
li_ren = MyZip_ExtractFileAll(as_name,as_path)
return li_ren
end function

public function boolean uf_downfile (ref string as_filename);string ls_systemName,ls_file,ls_path,ls_pathname,ls_ver
blob lb_file,lb_temp
long ll_filenum,i,loops,ll_len //���,ѭ������,ѭ��ֵ,�ļ�����
ls_systemname =gs_systemname
select filename,version into :ls_file,:ls_ver from share..sys_verfile
where  systemname=:ls_systemname;
as_filename  = ls_file
gs_ver = ls_ver
//ȡ��ǰ����·��
ls_path= gs_dir //ȡ����·���磺"d:\��������"
ls_path += '\'
ls_pathname = ls_path + ls_file //·�� + �ļ���

if isvalid(w_down) then 
	w_down.st_1.text='���ڴӷ�������ȡ�ļ������Ժ򡭡�'
end if

//��ȡѹ���ļ����ŵ�lb_file����
SelectBlob filebody Into :lb_file From share.dbo.sys_verfile
Where systemname = :ls_systemname And version = :ls_ver;
if isvalid(w_down) then 
	w_down.st_1.text='��ȡ�ļ���ϡ���'
end if
ll_len = len(lb_file)
loops = ceiling(ll_len / 32765)
//�����ļ�
ll_FileNum = FileOpen(ls_pathname,StreamMode!, Write!, LockReadWrite!, Replace!) //s_path+'\'+
If ll_FileNum < 1 Or IsNull(ll_FileNum) Then
	MessageBox('����','д���ļ�'+ls_pathname+'����',stopsign!)
	FileClose(ll_FileNum)
	return false 
End If
//����ļ�����32765,�ж���Ҫ���ٴζ�ȡ
for i = 1 to loops //��ȡ����
	lb_temp = BlobMid(lb_file,1 + (i - 1)*32765,32765)
	filewrite(ll_filenum,lb_temp)
next
FileClose(ll_FileNum)

return true

end function

on uo_updown.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_updown.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

