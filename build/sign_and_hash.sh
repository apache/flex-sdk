#!/bin/sh
#------------------------------------------------------------------------------
#   Copyright 2004 The Apache Software Foundation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#------------------------------------------------------------------------------
# $Id$
#
# Creates detached ascii signatures and md5 hashes for each of the files in the
# current directory.
#
# Also verifies the signatures.
#
# For each file in the current directory, two new files are created:
#
#   <name>.asc -- ascii-armored detached PGP digital signature
#   <name>.md5 -- md5 hash (checksum)
#
# where <name> is the name of the file, not including file path.  
# 
# For example, foo-1.0-src.tar.gz in the current directory will result in 
# foo-1.0-src.tar.gz.asc and foo-1.0-src.tar.gz.md5 added to the current 
# directory. 
#
# Deletes any .asc or .md5 files in the current directory before processing
# and does NOT recurse subdirectories.
#
# Assumes that you have a pgp id and keypair set up and prompts for the 
# passphrase for each signature created.
#
# usage:
#     sign_and_hash.sh
#
# requires:
#    gpg
#    md5sum
#------------------------------------------------------------------------------
`rm -f *.asc`
`rm -f *.md5`
for file in *.zip; do
    if [ -f "$file" ]; then
        #md5sum -b $file > ${file}.md5
        md5 -q $file > ${file}.md5
        gpg --armor --output ${file}.asc --detach-sig $file
        gpg --verify ${file}.asc $file
    fi
done
for file in *.gz; do
    if [ -f "$file" ]; then
         #md5sum -b $file > ${file}.md5
         md5 -q $file > ${file}.md5
         gpg --armor --output ${file}.asc --detach-sig $file
         gpg --verify ${file}.asc $file
    fi
done
