CREATE TABLE EMPLOYEES2
AS
WITH v1 AS (SELECT ROWNUM N FROM DUAL CONNECT BY LEVEL <= 10000)
SELECT ROWNUM AS EMPLOYEE_ID,
       DBMS_RANDOM.STRING ('a', 10) AS EMPLOYEE_NAME,
       TO_DATE(TRUNC(DBMS_RANDOM.VALUE(2451911,2455928)),'J') AS HIRE_DATE,
       trunc(dbms_random.value(10000,20000),2) as salary
  FROM v1
WHERE rownum <= 5000;
 
--ALTER TABLE employees2 ADD session_id NUMBER;

--dbms_parallel_execute

BEGIN
 
   dbms_parallel_execute.create_task
   (
      task_name => 'MyTask',
      comment => 'this is my task'
   );
 
END;
/

BEGIN
   dbms_parallel_execute.create_chunks_by_rowid
   (
      task_name   => 'MyTask',
      table_owner => USER,
      table_name  => 'EMPLOYEES2',
      by_row      => TRUE,
      chunk_size  => 1000
   );
 
END;
/

begin
   dbms_parallel_execute.create_chunks_by_number_col
   (
      task_name   => 'MyTask',
      table_owner => USER,
      table_name  => 'EMPLOYEES2',
      table_column => 'EMPLOYEE_ID',
      chunk_size  => 1000
   );
end;
/


SELECT *
  FROM user_parallel_execute_chunks
 ORDER BY chunk_id;


begin
 dbms_parallel_execute.drop_chunks(task_name => 'MyTask');
end;
/


BEGIN
 
   dbms_parallel_execute.run_task
   (
      task_name      => 'MyTask',
      sql_stmt       => 'BEGIN update_emps(:start_id, :end_id ); END;',
      language_flag  => DBMS_SQL.NATIVE,
      parallel_level => 4
   );
 
END;
/

https://oracle-base.com/articles/11g/dbms_parallel_execute_11gR2
