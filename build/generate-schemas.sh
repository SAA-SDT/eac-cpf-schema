#!/bin/bash

set -eo pipefail

# needs to be run from within the build directory for now.
saxon="../vendor/SaxonHE10-1J/saxon-he-10.1.jar"
jing="../vendor/jing-20181222/bin/jing.jar"
trang="../vendor/trang-20091111/trang.jar"

echo "Getting started."

java -cp $saxon net.sf.saxon.Transform -t -xsl:transformations/prep-source-schema-files.xsl -it

java -jar $jing -s ../source/modules/extensible-version/eac/eac-source.rng > ../xml-schemas/eac-cpf/eac.rng

java -cp $saxon net.sf.saxon.Transform -s:../xml-schemas/eac-cpf/eac.rng -xsl:transformations/add-comments-and-metadata.xsl -o:../xml-schemas/eac-cpf/eac.rng

java -jar $trang -o disable-abstract-elements -o any-process-contents=lax -o any-attribute-process-contents=lax ../xml-schemas/eac-cpf/eac.rng ../xml-schemas/eac-cpf/eac.xsd

java -cp $saxon net.sf.saxon.Transform -s:../xml-schemas/eac-cpf/eac.xsd -xsl:transformations/deglobalize-xsd.xsl -o:../xml-schemas/eac-cpf/eac.xsd

java -cp $saxon net.sf.saxon.Transform -s:../xml-schemas/eac-cpf/eac.xsd -xsl:transformations/update-namespace-prefix-in-xsd.xsl -o:../xml-schemas/eac-cpf/eac.xsd

# temporary.  will change this later in case we need to process the schematron file before moving.
cp ../source/modules/schematron/shared-rules.sch ../xml-schemas/eac-cpf/schematron/eac.sch

echo "All done."
