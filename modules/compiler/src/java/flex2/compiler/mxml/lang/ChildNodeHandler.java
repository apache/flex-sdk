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

package flex2.compiler.mxml.lang;

import flex2.compiler.mxml.dom.CDATANode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.reflect.*;

import java.util.Iterator;

/**
 * Extends DeclarationHandler to resolve child nodes. If
 * DeclarationHandler fails to resolve a child node's name, we go
 * through a series of child-node specific attempts at resolution.
 * <p>Note: language nodes (script, etc.) are not recognized. Up to
 * implementer to deal with 'em.
 */
public abstract class ChildNodeHandler extends DeclarationHandler
{
    protected final TypeTable typeTable;
    protected final boolean isFXG;
    protected final NodeTypeResolver nodeTypeResolver;
    protected final CoreDeclarationHandler coreDeclarationHandler;

    protected Node parent;
    protected Type parentType;
    protected Node child;
    protected int state;

    public ChildNodeHandler(TypeTable typeTable, boolean isFXG)
    {
        this.typeTable = typeTable;
        this.isFXG = isFXG;
        this.nodeTypeResolver = new NodeTypeResolver(typeTable);
        this.coreDeclarationHandler = new CoreDeclarationHandler();
    }

    /**
     * child node resolves to default property initializer node. valueCount indicates this node's position in the
     * sequence of default property initializer nodes under our parent.
     * @param locError
     */
    protected abstract void defaultPropertyElement(boolean locError);

    /**
     * child node resolves to a nested component declaration
     * <p>Note: if this method fires, child is guaranteed to be a value node, but not necessarily a Node. See
     * <code>ValueNodeResolver</code>.
     */
    protected abstract void nestedDeclaration();

    /**
     *
     */
    protected abstract void textContent();

    /**
     * e.g. language nodes, (script, etc.)
     */
    protected abstract void languageNode();

    /**
     * public entry point for scanning children - must all be done in one pass to properly enforce regional constraints
     */
    public void scanChildNodes(Node node, Type type)
    {
        resetState();
        for (Iterator iter = node.getChildIterator(); iter.hasNext(); )
        {
            invoke(node, type, (Node)iter.next());
        }
    }

    /**
     * Implements child node resolution as follows:
     * <pre>
     * If node is CDATA, then it's either
     * 1. a (non-binding-expression) text initializer for a default property, or
     * 2. text content (binding or non) to be applied to the parent node "as a whole"
     *
     * Otherwise, if the node is a "value node" (i.e., not a special language node), then it's either
     * 3. a event|property|effect|style declaration (see DeclarationHandler), or
     * 4. a default property initializer, if the parent's backing class has a default property (see unknown()), or
     * 5. a nested declaration (see unknown())
     *
     * 6. Otherwise, it's a language node.
     * </pre>
     * Note that the "non-binding-expression" qualification in (1) is due to the need to support the following syntax:
     * <pre>
     * &lt;App&gt;
     *  &lt;Comp id="comp"&gt;
     *      {expr}
     *  &lt;/Comp&gt;
     * &lt;/App&gt;
     * </pre>
     * For backwards compatibility, this must always be interpreted as setting a binding on App.comp, rather than on
     * App.comp.defaultProperty.
     */
    protected void invoke(Node parent, Type parentType, Node child)
    {
        //  String msg = "ChildNodeHandler[" + parent.image + "/" + parent.beginLine + ":" + parentType.getName() + "].invoke(" + child.image + "/" + child.beginLine + "): ";

        this.parent = parent;
        this.parentType = parentType;
        this.child = child;

        if (child instanceof CDATANode)
        {
            if (parentType.getDefaultProperty() != null)
            {
                transition(INPUT_DP_CHILD);
                defaultPropertyElement(getError() == ERR_DP_LOCATION);
            }
            else
            {
                transition(INPUT_NON_DP_CHILD);
                textContent();
            }
        }
        else if (NodeTypeResolver.isValueNode(child))
        {
            String namespace = child.getNamespace();
            String localPart = child.getLocalPart();

            if (child.getAttributeCount() == 0 && namespace.equals(this.parent.getNamespace()))
            {
                // We will treat state-specific value nodes separately during generation.
                if (TextParser.isScopedName(localPart))
                {
                    String[] statefulName = TextParser.analyzeScopedName(localPart);
                    localPart = (statefulName != null) ? statefulName[0] : localPart;
                }

                coreDeclarationHandler.invoke(this.parentType, namespace, localPart);
            }
            else
            {
                // System.out.println(msg + "unknown()");
                // WARNING: passing null is only okay as long as name remains unused in the implementation of unknown()...
                //     if you're not sure, use this: unknown(new QName(namespace, localPart).toString());
                unknown(namespace, localPart);
            }
        }
        else
        {
            languageNode();
        }
    }
    
   /**
    * Defer to our core declaration handler for state-centric invocations as well.
    */
    protected void invoke(Type type, String namespace, String localPart, String state)
    {
        coreDeclarationHandler.invoke(type, namespace, localPart, state);
    }

    /**
     * try our additional cases.
     * NOTE: the "visual child of visual container" special case is implemented in nestedDeclaration()
     */
    protected final void unknown(String namespace, String localPart)
    {
        //  String msg = "\tChildNodeHandler[" + parent.image + "/" + parent.beginLine + ":" + parentType.getName() + "].unknown(" + localPart + "/" + child.beginLine + "): ";
        if (parentType.getDefaultProperty() != null)
        {
            //  System.out.println(msg + "defaultPropertyElement()");
            transition(INPUT_DP_CHILD);
            defaultPropertyElement(getError() == ERR_DP_LOCATION);
        }
        else
        {
            //  System.out.println(msg + "nestedDeclaration()");
            transition(INPUT_NON_DP_CHILD);
            nestedDeclaration();
        }
    }

    /**
     *
     */
    protected final class CoreDeclarationHandler extends DeclarationHandler
    {
        protected void event(Event event)
        {
            transition(INPUT_NON_DP_CHILD);
            ChildNodeHandler.this.event(event);
        }

        protected void states(Property property)
        {
            transition(INPUT_NON_DP_CHILD);
            ChildNodeHandler.this.states(property);
        }
        
        protected void property(Property property)
        {
            transition(INPUT_NON_DP_CHILD);
            ChildNodeHandler.this.property(property);
        }

        protected void effect(Effect effect)
        {
            transition(INPUT_NON_DP_CHILD);
            ChildNodeHandler.this.effect(effect);
        }

        protected void style(Style style)
        {
            transition(INPUT_NON_DP_CHILD);
            ChildNodeHandler.this.style(style);
        }

        protected void dynamicProperty(String name, String state)
        {
            transition(INPUT_NON_DP_CHILD);
            ChildNodeHandler.this.dynamicProperty(name, state);
        }

        protected void unknown(String namespace, String localPart)
        {
            ChildNodeHandler.this.unknown(namespace, localPart);
        }

        public void invoke(Type type, String namespace, String localPart)
        {
            invoke(type, namespace, localPart, (String) null);
        }
    }

    /**
     * State mgmt
     */

    //  states
    protected final static int STATE_BEFORE_DP_CHILDREN = 0, STATE_IN_DP_CHILDREN = 1, STATE_AFTER_DP_CHILDREN = 2;
    protected final static int NUM_STATES = STATE_AFTER_DP_CHILDREN + 1;
    protected final static int STATE_BITS = (1 << 4) - 1;

    //  inputs
    protected final static int INPUT_NON_DP_CHILD = 0, INPUT_DP_CHILD = 1;
    protected final static int NUM_INPUTS = INPUT_DP_CHILD + 1;

    //  errors
    protected final static int ERR_DP_LOCATION = 1 << STATE_BITS;

    //  transitions - state x input -> state | error
    protected final static int TRAN[] =
    {
        STATE_BEFORE_DP_CHILDREN,                  //   ST_BEFORE_DP_CHILDREN x AT_NON_DP_CHILD,
        STATE_IN_DP_CHILDREN,                       //  ST_BEFORE_DP_CHILDREN x AT_DP_CHILD,

        STATE_AFTER_DP_CHILDREN,                    //  ST_IN_DP_CHILDREN x AT_NON_DP_CHILD,
        STATE_IN_DP_CHILDREN,                       //  ST_IN_DP_CHILDREN x AT_DP_CHILD,

        STATE_AFTER_DP_CHILDREN,                    //  ST_AFTER_DP_CHILDREN x AT_NON_DP_CHILD,
        STATE_AFTER_DP_CHILDREN | ERR_DP_LOCATION   //  ST_AFTER_DP_CHILDREN x AT_DP_CHILD,
    };

    //  drift checks
    static
    {
        assert NUM_STATES <= STATE_BITS;
        assert TRAN.length == NUM_STATES * NUM_INPUTS;
    }

    /**
     *
     */
    protected int getState()
    {
        return state & STATE_BITS;
    }

    /**
     *
     */
    protected int getError()
    {
        return state & ~STATE_BITS;
    }

    /**
     *
     */
    protected void resetState()
    {
        state = STATE_BEFORE_DP_CHILDREN;
    }

    /**
     *
     */
    protected void transition(int input)
    {
        state = TRAN[(getState() * NUM_INPUTS) + input];
    }
}
