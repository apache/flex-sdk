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

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import macromedia.asc.parser.*;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.localization.LocalizationManager;
import flash.swf.tools.as3.EvaluatorAdapter;
import flex2.compiler.SymbolTable;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.util.QName;


//     _____ _                   _                  _____           _             _
//    /  ___(_)                 | |                |  ___|         | |           | |
//    \ `--. _  __ _ _ __   __ _| |_ _   _ _ __ ___| |____   ____ _| |_   _  __ _| |_ ___  _ __
//     `--. \ |/ _` | '_ \ / _` | __| | | | '__/ _ \  __\ \ / / _` | | | | |/ _` | __/ _ \| '__|
//    /\__/ / | (_| | | | | (_| | |_| |_| | | |  __/ |___\ V / (_| | | |_| | (_| | || (_) | |
//    \____/|_|\__, |_| |_|\__,_|\__|\__,_|_|  \___\____/ \_/ \__,_|_|\__,_|\__,_|\__\___/|_|
//              __/ |
//             |___/

//   _        __ __            _  __ __       _______ _     __
//  |_)| ||  |_ (_   _ __  _| |_|(_ (_ | ||V||_)|  | / \|\|(_
//  | \|_||__|____) (_|| |(_| | |__)__)|_|| ||  | _|_\_/| |__)
//
// GENERAL
// * Packages can only have one top level definition in mxmlc, but not asc/authoring (therefore,
//   this evaluator might not be sufficient for ASC in the general case).
//
// * Ignoring all private variables and functions, method bodies, and defs outside the main package.
//
// * Includes are inlined into the source berore generating a signature
//
// * Definition(Node)s that are not in packages are not evaluated -- none of them should be externally visible
//
// * Peephole sorting: Attributes, CLASS IMPLEMENTS lists, INTERFACE EXTENDS lists, MetaData values,
//   and USE NAMESPACE (N1,N2) lists are sorted canonically (case-sensitive for stability).
//   (these use cases affect about 20% of the Flex SDK!)
//
// * Namespace values (e.g. http://www.adobe.com/2006/flex/mx/internal) DO affect dependent files
//   and therefore the signature; the value appears in dependent external definitions.
//
// * This evaluator does not support top-level ExpressionStatements -- statically executable code
//   (Flash's linker does this a lot, mxmlc does not even support it); another limitation is that
//   we only consider the first package, whereas ASC allows multiple packages in a file
//   (this stuff is easily fixable).
//
// * The values of MetaData are part of the signature since they can affect an arbitrary set of files.
//
// * The values of initializers and defaults are omitted, but their existence is significant for
//   type checking; therefore "=..." is emitted in their place.
//
//   One consideration on whether to mark that there's a default value is that the number of
//   expected arguments change when you add or remove a default value from a method parameter.
//   It may be necessary for the signature to reflect that.
//
// * If a variables or function has no access specifiers, the signature will contain "internal".
//
// IMPORT and USE directives
// * Since use namespace directives, and imports, are block scoped, their existence in function
//   bodies is not meaningful externally. Function bodies are entirely omitted.
//
// * Class and package level imports can affect signatures -- type declarations for external fields
//   and functions are multinames containing the set of imports; though the type name of an import
//   doesn't change, you could swap an import out for another which provides the same type name
//   but different definition, which requires a deep recompile.
//
// * ALL imports that are written in the original source are assumed to be in-use;
//   in other words, even unused imports are part of the signature.
//
// * Imports and use directives within functions are block scoped and not part of the signature
//

//   _  _  __ _____ _     __  _  _______   ______ _______ _     __
//  |_)/ \(_ (_  | |_)|  |_  / \|_)|  | |V| |  _/|_||  | / \|\|(_
//  |  \_/__)__)_|_|_)|__|__ \_/|  | _|_| |_|_/__| || _|_\_/| |__)
//
// * What other things can be canonical/sorted -- e.g. the list of implements (which is implemented)?
//
// * Semicolons would make signatures prettier.
//
// * non-human readable version: smaller files, most memory, faster CRC.
//   Excludes indentation, new-lines, semicolons.
//
// * Is (x) the same as (x:*)? The difference should probably be reflectted in the signature for
//   type checking and warning purposes. If no difference, then I can make both map to same sig.
//
// * Do I need to mark the existence of a variable initializer, or can I omit "=..."?
//
// * Do I need to print return values? as long as type checking continues to work on dependent
//   files, the return type is unused in dependent files -- we would only be recompiling them
//   to do type checking.
//
// * I already have a rule system that determines what gets included in a signature,
//   it'd be useful to to generate multiple signatures in one pass
//   (e.g. just protected methods, just public methods)
//
// * Unused imports could be excluded from signatures (assumes the files can compile and link).
//

//     ___ _  __   _
//    |_ _/ \|  \ / \
//     | ( o ) o | o )
//     |_|\_/|__/ \_/
//
// TODO handle TypeExpressionNode -- especially ! and ? chars
// TODO handle ES4 initializer lists -- see flashfarm changelist 296802

/**
 * Evaluates an AS3 syntax tree and emits a file signature.
 *
 * This class is not meant to be reused -- always create a new instance when you need it.
 *
 * @author Jono Spiro
 */
public class SignatureEvaluator extends EvaluatorAdapter implements Tokens
{

//    ______ _      _     _
//    |  ___(_)    | |   | |
//    | |_   _  ___| | __| |___
//    |  _| | |/ _ \ |/ _` / __|
//    | |   | |  __/ | (_| \__ \
//    \_|   |_|\___|_|\__,_|___/

    public static String NEWLINE = System.getProperty("line.separator");

    /**
     * This is where a finished signature ends up.
     */
    private StringBuilder out;

    /**
     * The current indent distance.
     */
    private int indent;

    /**
     * Used to determine which nodes may be evaluated and other things
     * about what the signatures will contain.
     */
    private final SignatureRules signatureRules;

    /**
     * Stores a cache of expensively computed attributes about DefinitionNodes;
     * used alongside SignatureRules, in checkFeature().
     */
    private final AttributeInfoCache attributeInfoCache = new AttributeInfoCache();

    private boolean humanReadable;

    // Assume package definitions can't be nested.
    private boolean insidePackage;

//     _____                 _                   _
//    /  __ \               | |                 | |
//    | /  \/ ___  _ __  ___| |_ _ __ _   _  ___| |_ ___  _ __ ___
//    | |    / _ \| '_ \/ __| __| '__| | | |/ __| __/ _ \| '__/ __|
//    | \__/\ (_) | | | \__ \ |_| |  | |_| | (__| || (_) | |  \__ \
//     \____/\___/|_| |_|___/\__|_|   \__,_|\___|\__\___/|_|  |___/

    /**
     * Save the StringBuilder some work and guess how big your signature might be.
     * Uses the default SignatureRules (rules for determining what to include in a signature).
     *
     * @see SignatureEvaluator(int suggestedBufferSize, SignatureRules signatureRules)
     */
    public SignatureEvaluator(int suggestedBufferSize, boolean humanReadable)
    {
        this(suggestedBufferSize, humanReadable, new SignatureRules());
    }

    /**
     * Save the StringBuilder some work and guess how big your signature might be.
     * Uses a custom SignatureRules (rules for determining what to include in a signature).
     */
    public SignatureEvaluator(int suggestedBufferSize, boolean humanReadable,
                              SignatureRules signatureRules)
    {
        this.out = new StringBuilder(suggestedBufferSize);
        this.humanReadable = humanReadable;
        this.signatureRules = signatureRules;
    }

//    ___  ___               _                ______                _   _
//    |  \/  |              | |               |  ___|              | | (_)
//    | .  . | ___ _ __ ___ | |__   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
//    | |\/| |/ _ \ '_ ` _ \| '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
//    | |  | |  __/ | | | | | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
//    \_|  |_/\___|_| |_| |_|_.__/ \___|_|    \_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

    public String getSignature()
    {
        return out.toString();
    }

    public String toString()
    {
        return getSignature();
    }

    private String indentCache;
    private int lastIndent;

    /**
     * Returns the current indentation.
     */
    private String indent()
    {
        assert (indent >= 0);
        if (lastIndent != indent)
        {
            indentCache = "";
            for (int i = 0; i < indent; i++)
            {
                indentCache += "    ";
            }
        }
        return indentCache;
    }

//                          _____            _             _
//            _____        | ____|_   ____ _| |_   _  __ _| |_ ___  _ __ ___         _____
//      _____|_____|_____  |  _| \ \ / / _` | | | | |/ _` | __/ _ \| '__/ __|  _____|_____|_____
//     |_____|_____|_____| | |___ \ V / (_| | | |_| | (_| | || (_) | |  \__ \ |_____|_____|_____|
//                         |_____| \_/ \__,_|_|\__,_|\__,_|\__\___/|_|  |___/

    public boolean checkFeature(Context cx, Node node)
    {
        // RULES!
        // if none of the rules fail, process the node (default)
        boolean result = true;
        if (node instanceof DefinitionNode)
        {
            final AttributeInfo attInfo = attributeInfoCache.getAttributeInfo((DefinitionNode)node);
            if (node instanceof FunctionDefinitionNode)
            {
                result = !((attInfo.isPublic    && !signatureRules.KEEP_FUN_SCOPE_PUBLIC)    ||
                           (attInfo.isPrivate   && !signatureRules.KEEP_FUN_SCOPE_PRIVATE)   ||
                           (attInfo.isProtected && !signatureRules.KEEP_FUN_SCOPE_PROTECTED) ||
                           (attInfo.isUser      && !signatureRules.KEEP_FUN_SCOPE_USER)      ||
                           (attInfo.isInternal  && !signatureRules.KEEP_FUN_SCOPE_INTERNAL));
            }
            else if (node instanceof VariableDefinitionNode)
            {
                result = !((attInfo.isPublic    && !signatureRules.KEEP_VAR_SCOPE_PUBLIC)    ||
                           (attInfo.isPrivate   && !signatureRules.KEEP_VAR_SCOPE_PRIVATE)   ||
                           (attInfo.isProtected && !signatureRules.KEEP_VAR_SCOPE_PROTECTED) ||
                           (attInfo.isUser      && !signatureRules.KEEP_VAR_SCOPE_USER)      ||
                           (attInfo.isInternal  && !signatureRules.KEEP_VAR_SCOPE_INTERNAL));
            }
            else if (node instanceof ImportDirectiveNode)
            {
                result = signatureRules.KEEP_IMPORTS;
            }
            else if (node instanceof ClassDefinitionNode)
            {
                result = signatureRules.KEEP_CLASSES;
            }
            else if (node instanceof InterfaceDefinitionNode)
            {
                result = signatureRules.KEEP_INTERFACES;
            }
            else if (node instanceof UseDirectiveNode)
            {
                result = signatureRules.KEEP_USE_NAMESPACE;
            }
        }
        else if (node instanceof MetaDataNode)
        {
            // only print metadata if the definition it is attached to will get evaluated
            result = (signatureRules.KEEP_METADATA && checkFeature(cx, ((MetaDataNode)node).def));
        }

        return result;
    }

    public Value evaluate(Context unused_cx, ProgramNode node)
    {
        final Context cx = node.cx;

        // if we don't have a package, an error will be reported downstream.
        if ((node.pkgdefs != null) && !node.pkgdefs.isEmpty())
        {
            // TODO (why?) there can be multiple packages inside of a file for some reason
            // we're only interested in the main package, however
            final PackageDefinitionNode mainPackage = node.pkgdefs.first();

            // BODY
            if (mainPackage.statements != null)
            {
                indent++;
                mainPackage.statements.evaluate(cx, this);
                indent--;
            }
        }

        return null;
    }

//    ______      __ _       _ _   _             _   _           _
//    |  _  \    / _(_)     (_) | (_)           | \ | |         | |
//    | | | |___| |_ _ _ __  _| |_ _  ___  _ __ |  \| | ___   __| | ___  ___
//    | | | / _ \  _| | '_ \| | __| |/ _ \| '_ \| . ` |/ _ \ / _` |/ _ \/ __|
//    | |/ /  __/ | | | | | | | |_| | (_) | | | | |\  | (_) | (_| |  __/\__ \
//    |___/ \___|_| |_|_| |_|_|\__|_|\___/|_| |_\_| \_/\___/ \__,_|\___||___/

    public Value evaluate(Context unused_cx, ClassDefinitionNode node)
    {
        final Context cx = node.cx;

        if (humanReadable)
        {
            out.append(indent());
        }

        // ATTRIBUTES
        if (node.attrs != null)
            node.attrs.evaluate(cx, this);

        // "No class name found for ClassDefinitionNode"
        assert node.name      != null : "Sanity Failed";
        assert node.name.name != null : "Sanity Failed";

        if (humanReadable)
        {
            out.append("class ");
        }
        else
        {
            out.append("C");
        }

        out.append(NodeMagic.getUnqualifiedClassName(node));

        if (node.baseclass != null)
        {
            if (humanReadable)
            {
                out.append(" extends ");
            }
            else
            {
                out.append(" E");
            }

            node.baseclass.evaluate(cx, this);
        }

        if (node.interfaces != null)
        {
            if (humanReadable)
            {
                out.append(" implements ");
            }
            else
            {
                out.append(" I");
            }

            // it's an unordered list, therefore it's sortable
            evaluateSorted(cx, node.interfaces);
        }

        if (humanReadable)
        {
            out.append(NEWLINE).append(indent()).append("{").append(NEWLINE);
        }

        // these only seem to be in use during FlowAnalyzer and later
        assert node.fexprs        == null : "Sanity Failed";
        assert node.staticfexprs  == null : "Sanity Failed";
        assert node.instanceinits == null : "Sanity Failed";

        if (node.statements != null)
        {
            indent++;
            node.statements.evaluate(cx, this);
            indent--;
        }

        if (humanReadable)
        {
            out.append(indent()).append("}").append(NEWLINE);
        }

        return null;
    }

    public Value evaluate(Context cx, InterfaceDefinitionNode node)
    {
        if (humanReadable)
        {
            out.append(indent());
        }

        // ATTRIBUTES
        if (node.attrs != null)
            node.attrs.evaluate(cx, this);

        // "No class name found for InterfaceDefinitionNode"
        assert node.name      != null : "Sanity Failed";
        assert node.name.name != null : "Sanity Failed";
        {
            if (humanReadable)
            {
                out.append("interface ");
            }
            else
            {
                out.append("I");
            }

            out.append(NodeMagic.getUnqualifiedClassName(node));
        }

        if (node.interfaces != null)
        {
            if (humanReadable)
            {
                out.append(" extends ");
            }
            else
            {
                out.append(" E");
            }

            // it's a list, it's sortable
            evaluateSorted(cx, node.interfaces);
        }

        // interfaces don't have a baseclass
        assert node.baseclass == null : "Sanity Failed";

        if (humanReadable)
        {
            out.append(NEWLINE).append(indent()).append("{").append(NEWLINE);
        }

        if (node.statements != null)
        {
            indent++;
            node.statements.evaluate(cx, this);
            indent--;
        }

        if (humanReadable)
        {
            out.append(indent()).append("}").append(NEWLINE);
        }

        return null;
    }

    public Value evaluate(Context unused_cx, FunctionDefinitionNode node)
    {
        final Context cx = node.cx;

        // ATTRIBUTES
        // if (node.attrs != null)
        //     node.attrs.evaluate(cx, this);

        // peephole optimization
        //   * functions without attributes or access specifiers are always marked internal
        //
        //          var foo --> internal var foo
        // internal var foo --> internal var foo
        //   static var foo --> internal static var foo
        final TreeSet<String> sortedAttributeSet = NodeMagic.getSortedAttributes(node.attrs);
        if(node.attrs == null || attributeInfoCache.getAttributeInfo(node).isInternal)
        {
            // it's a set, so it's okay if this is redundant
            sortedAttributeSet.add(NodeMagic.INTERNAL);
        }

        if (humanReadable)
        {
            out.append(indent());
        }

        out.append(NodeMagic.setToString(sortedAttributeSet, " "));

        if (humanReadable)
        {
            out.append(" function ");
        }
        else
        {
            out.append("F");
        }

        // GET or SET
        if (NodeMagic.functionIsGetter(node))
        {
            if (humanReadable)
            {
                out.append("get ");
            }
            else
            {
                out.append("G ");
            }
        }
        else if (NodeMagic.functionIsSetter(node))
        {
            if (humanReadable)
            {
                out.append("set ");
            }
            else
            {
                out.append("S ");
            }
        }

        // this should be a safe assumption, I think the only time this could be null is
        // when defining an anonymous function definition... within a function body
        assert node.name != null : "Sanity Failed";
        assert node.name.identifier != null : "Sanity Failed";

        // though it's often a QualifiedIdentifierNode (which includes attributes and namespace)
        // I am only interested in the unqualified function name
        // another way: ((IdentifierNode)node.name.identifier).evaluate(cx, this);
        out.append(NodeMagic.getUnqualifiedFunctionName(node));

        assert node.fexpr != null : "Sanity Failed";

        // PARAMETERS
        if (humanReadable)
        {
            out.append("(");
        }

        if (NodeMagic.getFunctionParamCount(node) > 0)
        {
            for(final Iterator<ParameterNode> iter = node.fexpr.signature.parameter.items.iterator(); iter.hasNext(); )
            {
                final ParameterNode param = iter.next();

                assert param.kind == VAR_TOKEN : "Sanity Failed";

                // rest (...)
                if(param instanceof RestParameterNode)
                    out.append("...");

                // normal parameter
                else
                {
                    //TODO OPTIMIZATION:
                    // Is (x) the same as (x:*)? the difference should probably be
                    // reflectted in the signature for type checking and warning purposes.

                    // if node has a type                       (x:foo.bar)
                    if(param.type != null)
                        param.type.evaluate(cx, this);

                    // or there is no annotation                (x:*)
                    else if (!param.no_anno)
                        out.append(SymbolTable.NOTYPE);

                    //else, no type declaration:                (x)
                        // print nothing

                    // INITIALIZERS/DEFAULT VALUES
                    // TODO OPTIMIZATION:
                    // Is printing =... even necessary for the signature?
                    // For now assuming so -- though default values and return values
                    // do not affect dependent bytecode, I need to check if the type checking
                    // works without recompiling dependent files (catching what would be RTEs).
                    // If it does, then we can omit these, if not, then we need them.
                    if(param.init != null)
                    {
                        if (signatureRules.KEEP_FUN_PARAM_INITIALIZER)
                        {
                            // what kinds of initializers are possible -- numbers, strings, nulls,
                            // anything else, that could possibly print incorrectly? anonymous
                            // function definitions!? (if so, node.name will be null, eek)
                            out.append("=<");
                            param.init.evaluate(null, this);
                            out.append(">");
                        }
                        else
                        {
                            out.append("=...");
                        }
                    }

                    if (iter.hasNext())
                        out.append(", ");
                }
            }
        }

        if (humanReadable)
        {
            out.append(")");
        }

        // RETURN TYPE

        // IGNORE ME: this is incomplete, but it may come in handy for testing
        // assertSanity(node.fexpr.signature.result == null ||
        //              node.fexpr.signature.result instanceof MemberExpressionNode ||
        //              node.fexpr.signature.result instanceof TypedIdentifierNode);

        // TODO OPTIMIZATION:
        // as long as type checking continues to work on dependent files, the return type
        // is technically not used in dependent files -- we would only be recompiling them
        // to do type checking. forget return values?

        //TODO patch NodeMagic.getFunctionTypeName with these cases?
        if (node.fexpr.signature.void_anno)
        {
            if (humanReadable)
            {
                out.append(":");
            }

            out.append("void");
        }
        else if (node.fexpr.signature.no_anno)
        {
            // print nothing
        }
        else if(node.fexpr.signature.result != null) // the return type is a literal string
        {
            // following is insufficient because of MemberExpressions that have non-null .base
            // as in: function foo():bar.Baz
            //out.append(":" + NodeMagic.getFunctionTypeName(node));

            if (humanReadable)
            {
                out.append(":");
            }

            node.fexpr.signature.result.evaluate(cx, this);
        }
        else
        {
            // result type is *
            if (humanReadable)
            {
                out.append(":");
            }

            out.append(SymbolTable.NOTYPE);
        }

        if (humanReadable)
        {
            out.append(NEWLINE);
        }

        //ignore node.body (we do need to evaluate the body looking for imports, though)
        //       node.fexpr.body
        //ignore .def, self-referrential
        assert node.fexpr.def == node : "Sanity Failed";

        //TODO Use statements and imports are block scoped, meaning they could show up in
        //     function bodies & that should only matter for the compilation unit though,
        //     not externally. for now I am going to not parse the bodies at all.

        // evaluate the body looking ONLY for imports using a
        // skeletal evluator that only secretes imports
        // if (node.fexpr.body != null)
        //     node.fexpr.body.evaluate(cx, methodBodyImportFinder);

        // this was handled implicitely rather than running through the evaluator
        // if (node.fexpr != null)
        //     node.fexpr.evaluate(cx, this);

        return null;
    }

    public Value evaluate(Context cx, VariableDefinitionNode node)
    {
        // ATTRIBUTES and USER NAMESPACE
        // if (node.attrs != null)
        //     node.attrs.evaluate(cx, this);

        // peephole optimization
        //   * variables without attributes or access specifiers are always marked internal
        //
        //          var foo --> internal var foo
        // internal var foo --> internal var foo
        //   static var foo --> internal static var foo
        final TreeSet<String> sortedAttributeSet = NodeMagic.getSortedAttributes(node.attrs);
        if(node.attrs == null || attributeInfoCache.getAttributeInfo(node).isInternal)
        {
            // it's a set, so it's okay if this is redundant
            sortedAttributeSet.add(NodeMagic.INTERNAL);
        }

        String kind;

        if (humanReadable)
        {
            kind = (node.kind == CONST_TOKEN) ? "const " : (node.kind == VAR_TOKEN)   ? "var " : null;
        }
        else
        {
            kind = (node.kind == CONST_TOKEN) ? "C" : (node.kind == VAR_TOKEN)   ? "V" : null;
        }

        assert kind != null : "Unknown VariableDefinitionNode.kind";

        // outputs a new variable declaration for each variable in a list
        // e.g. 'var a,b,c' => var a; var b; var c
        for(final Iterator<Node> iter = node.list.items.iterator(); iter.hasNext();)
        {
            final VariableBindingNode variableBinding = (VariableBindingNode)iter.next();

            // ATTRIBUTES and KIND
            if (humanReadable)
            {
                out.append(indent());
            }

            out.append(NodeMagic.setToString(sortedAttributeSet, " "));

            if (humanReadable)
            {
                out.append(" ");
            }

            out.append(kind);

            // NAME
            out.append(variableBinding.variable.identifier.name);

            // TYPE
            // if there is an annotation...
            if(variableBinding.variable.no_anno == false)
            {
                if (humanReadable)
                {
                    out.append(":");
                }

                if (variableBinding.variable.type != null)
                {
                    // :Object
                    variableBinding.variable.type.evaluate(cx, this);
                }
                else
                {
                    // :*
                    out.append(SymbolTable.NOTYPE);
                }
            }

            // TODO
            // I don't think variables with initializers need to emit their initialization;
            // if the initializer changes or not, we still recompile the file, and it doesn't
            // affect the API in the same way that a default argument affects the API.
            //
            // You can treat it as a a function body and omit it.
            //
            // (the reason I don't want to emit it is also because I'd need to write a very
            // complete Evaluator that will reproduce the exact statement following "=",
            // I cannot simply use SignatureEvaluator)

            // TODO
            // The question is, do I need to mark that it has an initializer at all?
            // For now, I will, with "=..." -- I might need to sort those with initializers separately.

            // INITIALIZER
            if (variableBinding.initializer != null)
            {
                //TODO do I need this at all?
                out.append("=...");
                // variableBinding.initializer.evaluate(cx, this);
            }

            if (humanReadable)
            {
                out.append(NEWLINE);
            }
        }

        // evaluated implicitely above
        //if (node.list != null)
        //    node.list.evaluate(cx, this);

        return null;
    }

    public Value evaluate(Context cx, ImportDirectiveNode node)
    {
        assert node.attrs == null : "Sanity Failed";

        // is it possible for node.name to be null?
        assert node.name != null : "Sanity Failed";
        assert node.name.id.list != null : "Sanity Failed";
        assert !node.name.id.list.isEmpty() : "Sanity Failed";

        if (humanReadable)
        {
            out.append(indent()).append("import ");
        }
        else
        {
            out.append("I ");
        }

        out.append(NodeMagic.getDottedImportName(node));

        if (humanReadable)
        {
            out.append(NEWLINE);
        }

        return null;
    }

    public Value evaluate(Context cx, NamespaceDefinitionNode node)
    {
        if (humanReadable)
        {
            out.append(indent());
        }

        if (node.attrs != null)
            node.attrs.evaluate(cx, this);

        if (humanReadable)
        {
            out.append("namespace ");
        }
        else
        {
            out.append("N");
        }

        if (node.name != null)
            node.name.evaluate(cx, this);

        // namespace values DO affect dependent files/the signature
        // clement: The namespace value might appear in the dependent external definitions.
        if (node.value != null)
        {
            out.append("=");
            node.value.evaluate(cx, this);
        }

        if (humanReadable)
        {
            out.append(NEWLINE);
        }

        return null;
    }

    // e.g. "config namespace FOO"
    public Value evaluate(Context cx, ConfigNamespaceDefinitionNode node)
    {
        // they are for conditional compilation, unusable, and only part
        // of the syntax tree for error checking (prevent namespace shadowing)
        // they should not be part of the signature
        return null;
    }

    private PackageDefinitionNode currentPackage;

    public Value evaluate(Context cx, PackageDefinitionNode node)
    {
        assert node.attrs == null : "Sanity Failed";

        if (currentPackage == null)
        {
            currentPackage = node;

            if (humanReadable)
            {
                out.append("package ");
            }
            else
            {
                out.append("P");
            }

            out.append(NodeMagic.getPackageName(node));

            if (humanReadable)
            {
                out.append(NEWLINE).append("{").append(NEWLINE);
            }
        }
        else
        {
            currentPackage = null;

            if (humanReadable)
            {
                out.append("}").append(NEWLINE);
            }
        }

        return null;
    }


    // TODO should use statements affect public sig? maybe not, depends how they are used
    //      certainly defining new members in a namespace, but redefining a namespsce var or fun?
    //
    // notes on absurdity:
    // * "use include ..." seems to be valid in the parser
    // * "use namespace a, b" is valid in the grammar, but illegal when compiling...
    //   (I am going to assume that order matters and not emit this alphabetically, e.g..)
    // * "use namespace (AS3, mx_internal)" compiles correctly (UGH)
    // * the parser will accept "use namespace (true ? AS3 : AS3);" (UGHHHHH)
    //
    //TODO add use directives into a list and emit later? is that how they work? (are they scoped?)
    public Value evaluate(Context cx, UseDirectiveNode node)
    {
        assert node.attrs == null : "Sanity Failed";

        if (humanReadable)
        {
            out.append(indent()).append("use namespace ");
        }
        else
        {
            out.append("U");
        }

        //TODO EvaluatorAdapter should get updated with this code (it's not there)
        //     there could be more than one namespace in expr
        if( node.expr != null )
        {
            // if it's a list, it's sortable
            if (node.expr instanceof ListNode)
                evaluateSorted(cx, (ListNode)node.expr);
            else
                node.expr.evaluate(cx,this);
        }

        if (humanReadable)
        {
            out.append(NEWLINE);
        }

        return null;
    }

    public Value evaluate(Context cx, MetaDataNode node)
    {
        // this fills out node.id and node.values
        if (node.data != null)
            (new macromedia.asc.parser.MetaDataEvaluator()).evaluate(cx, node);

        assert node.getId() != null : "Sanity Failed";

        // MetaDataNode without a definition:
        //    Disabled because apparently "[Foo];" is valid
        //    but causes def to be null since ';' is an EmptyStatementNode.
        //    See ASC-2786.
        //assert node.def != null : "Sanity Failed";

        if (humanReadable)
        {
            out.append(indent()).append("[");
        }

        out.append(node.getId()).append(NodeMagic.getSortedMetaDataParamString(node));
    
        if (humanReadable)
        {
            out.append("]").append(NEWLINE);
        }

        return null;
    }

    /*
     * This can be a top-level Node in a class (or package?), but should only affect linkage,
     * not dependencies.
     *
     * This comes up (as "Bar;") when you have code like:
     * class Foo
     * {
     *    import Bar;
     *    Bar;
     *    ...
     * }
     */
    public Value evaluate(Context cx, ExpressionStatementNode node)
    {
        return null;
    }

    /**
     * default xml namespace = new Namespace(...);
     */
    public Value evaluate(Context cx, DefaultXMLNamespaceNode node)
    {
        // I am pretty sure that the existence or value of this directive
        // cannot affect the signature of the current class (when used outside
        // of function scope) -- it should only affect the xmlns value of XML
        // objects within the block/class.
        return null;
    }

    public Value evaluate(Context cx, TryStatementNode node)
    {
        // these can show up as top-level statements in classes, and do not affect signature
        // ideally I'd like to check that the statement is either top level and return null,
        // or not top level an unreachable (in which case an assertion gets thrown).
        // currently no way to check what 'level' this definition is at... safe enough, though.
        //assert false : "Should be an unreachable codepath";
        return null;
    }

    public Value evaluate(Context cx, CatchClauseNode node)
    {
        // see the comments above for TryStatementNode... same reasoning
        //assert false : "Should be an unreachable codepath";
        return null;
    }

//     _____ _   _                 _   _           _
//    |  _  | | | |               | \ | |         | |
//    | | | | |_| |__   ___ _ __  |  \| | ___   __| | ___  ___
//    | | | | __| '_ \ / _ \ '__| | . ` |/ _ \ / _` |/ _ \/ __|
//    \ \_/ / |_| | | |  __/ |    | |\  | (_) | (_| |  __/\__ \
//     \___/ \__|_| |_|\___|_|    \_| \_/\___/ \__,_|\___||___/

    public Value evaluate(Context cx, ArgumentListNode node)
    {
        for(Iterator<Node> iter = node.items.iterator(); iter.hasNext(); )
        {
            final Node item = iter.next();
            item.evaluate(cx, this);

            // example: LiteralObjectNode.fieldlist: { foo:bar, two:2 }
            if (iter.hasNext())
            {
                if (humanReadable)
                {
                    out.append(", ");
                }
                else
                {
                    out.append(" ");
                }
            }
        }
        return null;
    }


    public Value evaluate(Context cx, ListNode node)
    {
        for (Iterator<Node> iter = node.items.iterator(); iter.hasNext(); )
        {
            iter.next().evaluate(cx, this);

            // this can happen on "A" and "B" when, e.g., you have "implements A, B"
            if (iter.hasNext())
            {
                if (humanReadable)
                {
                    out.append(", ");
                }
                else
                {
                    out.append(" ");
                }
            }
        }
        return null;
    }

    public Value evaluateSorted(Context cx, ListNode list)
    {
        StringBuilder tempOut = out;

        final TreeSet<String> sorted = new TreeSet<String>();

        // evaluate all elements of the list to strings, and sort on that
        for (Node node : list.items)
        {
            // temporarily swap out the in-use StringBuilder
            out = new StringBuilder();
            node.evaluate(cx, this);
            sorted.add(out.toString());
        }
        out = tempOut;

        // now add the sorted elements into the original StringBuilder
        for (Iterator<String> iter = sorted.iterator(); iter.hasNext(); )
        {
            out.append(iter.next());

            if (iter.hasNext())
            {
                if (humanReadable)
                {
                    out.append(", ");
                }
                else
                {
                    out.append(" ");
                }
            }
        }

        return null;
    }

    public Value evaluate(Context cx, GetExpressionNode node)
    {
        if (node.expr != null)
        {
            if (node.expr instanceof ArgumentListNode)
            {
                out.append("[");
                node.expr.evaluate(cx, this);
                out.append("]");
            }
            else
                node.expr.evaluate(cx, this);
        }

        return null;
    }


    // e.g., mx_internal::bar.Baz
    public Value evaluate(Context cx, QualifiedIdentifierNode node)
    {
        if (node.qualifier != null)
        {
            node.qualifier.evaluate(cx, this);
            // NOTE: "::" is not correct syntax, it should just be a dot,
            //       but this is a signature, so it doesn't matter.
            //
            // Pete: I know this is just trying to generate a unique signature,
            //       so this is just academic, but wouldn't :: be correct if use
            //       namespace had not been declared on the file, and a dot if it had?
            out.append("::");
        }

        // eval node to get it's value
        evaluate(cx, (IdentifierNode) node);

        return null;
    }


    // e.g., xmldata.@ns::["id"]
    // TODO This needs work to support all the types of this expression (incomplete):
    //        xmldata.@foo::["id"]
    //        xmldata.@*[1]
    //        xdata.@id
    public Value evaluate(Context cx, QualifiedExpressionNode node)
    {
        out.append("@");
        evaluate(cx, (QualifiedIdentifierNode)node);
        if (node.expr != null)
        {
            //TODO I don't know how complex the expr can be, e.g. (logical ? "id1" : "id2")
            //     but anything other than a simple literal is probably unsupported
            out.append("[");
            node.expr.evaluate(cx, this);
            out.append("]");
        }
        return null;
    }


    // e.g., interface foo extends bar.baz ("bar." is the base)
    public Value evaluate(Context cx, MemberExpressionNode node)
    {
        if (node.base != null)
        {
            node.base.evaluate(cx, this);
            if ((node.selector instanceof GetExpressionNode) &&
                (!(((GetExpressionNode) node.selector).expr instanceof ArgumentListNode)))
            {
                out.append(".");
            }
        }

        if (node.selector != null)
            node.selector.evaluate(cx, this);

        return null;
    }

    /**
     * Basically the same as MemberExpressionNodes, but only for type expressions.
     */
    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        return super.evaluate(cx, node);
    }


    /**
     * Attributes are printed in (alphabetical) order.
     */
    public Value evaluate(Context cx, AttributeListNode node)
    {
        final String attrs = NodeMagic.getSortedAttributeString(node, " ");
        if(attrs.length() > 0)
        {
            out.append(attrs).append(" ");
        }

        return null;
    }

    // Vector.<int>
    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        // e.g. Vector
        if (node.expr != null)
            node.expr.evaluate(cx, this);

        out.append(".<");

        // e.g. <int>
        if (node.typeArgs != null)
            node.typeArgs.evaluate(cx, this);

        out.append(">");

        return null;
    }

//     _     _ _                 _   _   _           _
//    | |   (_) |               | | | \ | |         | |
//    | |    _| |_ ___ _ __ __ _| | |  \| | ___   __| | ___  ___
//    | |   | | __/ _ \ '__/ _` | | | . ` |/ _ \ / _` |/ _ \/ __|
//    | |___| | ||  __/ | | (_| | | | |\  | (_) | (_| |  __/\__ \
//    \_____/_|\__\___|_|  \__,_|_| \_| \_/\___/ \__,_|\___||___/

//  TODO Different literal nodes can evaluate to the same textual representation,
//  for instance (x=2, y="2") or (x="true", y=true). If the value changes from one to
//  the other, the signature won't change. I could differentiate each literal's output
//  slightly, though it will look a little stupid. On the other other hand, it might not matter --
//  if a variable id typed to int and changes to String, it will diff; if it is typed to */Object,
//  then it may not matter that it changed type.

    public Value evaluate(Context cx, IdentifierNode node)
    {
        out.append(node.name);
        return null;
    }


    public Value evaluate(Context cx, LiteralArrayNode node)
    {
        out.append("[");
        {
            super.evaluate(cx, node);
        }
        out.append("]");

        return null;
    }


    public Value evaluate(Context cx, LiteralBooleanNode node)
    {
        out.append(node.value);
        return null;
    }


    // these are the key:value pairs in a LiteralObjectNode
    public Value evaluate(Context cx, LiteralFieldNode node)
    {
        if (node.name != null)
            node.name.evaluate(cx, this);

        if (node.value != null)
        {
            out.append(':');
            node.value.evaluate(cx, this);
        }

        return null;
    }


    public Value evaluate(Context cx, LiteralNullNode node)
    {
        out.append("null");
        return null;
    }


    public Value evaluate(Context cx, LiteralNumberNode node)
    {
        out.append(node.value);
        return null;
    }


    public Value evaluate(Context cx, LiteralObjectNode node)
    {
        out.append('{');
        {
            if (node.fieldlist != null)
                node.fieldlist.evaluate(cx, this);
        }
        out.append('}');
        return null;
    }


    public Value evaluate(Context cx, LiteralRegExpNode node)
    {
        out.append(node.value);
        return null;
    }


    public Value evaluate(Context cx, LiteralStringNode node)
    {
        // TODO I'd like to be able to print quotes someday... meaning checking for LSNs in places
        //      like InterfaceDefNodes and ClassDefNodes, and MemberExprNodes, and overriding
        //      the evaluating behavior

        // I don't do this anymore because LiteralStringNodes are used in places like
        // class Foo extends "FooPackage.Bar".MyClass
        // which looks wrong, AND it's used in places where the original syntax was "a string"

        // out.append('"');
        out.append(node.value);
        // out.append('"');

        return null;
    }

    public Value evaluate(Context cx, Node node)
    {
        return null;
    }

    public Value evaluate(Context cx, VariableBindingNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, UntypedVariableBindingNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, TypedIdentifierNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ParenExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ParenListExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, FunctionSignatureNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, FunctionCommonNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, PackageIdentifiersNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, PackageNameNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ClassNameNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, FunctionNameNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ImportNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ReturnStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, SuperExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, SuperStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, SwitchStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ThisExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ThrowStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, UnaryExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, WhileStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, WithStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, DeleteExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, DoStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, FinallyClauseNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ForStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, IfStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, IncrementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, RestParameterNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BreakStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, CallExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, CaseLabelNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ConditionalExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ContinueStatementNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryClassDefNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryFunctionDefinitionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryProgramNode node)
    {
        return null;
    }

    // used in for..in loops
    public Value evaluate(Context cx, HasNextNode node)
    {
        return null;
    }

    // used in for..in loops
    public Value evaluate(Context cx, LoadRegisterNode node)
    {
        return null;
    }

    // used in for..in loops
    public Value evaluate(Context cx, StoreRegisterNode node)
    {
        return null;
    }

    // used in for..in loops
    public Value evaluate(Context cx, RegisterNode node)
    {
        return null;
    }

    // seems like these are unused in syntax trees, just used during parsing/generation of classes
    public Value evaluate(Context cx, InheritanceNode node)
    {
        return null;
    }

    // see DataBindingFirtPassEvaluator.java::evaluate(Context context, InvokeNode node)
    public Value evaluate(Context cx, InvokeNode node)
    {
        return null;
    }

    // evaluated implicitly FunctionDefinitionNode
    public Value evaluate(Context cx, ParameterListNode node)
    {
        return null;
    }

    // evaluated implicitly FunctionDefinitionNode
    public Value evaluate(Context cx, ParameterNode node)
    {
        return null;
    }

    // evaluated implicitly FunctionDefinitionNode
    public Value evaluate(Context cx, RestExpressionNode node)
    {
        return null;
    }

    // abusive old-school labels for break and continue statements
    public Value evaluate(Context cx, LabeledStatementNode node)
    {
        return null;
    }


    // TODO BoxNodes do not seem to be created ANYWHERE in ASC or MXMLC
    //      Remove from Evaluator?
    // not part of AS3 syntax
    public Value evaluate(Context cx, BoxNode node)
    {
        return null;
    }

    // not part of AS3 syntax
    public Value evaluate(Context cx, CoerceNode node)
    {
        return null;
    }

    // TODO ToObjectNodes do not seem to be created ANYWHERE in ASC or MXMLC
    //      Remove from Evaluator?
    // not part of AS3 syntax
    public Value evaluate(Context cx, ToObjectNode node)
    {
        return null;
    }

    // unimplemented in AS3 syntax: "use pragmaDirective"
    public Value evaluate(Context cx, PragmaNode node)
    {
        return null;
    }

    // unimplemented in AS3 syntax: "use pragmaDirective"
    public Value evaluate(Context cx, PragmaExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, SetExpressionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, StatementListNode statementList)
    {
        StringBuilder originalOut = out;

        Set<String> imports = null;
        Set<String> useNamespaces = null;
        Map<String, Set<String>> variables = null; // declaration -> metadata
        Map<String, Set<String>> functions = null; // declaration -> metadata
        Map<String, Set<String>> classes = null; // declaration -> metadata
        Map<String, Set<String>> interfaces = null; // declaration -> metadata

        // Reevaluate the size for each iteration, because Nodes can
        // be added to "items" (See the NodeMagic.addImport() call in
        // flex2.compiler.as3.SyntaxTreeEvaluator.processResourceBundle())
        // and if the last Node is an IncludeDirectiveNode, we need to
        // be sure to evaluate it, so that in_this_include is turned
        // off.
        for (int i = 0; i < statementList.items.size(); i++)
        {
            Node node = statementList.items.get(i);

            if (insidePackage && (node instanceof ImportDirectiveNode))
            {
                if (imports == null)
                {
                    imports = new TreeSet<String>();
                }

                out = new StringBuilder();
                node.evaluate(cx, this);
                imports.add(out.toString());
                out = originalOut;
            }
            else if (insidePackage && (node instanceof NamespaceDefinitionNode))
            {
                if (useNamespaces == null)
                {
                    useNamespaces = new TreeSet<String>();
                }

                out = new StringBuilder();
                node.evaluate(cx, this);
                useNamespaces.add(out.toString());
                out = originalOut;
            }
            else if (insidePackage && (node instanceof ClassDefinitionNode))
            {
                if (classes == null)
                {
                    classes = new TreeMap<String, Set<String>>();
                }

                putDefinition(classes, cx, (DefinitionNode) node);
            }
            else if (insidePackage && (node instanceof InterfaceDefinitionNode))
            {
                if (interfaces == null)
                {
                    interfaces = new TreeMap<String, Set<String>>();
                }

                putDefinition(interfaces, cx, (DefinitionNode) node);
            }
            else if (insidePackage && (node instanceof FunctionDefinitionNode))
            {
                if (functions == null)
                {
                    functions = new TreeMap<String, Set<String>>();
                }

                putDefinition(functions, cx, (DefinitionNode) node);
            }
            else if (insidePackage && (node instanceof VariableDefinitionNode))
            {
                if (variables == null)
                {
                    variables = new TreeMap<String, Set<String>>();
                }

                putDefinition(variables, cx, (DefinitionNode) node);
            }
            else if (node instanceof PackageDefinitionNode)
            {
                if (insidePackage)
                {
                    appendSorted(imports, useNamespaces, variables, functions, classes, interfaces);
                    imports = null;
                    useNamespaces = null;
                    variables = null;
                    functions = null;
                    classes = null;
                    interfaces = null;

                    node.evaluate(cx, this);
                    insidePackage = false;
                }
                else
                {
                    node.evaluate(cx, this);
                    insidePackage = true;
                }
            }
            else if (!(node instanceof MetaDataNode))
            {
                node.evaluate(cx, this);
            }
        }

        appendSorted(imports, useNamespaces, variables, functions, classes, interfaces);

        return null;
    }

    private void appendSorted(Set<String> imports,
                              Set<String> useNamespaces,
                              Map<String, Set<String>> variables,
                              Map<String, Set<String>> functions,
                              Map<String, Set<String>> classes,
                              Map<String, Set<String>> interfaces)
    {
        appendSorted(imports);
        appendSorted(useNamespaces);
        appendSorted(variables);
        appendSorted(functions);
        appendSorted(classes);
        appendSorted(interfaces);
    }

    private void appendSorted(Set<String> statements)
    {
        if (statements != null)
        {
            for (String statement : statements)
            {
                out.append(statement);
            }
        }
    }

    private void appendSorted(Map<String, Set<String>> definitions)
    {
        if (definitions != null)
        {
            for (Entry<String, Set<String>> entry : definitions.entrySet())
            {
                if (entry.getValue() != null)
                {
                    for (String metaData : entry.getValue())
                    {
                        out.append(metaData);
                    }
                }

                out.append(entry.getKey());
            }
        }
    }

    private void putDefinition(Map<String, Set<String>> declarations,
                               Context cx, DefinitionNode definition)
    {
        StringBuilder originalOut = out;
        out = new StringBuilder();

        definition.evaluate(cx, this);
        String declaration = out.toString();
        Set<String> metaData = null;

        if (definition.metaData != null)
        {
            metaData = new TreeSet<String>();

            for (Node metaDataNode : definition.metaData.items)
            {
                out = new StringBuilder();
                metaDataNode.evaluate(cx, this);
                metaData.add(out.toString());
            }
        }

        declarations.put(declaration, metaData);

        out = originalOut;
    }

//     ___  _ _  ___  __  ___   __   _    _  _  _ ___   _   _   _  ___  ___  ___  ___
//    |_ _|| U || __|/ _|| __| |  \ / \  | \| |/ \_ _| | \_/ | / \|_ _||_ _|| __|| o \
//     | | |   || _| \_ \| _|  | o | o ) | \\ ( o ) |  | \_/ || o || |  | | | _| |   /
//     |_| |_n_||___||__/|___| |__/ \_/  |_|\_|\_/|_|  |_| |_||_n_||_|  |_| |___||_|\\
//
// These are in-use and can be commented out for production and left to the superclass.

    public void setLocalizationManager(LocalizationManager l10n)
    {
        super.setLocalizationManager(l10n);
    }

    public Value evaluate(Context cx, DocCommentNode node)
    {
        return super.evaluate(cx, node);
    }

    public Value evaluate(Context cx, EmptyStatementNode node)
    {
        return super.evaluate(cx, node);
    }

    // [1, 2, , 4] -- where 3 is an EmptyElementNode
    public Value evaluate(Context cx, EmptyElementNode node)
    {
        return super.evaluate(cx, node);
    }

    public Value evaluate(Context cx, IncludeDirectiveNode node)
    {
        return super.evaluate(cx, node);
    }

    public Value evaluate(Context cx, LiteralXMLNode node)
    {
        return super.evaluate(cx, node);
    }

    // TODO I'd like to find a way to generate one of these...
    //      should I catch this node and assume that the signature is not valid?
    public Value evaluate(Context cx, ErrorNode node)
    {
        return super.evaluate(cx, node);
    }
}



//     _   _      _                   _____ _
//    | | | |    | |                 /  __ \ |
//    | |_| | ___| |_ __   ___ _ __  | /  \/ | __ _ ___ ___  ___  ___
//    |  _  |/ _ \ | '_ \ / _ \ '__| | |   | |/ _` / __/ __|/ _ \/ __|
//    | | | |  __/ | |_) |  __/ |    | \__/\ | (_| \__ \__ \  __/\__ \
//    \_| |_/\___|_| .__/ \___|_|     \____/_|\__,_|___/___/\___||___/
//                 | |
//                 |_|


//      _  ___  ___  ___ _  ___ _ _  ___  ___   _  _  _  ___ _     __   _   __  _ _  ___
//     / \|_ _||_ _|| o \ || o ) | ||_ _|| __| | || \| || __/ \   / _| / \ / _|| U || __|
//    | o || |  | | |   / || o \ U | | | | _|  | || \\ || _( o ) ( (_ | o ( (_ |   || _|
//    |_n_||_|  |_| |_|\\_||___/___| |_| |___| |_||_|\_||_| \_/   \__||_n_|\__||_n_||___|

class AttributeInfoCache
{
    private Map<DefinitionNode, AttributeInfo> attributeInfoCache = new HashMap<DefinitionNode, AttributeInfo>();

    /**
     * This caches computed AttributeInfo objects because:
     *   - It's not cheap to compute (look at NodeMagic.getUserNamespace for instance)
     *   - Evaluating MetaData requires looking at the attributes of MetaData.def
     *   - The use case of a particular definition getting looked up more than once is
     *     pretty high (due to MetaData.def)
     */
    public AttributeInfo getAttributeInfo(DefinitionNode node)
    {
        AttributeInfo info = attributeInfoCache.get(node);

        if (info == null)
            attributeInfoCache.put(node, (info = new AttributeInfo(node)));

        return info;
    }
}



//      _  ___  ___  ___ _  ___ _ _  ___  ___   _  _  _  ___ _
//     / \|_ _||_ _|| o \ || o ) | ||_ _|| __| | || \| || __/ \
//    | o || |  | | |   / || o \ U | | | | _|  | || \\ || _( o )
//    |_n_||_|  |_| |_|\\_||___/___| |_| |___| |_||_|\_||_| \_/

class AttributeInfo
{
    public final boolean isInternal, isPrivate, isPublic, isProtected, isUser;

    /**
     * This is an expensive constructor, consider using an AttributeInfoCache
     * instead of calling this directly.
     */
    public AttributeInfo(DefinitionNode node)
    {
        final AttributeListNode attrs = node.attrs;

        // determine if we are internal
        if (attrs == null)
        {
            // implicit internal scope
            isPrivate = isPublic = isProtected = isUser = false;

            isInternal = true;
        }
        else
        {
            isPublic    = attrs.hasAttribute(NodeMagic.PUBLIC);
            isPrivate   = attrs.hasAttribute(NodeMagic.PRIVATE);
            isProtected = attrs.hasAttribute(NodeMagic.PROTECTED);
            isUser      = !NodeMagic.getUserNamespace(node).equals(QName.DEFAULT_NAMESPACE);

            isInternal  = (attrs.hasAttribute(NodeMagic.INTERNAL) ||
                    !(isPublic || isPrivate || isProtected || isUser));
        }
    }
}
