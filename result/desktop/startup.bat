set PATH=%CD%\jre\bin;%PATH%
call setenv.bat
start javaw -cp "atomskills.jar;lib/jetty/*;lib/*" application.Main