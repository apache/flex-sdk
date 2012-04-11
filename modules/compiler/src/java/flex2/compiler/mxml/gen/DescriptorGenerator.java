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

package flex2.compiler.mxml.gen;

import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.rep.DesignLayer;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MovieClip;
import flex2.compiler.mxml.rep.init.EventInitializer;
import flex2.compiler.mxml.rep.init.NamedInitializer;
import flex2.compiler.mxml.rep.init.VisualChildInitializer;
import flex2.compiler.util.NameFormatter;
import org.apache.commons.collections.Predicate;
import org.apache.commons.collections.iterators.FilterIterator;

import java.util.Collections;
import java.util.Iterator;
import java.util.Set;

/**
 * This utility class is used to generate the code for legacy Halo
 * descriptor trees, which are used at runtime to implement deferred
 * instantiation.
 *
 * @author Basil Hosmer
 */
public class DescriptorGenerator
{
    private final static String INDENT = "  ".intern();

    /**
     * wrapper for generating entire descriptor tree. See notes on includePropNames param below.
     */
    public static void addDescriptorInitializerFragments(CodeFragmentList list, Model model,
                                                         Set<String> includePropNames, boolean includeDesignLayer,
                                                         String indent)
    {
        addDescriptorInitializerFragments(list, model, indent, includePropNames, includeDesignLayer, true);
    }

    /**
     * convenience wrapper for generating non-toplevel descriptor entries
     */
    public static void addDescriptorInitializerFragments(CodeFragmentList list, Model model, String indent)
    {
        addDescriptorInitializerFragments(list, model, indent, null, true, false);
    }

    /**
     * @param includePropNames if non-null, this is a set of names of properties to include in the descriptor.
     *
     * A filtered set is sometimes needed to conform to the framework API, which requires a handful of properties
     * (e.g. height, width) be encoded into the top-level descriptor, even though procedural code sets all top-level
     * ('document') properties.
     *
     * Recursive calls to generateDescriptorCode() always pass null for this param, causing all child properties to be
     * encoded, as required by the framework.
     *
     * Note: as with includePropNames, non-property entries are only suppressed (controlled by the propsOnly param to
     * addDescriptorInitializerFragments being set to true) at the top level of the descriptor.
     *
     * Note: _childDescriptor, built from MovieClip.children, is encoded unconditionally at all levels.
     *
     * @param propsOnly if true, event, effect and style entries are suppressed. This is a top- vs. nontop-level
     * constraint, like includePropNames.
     */
    private static void addDescriptorInitializerFragments(CodeFragmentList list, Model model, String indent,
                                                          Set<String> includePropNames, boolean includeDesignLayer,
                                                          boolean propsOnly)
    {
        model.setDescribed(true);

        //  open ctor call
        list.add(indent, "new ", NameFormatter.toDot(model.getStandardDefs().CLASS_UICOMPONENTDESCRIPTOR), "({", 0);
        indent += DescriptorGenerator.INDENT;

        //  type
        list.add(indent, "type: ", NameFormatter.toDot(model.getType().getName()), model.getXmlLineNumber());

        //  id?
        if (model.isDeclared())
        {
            list.add(indent, ",", 0);
            list.add(indent, "id: ", TextGen.quoteWord(model.getId()), model.getXmlLineNumber());
        }
        
        //  events?
        if (!propsOnly)
            addDescriptorEvents(list, model, indent);

        //  effect names?
        if (!propsOnly)
            addDescriptorEffectNames(list, model, indent);

        //  styles and/or effects?
        if (!propsOnly)
            addDescriptorStylesAndEffects(list, model, indent);

        //  descriptor properties are Model.properties + synthetic property 'childDescriptors' from MovieClip.children
        addDescriptorProperties(list, model, includePropNames, includeDesignLayer, indent);

        //  close ctor call
        indent = indent.substring(0, indent.length() - INDENT.length());
        list.add(indent, "})", 0);
    }

    /**
     *
     */
    private static void addDescriptorProperties(CodeFragmentList list, Model model, final Set<String> includePropNames, 
                                                boolean includeDesignLayer, String indent)
    {
        //  ordinary properties
        Iterator propIter = includePropNames == null ?
                model.getPropertyInitializerIterator(false) :
                new FilterIterator(model.getPropertyInitializerIterator(false), new Predicate() {
                    public boolean evaluate(Object obj) { return includePropNames.contains(((NamedInitializer)obj).getName()); }
                });

        //  visual children
        Iterator vcIter = (model instanceof MovieClip && ((MovieClip)model).hasChildren()) ?
                ((MovieClip)model).children().iterator() :
                Collections.EMPTY_LIST.iterator();

        // designLayer ?
        Boolean hasDesignLayer = (includeDesignLayer && (model.layerParent != null) &&
                                  model.getType().isAssignableTo(model.getStandardDefs().INTERFACE_IVISUALELEMENT));
                
        if (propIter.hasNext() || vcIter.hasNext() || hasDesignLayer)
        {
            if (!list.isEmpty())
            {
                list.add(indent, ",", 0);
            }

            list.add(indent, "propertiesFactory: function():Object { return {", 0);
            indent += DescriptorGenerator.INDENT;
            
            while (propIter.hasNext())
            {
                NamedInitializer init = (NamedInitializer)propIter.next();
                if (!init.isStateSpecific())
                {
                    list.add(indent, init.getName(), ": ", init.getValueExpr(),
                            (propIter.hasNext() || vcIter.hasNext() || hasDesignLayer ? "," : ""),
                            init.getLineRef());
                }
            }
            
            if (hasDesignLayer)
            {
                list.add(indent, "designLayer", ": ", model.layerParent.getId(),
                		(vcIter.hasNext() ? "," : ""),
                		model.getXmlLineNumber());   
            }
         
            if (vcIter.hasNext())
            {
                list.add(indent, "childDescriptors: [", 0);

                // Generate each child descriptor unless the child as explicitly filtered out.
                boolean isFirst = true;
                while (vcIter.hasNext())
                {
                    VisualChildInitializer init = (VisualChildInitializer)vcIter.next();
                    Model child = (MovieClip)init.getValue();
                    if (child.isDescriptorInit()) 
                    {
                        if (!isFirst)
                        {
                            list.add(indent, ",", 0);
                        }
                        
                        addDescriptorInitializerFragments(list, child, indent + DescriptorGenerator.INDENT);
                        isFirst = false;
                    }

                }

                list.add(indent, "]", 0);
            }

            indent = indent.substring(0, indent.length() - INDENT.length());
            list.add(indent, "}}", 0);
        }
    }

    /**
     *
     */
    private static void addDescriptorStylesAndEffects(CodeFragmentList list, Model model, String indent)
    {
        Iterator styleAndEffectIter = model.getStyleAndEffectInitializerIterator();
        if (styleAndEffectIter.hasNext())
        {
            if (!list.isEmpty())
            {
                list.add(indent, ",", 0);
            }

            list.add(indent, "stylesFactory: function():void {", 0);
            indent += DescriptorGenerator.INDENT;

            while (styleAndEffectIter.hasNext())
            {
                NamedInitializer init = (NamedInitializer)styleAndEffectIter.next();
                list.add(indent, "this.", init.getName(), " = ", init.getValueExpr() + ";", init.getLineRef());
            }

            indent = indent.substring(0, indent.length() - INDENT.length());
            list.add(indent, "}", 0);
        }
    }

    /**
     *
     */
    private static void addDescriptorEffectNames(CodeFragmentList list, Model model, String indent)
    {
        String effectEventNames = model.getEffectNames();
        if (effectEventNames.length() > 0)
        {
            if (!list.isEmpty())
            {
                list.add(indent, ",", 0);
            }

            list.add(indent, "effects: [ ", effectEventNames, " ]", model.getXmlLineNumber());
        }
    }

    /**
     *
     */
    private static void addDescriptorEvents(CodeFragmentList list, Model model, String indent)
    {
        Iterator eventIter = model.getEventInitializerIterator();
        if (eventIter.hasNext())
        {
            if (!list.isEmpty())
            {
                list.add(indent, ",", 0);
            }

            list.add(indent, "events: {", 0);
            indent += DescriptorGenerator.INDENT;

            while (eventIter.hasNext())
            {
                EventInitializer init = (EventInitializer)eventIter.next();
                list.add(indent, init.getName(), ": ", TextGen.quoteWord(init.getValueExpr()),
                            (eventIter.hasNext() ? "," : ""),
                        init.getLineRef());
            }

            indent = indent.substring(0, indent.length() - INDENT.length());
            list.add(indent, "}", 0);
        }
    }
}
