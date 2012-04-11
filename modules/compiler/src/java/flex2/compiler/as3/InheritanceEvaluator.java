/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.as3;

import flash.swf.tools.as3.EvaluatorAdapter;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.Name;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import macromedia.asc.parser.BinaryClassDefNode;
import macromedia.asc.parser.BinaryInterfaceDefinitionNode;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.IdentifierNode;
import macromedia.asc.parser.ImportDirectiveNode;
import macromedia.asc.parser.InterfaceDefinitionNode;
import macromedia.asc.parser.LiteralStringNode;
import macromedia.asc.parser.MemberExpressionNode;
import macromedia.asc.parser.PackageDefinitionNode;
import macromedia.asc.parser.PackageIdentifiersNode;
import macromedia.asc.parser.PackageNameNode;
import macromedia.asc.parser.QualifiedIdentifierNode;
import macromedia.asc.semantics.NamespaceValue;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

/**
 * This Evaluator fills in the CompilationUnit's inheritance Set.
 * It's meant to be used during the parse1 phase, so that all of a
 * CompilationUnit's inheritance dependencies will be parsed before
 * the parse2 phase begins.  TypeAnalyzer requires this to work
 * properly.
 *
 * @author Paul Reilly
 @ @see flex2.compiler.as3.binding.TypeAnalyzer
 */
public class InheritanceEvaluator extends EvaluatorAdapter
{
    private Set<String> imports;
    private Map<String, String> qualifiedImports;
    private List<String> inheritanceNames = new ArrayList<String>();
    private Set<Name> inheritanceMultiNames = new HashSet<Name>();
    private List<MultiName> definitionMultiNames = new ArrayList<MultiName>();

    public InheritanceEvaluator()
    {
        addImport("");
    }

    private void addImport(String importName)
    {
        assert importName != null;

        if (imports == null)
        {
            imports = new TreeSet<String>();
        }

        imports.add(importName);
    }

    private void addQualifiedImport(String localPart, String namespace)
    {
        assert (localPart != null) && (localPart.length() > 0) && (namespace != null);

        if (qualifiedImports == null)
        {
            qualifiedImports = new TreeMap<String, String>();
        }

        qualifiedImports.put(localPart, namespace);
    }

    public Value evaluate(Context context, BinaryInterfaceDefinitionNode binaryInterfaceDefinition)
    {
        if ((binaryInterfaceDefinition.cframe != null) &&
            (binaryInterfaceDefinition.cframe.name != null) &&
            (binaryInterfaceDefinition.cframe.name.ns != null) &&
            (binaryInterfaceDefinition.cframe.name.ns.name.length() > 0))
        {
            addImport(binaryInterfaceDefinition.cframe.name.ns.name);
        }

        return evaluateInterface(binaryInterfaceDefinition);
    }

    public Value evaluate(Context context, BinaryClassDefNode binaryClassDefinition)
    {
        if ((binaryClassDefinition.cframe != null) &&
            (binaryClassDefinition.cframe.name != null) &&
            (binaryClassDefinition.cframe.name.ns != null) &&
            (binaryClassDefinition.cframe.name.ns.name.length() > 0))
        {
            addImport(binaryClassDefinition.cframe.name.ns.name);
        }

        return evaluate(context, (ClassDefinitionNode) binaryClassDefinition);
    }

    public Value evaluate(Context context, ClassDefinitionNode classDefinition)
    {
        if (classDefinition.pkgdef != null)
        {
            processImports(classDefinition.pkgdef.statements.items.iterator());

            PackageNameNode packageName = classDefinition.pkgdef.name;

            if (packageName != null)
            {
                PackageIdentifiersNode packageIdentifiers = packageName.id;

                if ((packageIdentifiers != null) && (packageIdentifiers.pkg_part != null))
                {
                    definitionMultiNames.add(new MultiName(packageIdentifiers.pkg_part, classDefinition.name.name));
                }
            }
        }

        if (classDefinition.statements != null)
        {
            processImports(classDefinition.statements.items.iterator());
        }

        // process extends
        if (classDefinition.baseclass != null)
        {
            if (classDefinition.baseclass instanceof MemberExpressionNode)
            {
                MemberExpressionNode memberExpression = (MemberExpressionNode) classDefinition.baseclass;

                if (memberExpression.selector != null)
                {
                    IdentifierNode identifier = memberExpression.selector.getIdentifier();
                    String baseClassName = toString(identifier);
                    inheritanceNames.add(baseClassName);
                }
            }
            else if (classDefinition.baseclass instanceof LiteralStringNode)
            {
                String baseClassName = ((LiteralStringNode) classDefinition.baseclass).value;
                inheritanceNames.add(baseClassName);
            }
            else
            {
                assert false;
            }
        }
        else
        {
        	inheritanceNames.add(":Object");
        }

        // process interfaces
        if (classDefinition.interfaces != null)
        {
            Iterator iterator = classDefinition.interfaces.items.iterator();

            while ( iterator.hasNext() )
            {
                MemberExpressionNode memberExpression = (MemberExpressionNode) iterator.next();

                if (memberExpression.selector != null)
                {
                    IdentifierNode identifier = memberExpression.selector.getIdentifier();
                    String interfaceName = toString(identifier);

                    if ((identifier.ref != null) && (identifier.ref.namespaces != null))
                    {
                        NamespaceValue namespaceValue = (NamespaceValue) identifier.ref.namespaces.get(0);
                        if (namespaceValue.name.length() > 0)
                        {
                            inheritanceMultiNames.add(new MultiName(namespaceValue.name, interfaceName));
                        }
                        else
                        {
                            inheritanceNames.add(interfaceName);
                        }
                    }
                    else
                    {
                        inheritanceNames.add(interfaceName);
                    }
                }
            }
        }

        return null;
    }

    public Value evaluate(Context context, ImportDirectiveNode importDirective)
    {
        if (importDirective.name.id.def_part.length() == 0)
        {
            addImport(importDirective.name.id.pkg_part);
        }
        else
        {
            addQualifiedImport(importDirective.name.id.def_part,
                               importDirective.name.id.pkg_part);
        }
        
        return null;
    }

    public Value evaluate(Context context, InterfaceDefinitionNode interfaceDefinition)
    {
        return evaluateInterface(interfaceDefinition);
    }

    public Value evaluate(Context cx, PackageDefinitionNode packageDefinition)
    {
        PackageNameNode packageName = packageDefinition.name;

        if (packageName != null)
        {
            PackageIdentifiersNode packageIdentifiers = packageName.id;
            if ((packageIdentifiers != null) && (packageIdentifiers.pkg_part != null))
            {
                addImport(packageIdentifiers.pkg_part);
            }
        }

        return null;
    }

    private Value evaluateInterface(ClassDefinitionNode interfaceDefinition)
    {
        if (interfaceDefinition.pkgdef != null)
        {
            processImports(interfaceDefinition.pkgdef.statements.items.iterator());

            PackageNameNode packageName = interfaceDefinition.pkgdef.name;

            if (packageName != null)
            {
                PackageIdentifiersNode packageIdentifiers = packageName.id;

                if ((packageIdentifiers != null) && (packageIdentifiers.pkg_part != null))
                {
                    definitionMultiNames.add(new MultiName(packageIdentifiers.pkg_part, interfaceDefinition.name.name));
                }
            }
        }

        if (interfaceDefinition.statements != null)
        {
            processImports(interfaceDefinition.statements.items.iterator());
        }

        // process extends
        if (interfaceDefinition.baseclass != null)
        {
            if (interfaceDefinition.baseclass instanceof MemberExpressionNode)
            {
                MemberExpressionNode memberExpression = (MemberExpressionNode) interfaceDefinition.baseclass;

                if (memberExpression.selector != null)
                {
                    IdentifierNode identifier = memberExpression.selector.getIdentifier();
                    String baseInterfaceName = toString(identifier);
                    inheritanceNames.add(baseInterfaceName);
                }
            }
            else
            {
                assert false;
            }
        }
        else
        {
        	inheritanceNames.add(":Object");
        }

        // process interfaces: It would seem that ASC sometimes puts an interface's base
        // interface in the InterfaceDefinitionNode's interfaces list.  I'm not sure if
        // this is always the case, though.
        if (interfaceDefinition.interfaces != null)
        {
            Iterator iterator = interfaceDefinition.interfaces.items.iterator();

            while ( iterator.hasNext() )
            {
                MemberExpressionNode memberExpression = (MemberExpressionNode) iterator.next();

                if (memberExpression.selector != null)
                {
                    IdentifierNode identifier = memberExpression.selector.getIdentifier();
                    String baseInterfaceName = toString(identifier);

                    if ((identifier.ref != null) && (identifier.ref.namespaces != null))
                    {
                        NamespaceValue namespaceValue = (NamespaceValue) identifier.ref.namespaces.get(0);
                        if (namespaceValue.name.length() > 0)
                        {
                            inheritanceMultiNames.add(new MultiName(namespaceValue.name, baseInterfaceName));
                        }
                        else
                        {
                            inheritanceNames.add(baseInterfaceName);
                        }
                    }
                    else
                    {
                        inheritanceNames.add(baseInterfaceName);
                    }
                }
            }
        }

        return null;
    }

    public Set<Name> getInheritance()
    {
        if (inheritanceNames != null)
        {
            Iterator<String> iterator = inheritanceNames.iterator();

            while ( iterator.hasNext() )
            {
                String inheritanceName = iterator.next();

                MultiName inheritanceMultiName = getMultiName(inheritanceName);

                inheritanceMultiNames.add(inheritanceMultiName);
            }
        }

        // Remove definitions from the inheritance, so we don't run into circular
        // reference errors downstream.
        Iterator inheritanceIterator = inheritanceMultiNames.iterator();

        while ( inheritanceIterator.hasNext() )
        {
            MultiName inheritanceMultiName = (MultiName) inheritanceIterator.next();
            String[] namespaces = inheritanceMultiName.getNamespace();
            Iterator<MultiName> definitionIterator = definitionMultiNames.iterator();

            while ( definitionIterator.hasNext() )
            {
                MultiName definitionMultiName = definitionIterator.next();
                String namespace = definitionMultiName.getNamespace()[0];

                if (inheritanceMultiName.getLocalPart().equals(definitionMultiName.getLocalPart()))
                {
                    for (int i = 0; i < inheritanceMultiName.namespaceURI.length; i++)
                    {
                        if (namespaces[i].equals(namespace))
                        {
                            inheritanceIterator.remove();
                        }
                    }
                }
            }
        }

        return inheritanceMultiNames;
    }

    private MultiName getMultiName(String name)
    {
        assert name != null : "InheritanceEvaluator.getMultiName(): null name";

        MultiName result;

        int lastIndex = name.lastIndexOf(":");

        if (lastIndex < 0)
        {
            lastIndex = name.lastIndexOf(".");
        }

        if (lastIndex >= 0)
        {
            result = new MultiName(new String[] {name.substring(0, lastIndex)},
                                   name.substring(lastIndex + 1));
        }
        else if ((qualifiedImports != null) && qualifiedImports.containsKey(name))
        {
            result = new MultiName(new String[] {qualifiedImports.get(name)}, name);
        }
        else if (imports != null)
        {
            String[] namespaces = new String[imports.size()];
            imports.toArray(namespaces);
            result = new MultiName(namespaces, name);
        }
        else
        {
            result = new MultiName(name);
        }

        return result;
    }

    private void processImports(Iterator iterator)
    {
        while ( iterator.hasNext() )
        {
            Object node = iterator.next();

            if (node instanceof ImportDirectiveNode)
            {
                ImportDirectiveNode importDirective = (ImportDirectiveNode) node;

                if (importDirective.name.id.def_part.length() == 0)
                {
                    addImport(importDirective.name.id.pkg_part);
                }
                else
                {
                    addQualifiedImport(importDirective.name.id.def_part,
                                       importDirective.name.id.pkg_part);
                }
            }
        }
    }

    private String toString(IdentifierNode identifier)
    {
        String result = null;

        if (identifier instanceof QualifiedIdentifierNode)
        {
            QualifiedIdentifierNode qualifiedIdentifier = (QualifiedIdentifierNode) identifier;

            if (qualifiedIdentifier.qualifier instanceof LiteralStringNode)
            {
                LiteralStringNode literalString = (LiteralStringNode) qualifiedIdentifier.qualifier;
                result = literalString.value + ":" + qualifiedIdentifier.name;
            }
            else
            {
                assert false : ("Unhandled QualifiedIdentifierNode qualifier type: " +
                                qualifiedIdentifier.qualifier.getClass().getName());
            }
        }
        else
        {
            result = identifier.name;
        }

        return result;
    }
}
