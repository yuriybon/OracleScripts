/* dynamic SQL */
create or replace procedure exec_dynamic_col as
 v_sql varchar2(4000) := 'select V.* from EMP_DETAILS_VIEW  V where department_id in (';
 
 v_list_ids varchar2(4000);
 
 type t_list_from_view is table of EMP_DETAILS_VIEW%rowtype;
 list_from_view_nt t_list_from_view;
 
 v_cursor sys_refcursor;
-- v_tmp EMP_DETAILS_VIEW%rowtype;
begin 
 for i in 1..5
 loop 
  dbms_output.put_line(i);
  begin
      select LISTAGG(department_id, ', ') WITHIN GROUP (ORDER BY department_id) 
        into v_list_ids 
        from (select department_id from(select department_id from departments sample(50) a )where rownum <=10) ;
  exception
  when no_data_found then
   null;
  end; 
  
  execute immediate v_sql ||v_list_ids||') ' ;
  open v_cursor for v_sql ||v_list_ids||') ';
  fetch v_cursor bulk collect into list_from_view_nt;
  close v_cursor;
 end loop;
end;
/