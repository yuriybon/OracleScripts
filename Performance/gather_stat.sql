SET SERVEROUTPUT ON
BEGIN
    runstats_pkg.rs_start;
    exec_compiled;
    runstats_pkg.rs_middle;
    exec_dynamic_col;
    runstats_pkg.rs_stop(10);
   --runstats_pkg.rs_stop('memory');
END;