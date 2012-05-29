#!/bin/sh

CLASSPATH=.:../../bin/classes

for jar in ../../build/lib/*.jar
do
    CLASSPATH=${CLASSPATH}:${jar}
done

java -cp ${CLASSPATH} org.apache.flex.forks.velocity.runtime.compiler.Compiler $1
