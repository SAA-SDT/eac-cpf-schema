@echo off

set parameters=-Xmx1024m
set CP=-cp ..\vendor\SaxonHE10-1J\saxon-he-10.1.jar
set jing=..\vendor\jing-20181222\bin\jing.jar
set trang=..\vendor\trang-20091111\trang.jar

:: check if Java is installed
where java >nul 2>nul
if %errorlevel%==1 (
    @echo Java not found in path.
    exit
)


rem still need to update for when we switch between EAD / EAC transformations, which we can do by passing parameters 

@echo Getting started.

java %parameters% %CP% net.sf.saxon.Transform -t -xsl:transformations\prep-source-schema-files.xsl -it 

java -jar %jing% -s ..\source\modules\do-not-edit-directly\eac\eac-source.rng > ..\xml-schemas\eac-cpf\cpf.rng

java %parameters% %CP% net.sf.saxon.Transform -s:..\xml-schemas\eac-cpf\cpf.rng -xsl:transformations\add-comments-and-metadata.xsl -o:..\xml-schemas\eac-cpf\cpf.rng -warnings:silent

java -jar %trang% -o disable-abstract-elements -o any-process-contents=lax -o any-attribute-process-contents=lax ..\xml-schemas\eac-cpf\cpf.rng ..\xml-schemas\eac-cpf\cpf.xsd

java %parameters% %CP% net.sf.saxon.Transform -s:..\xml-schemas\eac-cpf\cpf.xsd -xsl:transformations\deglobalize-xsd.xsl -o:..\xml-schemas\eac-cpf\cpf.xsd -warnings:silent

@echo All done.

pause