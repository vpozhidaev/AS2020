set PATH=%CD%\bin;%PATH%
call setenv.bat
set PGUSER=%db.user%
set PGPASSWORD=%db.password%
set PGCLIENTENCODING=UTF8
psql -U %PGUSER% -d %db.dbname% -h %db.host% -p %db.port% -f init.sql