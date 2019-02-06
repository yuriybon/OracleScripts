-- select * from user_objects;
--explain plan for select * from dba_objects;
--
--select * from table(dbms_xplan.display(format => 'cost'));
--select * from table(dbms_xplan.display(format => 'rows'));


--select * from EMP_DETAILS_VIEW ;

declare 
 det_view EMP_DETAILS_VIEW%ROWTYPE;
begin
 dbms_hprof.start_profiling(location=>'IO', filename=>'wrap.txt');
 select A.* bulk collect into det_view from EMP_DETAILS_VIEW A;
 dbms_hprof.stop_profiling;
end;
/
