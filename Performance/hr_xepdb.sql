

--select * from employees where department_id in (select column_value from table(dbmsoutput_linesarray('100','200','300','400')));
ALTER SESSION SET optimizer_dynamic_sampling=4;
explain plan for
select * 
  from employees 
 where department_id in (
 select /*+ FIRST_ROWS DYNAMIC_SAMPLING (t 2) */ column_value 
  from table(dbmsoutput_linesarray('100','200','300','400')) t
  );
select * from table(dbms_xplan.display);

explain plan for
select * 
  from EMP_DETAILS_VIEW 
 where department_id in ('100','200','300','400')
;

--SELECT * FROM table(dbms_xplan.display(format=>'basic rows'));

select * from table(dbms_xplan.display(format=>'basic rows'));

select * from table(dbms_xplan.display);


select * 
  from EMP_DETAILS_VIEW 
  where department_id in (
 select column_value department_id
  from table(dbmsoutput_linesarray('100','200','300','400')) t
  );

explain plan for 
select * from EMP_DETAILS_VIEW where department_id in (
 select /*+ FIRST_ROWS */ column_value 
  from table(dbmsoutput_linesarray('100','200','300','400')) t
  );
  
  select * from table(dbms_xplan.display(format => 'basic rows'));
  
  create global temporary table gtt_ids (
  department_id    NUMBER(4)
  );
  
  insert into gtt_ids select /*+ FIRST_ROWS */ column_value 
  from table(dbmsoutput_linesarray('100','200','300','400')) t
 ;
  select * from gtt_ids;
  
/*

    numrows : Number of rows in the table.
    numblks : Number of blocks the table uses.  Note: This may also influence the rule-based optimizer behavior. (The RULE hint)
    avgrlen : The average row length for the table.

*/
  explain plan for select * from EMP_DETAILS_VIEW 
  where department_id in (select /*+ FIRST_ROWS */ department_id from gtt_ids t);
  
  explain plan for select * from EMP_DETAILS_VIEW 
  where department_id in (
 select /*+ FIRST_ROWS DYNAMIC_SAMPLING (t 2) */ to_number(column_value) dept_id 
  from table(dbmsoutput_linesarray('100','200','300','400')) t
  );
  
  select * from table(dbms_xplan.display(format=>'basic rows'));
  
  select * from table(dbms_xplan.display);
  
  
  
  
  