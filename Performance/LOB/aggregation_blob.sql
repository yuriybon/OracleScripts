CREATE OR REPLACE TYPE t_string_agg AS OBJECT
(
  g_string  VARCHAR2(32767),
  g_clob clob,
  g_length number,
  g_clob_length number,
  
  STATIC FUNCTION ODCIAggregateInitialize(sctx  IN OUT  t_string_agg)
    RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateIterate(self   IN OUT  t_string_agg,
                                       value  IN      VARCHAR2 )
     RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateTerminate(self         IN   t_string_agg,
                                         returnValue  OUT  CLOB,
                                         flags        IN   NUMBER)
    RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateMerge(self  IN OUT  t_string_agg,
                                     ctx2  IN      t_string_agg)
    RETURN NUMBER
);
/


CREATE OR REPLACE TYPE BODY t_string_agg IS
  STATIC FUNCTION ODCIAggregateInitialize(sctx  IN OUT  t_string_agg)
    RETURN NUMBER IS
  BEGIN
    sctx := t_string_agg(NULL,NULL,0,0);
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateIterate(self   IN OUT  t_string_agg,
                                       value  IN      VARCHAR2 )
    RETURN NUMBER IS
  BEGIN
   if self.g_length+length(value) > 32767 then
     dbms_lob.writeappend(self.g_clob,self.g_length,self.g_string);
     self.g_clob_length := self.g_clob_length + self.g_length;
     self.g_string:=value;
     self.g_length:=length(value);
   else
     self.g_string:=self.g_string||','||value;
     self.g_length:=self.g_length+length(value);
   end if; 
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateTerminate(self         IN   t_string_agg,
                                         returnValue  OUT  CLOB,
                                         flags        IN   NUMBER)
    RETURN NUMBER IS
  BEGIN
    case 
    when self.g_length != 0 and self.g_clob_length = 0 then
        returnValue := self.g_string;
    when self.g_length = 0 and self.g_clob_length != 0 then
        returnValue := self.g_clob;
    when self.g_length != 0 and self.g_clob_length != 0 then
        dbms_lob.writeappend(self.g_clob,self.g_length,self.g_string);
        returnValue := self.g_clob;
    else
       returnValue := null;
    end case;

    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateMerge(self  IN OUT  t_string_agg,
                                     ctx2  IN      t_string_agg)
    RETURN NUMBER IS
  BEGIN
    SELF.g_string := SELF.g_string || ctx2.g_string;
    RETURN ODCIConst.Success;
  END;
END;
/

