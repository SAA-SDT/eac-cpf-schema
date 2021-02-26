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

java -jar %jing% -s ..\source\modules\extensible-version\eac\eac-source.rng > ..\xml-schemas\eac-cpf\eac.rng

java %parameters% %CP% net.sf.saxon.Transform -s:..\xml-schemas\eac-cpf\eac.rng -xsl:transformations\add-comments-and-metadata.xsl -o:..\xml-schemas\eac-cpf\eac.rng -warnings:silent

java -jar %trang% -o disable-abstract-elements -o any-process-contents=lax -o any-attribute-process-contents=lax ..\xml-schemas\eac-cpf\eac.rng ..\xml-schemas\eac-cpf\eac.xsd

java %parameters% %CP% net.sf.saxon.Transform -s:..\xml-schemas\eac-cpf\eac.xsd -xsl:transformations\deglobalize-xsd.xsl -o:..\xml-schemas\eac-cpf\eac.xsd -warnings:silent

java %parameters% %CP% net.sf.saxon.Transform -s:..\xml-schemas\eac-cpf\eac.xsd -xsl:transformations\update-namespace-prefix-in-xsd.xsl -o:..\xml-schemas\eac-cpf\eac.xsd -warnings:silent

rem temporary.  will change this later in case we need to process the schematron file before moving.

copy ..\source\modules\schematron\shared-rules.sch ..\xml-schemas\eac-cpf\schematron\eac.sch

@echo All done.

pause
