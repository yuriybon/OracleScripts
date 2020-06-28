
create or replace function grt_sfunc(agg_state point, el float8)
returns point
immutable
language plpgsql
as $$
declare
  greatest_sum float8;
  current_sum float8;
begin
 if el is null then
  return agg_state;
 end if; 
  if agg_state is null then
    agg_state := point(0,0);
  end if;
  current_sum := agg_state[0] + el;
  if agg_state[1] < current_sum then
    greatest_sum := current_sum;
  else
    greatest_sum := agg_state[1];
  end if;
  return point(current_sum, greatest_sum);
end;
$$;


create or replace function grt_finalfunc(agg_state point)
returns float8
immutable
strict
language plpgsql
as $$
begin
  return agg_state[1];
end;
$$;

drop aggregate greatest_running_total (float8);

create aggregate greatest_running_total (float8)
(
    sfunc = grt_sfunc,
    stype = point,
    finalfunc = grt_finalfunc
);


select greatest_running_total(amount order by id asc)
from entries;



select greatest_running_total(amount)
from entries;

select *
from entries;

create table lem_core_xref (
vendor_id varchar(32),
system_id varchar(8),
lem_id numeric,
party_name varchar(500)
);

create table lem_core (
lem_id numeric,
party_name varchar(500)
);


insert into lem_core_xref values('1','BBG',100,'BBG_PARTY');
insert into lem_core_xref values('14','TELEKURS',100,'TELEKURS_PARTY');
insert into lem_core_xref values('9','GLEIF',100,'GLEIF_PARTY');
commit;


insert into lem_core_xref values('1','BBG',200,'BBG_PARTY');
insert into lem_core_xref values('14','TELEKURS',200,'TELEKURS_PARTY');
insert into lem_core_xref values('9','GLEIF',200,'GLEIF_PARTY');
commit;

update lem_core_xref set party_name='GLEIF_PARTY2' where lem_id = 200 and system_id='GLEIF';
update lem_core_xref set party_name='BBG_PARTY2' where lem_id = 200 and system_id='BBG';
commit;

delete from lem_core_xref;
delete from lem_core;
commit;

select * from lem_core_xref;
select * from lem_core;


create type trust_value AS (
str_value VARCHAR,
trust INT,
system_id VARCHAR
);

create type trust_value AS (
str_value VARCHAR,
trust INT,
system_id VARCHAR
);

create or replace function iterate_trust_sfunc(agg_state trust_value, val varchar, trust float8, system_id varchar)
returns trust_value
immutable
language plpgsql
as $$
declare
  greatest_sum float8;
  current_sum float8;
begin
  if agg_state is null then
    agg_state.str_value := null;
    agg_state.trust := 0;
    agg_state.system_id := null;
  end if;

  if agg_state.trust < trust then
    agg_state.str_value := val;
    agg_state.trust := trust;
    agg_state.system_id := system_id;
  end if;
  return agg_state;
end;
$$;

create or replace function gtv_finalfunc(agg_state trust_value)
returns varchar
immutable
strict
language plpgsql
as $$
begin
  return agg_state.str_value;
end;
$$;

create aggregate gtv(varchar,float8,varchar)
(
    sfunc = iterate_trust_sfunc,
    stype = trust_value,
    finalfunc = gtv_finalfunc
);

create table if not exists lem_trusts (attr_id varchar(32), system_id varchar(8), trust numeric(3,0));

insert into lem_trusts values( 'PARTY_NAME','BBG',20);
insert into lem_trusts values( 'PARTY_NAME','TELEKURS',30);
insert into lem_trusts values( 'PARTY_NAME','GLEIF',50);
commit;


select lem_id, gtv(party_name,pn.trust,x.system_id) tv 
from lem_core_xref x
join lem_trusts pn on ( pn.attr_id = 'PARTY_NAME' and pn.system_id=x.system_id )
group by lem_id;


create schema lem_stg;
    
CREATE TABLE lem_stg.AUDIT(
   EMP_ID INT NOT NULL,
   ENTRY_DATE TEXT NOT NULL
);    

CREATE OR REPLACE FUNCTION auditlogfunc() RETURNS TRIGGER AS 
$lem_core_xref$
   BEGIN
            INSERT INTO lem_core (
                lem_id,
                party_name
            )
                SELECT
                    lem_id,
                    gtv(party_name,pn.trust,x.system_id) party_name
                FROM
                    lem_core_xref x
                    JOIN lem_trusts pn ON ( pn.attr_id = 'PARTY_NAME'
                                            AND pn.system_id = x.system_id )
                WHERE
                    x.lem_id in (select ins_t.lem_id from ins_t)
                GROUP BY
                    lem_id
        ON CONFLICT (lem_id) DO UPDATE
        SET party_name = excluded.party_name;    
      RETURN NEW;
   END;
$lem_core_xref$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_lem_core() RETURNS TRIGGER AS 
$lem_core_xref$
   BEGIN
            INSERT INTO lem_core (
                lem_id,
                party_name
            )
                SELECT
                    lem_id,
                    gtv(party_name,pn.trust,x.system_id) party_name
                FROM
                    lem_core_xref x
                    JOIN lem_trusts pn ON ( pn.attr_id = 'PARTY_NAME'
                                            AND pn.system_id = x.system_id )
                WHERE
                    x.lem_id in (select ins_t.lem_id from ins_t union select u.lem_id from upd_t u)
                GROUP BY
                    lem_id
        ON CONFLICT (lem_id) DO UPDATE
        SET party_name = excluded.party_name;    
      RETURN NEW;
   END;
$lem_core_xref$ LANGUAGE plpgsql;

    

CREATE TRIGGER example_lem_core_xref 
  AFTER INSERT ON lem_core_xref
  REFERENCING NEW TABLE AS ins_t
--  FOR EACH STATEMENT
  FOR EACH STATEMENT
  EXECUTE PROCEDURE auditlogfunc();    

CREATE TRIGGER upd_lem_core_xref_trg
  AFTER UPDATE ON lem_core_xref
  REFERENCING NEW TABLE AS ins_t OLD TABLE upd_t
--  FOR EACH STATEMENT
  FOR EACH STATEMENT
  EXECUTE PROCEDURE update_lem_core();    


select * from lem_stg.audit;

drop TRIGGER example_lem_core_xref on lem_core_xref;

select version();
    

