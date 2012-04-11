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

package flex2.compiler.mxml.rep;

import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.mxml.gen.CodeFragmentList;
import flex2.compiler.mxml.gen.StatesGenerator;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.rep.DocumentInfo;
import flex2.compiler.mxml.rep.decl.PropertyDeclaration;
import flex2.compiler.mxml.rep.init.ValueInitializer;
import flex2.compiler.mxml.rep.init.EventInitializer;
import flex2.compiler.mxml.rep.init.Initializer;
import flex2.compiler.mxml.rep.init.NamedInitializer;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.IteratorList;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.mxml.reflect.ElementTypeNotFound;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.Property;
import flex2.compiler.mxml.reflect.Style;
import flex2.tools.oem.Library;
import macromedia.asc.parser.*;

import java.util.*;

/**
 * This class is responsible for maintaining a record of all state-specific nodes and 
 * properties within an an MXML document instance.  Additionally this model is then
 * transformed into a set of runtime DOM overrides.
 */
public final class StatesModel
{    
    public final DocumentInfo info;
    public final MxmlDocument document;
    public final StandardDefs standardDefs;
    public final Map<String,State> states;
    public final Map<String, SharedObject> sharedObjects;
    public final Set<Object> initializedModels;
    public final List<String> earlyInitObjects;
    private Map<String, List<ReparentInfo>> reparentNodes;
    private Collection<Model> statefulModels;
    private final Set<String> statesDefined;
   
    // Interned constants used for AST generation.
    private static final String _FACTORY = "_factory".intern();
    private static final String ADDITEMS = "AddItems".intern();
    private static final String DESTINATION = "destination".intern();
    private static final String DESTRUCTIONPOLICY = "destructionPolicy".intern();
    private static final String HANDLERFUNCTION = "handlerFunction".intern();
    private static final String INITIALIZEFROMOBJECT = "initializeFromObject".intern();
    private static final String ISARRAY = "isArray".intern();
    private static final String ISBASEVALUEDATABOUND = "isBaseValueDataBound".intern();
    private static final String ISSTYLE = "isStyle".intern();
    private static final String ITEMSFACTORY = "itemsFactory".intern();
    private static final String LESS_THAN = "<";
    private static final String NAME = "name".intern();
    private static final String OVERRIDES = "overrides".intern();
    private static final String ORIGINALHANDLERFUNCTION = "originalHandlerFunction".intern();
    private static final String POSITION = "position".intern();
    private static final String PROPERTYNAME = "propertyName".intern();
    private static final String RELATIVETO = "relativeTo".intern();
    private static final String SETPROPERTY = "SetProperty".intern();
    private static final String SETSTYLE = "SetStyle".intern();
    private static final String SETEVENTHANDLER = "SetEventHandler".intern();
    private static final String STATE = "State".intern();
    private static final String STATEGROUPS = "stateGroups".intern();
    private static final String TARGET = "target".intern();
    private static final String UNDEFINED = "undefined".intern();
    private static final String VALUE = "value".intern();
    private static final String VALUEFACTORY = "valueFactory".intern();
    private static final String VECTORCLASS = "vectorClass".intern();

    /*
     * Constructor
     */
    public StatesModel(MxmlDocument doc, DocumentInfo info, StandardDefs defs)
    {
        this.info = info;
        this.document = doc;
        this.standardDefs = defs;
        states = new HashMap<String,State>();
        sharedObjects = new TreeMap<String, SharedObject>();
        earlyInitObjects = new ArrayList<String>();
        statefulModels = new ArrayList<Model>();
        initializedModels = new HashSet<Object>();
        statesDefined = new HashSet<String>();
        
        if ((!info.getStateNames().isEmpty()) && info.getVersion() >= 4 )
        {
            info.addImportName(NameFormatter.toDot(standardDefs.CLASS_STATE), 0);
            info.addInterfaceName(NameFormatter.toDot(standardDefs.INTERFACE_ISTATECLIENT2), 0);
        }
    }
    
    /*
     * Ensure that a state-specific node or property is targetting a state
     * that was previously defined within the 'mx:states' list or implicitly
     * as a state-group.
     */
    public boolean validateState(String state)
    { 
         boolean isValid = (state != null) ? info.getStateNames().contains(state) : false;
         isValid = !isValid ? info.getStateGroups().containsKey(state) : true;
         return isValid;
    }
    
    /*
     * Returns whether or not any states have been defined.
     */
    public boolean isEmpty()
    {
        return states.isEmpty();
    }
    
    /*
     * If a default state was not specified, ensure that we default to the
     * first named state in our states list.
     */
    public void setInitialState()
    {
        if (info.getVersion() >= 4)
        {
            Model root = document.getRoot();
            Set<String> states = info.getStateNames();
            if (!states.isEmpty() && !root.hasProperty(StandardDefs.PROP_CURRENTSTATE) )
            {
                root.setProperty(StandardDefs.PROP_CURRENTSTATE, states.iterator().next(), 0);
            }
        }
    }
    
    /*
     * Register a realized State tag so the id and any event initializers are accounted
     * for during code generation.
     */
    public void registerState(Model model, Node node)
    { 
        String name = (String) node.getAttributeValue("", "name");
        if (states != null && name != null)
        {
        	if (statesDefined.contains(name))
        	{
        		ThreadLocalToolkit.log(new DuplicateState(name), document.getSourcePath(), model.getXmlLineNumber());
        		return;
        	}
        		
            State state = stateByName(name);
            state.model = model;
            statesDefined.add(name);
        }
    }
    
    /*
     * Take note of a model which is to be considered transient (state-specific).  Generate the appropriate
     * override (AddItems) to represent this state-specific node, and append to the corresponding state's
     * override list.
     */
    public void registerStateSpecificNode(Model model, Node node, Collection<String> includedStates, Collection<String> excludedStates)
    {     
        // Register the model for later processing.
        statefulModels.add(model);
        
        // Obtain parent context so we can later ensure it is declared.      
        Model context = model.getParent();
        
        // For now we defer any reparent nodes we find so that later, after 
        // we process the document, we can generate the appropriate reparenting
        // overrides (after all definition names are valid).
        if (node.getLocalPart().equals("Reparent"))
        {
            queueReparent(model, node, includedStates, excludedStates, getSiblingCount(context));
            return;
        }
        
        // Analyze siblings to determine if any of our preceding siblings are
        // themselves stateful.  This will dictate the list of siblings that 
        // we are to consider during relative placement in the DOM.
        ArrayList<Model> relativeNodes = null;
        String position = null;
        
        if ((context.getType() == document.getTypeTable().arrayType) ||
            (context.getType().getElementType() != null) ||
            (context instanceof MovieClip))
        {
            ArrayList siblings = context instanceof MovieClip ?
                   (ArrayList)((MovieClip)context).children() :
                   (ArrayList)((Array)context).getEntries();
                   
            relativeNodes = buildRelativeSiblingList(model, siblings, (siblings != null) ? (siblings.size() - 1) : 0);
            position = relativeNodes.isEmpty() ? "first" : "after";
        }
        
        // If our current node is an array or vector element, take
        // note of the property which our parent is associated with
        // and ensure declaration of the new node.
        String parentProperty = null;
        if ((context.getType() == document.getTypeTable().arrayType) ||
            (context.getType().getElementType() != null))
        {   
            parentProperty = (context.getParentIndex() != null) ? context.getParentIndex() : context.getId();
            context = context.getParent(); 
            model.ensureDeclaration();
        }
        
        // Ensure declaration of the new node if this happens to be
        // special case of Array or Vector.
        if ((model instanceof Array) || (model instanceof Vector))
        {
            model.ensureDeclaration();
            model.ensureBindable();
        }
         
        // Ensure that our destination context and model are accessible at runtime by name.
        if (context != null)
        {
            context.ensureDeclaration();
            context.ensureBindable();
        }

        // Generate consistent white list of states
        Collection<String> states = consolidateStateNames(includedStates, excludedStates);
        
        // We want to make sure a constructor is generated so we can use for
        // our state target factory.
        model.setStateSpecific(true);
        model.setStates(states);
        model.setDescriptorInit(false);

        Model destination = (context != null && context.getParent() != null) ? context : null;
        
        // Special case for ItemsComponent. The default property is "contentFactory", but we don't
        // want to specify that in the AddItems code. By eliminating the property name, we rely
        // on the runtime to figure out the right thing to do. 
        Type parentType = destination != null ? destination.getType() : document.getRoot().getType();
        if (standardDefs.isItemsComponent(parentType) && 
            parentType.getDefaultProperty().getName() == parentProperty)
        {
            parentProperty = null;
        }

        // Validate we're ok to use include/exclude on this node (exclude scalar values)
        if (!validateStatefulModelType(model, destination, parentProperty))
            return;
        
        // Now that we've inferred context, construct our override descriptor.
        constructAddItems(model, destination, parentProperty, 
                (context != null) ? context.getId() : null, position, relativeNodes, states);
    }
    
    /*
     * Take note of a reparent's target model which is to be considered transient (state-specific).  Generate the
     * overrides (RemoveItems/AddItems) to represent this state-specific node, and append to the corresponding 
     * override list.
     */
    private boolean processReparentNode(ReparentInfo reparentNode, Model targetModel)
    {             
        // Ensure relative context (parent, or immediate sibling(s)) is
        // accessible as top level property.       
        Model context = reparentNode.model.getParent();
        
        // Analyze siblings to determine if any of our preceding siblings are
        // themselves stateful.  This will dictate the list of siblings that 
        // we are to consider during relative placement in the DOM.
        ArrayList<Model> relativeNodes = null;
        String position = null;
        
        if ((context.getType() == document.getTypeTable().arrayType) ||
            (context.getType().getElementType() != null) ||
            (context instanceof MovieClip))
        {
            ArrayList siblings = context instanceof MovieClip ?
                   (ArrayList)((MovieClip)context).children() :
                   (ArrayList)((Array)context).getEntries();
                   
            relativeNodes = buildRelativeSiblingList(targetModel, siblings, reparentNode.childIndex - 1);
            position = relativeNodes.isEmpty() ? "first" : "after";
        }
        
        // If our current node is an array or vector element, take
        // note of the property which our parent is associated with.
        String parentProperty = null;
        if ((context.getType() == document.getTypeTable().arrayType) ||
            (context.getType().getElementType() != null))
        {            
            parentProperty = (context.getParentIndex() != null) ? context.getParentIndex() : context.getId();
            context = context.getParent();
        }
        
        // Ensure that our destination context is accessible at runtime by name.
        if (context != null && context.getIdIsAutogenerated())
        {
            document.addDeclaration(context.getId(), context.getType().getName(), context.getXmlLineNumber(),
                    true, true, true, true);
        }

        // Infer our destination from the context.
        Model destination = (context != null && context.getParent() != null) ? context : null;
        
        // Special case for ItemsComponent. The default property is "contentFactory", but we don't
        // want to specify that in the AddItems code. By eliminating the property name, we rely
        // on the runtime to figure out the right thing to do. 
        Type parentType = destination != null ? destination.getType() : document.getRoot().getType();
        if (standardDefs.isItemsComponent(parentType) && 
            parentType.getDefaultProperty().getName() == parentProperty)
        {
            parentProperty = null;
        }
      
        // Validate our reparent and construct our override nodes.
        if (!validateReparentStates(reparentNode.states, reparentNode, targetModel))
            return false;
        
        // Validate the node we are reparenting is of a compatible type for the destination.
        if (!validateReparentType(targetModel, destination, parentProperty, reparentNode))
            return false;
        
        // Now that we've inferred context, construct our override descriptor.
        constructAddItems(targetModel, destination, parentProperty, (context != null) ? context.getId() : null, position, 
                relativeNodes, reparentNode.states);
        
        return true;
    }
    
    /*
     * Apply states metadata for this component.
     */
    public void applyMetadata()
    {
        Set<String> states = info.getStateNames();
        if (!states.isEmpty())
        {
            String metadata = "[States(";
            for (Iterator<String> iter = states.iterator(); iter.hasNext(); )
            {
                String state = iter.next();
                metadata += "\"" + state + "\"";
                metadata += iter.hasNext() ? ", " : "";
            }
            metadata += ")]";
            Script script = new Script( metadata );
            document.addMetadata( script );
        }
    }
    
    /*
     * Save the information for a reparent node, for later processing.
     */
    private void queueReparent(Model model, Node node, Collection<String> includedStates, Collection<String> excludedStates, int childIndex)
    {
        reparentNodes = (reparentNodes != null) ? reparentNodes : new HashMap<String, List<ReparentInfo>>();
        List<ReparentInfo> nodes = reparentNodes.get(model.getId());
        nodes = (nodes != null) ? nodes : new ArrayList<ReparentInfo>();
        Collection<String> states = consolidateStateNames(includedStates, excludedStates);
        model.setStates(states);
        nodes.add(new ReparentInfo(model, node, states, childIndex));
        reparentNodes.put(model.getId(), nodes);
    }
    
    /*
     * Ensures that the states specified for a given node are compatible with those states
     * our ancestors may be in. Flag errors accordingly if a node is to be realized in a state
     * that an ancestor is explicitly excluded.  Also detect circular references that
     * may have been caused by reparent tag.
     */
    private boolean ensureCompatibleAncestors(Model model, Model destination, Collection<String> states, Model startNode)
    {
        Model currentModel = destination;
        while (currentModel != null)
        {
            // Check that we haven't ended up in a cycle caused by a reparent.
            if (startNode == currentModel)
            {
                ThreadLocalToolkit.log(new CircularReparent(states.iterator().next()), 
                        document.getSourcePath(), currentModel.getXmlLineNumber());
                return false;
            }
            
            // Check that the current ancestor is declared within all states
            // that our model is.
            Collection<String> extraStates = checkForExtraStates(currentModel, model, states);
            if (!extraStates.isEmpty())
            {
                for (Iterator<String> iter = extraStates.iterator(); iter.hasNext(); )
                {
                    String state = iter.next();
                    Model reparent =  getReparentForState(currentModel, state);
                    if (reparent != null)
                    {
                        Collection<String> reparentState = new ArrayList<String>();
                        reparentState.add(state);
                        boolean result = ensureCompatibleAncestors(model, reparent, reparentState, startNode);
                        if (!result) return false;
                    }
                    else
                    {
                        ThreadLocalToolkit.log(new IncompatibleState(state), 
                                document.getSourcePath(), model.getXmlLineNumber());
                        return false;
                    }
                }   
            }
            
            // If the currentModel is an rvalue node or descendant of
            // a state-specific property, validate that the states are
            // compatible.
            if (currentModel.getParentIndexState() != null)
            {
                String state = states.iterator().next();
                if (states.size() != 1 || !state.equals(currentModel.getParentIndexState()))
                {
                    ThreadLocalToolkit.log(new IncompatibleState(state), 
                            document.getSourcePath(), model.getXmlLineNumber());
                    return false;
                }
            }
            
            currentModel = currentModel.getParent();
        }   
        return true;
    }
    
    /*
     * Returns true if the given ancestor is to be realized within the list of states 
     * provided (inclusive).  Report error otherwise 
     */
    private Collection<String> checkForExtraStates(Model ancestor, Model model, Collection<String> states)
    {
        Collection<String> results = new ArrayList<String>();
        if (ancestor.isStateSpecific())
        {
            for (Iterator<String> iter = states.iterator(); iter.hasNext(); )
            {
                String state = iter.next();
                if (!ancestor.hasState(state))
                    results.add(state);
            }
        }
        return results;
    }
    
    /*
     * Ensures that the states specified for a given reparent target don't overlap
     * with the target's existing states list.
     */
    private boolean validateReparentStates(Collection<String> states, ReparentInfo reparentNode, Model target)
    {
        List<ReparentInfo> list = reparentNodes.get(target.getId());
        
        // First check the list of states set on the target model itself.
        for (Iterator<String> iter = states.iterator(); iter.hasNext(); )
        {
            String currentState = iter.next();
            if ((!target.isStateSpecific()) || target.hasState(currentState))
            {
                ThreadLocalToolkit.log(new InvalidReparentState(currentState, target.getId()), document.getSourcePath(), reparentNode.model.getXmlLineNumber());
                return false;
            }
            
            // Now ensure this reparent node isn't conflicting with another.
            for (Iterator<ReparentInfo> listIter = list.iterator(); listIter.hasNext(); )
            {
                ReparentInfo node = (ReparentInfo) listIter.next();
                if ((node != reparentNode) && node.states.contains(currentState))
                {
                    ThreadLocalToolkit.log(new ConflictingReparentTags(currentState, target.getId()), document.getSourcePath(), reparentNode.model.getXmlLineNumber());
                    return false;
                }
            }
        }  
        return true;
    }
    
    /*
     * Ensures that the instance we are reparenting is compatible with the destination
     * type.
     */
    private boolean validateReparentType(Model targetModel, Model destination, String parentProperty, ReparentInfo reparentNode)
    {
        Type childType = targetModel.getType();
        Type parentType = destination != null ? destination.getType() : document.getRoot().getType();
        
        if (standardDefs.isContainer(parentType) && standardDefs.isIUIComponent(childType) && parentProperty == null)
        {
            return true;
        }
        else if (parentProperty != null || parentType.getDefaultProperty() != null)
        {
            Property property = (parentProperty != null) ? parentType.getProperty(parentProperty) : parentType.getDefaultProperty();
            Style style = (parentProperty != null) ? parentType.getStyle(parentProperty) : null;
            
            if (standardDefs.isItemsComponent(parentType) && (property.getName() == parentType.getDefaultProperty().getName()))
            {
                return true;
            }
            
            if ((property != null) && 
                ((property.getType() == document.getTypeTable().arrayType) ||
                 (property.getType().getElementType() != null)))
            {
                Type propertyElementType = property.getElementType();

                if ((propertyElementType == null) || childType.isAssignableTo(propertyElementType))
                    return true;
            }
            else if (property != null && isStatefulCompatibleType(property.getType()))
            {
                return true;
            }
            else if (style != null && isStatefulCompatibleType(style.getType()))
            {
                return true;
            }
        }
        
        ThreadLocalToolkit.log(new IncompatibleReparentType(targetModel.getId()), document.getSourcePath(), reparentNode.model.getXmlLineNumber());
        return false;
    }
    
    /*
     * Ensures that the instance we are marking state-specific is not a scalar property value.
     */
    private boolean validateStatefulModelType(Model targetModel, Model destination, String parentProperty)
    {
        Type parentType = destination != null ? destination.getType() : document.getRoot().getType();
        Property property = (parentProperty != null) ? parentType.getProperty(parentProperty) : parentType.getDefaultProperty();
        Style style = (parentProperty != null) ? parentType.getStyle(parentProperty) : null;
        
        if (parentType != null && property != null && (standardDefs.isItemsComponent(parentType) && 
            (property.getName() == parentType.getDefaultProperty().getName())))
        {
            return true;
        }
        if (property != null && !isStatefulCompatibleType(property.getType()))
        {
            ThreadLocalToolkit.log(new IncompatibleStatefulNode(), document.getSourcePath(), targetModel.getXmlLineNumber());
            return false;
        }
        else if (style != null && !isStatefulCompatibleType(style.getType()))
        {
            ThreadLocalToolkit.log(new IncompatibleStatefulNode(), document.getSourcePath(), targetModel.getXmlLineNumber());
            return false;
        }
           
        return true;
    }
    
    /*
     * Helper that checks a type is either object, *, or array.
     */
    private boolean isStatefulCompatibleType(Type type)
    {
        return ((type == document.getTypeTable().arrayType) ||
                (type.getElementType() != null) ||
                (type == document.getTypeTable().objectType) ||
                (type == document.getTypeTable().noType));
    }
    
    /*
     * Helper used to generate a consistent white list of state names. 
     * Expands all state-group macros as well.
     */
    private Collection<String> consolidateStateNames(Collection<String> includedStates, Collection<String> excludedStates)
    {
        Collection<String> states = !includedStates.isEmpty() ? includedStates : inverseOf(excludedStates);
        return expandStateList(states);
    }
    
    /*
     * Helper used to expand a state identifier if necessary from a state-group.
     */
    private Set<String> expandState(String state)
    {
        Set<String> states = new HashSet<String>();
        Map <String, Collection<String>> groupMap = info.getStateGroups();
        
        if (groupMap.containsKey(state))
        {
            states.addAll(groupMap.get(state));
        }
        else
        {
            states.add(state);
        }
        
        return states;
    }
    
    /*
     * Helper used to expand a list of state identifiers, resolving all
     * state-group macros along the way.
     */
    private Set<String> expandStateList(Collection<String> stateList)
    {
        Set<String> expandedStates = new HashSet<String>();
        Map <String, Collection<String>> groupMap = info.getStateGroups();
        
        for (Iterator<String> iter = stateList.iterator(); iter.hasNext(); )
        {
            String state = iter.next();
            if (groupMap.containsKey(state))
            {
                expandedStates.addAll(groupMap.get(state));
            }
            else
            {
                expandedStates.add(state);
            }
        }
        
        return expandedStates;
    }
    
    /*
     * Helper for reparent nodes to infer the tags position relative to its siblings.
     */
    private int getSiblingCount(Model model)
    {
        if ((model.getType() == document.getTypeTable().arrayType) ||
            (model.getType().getElementType() != null) ||
            (model instanceof MovieClip))
        {
            ArrayList siblings = model instanceof MovieClip ?
                    (ArrayList)((MovieClip)model).children() :
                    (ArrayList)((Array)model).getEntries();
            return (siblings != null) ? siblings.size() : 0;     
        }
        return 0;
    }
    
    /*
     * Walk through all pending reparent nodes and generate overrides representing each.
     */
    public boolean processReparents()
    {
        if (reparentNodes != null && !reparentNodes.isEmpty())
        {
            for (Iterator<String> iter = reparentNodes.keySet().iterator(); iter.hasNext(); )
            {
                List<ReparentInfo> list = reparentNodes.get(iter.next());
                for (Iterator<ReparentInfo> listIter = list.iterator(); listIter.hasNext(); )
                {
                    ReparentInfo node = listIter.next();
                    String target = node.model.getId();
                    PropertyDeclaration decl = document.getDeclaration(target);
                    if (decl != null && decl instanceof ValueInitializer)
                    {
                        ValueInitializer initializedDecl = (ValueInitializer) decl;
                        Model model = (Model) initializedDecl.getValue();
                        if (!processReparentNode(node, model))
                            return false;
                    }
                    else
                    {
                        ThreadLocalToolkit.log(new TargetResolutionError(target), document.getSourcePath(), node.model.getXmlLineNumber());
                        return false;
                    }
                }
            }
        }
        return true;
    }
    
    /*
     * Walk through all state-specific models in order to validate they can be 
     * fully realized (for all states).
     */
    public void processStatefulModels()
    {
        for (Iterator<Model> models = statefulModels.iterator(); models.hasNext(); )
        {
            Model model = models.next();
            ensureCompatibleAncestors(model, model.getParent(), model.getStates(), model);
        } 
    }
    
    /*
     * Private helper used to generate a list of nodes which are used at runtime
     * when positioning items "relativeTo" another.  We walk the preceding
     * siblings of a given node until we've reached the start of the child list
     * or we have reached a persistent (non-state-specific) node.
     */
    private ArrayList<Model> buildRelativeSiblingList(Model model, ArrayList siblings, int startIndex)
    {
        ArrayList<Model> relativeSiblings = new ArrayList<Model>();
        for (int i = startIndex; i > -1; i--)
        {
            ValueInitializer initializer = (ValueInitializer)siblings.get(i);
            Model sibling = (Model)initializer.getValue();
            
            Boolean intersects = false;
            if (sibling.isStateSpecific())
            {
                for (Iterator<String> iter = sibling.getStates().iterator(); iter.hasNext(); )
                {
                    String state = iter.next();
                    if (model.hasState(state))
                    {
                        intersects = true;
                        break;
                    }
                }
            }
            
            if (!sibling.isStateSpecific() || intersects)
            {
                relativeSiblings.add(sibling);
            
                // Ensure that this model is declared (if not already). Note, we cannot
                // use ensureDeclaration() here as these models have already been processed.
                if (sibling.getIdIsAutogenerated()  && !(sibling instanceof flex2.compiler.mxml.rep.Reparent))
                {
                    document.addDeclaration(sibling.getId(), sibling.getType().getName(), 
                            sibling.getXmlLineNumber(), true, true, true, sibling.getBindabilityEnsured());
                }
            }
            
            // Terminate at the first persistent model we find.
            if (!sibling.isStateSpecific())
                break;
        }
        return relativeSiblings;
    }
    
    /*
     * Take note of a property which is to be considered transient (state-specific).  Generate the appropriate
     * override (SetProperty) to represent this state-specific node, and append to the corresponding state's
     * override list.
     */
    public void registerStateSpecificProperty(Model model, String property, ValueInitializer value, String stateName)
    {
        generatePropertyOverrides(model, property, value, stateName, false);
    }
    
    /*
     * Take note of a style which is to be considered transient (state-specific).  Generate the appropriate
     * override (SetStyle) to represent this state-specific node, and append to the corresponding state's
     * override list.
     */
    public void registerStateSpecificStyle(Model model, String property, ValueInitializer value, String stateName)
    {
        generatePropertyOverrides(model, property, value, stateName, true);
    }
    
    /*
     * Helper method used when registering state specific properties or styles.
     */
    private void generatePropertyOverrides(Model model, String property, ValueInitializer value, String stateName, Boolean isStyle)
    {
        Collection<String> stateNames = expandState(stateName);
        
        String factory = null;
        if (stateNames.size() > 1)
        {
            // If we need to share a state-specific property value between multiple states
            // and the value does not represent a value or inline RValue, we need to ensure
            // that an instance factory is registered for the value's model.
            if (!(value.getValue() instanceof BindingExpression) && value.hasDefinition())
            {
                if (value.getValue() instanceof Model)
                {
                    
                    Model valueModel = (Model) value.getValue();
                    factory = valueModel.getDefinitionName();
                    sharedObjects.put(valueModel.getDefinitionName(), 
                        new SharedObject(valueModel.getDefinitionName(), valueModel.isDeclared(), valueModel));
                }
            }
        }
        
        for (Iterator<String> iter = stateNames.iterator(); iter.hasNext(); )
        {
            State state = stateByName(iter.next());
            if (state != null)
            {
                SetPropertyOverride override = isStyle ? new SetStyleOverride(model, property, value, factory) :
                    new SetPropertyOverride(model, property, value, factory);
                postProcessBindingInstance(value, override);
                state.addOverride(override, model != null ? model.getXmlLineNumber() : 0);
            }
        }       
    }
    
    /*
     * Take note of a event handler which is to be considered transient (state-specific).  Generate the appropriate
     * override (SetEvent) to represent this state-specific node, and append to the corresponding state's
     * override list.
     */
    public void registerStateSpecificEventHandler(Model model, String event, EventInitializer value, String stateName)
    {
        Collection<String> stateNames = expandState(stateName);
        for (Iterator<String> iter = stateNames.iterator(); iter.hasNext(); )
        {
            State state = stateByName(iter.next());
            if (state != null)
            {
                SetEventOverride override = new SetEventOverride(model, event, value);
                state.addOverride(override, model != null ? model.getXmlLineNumber() : 0);
            }
        }
    }
    
    /*
     * Take note of those nodes which were marked with itemCreationPolicy='immediate', 
     * such that we ensure they are accessible at runtime even before the stateful
     * document model requires them.
     */
    public void registerEarlyInitNode(Model model)
    {
        sharedObjects.put(model.getDefinitionName(), new SharedObject(model.getDefinitionName(), model.isDeclared(), model));
        earlyInitObjects.add(model.getDefinitionName());
        model.setEarlyInit(true);
    }
    
    /*
     * Construct stateful node overrides for a list of states, matching criteria
     * specified.
     */
    private void constructAddItems(Model model, Model parent, String parentIndex, String parentId, String position, 
                                   ArrayList<Model> relativeNodes, Collection<String> statesList)
    {
        sharedObjects.put(model.getDefinitionName(), new SharedObject(model.getDefinitionName(), model.isDeclared(), model));
        
        // Determine if target happens to be a style.
        boolean isStyle = false;
        if (parent != null && parentIndex != null)
        {
            isStyle = (parent.getType().getStyle(parentIndex) != null) ? true : false;
        }
        
        // Determine if adding an array instance so our override can treat it
        // as a whole vs. list of items to add.
        boolean isArray = (model.getType() == document.getTypeTable().arrayType) ? true : false;
        String vectorClassName = null;

        if (model.getParent().getType().getElementType() != null)
        {
            vectorClassName = NameFormatter.toDot(model.getParent().getType().getName());
        }

        // Enforce set semantics for our state list and construct representative overrides for each state.
        Set<Object> states = new HashSet<Object>(statesList);
        for (Iterator<Object> iter = states.iterator(); iter.hasNext(); )
        {
            State state = stateByName((String)iter.next());
            if (state != null)
            {
                AddItemsOverride override =
                    new AddItemsOverride(parent, parentIndex, parentId, model.getDefinitionName(),
                                         position, relativeNodes, isStyle, isArray, vectorClassName, model);
                state.addOverride(override, model != null ? model.getXmlLineNumber() : 0);
            }
        }
    }
    
    /*
     * Here any values that are driven by a binding instance are redirected. Instead of the binding 
     * target being the DOM node, we redirect the binding to apply its changes directly to our 
     * override (which serves as the middle man between the binding and the DOM node.
     */
    private void postProcessBindingInstance(ValueInitializer value, SetPropertyOverride override) 
    {
        if (value.getValue() instanceof BindingExpression)
        {
            Type type = document.getTypeTable().getType(override.getDeclaredType());
            Model model = new Model(document, type, null, 0);
            document.ensureDeclaration(model);
            model.ensureBindable();
        
            // We need to ensure each override has its own unique copy of the 
            // the BindingExpression, as several overrides could share a binding
            // instance via stateGroups.
            
            BindingExpression sourceExpression = (BindingExpression)value.getValue();    
            BindingExpression bindingExpression = new BindingExpression(
                    sourceExpression.getSourceExpression(),
                    sourceExpression.xmlLineNumber, 
                    document);
            
            bindingExpression.setDestination(model);
            bindingExpression.setDestinationLValue("value");
            bindingExpression.setDestinationProperty("value");
            bindingExpression.setDestinationStyle(null);
            override.setDeclaration(model.getId());
            
            // Ensure the original binding expression is discarded.
            sourceExpression.setId(-1);
            document.removeBindingExpression(sourceExpression);

            try
            {
                ValueInitializer valueClone = value.clone();
                valueClone.setValue(bindingExpression);
                override.value = valueClone;
            }
            catch ( CloneNotSupportedException e ) 
            {
                throw new RuntimeException(e); //wont happen
            }
        }
    }
    
    /*
     * Utility method to convert a black list (excludeFrom) to a white list,
     * (includeIn).
     */
    private Collection<String> inverseOf(Collection<String> list) {
        
        Collection<String> inverse = new TreeSet<String>(); 
        Set<String> all = info.getStateNames(); 
        Set<String> expandedList = expandStateList(list);
        
        for (Iterator<String> iter = all.iterator(); iter.hasNext(); )
        {
            String name = iter.next();
            if (!expandedList.contains(name))
                inverse.add(name);
        }
        return inverse;
    }
    
    /*
     * Retrieve the corresponding State object for a given state name.
     * Create one if none specified previously.
     */
    public State stateByName(String name)
    {   
        State entry = states.get(name);
        if (entry == null) 
        {
            entry = new State(name);
            states.put(name, entry);
        }
        return entry;
    }
    
    /*
     * Retrieve the reparent node (if any) for the model and state specified.
     */
    private Model getReparentForState(Model model, String state)
    {
        if (reparentNodes != null)
        {
            List<ReparentInfo> list = reparentNodes.get(model.getId());
            for (Iterator<ReparentInfo> iter = list.iterator(); iter.hasNext(); )
            {
                ReparentInfo ri = iter.next();
                if (ri.states.contains(state))
                    return ri.model;
            }
        }
        return null;
    }
    
    /*
     * Retrieve list of groups for which a given state is a member.
     */
    public Collection<String> getGroupsForState(String name)
    {
        Collection<String> groups = new ArrayList<String>();
        Map<String, Collection<String>> stateGroups = info.getStateGroups();
        
        for (Iterator<String> iter = stateGroups.keySet().iterator(); iter.hasNext(); )
        {
            String groupName = iter.next();
            if (stateGroups.get(groupName).contains(name))
            {
                groups.add(groupName);
            }
        }
           
        return groups;
    }
        
    /*
     * Generate sub-definition initializer fragments from each of our state-
     * specific property values.
     */
    public Iterator<CodeFragmentList> getSubDefinitionIterators()
    {   
        IteratorList iterList = new IteratorList();

        Set<String> states = info.getStateNames();
        for (Iterator<String> iter = states.iterator(); iter.hasNext();  )
        {
            State state = (State) stateByName(iter.next());
            if (state != null)
            {
                // State event initializers
                for (Iterator<Initializer> eventList = state.getEvents(); eventList.hasNext(); )
                {
                    EventInitializer ei = (EventInitializer) eventList.next();
                    iterList.add(ei.getDefinitionsIterator());                  
                }
                
                
                // Override value initializers
                for (Iterator<StatesModel.Override> items = state.overrides.iterator(); items.hasNext(); )
                {
                    StatesModel.Override override = items.next();
                    if (override instanceof SetPropertyOverride)
                    { 
                        ValueInitializer initializer = ((SetPropertyOverride)override).value;
                        Object rvalue = initializer.getValue();
                        if (rvalue instanceof Model && !initializedModels.contains(rvalue))
                        {
                            iterList.add(initializer.getDefinitionsIterator());
                            initializedModels.add(rvalue);
                        }
                    }
                }
            }
        }
        
        return iterList.toIterator();
    }
    
    /*
     * Generate initializer iterator from each of our state-
     * specific property values.
     */
    public Iterator<Initializer> getSubInitializerIterators()
    {   
        IteratorList iterList = new IteratorList();

        // Override Initializers
        Set<String> states = info.getStateNames();
        for (Iterator<String> iter = states.iterator(); iter.hasNext();  )
        {
            State state = (State) stateByName(iter.next());
            if (state != null)
            {
                // State event initializers
                iterList.add(state.getEvents());  
                
                // Override value initializers
                ArrayList<Initializer> values = new ArrayList<Initializer>();
                for (Iterator<StatesModel.Override> items = state.overrides.iterator(); items.hasNext(); )
                {
                    StatesModel.Override override = items.next();
                    if (override instanceof SetPropertyOverride)
                    { 
                        ValueInitializer initializer = ((SetPropertyOverride)override).value;
                        Object rvalue = initializer.getValue();
                        if (rvalue instanceof Model && !initializedModels.contains(rvalue))
                        {
                            values.add(initializer);
                            initializedModels.add(rvalue);
                        }
                    }
                }
                iterList.add(values.iterator());
            }
        }
        
        return iterList.toIterator();
    }
    
    /*
     * This class represents a single component 'state.  It contains a set of 
     * changes to apply to the component/document for the given state.
     */
    public class State
    {
        public String name;
        public List<Override> overrides;
        public Model model;
        
        public State(String name)
        {
            this.name = name;
            overrides = new ArrayList<Override>();
        }
        
        public void addOverride(Override override, int line) 
        {
            // Check for possibility of a property having already been
            // intialized for this state.
            if (!previouslyInitialized(override, line))
            {
                // Ensure possible targets of mutation operations precede the others
                // in our list of state overrides.  TODO(crl): Flush out a more robust
                // precedence scheme.
                
                boolean isArrayOrVectorValue = ((override instanceof SetPropertyOverride) && 
                                                ((((SetPropertyOverride)override).value.getValue() instanceof Array) ||
                                                 (((SetPropertyOverride)override).value.getValue() instanceof Vector)));
                
                boolean isAddItems = override instanceof AddItemsOverride;
                
                if (isArrayOrVectorValue || isAddItems)
                    overrides.add(0,override);
                else
                    overrides.add(override);
            }       
        }
 
        /*
         * Generate code representation of this state.
         */
        public void getDefinitionBody(CodeFragmentList list, String indent, List<StatesModel.Override> bindingsQueue)
        {
            list.add(indent, "new State ({", 0);
            indent += StatesGenerator.INDENT;
            list.add(indent, "name: \"" + name + "\",", 0);
            
            // "Other" valid State attributes.
            for (Iterator<Initializer> iter = model.getPropertyInitializerIterator(false); iter.hasNext(); )
            {
                Initializer init = iter.next();
                if (init instanceof NamedInitializer)
                {
                    NamedInitializer namedInit = (NamedInitializer) init;
                    String initName = namedInit.getName();
                    if (!initName.equals("name") && !initName.equals("stateGroups") && !initName.equals("overrides"))
                    {
                        list.add(indent, initName + ": " + namedInit.getValueExpr() + ",", 0);
                    }
                }
            }
            
            // State groups
            Collection<String> groups = getGroupsForState(name);
            if (!groups.isEmpty())
            {
                String groupNames = "";
                for (Iterator<String> iter = groups.iterator(); iter.hasNext(); )
                {
                    groupNames += "'" + iter.next() + (iter.hasNext() ? "'," : "'");
                }
                list.add(indent, "stateGroups: [" + groupNames + "],", 0);
            }
            
            list.add(indent, "overrides: [", 0);
                        
            indent += StatesGenerator.INDENT;
            for (Iterator<StatesModel.Override> iter = overrides.iterator(); iter.hasNext(); )
            {
                StatesModel.Override override = iter.next();
                override.getDefinitionBody(list, indent);
                
                // If this override is to be declared we know that it is a binding target.
                // Queue a binding initializer up for this object.
                if (override.declaration != null)
                {
                    bindingsQueue.add(override);
                }
                
                if (iter.hasNext()) list.add(indent, ",", 0);
            }
            indent = indent.substring(0, indent.length() - StatesGenerator.INDENT.length());
            
            list.add(indent, "]", 0);
            indent = indent.substring(0, indent.length() - StatesGenerator.INDENT.length());
            list.add(indent, "})", 0);
        }
        
        /*
         * Generate AST representation of this state.
         */
        public MemberExpressionNode generateDefinitionBody(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                           boolean generateDocComments, List<StatesModel.Override> bindingsQueue)
        {
            IdentifierNode stateIdentifier = nodeFactory.identifier(STATE, false);
            IdentifierNode nameIdentifier = nodeFactory.identifier(NAME, false);
            IdentifierNode overridesIdentifier = nodeFactory.identifier(OVERRIDES, false);
            
            ArgumentListNode stateArguments = null;
            
            // name
            LiteralStringNode literalString = nodeFactory.literalString(name);
            LiteralFieldNode literalField = nodeFactory.literalField(nameIdentifier, literalString);
            stateArguments = nodeFactory.argumentList(stateArguments, literalField);
             
            // "other" valid State attributes.
            for (Iterator<Initializer> iter = model.getPropertyInitializerIterator(false); iter.hasNext(); )
            {
                Initializer init = iter.next();
                if (init instanceof NamedInitializer)
                {
                    NamedInitializer namedInit = (NamedInitializer) init;
                    String initName = namedInit.getName();
                    if (!initName.equals("name") && !initName.equals("stateGroups") && !initName.equals("overrides"))
                    {
                        IdentifierNode propIdentifier = nodeFactory.identifier(initName);
                        literalField = nodeFactory.literalField(propIdentifier,
                                                                namedInit.generateValueExpr(nodeFactory, configNamespaces,
                                                                                            generateDocComments));
                        stateArguments = nodeFactory.argumentList(stateArguments, literalField);
                    }
                }
            }
            
            // state groups
            Collection<String> groups = getGroupsForState(name);
            if (!groups.isEmpty())
            {
                ArgumentListNode groupArguments = null;
                for (Iterator<String> iter = groups.iterator(); iter.hasNext(); )
                {
                     LiteralStringNode sibling = nodeFactory.literalString(iter.next());
                     groupArguments = nodeFactory.argumentList(groupArguments, sibling);       
                }
                LiteralArrayNode relArray = nodeFactory.literalArray(groupArguments);
                IdentifierNode relIdentifier = nodeFactory.identifier(STATEGROUPS, false);
                literalField = nodeFactory.literalField(relIdentifier, relArray);
                stateArguments = nodeFactory.argumentList(stateArguments, literalField);
            }
            
            // overrides
            ArgumentListNode overridesArgumentList = null;
            for (Iterator<StatesModel.Override> iter = overrides.iterator(); iter.hasNext(); )
            {
                StatesModel.Override override = iter.next();
                MemberExpressionNode memberExpression =
                    override.generateDefinitionBody(nodeFactory, configNamespaces, generateDocComments);
                overridesArgumentList = nodeFactory.argumentList(overridesArgumentList, memberExpression);
                
                // If this override is to be declared we know that it is a binding target.
                // Queue a binding initializer up for this object.
                if (override.declaration != null)
                {
                    bindingsQueue.add(override);
                }
            }

            LiteralArrayNode overridesArray = nodeFactory.literalArray(overridesArgumentList);
            literalField = nodeFactory.literalField(overridesIdentifier, overridesArray);
            stateArguments = nodeFactory.argumentList(stateArguments, literalField);      
            LiteralObjectNode literalObject = nodeFactory.literalObject(stateArguments);
            ArgumentListNode stateDescriptorArgumentList = nodeFactory.argumentList(null, literalObject);
            
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(stateIdentifier, stateDescriptorArgumentList);
            callExpression.is_new = true;
            callExpression.setRValue(false);
            
            return nodeFactory.memberExpression(null, callExpression);

        }
        
        
        /*
         * Validates that there are no previous initializers for a given property/value.
         */
        private boolean previouslyInitialized(Override override, int line)
        {
            if (isPropertyOverride(override))
            {
                for (Iterator<Override> iter = overrides.iterator(); iter.hasNext(); )
                {
                    Override current = iter.next();
                    if (override.getDeclaredType() == current.getDeclaredType())
                    {
                        boolean conflict = false;
                        String property = "";
                                                
                        if (override instanceof SetPropertyOverride)
                        {
                            Model context = ((SetPropertyOverride)override).context;
                            property = ((SetPropertyOverride)override).property;
                            conflict = (((SetPropertyOverride)current).property == property &&
                                          ((SetPropertyOverride)current).context == context);
                        }
                        else if (override instanceof SetEventOverride)
                        {
                            Model context = ((SetEventOverride)override).context;
                            property = ((SetEventOverride)override).event;
                            conflict = (((SetEventOverride)current).event == property &&
                                          ((SetEventOverride)current).context == context);
                        }
                        
                        if (conflict)
                        {
                            ThreadLocalToolkit.log(new MultipleInitializers(property, name), document.getSourcePath(), line);
                            return true;
                        }
                    }
                }
            }
            return false;
        }
        
        /*
         * Filters for those overrides which we need to check for multiple
         * initializers
         */
        private boolean isPropertyOverride(Override override)
        {
            return ((override instanceof SetPropertyOverride) || 
                    (override instanceof SetEventOverride));
        }
        
        /*
         * Return event iterator for this state.
         */
        public Iterator<Initializer> getEvents()
        {
            return (model != null) ? model.getEventInitializerIterator() : null;
        }
        
        /*
         * Return whether or not this state is to be declared.
         */
        public boolean isDeclared()
        {
            return (model != null) ? model.isDeclared() : false;
        }
        
        /*
         * Return id for this state.
         */
        public String getId()
        {
            return (model != null) ? model.getId() : null;
        }
    }
        
    /*
     * Base class for all override instances.  
     */
    public abstract class Override
    {
        public String declaration;
        public Override(){};
        
        /*
         * The declaration property is used only when an override serves as a binding
         * target.  Binding initializers are generated for any overrides that are data
         * bound.
         */
        public void setDeclaration(String declaration)
        {
            this.declaration = declaration;
        }
        
        public abstract void getDefinitionBody(CodeFragmentList list, String indent);
        public abstract MemberExpressionNode generateDefinitionBody(NodeFactory nodeFactory,
                                                                    HashSet<String> configNamespaces,
                                                                    boolean generateDocComments);
        public abstract String getDeclaredType();
    }
    
    /*
     * Represents an override responsible for transient DOM nodes (state-specific).
     */
    public class AddItemsOverride extends Override
    {
        public String context;
        public String propertyName;
        public String factory;
        public Model parent;
        public Model model;
        public String position;
        public ArrayList<Model> relativeNodes;
        public boolean isStyle;
        public boolean isArray;
        public String vectorClassName;
        
        public AddItemsOverride(Model parent, String propertyName, String context, String factory,
                                String position, ArrayList<Model> relativeNodes, boolean isStyle,
                                boolean isArray, String vectorClassName, Model model)
        {
            this.parent = parent;
            this.context = context;
            this.factory = factory;
            this.propertyName = propertyName;
            this.position = position;
            this.relativeNodes = relativeNodes;
            this.isStyle = isStyle;
            this.isArray = isArray;
            this.vectorClassName = vectorClassName;
            this.model = model;
            info.addImportName(NameFormatter.toDot(getDeclaredType()), 0);
        }
        
        /*
         * Generate code representation of this override.
         */
        public void getDefinitionBody(CodeFragmentList list, String indent)
        {
            String typeName = NameFormatter.retrieveClassName(getDeclaredType());
            list.add(indent, "new " + typeName + "().initializeFromObject({", 0);
            indent += StatesGenerator.INDENT;
            if (model.getIsTransient())
            {
                list.add(indent, "destructionPolicy: \"auto\",", 0);
            }
            list.add(indent, "itemsFactory: " + factory +"_factory,", 0);
            if (isStyle)
            {
                list.add(indent, "isStyle: true ,", 0);
            }
            
            // Determine sibling element count if this is an array element.
            int parentElementCount = 0;
            if (model.getParent() != null)
            {
                if (model.getParent().getType() == document.getTypeTable().arrayType)
                {
                    parentElementCount = ((Array) model.getParent()).getEntries().size();
                }
                else if (model.getParent().getType().getElementType() != null)
                {
                    parentElementCount = ((Vector) model.getParent()).getEntries().size();
                }
            }
            
            // Only mark item as array if it has siblings.
            if (isArray && parentElementCount > 1)
                list.add(indent, "isArray: true ,", 0);

            if (vectorClassName != null)
                list.add(indent, "vectorClass: " + vectorClassName + ",", 0);
            
            String destination = (parent != null) ? ("\"" + parent.getId() + "\"") : "null";
            list.add(indent, "destination: " + destination + ((propertyName != null || position != null) ? "," : ""), 0);
            if (propertyName != null)
            {
                list.add(indent, "propertyName: \"" + propertyName + "\"" + (position != null ? "," : ""), 0);
            }
            if (position != null)
            {
                list.add(indent, "position: \"" + position + "\"" + (position != "first" ? "," : ""), 0);
                if (position.equals("after") && !relativeNodes.isEmpty())
                {
                    String siblingList = "";
                    for (int i = 0; i < relativeNodes.size(); i++)
                    {
                        siblingList = siblingList + '"' + relativeNodes.get(i).getId() + '"';
                        siblingList += (i != (relativeNodes.size() - 1)) ? ", " : "";
                    } 
                    list.add(indent, "relativeTo: [" + siblingList + "]", 0);
                }
            }
            indent = indent.substring(0, indent.length() - StatesGenerator.INDENT.length());
            list.add(indent, "})", 0);
        }
        
        /*
         * Generate AST representation of this override.
         */
        public MemberExpressionNode generateDefinitionBody(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                           boolean generateDocComments)
        {
            IdentifierNode addItemsIdentifier = nodeFactory.identifier(ADDITEMS, false);
            IdentifierNode initObjectIdentifier = nodeFactory.identifier(INITIALIZEFROMOBJECT, false);
            
            ArgumentListNode aiArguments = null;
            
            // destructionPolicy
            if (model.getIsTransient())
            {
                IdentifierNode propIdentifier = nodeFactory.identifier(DESTRUCTIONPOLICY, false);
                LiteralStringNode propNode = nodeFactory.literalString("auto");
                LiteralFieldNode literalField = nodeFactory.literalField(propIdentifier, propNode);
                aiArguments = nodeFactory.argumentList(aiArguments, literalField);
            }
            
            // itemsFactory
            IdentifierNode itemsIdentifier = nodeFactory.identifier(ITEMSFACTORY, false);
            String factorySymbol = ((String)factory + _FACTORY).intern();
            IdentifierNode factoryIdentifier = nodeFactory.identifier(factorySymbol, false);
            GetExpressionNode factoryExpression = nodeFactory.getExpression(factoryIdentifier);
            MemberExpressionNode factory = nodeFactory.memberExpression(null, factoryExpression);
            LiteralFieldNode literalField = nodeFactory.literalField(itemsIdentifier, factory);
            aiArguments = nodeFactory.argumentList(aiArguments, literalField);
            
            // isStyle
            if (isStyle)
            {
                IdentifierNode isStyleIdentifier = nodeFactory.identifier(ISSTYLE, false);
                LiteralBooleanNode value = nodeFactory.literalBoolean(true);
                literalField = nodeFactory.literalField(isStyleIdentifier, value);
                aiArguments = nodeFactory.argumentList(aiArguments, literalField);
            }
            
            // Determine sibling element count if this is an array element.
            int parentElementCount = 0;
            if (model.getParent() != null)
            {
                if (model.getParent().getType() == document.getTypeTable().arrayType)
                {
                    parentElementCount = ((Array) model.getParent()).getEntries().size();
                }
                else if (model.getParent().getType().getElementType() != null)
                {
                    parentElementCount = ((Vector) model.getParent()).getEntries().size();
                }
            }
            
            // Only mark item as array if it has siblings.
            if (isArray && parentElementCount > 1)
            {
                IdentifierNode isArrayIdentifier = nodeFactory.identifier(ISARRAY, false);
                LiteralBooleanNode value = nodeFactory.literalBoolean(true);
                literalField = nodeFactory.literalField(isArrayIdentifier, value);
                aiArguments = nodeFactory.argumentList(aiArguments, literalField);
            }

            // vectorClass
            if (vectorClassName != null)
            {
                IdentifierNode vectorClassIdentifier = nodeFactory.identifier(VECTORCLASS, false);
                ApplyTypeExprNode applyTypeExpr =
                    AbstractSyntaxTreeUtil.generateApplyTypeExpr(nodeFactory, vectorClassName, vectorClassName.indexOf(LESS_THAN));
                MemberExpressionNode typeValue = nodeFactory.memberExpression(null, applyTypeExpr);
                literalField = nodeFactory.literalField(vectorClassIdentifier, typeValue);
                aiArguments = nodeFactory.argumentList(aiArguments, literalField);
            }
            
            // destination
            macromedia.asc.parser.Node valueNode = null;
            IdentifierNode destIdentifier = nodeFactory.identifier(DESTINATION, false);
            valueNode = (parent != null) ? nodeFactory.literalString(parent.getId()) 
                    : nodeFactory.literalNull();
            literalField = nodeFactory.literalField(destIdentifier, valueNode);
            aiArguments = nodeFactory.argumentList(aiArguments, literalField);
            
            // propertyName
            if (propertyName != null)
            {
                IdentifierNode propIdentifier = nodeFactory.identifier(PROPERTYNAME, false);
                LiteralStringNode propNode = nodeFactory.literalString(propertyName);
                literalField = nodeFactory.literalField(propIdentifier, propNode);
                aiArguments = nodeFactory.argumentList(aiArguments, literalField);
            }
            
            // position
            if (position != null)
            {
                IdentifierNode posIdentifier = nodeFactory.identifier(POSITION, false);
                LiteralStringNode posNode = nodeFactory.literalString(position);
                literalField = nodeFactory.literalField(posIdentifier, posNode);
                aiArguments = nodeFactory.argumentList(aiArguments, literalField);
                
                if (position.equals("after") && !relativeNodes.isEmpty())
                {
                    ArgumentListNode relArguments = null;
                    for (int i = 0; i < relativeNodes.size(); i++)
                    {
                        LiteralStringNode sibling = nodeFactory.literalString(relativeNodes.get(i).getId());
                        relArguments = nodeFactory.argumentList(relArguments, sibling);                 
                    } 
                    LiteralArrayNode relArray = nodeFactory.literalArray(relArguments);
                    IdentifierNode relIdentifier = nodeFactory.identifier(RELATIVETO, false);
                    literalField = nodeFactory.literalField(relIdentifier, relArray);
                    aiArguments = nodeFactory.argumentList(aiArguments, literalField);
                }
            }
            
            LiteralObjectNode literalObject = nodeFactory.literalObject(aiArguments);
            ArgumentListNode addItemsArgumentList = nodeFactory.argumentList(null, literalObject);
            
            CallExpressionNode initExpression =
                (CallExpressionNode) nodeFactory.callExpression(initObjectIdentifier, addItemsArgumentList);
            initExpression.setRValue(false);
            
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(addItemsIdentifier, null);
            callExpression.is_new = true;
            callExpression.setRValue(false);
            
            MemberExpressionNode base = nodeFactory.memberExpression(null, callExpression);
            
            return nodeFactory.memberExpression(base, initExpression);
        }
        
        public String getDeclaredType()
        {
            return standardDefs.CLASS_ADDITEMS;
        }
    }
    
    /*
     * Utility class used to represent an object factory that is to be shared between
     * multiple states.  Used with AddItems overrides.
     */
    public class SharedObject
    {
        public String  name;
        public boolean isDeclared;
        public Model model;
        
        public SharedObject(String name, boolean isDeclared, Model model)
        {
            this.name = name;
            this.isDeclared = isDeclared;
            this.model = model;
        }
    }
    
    /*
     * Utility class used to store the information from a Reparent instance,
     * converted into overrides during a compiler post-process phase.
     */
    private class ReparentInfo
    {
        public Collection<String> states;
        public Model model;
        public Node node;
        public int childIndex;
        
        public ReparentInfo(Model model, Node node, Collection<String> states, int childIndex)
        {
            this.model = model;
            this.node = node;
            this.states = states;
            this.childIndex = childIndex;
        }
    }
    
    
    /*
     * Represents an override responsible for managing state-specific properties.
     */
    public class SetPropertyOverride extends Override
    {
        public Model context;
        public ValueInitializer value;
        public String property;
        public Boolean clear;
        public String factory;
        
        public SetPropertyOverride(Model context, String property, ValueInitializer value, String factory)
        {
            this.value = value;
            this.factory = factory;
            this.property = property;
            this.context = context;
            this.clear = (value.getValue() != null && value.getValue() instanceof AtClear) ? true : false;
            info.addImportName(NameFormatter.toDot(getDeclaredType()), 0);
        }
        
        /*
         * Generate code representation of this override.
         */
        public void getDefinitionBody(CodeFragmentList list, String indent)
        {
            boolean isDataBound = getDeclaredClass() == SETPROPERTY ? 
                    context.hasDataBoundProperty(property) :
                    context.hasDataBoundStyle(property);
            
            String typeName = NameFormatter.toDot(getDeclaredType());
            String prefix = (declaration != null) ? declaration + " = " + typeName + "( " : "";
            String suffix = (declaration != null) ? ")" : "";
            list.add(indent, prefix + "new " + typeName + "().initializeFromObject({", 0);
            indent += StatesGenerator.INDENT;
            
            // Only mark an override as data bound, if the base property is
            // associated with a binding instance.
            if (isDataBound)
                list.add(indent, "isBaseValueDataBound: true ,", 0);
            
            if (document.getRoot() != context)
            {
                list.add(indent, "target: \"" + context.getId() +"\",", 0);
            }
            list.add(indent, "name: \"" + property +"\"" + (!clear ? "," : ""), 0);
            if (!clear)
            {
                if (factory != null)
                    list.add(indent, "valueFactory: " + factory +"_factory", 0);
                else
                    list.add(indent, "value: " + value.getValueExpr(), 0);
            } 
            indent = indent.substring(0, indent.length() - StatesGenerator.INDENT.length());
            list.add(indent, "})" + suffix, 0);
        }
        
        /*
         * Generate AST representation of this override.
         */
        public MemberExpressionNode generateDefinitionBody(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                           boolean generateDocComments)
        {
            boolean isDataBound = getDeclaredClass() == SETPROPERTY ? 
                    context.hasDataBoundProperty(property) :
                    context.hasDataBoundStyle(property);
                    
            QualifiedIdentifierNode qualifiedIdentifier =
                AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, 
                standardDefs.getStatesPackage(), getDeclaredClass(), false);
            
            IdentifierNode initObjectIdentifier = nodeFactory.identifier(INITIALIZEFROMOBJECT, false);
            
            ArgumentListNode spArguments = null;
            
            // isBaseValueDataBound
            if (isDataBound)
            {
                IdentifierNode isStyleIdentifier = nodeFactory.identifier(ISBASEVALUEDATABOUND, false);
                LiteralBooleanNode value = nodeFactory.literalBoolean(true);
                LiteralFieldNode literalField = nodeFactory.literalField(isStyleIdentifier, value);
                spArguments = nodeFactory.argumentList(spArguments, literalField);
            }
            
            // target
            if (document.getRoot() != context)
            {
                IdentifierNode targetIdentifier = nodeFactory.identifier(TARGET, false);
                LiteralStringNode valueNode = nodeFactory.literalString(context.getId());
                LiteralFieldNode literalField = nodeFactory.literalField(targetIdentifier, valueNode);
                spArguments = nodeFactory.argumentList(spArguments, literalField);
            }
            
            // name
            IdentifierNode nameIdentifier = nodeFactory.identifier(NAME, false);
            LiteralStringNode nameNode = nodeFactory.literalString(property);
            LiteralFieldNode literalField = nodeFactory.literalField(nameIdentifier, nameNode);
            spArguments = nodeFactory.argumentList(spArguments, literalField);
            
            // value
            if (!clear)
            {
                if (factory != null)
                {
                    // valueFactory
                    IdentifierNode itemsIdentifier = nodeFactory.identifier(VALUEFACTORY, false);
                    String factorySymbol = ((String)factory + _FACTORY).intern();
                    IdentifierNode factoryIdentifier = nodeFactory.identifier(factorySymbol, false);
                    GetExpressionNode factoryExpression = nodeFactory.getExpression(factoryIdentifier);
                    MemberExpressionNode factory = nodeFactory.memberExpression(null, factoryExpression);
                    LiteralFieldNode literalFieldVF = nodeFactory.literalField(itemsIdentifier, factory);
                    spArguments = nodeFactory.argumentList(spArguments, literalFieldVF);
                }
                else
                {
                    macromedia.asc.parser.Node valueNode = null;
                    IdentifierNode valueIdentifier = nodeFactory.identifier(VALUE, false);
                    if (value == null || value.isBinding())
                    {
                        IdentifierNode undefinedIdentifier = nodeFactory.identifier(UNDEFINED, false);
                        GetExpressionNode getter = nodeFactory.getExpression(undefinedIdentifier);
                        valueNode = nodeFactory.memberExpression(null, getter);
                    }
                    else
                    {
                        valueNode = value.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
                    }
                    literalField = nodeFactory.literalField(valueIdentifier, valueNode);
                    spArguments = nodeFactory.argumentList(spArguments, literalField);
                }
            }
            
            LiteralObjectNode literalObject = nodeFactory.literalObject(spArguments);
            ArgumentListNode addItemsArgumentList = nodeFactory.argumentList(null, literalObject);
            
            CallExpressionNode initExpression =
                (CallExpressionNode) nodeFactory.callExpression(initObjectIdentifier, addItemsArgumentList);
            initExpression.setRValue(false);
            
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, null);
            callExpression.is_new = true;
            callExpression.setRValue(false);
            
            MemberExpressionNode base = nodeFactory.memberExpression(null, callExpression);
            
            MemberExpressionNode expNode = nodeFactory.memberExpression(base, initExpression);
            
            // For use with databound value only (when there is an lvalue).
            if (declaration != null)
            {
                ArgumentListNode castArgList2 = nodeFactory.argumentList(null, expNode);
                CallExpressionNode castExpression =
                    (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, castArgList2);
                castExpression.setRValue(false);
                MemberExpressionNode castNode = nodeFactory.memberExpression(null, castExpression);
                ArgumentListNode castArgList = nodeFactory.argumentList(null, castNode);
                IdentifierNode declIdentifier = nodeFactory.identifier(declaration);
                SetExpressionNode declSelector = nodeFactory.setExpression(declIdentifier, castArgList, false);
                return nodeFactory.memberExpression(null, declSelector);
            }
           
            return expNode;
        }
        
        public String getDeclaredType()
        {
            return standardDefs.CLASS_SETPROPERTY;
        }   
        
        protected String getDeclaredClass()
        {
            return SETPROPERTY;
        }   
    }
    
    /*
     * Represents an override responsible for managing state-specific styles.
     */
    public class SetStyleOverride extends SetPropertyOverride
    {        
        public SetStyleOverride(Model context, String property, ValueInitializer value, String factory)
        {
            super(context, property, value, factory);
        }
            
        public String getDeclaredType()
        {
            return standardDefs.CLASS_SETSTYLE;
        }
        
        protected String getDeclaredClass()
        {
            return SETSTYLE;
        }  
    }
    
    /*
     * Represents an override responsible for managing state-specific event handlers.
     */
    public class SetEventOverride extends Override
    {
        public Model context;
        public String event;
        public EventInitializer value;
        public Boolean clear;
        
        public SetEventOverride(Model context, String event, EventInitializer value)
        {
            this.context = context;
            this.value = value;
            this.event = event;
            this.clear = value.getHandlerText().equals("@Clear()") ? true : false;
            info.addImportName(NameFormatter.toDot(getDeclaredType()), 0);
        }
        
        /*
         * Generate code representation of this override.
         */
        public void getDefinitionBody(CodeFragmentList list, String indent)
        {
            String typeName = NameFormatter.retrieveClassName(getDeclaredType());
            boolean isDataBound = context.hasDataBoundEvent(event);
            
            list.add(indent, "new " + typeName + "().initializeFromObject({", 0);
            indent += StatesGenerator.INDENT;
            
            // Only mark an override as data bound, if the base property is
            // associated with a binding instance.
            if (isDataBound)
                list.add(indent, "isBaseValueDataBound: true ,", 0);
            
            // Look for non state-specific event handler for our event if any.
            Initializer base = context.getEventInitializer(event);
            
            if (document.getRoot() != context)
            {
                list.add(indent, "target: \"" + context.getId() +"\",", 0);
            }
            
            list.add(indent, "name: \"" + event +"\"" + ((!clear || base != null) ? "," : ""), 0);

            if (base != null)
            {
            	// Specify the base handler for this event so that our override can remove at runtime.
            	list.add(indent, "originalHandlerFunction: " + base.getValueExpr() + (!clear ? "," : ""), 0);
            }
            
            if (!clear)
            {
                list.add(indent, "handlerFunction: " + value.getValueExpr(), 0);
            }
           
            indent = indent.substring(0, indent.length() - StatesGenerator.INDENT.length());
            list.add(indent, "})", 0);
        }
        
        /*
         * Generate AST representation of this override.
         */
        public MemberExpressionNode generateDefinitionBody(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                           boolean generateDocComments)
        {
            boolean isDataBound = context.hasDataBoundEvent(event);
            
            IdentifierNode seItemsIdentifier = nodeFactory.identifier(SETEVENTHANDLER, false);
            IdentifierNode initObjectIdentifier = nodeFactory.identifier(INITIALIZEFROMOBJECT, false);
            
            ArgumentListNode spArguments = null;
            
            // Look for non state-specific event handler for our event if any.
            Initializer baseValue = context.getEventInitializer(event);
            
            // isBaseValueDataBound
            if (isDataBound)
            {
                IdentifierNode isStyleIdentifier = nodeFactory.identifier(ISBASEVALUEDATABOUND, false);
                LiteralBooleanNode value = nodeFactory.literalBoolean(true);
                LiteralFieldNode literalField = nodeFactory.literalField(isStyleIdentifier, value);
                spArguments = nodeFactory.argumentList(spArguments, literalField);
            }
            
            // target
            if (document.getRoot() != context)
            {
                IdentifierNode targetIdentifier = nodeFactory.identifier(TARGET, false);
                LiteralStringNode valueNode = nodeFactory.literalString(context.getId());
                LiteralFieldNode literalField = nodeFactory.literalField(targetIdentifier, valueNode);
                spArguments = nodeFactory.argumentList(spArguments, literalField);
            }
            
            // name
            IdentifierNode nameIdentifier = nodeFactory.identifier(NAME, false);
            LiteralStringNode nameNode = nodeFactory.literalString(event);
            LiteralFieldNode literalField = nodeFactory.literalField(nameIdentifier, nameNode);
            spArguments = nodeFactory.argumentList(spArguments, literalField);
            
            // baseEventHandler
            if (baseValue != null)
            {
                IdentifierNode valueIdentifier = nodeFactory.identifier(ORIGINALHANDLERFUNCTION, false);
                macromedia.asc.parser.Node valueNode =
                    baseValue.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
                literalField = nodeFactory.literalField(valueIdentifier, valueNode);
                spArguments = nodeFactory.argumentList(spArguments, literalField);
            }
            
            // eventHandler
            if (!clear)
            {
                IdentifierNode valueIdentifier = nodeFactory.identifier(HANDLERFUNCTION, false);
                macromedia.asc.parser.Node valueNode =
                    value.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
                literalField = nodeFactory.literalField(valueIdentifier, valueNode);
                spArguments = nodeFactory.argumentList(spArguments, literalField);
            }
            
            LiteralObjectNode literalObject = nodeFactory.literalObject(spArguments);
            ArgumentListNode addItemsArgumentList = nodeFactory.argumentList(null, literalObject);
            
            CallExpressionNode initExpression =
                (CallExpressionNode) nodeFactory.callExpression(initObjectIdentifier, addItemsArgumentList);
            initExpression.setRValue(false);
            
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(seItemsIdentifier, null);
            callExpression.is_new = true;
            callExpression.setRValue(false);
            
            MemberExpressionNode base = nodeFactory.memberExpression(null, callExpression);
            
            return nodeFactory.memberExpression(base, initExpression);
        }
        
        public String getDeclaredType()
        {
            return standardDefs.CLASS_SETEVENTHANDLER;
        }
    }
    
    public static class TargetResolutionError extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4029357697637073854L;
        public String name;
        public TargetResolutionError(String name) { this.name = name; }
    }
    
    public static class InvalidReparentState extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4395501005501097900L;
        public String name;
        public String target;
        public InvalidReparentState(String name, String target) 
        { 
            this.name = name; 
            this.target = target;
        }
    }
    
    public static class IncompatibleReparentType extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4395501003501097900L;
        public String target;
        public IncompatibleReparentType(String target) 
        { 
            this.target = target;
        }
    }
    
    public static class ConflictingReparentTags extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 6062583302608913991L;
        public String name;
        public String target;
        public ConflictingReparentTags(String name, String target) 
        { 
            this.name = name; 
            this.target = target;
        }
    }
    
    public static class MultipleInitializers extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 6062583302608912991L;
        public String name;
        public String state;
        public MultipleInitializers(String name, String state) 
        { 
            this.name = name; 
            this.state = state;
        }
    }
    
    public static class IncompatibleState extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4393031003501097900L;
        public String state;
        public IncompatibleState(String state) 
        { 
            this.state = state;
        }
    }
    
    public static class CircularReparent extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4393031003519097900L;
        public String state;
        public CircularReparent(String state) 
        { 
            this.state = state;
        }
    }
    
    public static class IncompatibleStatefulNode extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4393031143519097900L;
        public IncompatibleStatefulNode() {};
    }
    
    public static class DuplicateState extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4393031004536097900L;
        public String state;
        public DuplicateState(String state) 
        { 
            this.state = state;
        }
    }
    
}
