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

package flex2.compiler.as3.binding;

import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.abc.MetaData;
import flex2.compiler.abc.Method;
import flex2.compiler.abc.Variable;
import flex2.compiler.as3.reflect.As3Class;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.QName;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.NamespaceValue;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.swf.tools.as3.EvaluatorAdapter;
import flash.util.Trace;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This utility class is used to build up rough type information after
 * the parse1 phase.  It's information isn't validated and it's only
 * meant to guide code generation for features like Bindable metadata.
 * For example, TypeAnalyzer helps us know if a class already
 * implements IEventDispatcher and if so, we don't have to add an
 * implementation for use by Bindable's generated setters.  It's used
 * in other places in the compiler and it should really be moved to
 * another package to reflect is more general use, something like
 * flex2.compiler.type. or flex2.compiler.as3.type.
 *
 * @author Paul Reilly
 */
public class TypeAnalyzer extends EvaluatorAdapter
{
	//	each subcompiler uses a delegate compilation unit for generated code
	private static final String DELEGATE_UNIT = "DelegateUnit";
	private static final String REQUIRED = "required";
	private static final String SKINPART = "SkinPart";
	private static final String TRUE = "true";

    private SymbolTable symbolTable;
    private Map<String, ClassInfo> classInfoMap;
    private Map<String, InterfaceInfo> interfaceInfoMap;
    private Info currentInfo;
    private String currentPackageName;

    public TypeAnalyzer(SymbolTable symbolTable)
    {
        this.symbolTable = symbolTable;
        classInfoMap = new HashMap<String, ClassInfo>();
        interfaceInfoMap = new HashMap<String, InterfaceInfo>();
    }

    private void analyzeInterfaces(Context context, List multiNames, Info info)
    {
        Iterator iterator = multiNames.iterator();

        while ( iterator.hasNext() )
        {
            MultiName multiName = (MultiName) iterator.next();

            analyzeInterface(context, multiName, info);
        }
    }

    public InterfaceInfo analyzeInterface(Context context, MultiName multiName, Info info)
    {
        InterfaceInfo interfaceInfo = null;

        QName qName = findQName(multiName);

        if (qName != null)
        {
            Source source = symbolTable.findSourceByQName(qName);

            interfaceInfo = interfaceInfoMap.get( qName.toString() );

            if (interfaceInfo == null)
            {
                CompilationUnit compilationUnit = source.getCompilationUnit();

                if (compilationUnit != null)
                {
                    AbcClass abcClass = compilationUnit.classTable.get( qName.toString() );

                    if (abcClass != null)
                    {
                        buildInterfaceInfo(context, qName, abcClass);
                    }
                    else
                    {
                        Node node = getNode(compilationUnit);

                        if (node != null)
                        {
                            Info oldInfo = currentInfo;
                            currentInfo = null;                            
                            node.evaluate(context, this);
                            currentInfo = oldInfo;
                        }
                        else
                        {
                            assert false : "Compilation unit had no type info and after parsing has no syntax tree";
                        }
                    }
                }

                interfaceInfo = interfaceInfoMap.get( qName.toString() );
            }

            // The interfaceInfo can be null if there was a missing import.
            if (interfaceInfo != null)
            {
                info.addInterfaceInfo(interfaceInfo);
            }
            else if (Trace.binding)
            {
                Trace.trace("TypeAnalyzer.analyzeInterfaces: unresolved qName " + qName);
            }                
        }
        else
        {
            if (Trace.binding)
            {
                Trace.trace("TypeAnalyzer.analyzeInterfaces: unresolved multiName " + multiName);
            }
        }

        return interfaceInfo;
    }

    private void analyzeBaseClass(Context context, MultiName multiName, ClassInfo classInfo)
    {
        ClassInfo baseClassInfo = analyzeClass(context, multiName);

        if (baseClassInfo != null)
        {
            classInfo.setBaseClassInfo(baseClassInfo);
        }
    }

    /**
     *
     */
    public ClassInfo analyzeClass(Context context, MultiName multiName)
    {
        ClassInfo classInfo = null;

        QName qName = findQName(multiName);

        if (qName != null)
        {
            classInfo = classInfoMap.get( qName.toString() );

            if (classInfo == null)
            {
                Source source = symbolTable.findSourceByQName(qName);

                assert source != null : "no source for qname '" + qName + "', even though multiname was resolved";

                CompilationUnit compilationUnit = source.getCompilationUnit();

                AbcClass abcClass = compilationUnit.classTable.get( qName.toString() );

                if (abcClass != null)
                {
                    buildClassInfo(context, qName, abcClass);
                }
                else
                {
                    Node node = getNode(compilationUnit);

                    if (node != null)
                    {
                        Info oldInfo = currentInfo;
                        currentInfo = null;
                        node.evaluate(context, this);
                        currentInfo = oldInfo;
                    }
                    else if (Trace.error)
                    {
                        // This can happen when an error, like base class not found, happens.
                        Trace.trace("Compilation unit had no type info and after parsing has no syntax tree: qname = '" +
                                    qName.toString() + "'");
                    }
                }

                classInfo = classInfoMap.get( qName.toString() );
            }
        }
        else
        {
            if (Trace.binding)
            {
                Trace.trace("TypeAnalyzer.analyzeBaseClass: unresolved multiName " + multiName);
            }
        }

        return classInfo;
    }

    private void analyzeBaseInterface(Context context, MultiName multiName, InterfaceInfo interfaceInfo)
    {
        QName qName = findQName(multiName);

        if (qName != null)
        {
            Source source = symbolTable.findSourceByQName(qName);

            InterfaceInfo baseInterfaceInfo = interfaceInfoMap.get( qName.toString() );

            if (baseInterfaceInfo == null)
            {
                CompilationUnit compilationUnit = source.getCompilationUnit();

                AbcClass abcClass = null;

                if (compilationUnit != null)
                {
                    abcClass = compilationUnit.classTable.get( qName.toString() );

                    if (abcClass != null)
                    {
                        buildInterfaceInfo(context, qName, abcClass);
                    }
                }

                if (abcClass == null)
                {
                    Node node = getNode(compilationUnit);
                    
                    if (node != null)
                    {
                        Info oldInfo = currentInfo;
                        currentInfo = null;
                        node.evaluate(context, this);
                        currentInfo = oldInfo;
                    }
                    else
                    {
                        assert false : "Compilation unit had no type info and after parsing has no syntax tree";
                    }
                }

                baseInterfaceInfo = interfaceInfoMap.get( qName.toString() );
            }

            // The baseInterfaceInfo can be null if there was a missing import.
            if (baseInterfaceInfo != null)
            {
                interfaceInfo.setBaseInterfaceInfo(baseInterfaceInfo);
            }
            else if (Trace.binding)
            {
                Trace.trace("TypeAnalyzer.analyzeInterfaces: unresolved qName " + qName);
            }                
        }
        else
        {
            if (Trace.binding)
            {
                Trace.trace("TypeAnalyzer.analyzeBaseInterface: unresolved multiName " + multiName);
            }
        }
    }

    private void buildClassInfo(Context context, QName qName, AbcClass abcClass)
    {
        ClassInfo classInfo = new ClassInfo( abcClass.getName() );

        if (currentPackageName != null)
        {
            currentInfo.addImport(currentPackageName);
        }

        classInfoMap.put(qName.toString(), classInfo);

        String superTypeName = abcClass.getSuperTypeName();

        if (superTypeName != null)
        {
            classInfo.setBaseClassName(superTypeName);

            analyzeBaseClass(context, classInfo.getBaseClassMultiName(), classInfo);
        }

        String[] interfaceNames = abcClass.getInterfaceNames();

        if (interfaceNames != null)
        {
            for (int i = 0; i < interfaceNames.length; i++)
            {
                classInfo.addInterfaceName(interfaceNames[i]);
            }

            analyzeInterfaces(context, classInfo.getInterfaceMultiNames(), classInfo);
        }

        processMembers(abcClass, classInfo);
    }

    private void processMembers(AbcClass abcClass, ClassInfo classInfo)
    {
        Iterator<Method> meth_iter= abcClass.getMethodIterator();

        while(meth_iter.hasNext())
        {
            classInfo.addFunction(meth_iter.next().getQName());
        }

        Iterator<Method> get_iter = abcClass.getGetterIterator();

        while(get_iter.hasNext())
        {
            Method getter = get_iter.next();
            QName getterName = getter.getQName();
            classInfo.addGetter(getterName);

            processSkinPartMetaData(getter.getMetaData(SKINPART), classInfo, getterName);
        }

        Iterator<Method> set_iter = abcClass.getSetterIterator();

        while(set_iter.hasNext())
        {
            classInfo.addSetter(set_iter.next().getQName());
        }

        Iterator<Variable> var_iter = abcClass.getVarIterator();
        while (var_iter.hasNext())
        {
            Variable variable = var_iter.next();
            QName varName = variable.getQName();
            classInfo.addVariable(varName);

            processSkinPartMetaData(variable.getMetaData(SKINPART), classInfo, varName);
        }
    }

    private void processSkinPartMetaData(List<MetaData> metaData, ClassInfo classInfo, QName qname)
    {
    	if (metaData != null)
        {
    		for (MetaData skinPart : metaData)
            {
    			String sRequired = skinPart.getValue(REQUIRED);
                boolean required = ((sRequired != null) && sRequired.equalsIgnoreCase(TRUE)) ? true : false;
                classInfo.addSkinPart(qname.getLocalPart(), required);
            }
        }
    }

    private void buildInterfaceInfo(Context context, QName qName, AbcClass abcClass)
    {
        InterfaceInfo interfaceInfo = new InterfaceInfo( abcClass.getName() );

        interfaceInfoMap.put(qName.toString(), interfaceInfo);

		String superTypeName = abcClass.getSuperTypeName();

        if (superTypeName != null)
        {
            interfaceInfo.setBaseInterfaceName( superTypeName );

            analyzeBaseInterface(context, interfaceInfo.getBaseInterfaceMultiName(), interfaceInfo);
        }

        String[] interfaceNames = abcClass.getInterfaceNames();

        if (interfaceNames != null)
        {
            for (int i = 0; i < interfaceNames.length; i++)
            {
                interfaceInfo.addInterfaceName(interfaceNames[i]);
            }

            analyzeInterfaces(context, interfaceInfo.getInterfaceMultiNames(), interfaceInfo);
        }

        Iterator<Method> meth_iter = abcClass.getMethodIterator();

        while (meth_iter.hasNext())
        {
            interfaceInfo.addFunction(meth_iter.next().getQName());
        }
    }

    public Value evaluate(Context context, BinaryInterfaceDefinitionNode binaryInterfaceDefinition)
    {
        if ((binaryInterfaceDefinition.cframe != null) &&
            (binaryInterfaceDefinition.cframe.name != null) &&
            (binaryInterfaceDefinition.cframe.name.ns != null))
        {
            currentPackageName = binaryInterfaceDefinition.cframe.name.ns.name;
        }

        Value result = evaluateInterface(context, binaryInterfaceDefinition);

        currentPackageName = null;

        return result;
    }

    public Value evaluate(Context context, BinaryClassDefNode binaryClassDefinition)
    {
        if ((binaryClassDefinition.cframe != null) &&
            (binaryClassDefinition.cframe.name != null) &&
            (binaryClassDefinition.cframe.name.ns != null))
        {
            currentPackageName = binaryClassDefinition.cframe.name.ns.name;
        }

        Value result = evaluate(context, (ClassDefinitionNode) binaryClassDefinition);

        currentPackageName = null;

        return result;
    }

    public Value evaluate(Context context, ClassDefinitionNode classDefinition)
    {
        String className = NodeMagic.getClassName(classDefinition);

        if (classInfoMap.get(className) == null)
        {
            Info oldInfo = currentInfo;
            currentInfo = new ClassInfo(className);
            classInfoMap.put(className, (ClassInfo)currentInfo);

            if (currentPackageName != null)
            {
                currentInfo.addImport(currentPackageName);
            }

            if (classDefinition.pkgdef != null)
            {
                processImports(classDefinition.pkgdef.statements.items.iterator(), currentInfo);
            }

            if (classDefinition.statements != null)
            {
                processImports(classDefinition.statements.items.iterator(), currentInfo);
            }

            // process extends
            if (classDefinition.baseclass != null)
            {
                ClassInfo classInfo = (ClassInfo) currentInfo;
                if (classDefinition.baseclass instanceof MemberExpressionNode)
                {
                    MemberExpressionNode memberExpression = (MemberExpressionNode) classDefinition.baseclass;

                    if (memberExpression.selector != null)
                    {
                        IdentifierNode identifier = memberExpression.selector.getIdentifier();
                        String baseClassName = toString(identifier);
                        classInfo.setBaseClassName(baseClassName);
                        analyzeBaseClass(context, classInfo.getBaseClassMultiName(), classInfo);
                    }
                }
                else if (classDefinition.baseclass instanceof LiteralStringNode)
                {
                    String baseClassName = ((LiteralStringNode) classDefinition.baseclass).value;
                    classInfo.setBaseClassName(baseClassName);
                    analyzeBaseClass(context, classInfo.getBaseClassMultiName(), classInfo);
                }
                else
                {
                    assert false;
                }
            }

            processInterfaces(context, classDefinition);

            if( classDefinition instanceof BinaryClassDefNode )
            {
                // OV is already built, so use that to process the members, since
                // binary class defs won't have anything in their statement lists
                processMembers(new As3Class(classDefinition, null), (ClassInfo)currentInfo);
            }

            super.evaluate(context, classDefinition);

            currentInfo = oldInfo;
        }

        return null;
    }

    /*
    public Value evaluate(Context context, ImportDirectiveNode importDirective)
    {
        if (importDirective.name.id.def_part.length() == 0)
        {
            currentInfo.addImport(importDirective.name.id.pkg_part);
        }
        else
        {
            currentInfo.addQualifiedImport(importDirective.name.id.def_part,
                                           importDirective.name.id.pkg_part);
        }
        
        return null;
    }
    */

    public Value evaluate(Context context, InterfaceDefinitionNode interfaceDefinition)
    {
        return evaluateInterface(context, interfaceDefinition);
    }

    private Value evaluateInterface(Context context, ClassDefinitionNode interfaceDefinition)
    {
        String interfaceName = NodeMagic.getClassName(interfaceDefinition);

        if (interfaceInfoMap.get(interfaceName) == null)
        {
            Info oldInfo = currentInfo;
            currentInfo = new InterfaceInfo(interfaceName);
            interfaceInfoMap.put(interfaceName, (InterfaceInfo)currentInfo);

            if (interfaceDefinition.pkgdef != null)
            {
                processImports(interfaceDefinition.pkgdef.statements.items.iterator(), currentInfo);
            }

            if (interfaceDefinition.statements != null)
            {
                processImports(interfaceDefinition.statements.items.iterator(), currentInfo);
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
                        InterfaceInfo interfaceInfo = (InterfaceInfo) currentInfo;
                        interfaceInfo.setBaseInterfaceName(baseInterfaceName);
                        analyzeBaseInterface(context, interfaceInfo.getBaseInterfaceMultiName(), interfaceInfo);
                    }
                }
                else
                {
                    assert false;
                }
            }

            // It would seem that ASC sometimes puts an interface's
            // base interface in the InterfaceDefinitionNode's
            // interfaces list.  I'm not sure if this is always the
            // case, though.
            processInterfaces(context, interfaceDefinition);
            
            super.evaluate(context, interfaceDefinition);

            currentInfo = oldInfo;
        }

        return null;
    }

    public Value evaluate(Context context, FunctionCommonNode functionCommon)
    {
        return null;
    }

    public Value evaluate(Context context, FunctionDefinitionNode functionDefinition)
    {
        if ((functionDefinition.name != null) &&
            (functionDefinition.name.identifier != null) &&
            (functionDefinition.name.identifier.name != null))
        {
            QName functionName = new QName(NodeMagic.getUserNamespace(functionDefinition),
                                           NodeMagic.getFunctionName(functionDefinition));

			if (currentInfo != null)
            {
				//	CAUTION used to test fexpr.kind, not name.kind. Ditto setter case below
				if (NodeMagic.functionIsGetter(functionDefinition))
                {
                    currentInfo.addGetter(functionName);
                }
                else if (NodeMagic.functionIsSetter(functionDefinition))
                {
                    currentInfo.addSetter(functionName);
                }
                else
                {
                    currentInfo.addFunction(functionName);
                }
            }
            else
            {
                // Ignore these, they are classless functions like
                // trace() in the flash.utils package.
            }
        }

        return null;
    }

    public Value evaluate(Context cx, PackageDefinitionNode packageDefinition)
    {
        PackageNameNode packageName = packageDefinition.name;

        if (packageName != null)
        {
            PackageIdentifiersNode packageIdentifiers = packageName.id;
            if ((packageIdentifiers != null) && (packageIdentifiers.pkg_part != null))
            {
                currentPackageName = packageIdentifiers.pkg_part;
            }
        }

        super.evaluate(cx, packageDefinition);

        currentPackageName = null;

        return null;
    }

    public Value evaluate(Context context, VariableDefinitionNode variableDefinition)
    {
        if ((variableDefinition.list != null) &&
            (variableDefinition.list.items != null) &&
            (variableDefinition.list.items.get(0) instanceof VariableBindingNode))
        {
            QName variableName = new QName(NodeMagic.getUserNamespace(variableDefinition),
                                           NodeMagic.getVariableName(variableDefinition));

            if (currentInfo != null)
            {
                // if currentInfo is an instance of InterfaceInfo, ASC
                // will report an error downstream, because variable
                // declarations are not permitted in interfaces.
                if (currentInfo instanceof ClassInfo)
                {
                    ((ClassInfo) currentInfo).addVariable(variableName);
                }
            }
            else
            {
                // Ignore these, they are classless variables. 
            }
        }

        return null;
    }
    
    /**
     * Currently only used for SkinParts. When metadata with the id SkinPart is
     * found it gets added to the ClassInfo instance. 
     * 
     * @param cx  The current context
     * @param node The current metadata node
     */
    public Value evaluate(Context cx, MetaDataNode node)
    {
        //SkinParts
        if((node.getId() != null) && node.getId().equals(SKINPART))
        {
        	if(node.def instanceof VariableDefinitionNode || 
        	   node.def instanceof FunctionDefinitionNode)
        	{
                String fieldName;
        		
                if (node.def instanceof VariableDefinitionNode)
                    fieldName = NodeMagic.getVariableName((VariableDefinitionNode) node.def);
                else
                    fieldName = NodeMagic.getFunctionName((FunctionDefinitionNode) node.def);
	
	            //skin parts are not always required
	            String value = node.getValue(REQUIRED);
	            ((ClassInfo) currentInfo).addSkinPart(fieldName, TRUE.equalsIgnoreCase(value));
        	}
        }
       
        return null;
    }

    // Ignore ambiguity checks here, because they are checked by CompilerAPI.resolveMultiName().
    private QName findQName(MultiName multiName)
    {
        String[] namespace = multiName.getNamespace();
        String localPart = multiName.getLocalPart();
        int i = 0;
        int length = namespace.length;
        QName result = null;

        while ((i < length) && (result == null))
        {
            if (symbolTable.findSourceByQName(namespace[i], localPart) != null)
            {
                result = multiName.getQName(i);
            }
            i++;
        }

        return result;
    }

    public ClassInfo getClassInfo(String className)
    {
        return classInfoMap.get(className);
    }

    public Iterator<ClassInfo> getClassInfoIterator()
    {
        return classInfoMap.values().iterator();
    }

    private Node getNode(CompilationUnit compilationUnit)
    {
        assert compilationUnit != null : "null CompilationUnit passed to getNode()";

        Node result = null;

        Object syntaxTree = compilationUnit.getSyntaxTree();

        if (syntaxTree != null)
        {
            if (!(syntaxTree instanceof Node))
            {
                flex2.compiler.CompilerContext context = compilationUnit.getContext();
                CompilationUnit delegateUnit =
                    (CompilationUnit) context.getAttribute(DELEGATE_UNIT);
                // delegateUnit can be null in the case of an error, like base class not
                // found.
                if (delegateUnit != null)
                {
                    result = (Node) delegateUnit.getSyntaxTree();
                }
            }
            else
            {
                result = (Node) syntaxTree;
            }
        }

        return result;
    }

    private void processImports(Iterator iterator, Info info)
    {
        while ( iterator.hasNext() )
        {
            Object node = iterator.next();

            if (node instanceof ImportDirectiveNode)
            {
                ImportDirectiveNode importDirective = (ImportDirectiveNode) node;

                if (importDirective.name.id.def_part.length() == 0)
                {
                    info.addImport(importDirective.name.id.pkg_part);
                }
                else
                {
                    info.addQualifiedImport(importDirective.name.id.def_part,
                                            importDirective.name.id.pkg_part);
                }
            }
        }
    }

    private void processInterfaces(Context context, ClassDefinitionNode definition)
    {
        if (definition.interfaces != null)
        {
            Iterator iterator = definition.interfaces.items.iterator();

            while ( iterator.hasNext() )
            {
                MemberExpressionNode memberExpression = (MemberExpressionNode) iterator.next();

                if (memberExpression.selector != null)
                {
                    IdentifierNode identifier = memberExpression.selector.getIdentifier();
                    String interfaceName = toString(identifier);
                    
                    if ((identifier.ref != null) && (identifier.ref.namespaces != null))
                    {
                        int size = identifier.ref.namespaces.size();

                        if (size == 0)
                        {
                            NamespaceValue namespaceValue = (NamespaceValue) identifier.ref.namespaces.get(0);
                            if (namespaceValue.name.length() > 0)
                            {
                                currentInfo.addInterfaceMultiName(namespaceValue.name, interfaceName);
                            }
                            else
                            {
                                currentInfo.addInterfaceName(interfaceName);
                            }
                        }
                        else
                        {
                            Set<String> namespacesSet = new HashSet<String>();
                            
                            for (int i = 0; i < size; i++)
                            {
                                NamespaceValue namespaceValue = (NamespaceValue) identifier.ref.namespaces.get(i);
                                
                                if (namespaceValue.name.length() > 0)
                                {
                                    namespacesSet.add(namespaceValue.name);
                                }
                            }
                            
                            String[] namespaces = new String[namespacesSet.size()];
                            namespacesSet.toArray(namespaces);
                            currentInfo.addInterfaceMultiName(namespaces, interfaceName);
                        }
                    }
                    else
                    {
                        currentInfo.addInterfaceName(interfaceName);
                    }
                }
            }
            
            analyzeInterfaces(context, currentInfo.getInterfaceMultiNames(), currentInfo);
        }
    }

    public void removeClassInfo(String className)
    {
        classInfoMap.remove(className);
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
