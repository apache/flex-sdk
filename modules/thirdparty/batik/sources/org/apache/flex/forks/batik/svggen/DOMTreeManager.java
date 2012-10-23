/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.svggen;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.Collections;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;
import org.w3c.dom.Comment;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * This class is used by the SVGGraphics2D SVG Generator to manage
 * addition of new Nodes to the SVG DOM Tree. This class handles
 * a set of DOMGroupManager objects that can all append to the
 * top level group managed by this class. This allows multiple
 * SVGGraphics2D instances, created from the same SVGGraphics2D
 * through the various create methods, to append to the same
 * SVG document and keep the rendering order correct.
 *
 * The root node managed by this DOMTreeManager contains two children:
 * a top level group node and a top level defs node. The top level
 * defs node contains the definition of common SVG entities such as
 * the various AlphaComposite rules. Note that other defs can also be
 * created under the top level group, for example to represent
 * gradient or pattern paints.
 * <br>
 * [svg]
 *   |
 *   +-- [defs] Contain generic definitions
 *   +-- [g]    Top level group
 *        |
 *        +-- [defs] Contains definitions specific to rendering
 *        +-- [g]    Group 1
 *        +-- ...
 *        +-- [g]    Group n
 *
 * @author <a href="mailto:cjolif">Christophe Jolif</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DOMTreeManager.java 522302 2007-03-25 17:04:48Z dvholten $
 */
public class DOMTreeManager implements SVGSyntax, ErrorConstants {

    /**
     * Maximum of Graphic Context attributes overrides
     * in children of the current group.
     */
    int maxGCOverrides;

    /**
     * Set of group managers that build groups for
     * this manager.
     * The synchronizedList is part of the fix for bug #40686
     */
    protected final List groupManagers = Collections.synchronizedList( new ArrayList() );

    /**
     * Set of definitions that are to be placed at the top of the
     * document tree
     */
    protected List genericDefSet = new LinkedList();

    /**
     * Default SVG GraphicContext state
     */
    SVGGraphicContext defaultGC;

    /**
     * Top level group
     */
    protected Element topLevelGroup;

    /**
     * Used to convert the Java 2D API graphic context state
     * into the SVG equivalent set of attributes and related
     * definitions
     */
    SVGGraphicContextConverter gcConverter;

    /**
     * The context that stores the domFactory, the imageHandler
     * and the extensionHandler.
     */
    protected SVGGeneratorContext generatorContext;

    /**
     * Converters used bVy this object to translate graphic context
     * attributes
     */
    protected SVGBufferedImageOp filterConverter;

    /**
     * Set of definitions which can be used by custom extensions
     */
    protected List otherDefs;

    /**
     * Constructor
     * @param gc default graphic context state
     * @param generatorContext the SVG generator context
     * @param maxGCOverrides defines how many overrides are allowed
     *                       in children nodes of the current group.
     */
    public DOMTreeManager(GraphicContext gc,
                          SVGGeneratorContext generatorContext,
                          int maxGCOverrides){
        if (gc == null)
            throw new SVGGraphics2DRuntimeException(ERR_GC_NULL);

        if (maxGCOverrides <= 0)
            throw new SVGGraphics2DRuntimeException(ERR_MAXGCOVERRIDES_OUTOFRANGE);

        if (generatorContext == null)
            throw new SVGGraphics2DRuntimeException(ERR_CONTEXT_NULL);

        this.generatorContext = generatorContext;
        this.maxGCOverrides = maxGCOverrides;

        // Start with a new Top Level Group
        recycleTopLevelGroup();

        // Build the default GC descriptor
        defaultGC = gcConverter.toSVG(gc);
    }

    /**
     * @param groupManager new DOMGroupManager to add to the list of
     *        managers that collaborate with this tree manager.
     */
    public void addGroupManager(DOMGroupManager groupManager){
        if(groupManager != null)
            groupManagers.add(groupManager);
    }

    /**
     * @param groupManager DOMGroupManager to remove from the list of
     *        managers that collaborate with this tree manager
     */
    public void removeGroupManager(DOMGroupManager groupManager){
        if(groupManager != null)
            groupManagers.remove( groupManager );
    }

    /**
     * When a group is appended to the tree by this call, all the
     * other group managers are requested to start new groups, in
     * order to preserve the Z-order.
     *
     * @param group new group to be appended to the topLevelGroup
     * @param groupManager DOMTreeManager that produced the group.
     */
    public void appendGroup(Element group, DOMGroupManager groupManager){
        topLevelGroup.appendChild(group);
        synchronized( groupManagers ){
            // we want to prevent that the groupManagers-list changes while
            // we iterate over it. If that would happen, we might skip entries
            // within the list or ignore new entries at the end. Fix #40686
            int nManagers = groupManagers.size();
            for(int i=0; i<nManagers; i++){
                DOMGroupManager gm = (DOMGroupManager)groupManagers.get(i);
                if( gm != groupManager )
                    gm.recycleCurrentGroup();
            }
        }
    }

    /**
     * Reset the state of this object to handler a new topLevelGroup
     */
    protected void recycleTopLevelGroup(){
        recycleTopLevelGroup(true);
    }


    /**
     * Reset the state of this object to handler a new topLevelGroup
     */
    protected void recycleTopLevelGroup(boolean recycleConverters){
        // First, recycle group managers
        synchronized( groupManagers ){
            // we want to prevent that the groupManagers-list changes while
            // we iterate over it. If that would happen, we might skip entries
            // within the list or ignore new entries at the end. Fix #40686
            int nManagers = groupManagers.size();
            for(int i=0; i<nManagers; i++){
                DOMGroupManager gm = (DOMGroupManager)groupManagers.get(i);
                gm.recycleCurrentGroup();
            }
        }

        // Create top level group node
        topLevelGroup = generatorContext.domFactory.
            createElementNS(SVG_NAMESPACE_URI, SVG_G_TAG);

        // Build new converters
        if (recycleConverters) {
            filterConverter =
                new SVGBufferedImageOp(generatorContext);
            gcConverter =
                new SVGGraphicContextConverter(generatorContext);
        }
    }

    /**
     * Sets the topLevelGroup to the input element. This will throw an
     * exception if the input element is not of type 'g' or if it is
     * null.
     */
    public void setTopLevelGroup(Element topLevelGroup){
        if(topLevelGroup == null)
            throw new SVGGraphics2DRuntimeException(ERR_TOP_LEVEL_GROUP_NULL);

        if(!SVG_G_TAG.equalsIgnoreCase(topLevelGroup.getTagName()))
            throw new SVGGraphics2DRuntimeException(ERR_TOP_LEVEL_GROUP_NOT_G);

        recycleTopLevelGroup(false);
        this.topLevelGroup = topLevelGroup;
    }

    /**
     * Returns the root element with the generic definitions and
     * the topLevelGroup.
     */
    public Element getRoot(){
        return getRoot(null);
    }

    /**
     * Returns the root element with the generic definitions and
     * the topLevelGroup.
     */
    public Element getRoot(Element svgElement){
        Element svg = svgElement;

        if (svg == null) {
            svg = generatorContext.domFactory.
                createElementNS(SVG_NAMESPACE_URI, SVG_SVG_TAG);
        }

        // Enable background if required by AlphaComposite convertion
        if (gcConverter.getCompositeConverter().
            getAlphaCompositeConverter().requiresBackgroundAccess())
            svg.setAttributeNS
                (null, SVG_ENABLE_BACKGROUND_ATTRIBUTE, SVG_NEW_VALUE);

        if (generatorContext.generatorComment != null) {
            Comment generatorComment = generatorContext.domFactory.
                createComment(generatorContext.generatorComment);
            svg.appendChild(generatorComment);
        }

        // Set default rendering context attributes in node
        applyDefaultRenderingStyle(svg);

        svg.appendChild(getGenericDefinitions());
        svg.appendChild(getTopLevelGroup());

        return svg;
    }

    public void applyDefaultRenderingStyle(Element element) {
        Map groupDefaults = defaultGC.getGroupContext();
        generatorContext.styleHandler.setStyle(element, groupDefaults, generatorContext);
    }

    /**
     * @return a defs element that contains all the generic
     *         definitions
     */
    public Element getGenericDefinitions() {
        // when called several times, this will create several generic
        // definition elements... not sure it is desired behavior...
        Element genericDefs =
            generatorContext.domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                        SVG_DEFS_TAG);
        Iterator iter = genericDefSet.iterator();
        while (iter.hasNext()) {
            genericDefs.appendChild((Element)iter.next());
        }

        genericDefs.setAttributeNS(null, SVG_ID_ATTRIBUTE, ID_PREFIX_GENERIC_DEFS);
        return genericDefs;
    }

    /**
     * @return the extension handler used by the DOMTreeManager.
     */
    public ExtensionHandler getExtensionHandler(){
        return generatorContext.getExtensionHandler();
    }

    /**
     * This will change the extension handler on the
     * <code>SVGGeneratorContext</code>.
     * @param extensionHandler new extension handler this object should use
     */
    void setExtensionHandler(ExtensionHandler extensionHandler) {
        generatorContext.setExtensionHandler(extensionHandler);
    }

    /**
     * Invoking this method will return a set of definition element that
     * contain all the definitions referenced by the attributes generated by
     * the various converters. This also resets the converters.
     */
    public List getDefinitionSet(){
        //
        // The definition set contains all the definitions minus
        // any definition that has been placed in the generic definition set
        //
        List defSet = gcConverter.getDefinitionSet();
        defSet.removeAll(genericDefSet);
        defSet.addAll(filterConverter.getDefinitionSet());
        if (otherDefs != null){
            defSet.addAll(otherDefs);
            otherDefs = null;
        }

        // Build new converters
        filterConverter = new SVGBufferedImageOp(generatorContext);
        gcConverter = new SVGGraphicContextConverter(generatorContext);

        return defSet;
    }

    /**
     * Lets custom implementations for various extensions add
     * elements to the <defs> sections.
     */
    public void addOtherDef(Element definition){
        if (otherDefs == null){
            otherDefs = new LinkedList();
        }

        otherDefs.add(definition);
    }

    /**
     * Invoking this method will return a reference to the topLevelGroup
     * Element managed by this object. It will also cause this object
     * to start working with a new topLevelGroup.
     *
     * @return top level group
     */
    public Element getTopLevelGroup(){
        boolean includeDefinitionSet = true;
        return getTopLevelGroup(includeDefinitionSet);
    }

    /**
     * Invoking this method will return a reference to the topLevelGroup
     * Element managed by this object. It will also cause this object
     * to start working with a new topLevelGroup.
     *
     * @param includeDefinitionSet if true, the definition set is included and
     *        the converters are reset (i.e., they start with an empty set
     *        of definitions).
     * @return top level group
     */
    public Element getTopLevelGroup(boolean includeDefinitionSet){
        Element topLevelGroup = this.topLevelGroup;

        //
        // Include definition set if requested
        //
        if(includeDefinitionSet){
            List defSet = getDefinitionSet();
            if(defSet.size() > 0){
                Element defElement = null;

                NodeList defsElements =
                    topLevelGroup.getElementsByTagName(SVG_DEFS_TAG);
                if (defsElements.getLength() > 0)
                    defElement = (Element)defsElements.item(0);

                if (defElement == null) {
                    defElement =
                        generatorContext.domFactory.
                        createElementNS(SVG_NAMESPACE_URI,
                                        SVG_DEFS_TAG);
                    defElement.
                        setAttributeNS(null, SVG_ID_ATTRIBUTE,
                                       generatorContext.idGenerator.
                                       generateID(ID_PREFIX_DEFS));
                    topLevelGroup.insertBefore(defElement,
                                               topLevelGroup.getFirstChild());
                }

                Iterator iter = defSet.iterator();
                while(iter.hasNext())
                    defElement.appendChild((Element)iter.next());
            }
        }

        // If the definition set is included, then the converters have already
        // been recycled in getDefinitionSet. Otherwise, they should not be
        // recycled. So, in all cases, do not recycle the converters here.
        recycleTopLevelGroup(false);

        return topLevelGroup;
    }

    public SVGBufferedImageOp getFilterConverter() {
        return filterConverter;
    }

    public SVGGraphicContextConverter getGraphicContextConverter() {
        return gcConverter;
    }

    SVGGeneratorContext getGeneratorContext() {
        return generatorContext;
    }

    Document getDOMFactory() {
        return generatorContext.domFactory;
    }

    StyleHandler getStyleHandler() {
        return generatorContext.styleHandler;
    }
}
