grant dba TO HR;

grant SELECT_CATALOG_ROLE TO HR;

grant select on v_$instance to HR;

SELECT
  *
FROM
  DBA_TAB_PRIVS;


revoke dba from HR;
grant SELECT ANY DICTIONARY to HR;
grant SELECT ANY  to HR;

drop role stats_role;


--grant select on v$_mystat to HR;
--grant select on v$statname to stats_role;
--grant select on v$timer to stats_role;
--grant select on v$latch to stats_role;
--grant stats_role to HR;
--grant select_catalog_role to HR;


select * from v$latch;