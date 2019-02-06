BEGIN
  /* Start profiling.
     Write raw profiler output to file test.trc in a directory
     that is mapped to directory object PLSHPROF_DIR
     (see note following example). */

  DBMS_HPROF.START_PROFILING('PLSHPROF_DIR', 'test.trc');
END;
/

--SELECT * FROM   TABLE(ccard(collection_type('A','B','C')));
explain plan for SELECT * FROM TABLE(ccard(ccard_ntt('A','B','C'))) t;

explain plan for SELECT   /*+ DYNAMIC_SAMPLING( t  2 )   */ * FROM TABLE(dbmsoutput_linesarray('A','B','C')) t;

select * from table(dbms_xplan.display(format=> 'basic rows'));

select * from user_data;



set serveroutput on
declare
 v_row users%rowtype;
begin
  runstats_pkg.rs_start;
  select * into v_row from users;
  runstats_pkg.rs_middle;  
  select * into v_row from users;
  runstats_pkg.rs_stop(100);  
end;
/

  
