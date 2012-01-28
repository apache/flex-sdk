////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.olap
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Proxy;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ISort;
import mx.core.mx_internal;
import mx.events.CubeEvent;
import mx.resources.ResourceManager;
import mx.rpc.AsyncToken;
import mx.rpc.Fault;
import mx.rpc.IResponder;
import mx.rpc.events.FaultEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
*  Dispatched when a cube has been created
*  and is ready to be queried.
*
*  @eventType mx.events.CubeEvent.CUBE_COMPLETE
*  
*  @langversion 3.0
*  @playerversion Flash 9
*  @playerversion AIR 1.1
*  @productversion Flex 3
*/
[Event(name="complete", type="mx.events.CubeEvent")]

/**
*  Dispatched continuously as a cube is being created
*  by a call to the <code>refresh()</code> method.
*
*  @eventType mx.events.CubeEvent.CUBE_PROGRESS
*  
*  @langversion 3.0
*  @playerversion Flash 9
*  @playerversion AIR 1.1
*  @productversion Flex 3
*/
[Event(name="progress", type="mx.events.CubeEvent")]
    
/**
*  Dispatched continuously as a query result is being generated
*  by a call to the <code>execute()</code> method.
*
*  @eventType mx.events.CubeEvent.QUERY_PROGRESS
*  
*  @langversion 3.0
*  @playerversion Flash 9
*  @playerversion AIR 1.1
*  @productversion Flex 3
*/
[Event(name="queryProgress", type="mx.events.CubeEvent")]

//--------------------------------------
//  metadata
//--------------------------------------

[DefaultProperty("elements")]

[ResourceBundle("olap")]
    
/**
 *  The OLAPCube class represents an OLAP cube.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPCube&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPCube
 *    <b>Properties</b>
 *    dataProvider=""
 *    dimensions=""
 *    elements=""
 *    measures=""
 *  /&gt;
 *.
 *  @see mx.olap.IOLAPCube
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPCube extends Proxy implements IOLAPCube, IEventDispatcher
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param name The name of the OLAP cube.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPCube(name:String=null)
    {
        OLAPTrace.traceMsg("Creating cube: " + name, OLAPTrace.TRACE_LEVEL_3);
        super();
        
        this.name = name;
    
        ev = new EventDispatcher(this);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  A map of dimensions based on their name. 
     */
    private var _dimensionMap:Dictionary = new Dictionary(true);
    
    //flag indicating whether we have prepared the dataProvider for processing
    private var prepare:Boolean = false;
    
    //saved sort property of the source dataProvider.
    private var oldSort:ISort;

    // index of the dimension being processed.
    private var dimIndex:int = 0;

    //progress in cube building    
    private var progress:int;
    
    //total number of dimensions/data rows to process 
    private var total:int;
    
    //the embedded event dispatcher object to support IEventDispatcher interface.    
    private var ev:EventDispatcher;
    
    /**
     *  @private
     *  Timer used to build the cube. 
     */
    private var cubeBuildingTimer:Timer;
    
    /**
     *  @private
     *  Timer used to compute query results.
     */
    private var queryTimer:Timer;
    
    /**
     *  @private
     *  Array holding all queries to be executed 
     */
    private var _queriesPending:Array = [];
    
    /**
     *  @private
     *  Map of query objects to their AsyncToken 
     */
    private var _queryToken:Dictionary = new Dictionary(true);
    
    private var _cubeImpl:IOLAPCubeImpl = new DefaultCubeImpl;
    
    mx_internal var defaultMeasure:OLAPMeasure;
    
    mx_internal var attributeToIndex:Dictionary;
    
    /**
     *  Sets the name of the dimension for the measures of the OLAP cube. 
     *
     *  @default "Measures"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var measureDimensionName:String = "Measures";
    
    /**
     *  The class used by an OLAPCube instance to return the result. 
     *  You can replace the default class, OLAPResult, with your own implementation 
     *  of the IOLAPResult interface to customize the result.
     *
     *  @default OLAPResult
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var resultClass:Class = OLAPResult;
    
    /**
     *  The time interval, in milliseconds, used by the timer of the <code>refresh()</code> method 
     *  to iteratively build the cube. 
     *  You can set it to a higher value if you can wait longer before the cube is built. 
     *  You can set it to a lower value, but it might negatively impact responsiveness of your application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var cubeBuildingTimeInterval:int = 5;
    
    /**
     *  The time interval, in milliseconds, used by the timer of the <code>execute()</code> method 
     *  to iteratively process queries. 
     *  You can set it to a higher value if you can wait for longer 
     *  before the cube generates the query result. 
     *  You can set it to a lower value to obtain query results faster, 
     *  but it might negatively impact the responsiveness of your application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var queryBuildingTimeInterval:int = 1;
    
    /**
     *  The time, in milliseconds, used by the <code>refresh()</code> method 
     *  to iteratively build the cube. 
     *  A higher value would mean more rows would get processed at each timer event.
     *  You can set it to a higher value if you want the cube to be built faster, 
     *  but it might negatively impact responsiveness of your application. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var workDuration:int = 50;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // attributeLevels
    //----------------------------------
    
    /**
     *  @private
     *  Returns an array of all levels in the cube.
     *  Attribute levels duplicated in user defined hierarchy are skipped.
     */
    private var _attributeLevels:Array;
    
    mx_internal function get attributeLevels():Array
    {
        if (_attributeLevels)
            return _attributeLevels;
            
        _attributeLevels = [];
        
        var a:OLAPAttribute; 
        for each (var dim:IOLAPDimension in dimensions)
        {
            //skip measure dimension
            if (dim.isMeasure)
                continue;
            
            //including attributes which are not part of any user defined hierarchy.
            for each (a in dim.attributes)
            {
                // if the attribute is used in a user defined hierarchy we want to
                // pick the attributes in the user specified order.
                // so we skip it here.
                if (!a.userHierarchyLevel)
                    _attributeLevels = _attributeLevels.concat(a.allLevels.toArray());
            }

            //attributes in user defined hierarchy
            for each (var h:OLAPHierarchy in dim.hierarchies)
            {
                var hLevels:IList = h.levels;
                var length:int = hLevels.length;
                for (var i:int = 0; i < length; ++i)
                {
                    a = OLAPLevel(hLevels.getItemAt(i)).attribute;
                    _attributeLevels = _attributeLevels.concat(a.allLevels.toArray());
                }
            }
        }
        
        return _attributeLevels;
    }
    
    //----------------------------------
    // dataProvider
    //----------------------------------
    
    private var _dataProvider:ICollectionView;
    
    /**
     *  The flat data used to populate the OLAP cube. 
     *  You must call the <code>refresh()</code> method 
     *  to initialize the cube after setting this property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataProvider():ICollectionView
    {
        return _dataProvider;
    }
    
    /**
     *  @private
     */
    public function set dataProvider(value:ICollectionView):void
    {
        var collection:ICollectionView = value as ICollectionView;
        
        _dataProvider = collection;
    }
    
    //----------------------------------
    // defaultTupleMembers
    //----------------------------------
    
    mx_internal var _defaultTupleMembers:Array;
    
    mx_internal function get defaultTupleMembers():Array
    {
        if (!_defaultTupleMembers)
        {
            _defaultTupleMembers = new Array(attributeLevels.length/2);
            attributeToIndex = new Dictionary;
            var aIndex:int = 0;
            var n:int = attributeLevels.length;
            for (var i:int = 0; i < n; i += 2)
            {
                var attr:OLAPAttribute = attributeLevels[i].attribute;
                attributeToIndex[attr] = aIndex;
                _defaultTupleMembers[aIndex++] = attr.defaultMember;
            }
        }
        
        return _defaultTupleMembers.slice();
    }
    
    //----------------------------------
    // dimensions
    //----------------------------------
    
    /**
     * @private  
     */    
    private var _dimensions:IList = new ArrayCollection;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dimensions():IList
    {
        return _dimensions;
    }

    /**
     *  @private
     */
    public function set dimensions(value:IList):void
    {
        //reset the cache of levels
        _attributeLevels = null;
        _dimensions = value;
        var n:int = value.length;
        for (var i:int = 0; i < n; ++i)
        {
            var dim:OLAPDimension = value.getItemAt(i) as OLAPDimension;
            dim.cube = this;
            _dimensionMap[dim.name] = dim;
        }
    }
    
    //----------------------------------
    // elements
    //----------------------------------
    
    /**
    *  Processes the input Array and initializes the <code>dimensions</code>
    *  and <code>measures</code> properties based on the elements of the Array.
    *  Dimensions are represented in the Array by instances of the OLAPDimension class, 
    *  and measures are represented by instances of the OLAPMeasure class.
    *
    *  <p>Use this property to define the dimensions and measures of a cube in a single Array.</p>
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function set elements(value:Array):void
    {
        var dims:ArrayCollection = new ArrayCollection();
        var userMeasures:ArrayCollection = new ArrayCollection();
        for each (var element:Object in value)
        {
            if (element is OLAPDimension)
                dims.addItem(element);
            else if (element is OLAPMeasure)
                userMeasures.addItem(element);
            else
                OLAPTrace.traceMsg("Invalid element specified for cube elements");
        }
        
        dimensions = dims;
        measures = userMeasures;        
    }
    
    //----------------------------------
    // measures
    //----------------------------------
    
    /**
     * @private
     */    
    private var _measures:IList; //of OLAPMeasures
    
    /**
     *  Sets the measures of the OLAP cube, as a list of OLAPMeasure instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function set measures(value:IList):void
    {
        _measures = value;
    }
    
    //----------------------------------
    // name
    //----------------------------------

    /**
     * @private
     */
    private var _name:String;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get name():String
    {
        return _name;
    }

    /**
     *  @private
     */
    public function set name(value:String):void
    {
        _name = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public function cancelQuery(query:IOLAPQuery):void
    {
        var queryIndex:int = _queriesPending.indexOf(query);
        if (queryIndex != -1) 
        {
            // if the query was the current query ask cubeImpl to
            // abort the query.
            if (queryIndex == 0)
                _cubeImpl.cancelQuery(query);
            _queriesPending.splice(queryIndex, 1);

            //TODO make a fault call?
            delete _queryToken[query];
            if (_queriesPending.length == 0)
            {
                queryTimer.stop();
                queryTimer = null;
            }
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public function cancelRefresh():void
    {
        prepare = false;
        progress = 0;

        _cubeImpl.cancelRefresh();

        if (cubeBuildingTimer)
        {
            cubeBuildingTimer.stop();
            cubeBuildingTimer.removeEventListener(TimerEvent.TIMER,  updateDimensions);
            cubeBuildingTimer.removeEventListener(TimerEvent.TIMER,  buildCube);
            cubeBuildingTimer = null;
        }
        
        if (oldSort)
        {
            dataProvider.sort = oldSort;
            dataProvider.refresh();
        }
    }

    /**
     *  @private
     *  Creates a new dimension of the cube with the specified name.
     *
     *  @param name The name of the new dimension.
     *
     *  @return An OLAPDimension instance representing the new dimension.
     */        
    public function createDimension(name:String):OLAPDimension
    {
        var dim:OLAPDimension = new OLAPDimension(name);
        dim.cube = this;
        _dimensions.addItem(dim);
        _dimensionMap[name] = dim;
        return dim;
    }
        
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function findDimension(name:String):IOLAPDimension
    {
        return _dimensionMap[name];         
    }
    
     /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function refresh():void
    {
        // check if the refresh is already in progress and return in that case.
        // we can get into a infinite loop if refresh is being called in 
		// a collection change handler because a call to refresh sorts the dataProvider
		// resulting in a collection changed event
        if(cubeBuildingTimer)
            return;
		
        _attributeLevels = null;
        
        //TODO if user sets new dimensions after refreshing we need to again
        // position the measures dimension to the end of the list
         
        // is this the right place to do this creation of Measures Level?
        if (!findDimension(measureDimensionName))
        {
            var measuresDim:OLAPDimension = createDimension(measureDimensionName);
            var measuresHierarchy:OLAPHierarchy = measuresDim.createHierarchy(measureDimensionName);
            measuresHierarchy.hasAll = false;
            measuresHierarchy.dimension = measuresDim;
            var measuresLevel:OLAPLevel  = measuresHierarchy.createLevel(measureDimensionName);
            measuresDim.setAsMeasure(true);
            
            measuresDim.refresh();
            
            if (!_measures || _measures.length == 0)
            {
                var message:String = ResourceManager.getInstance().getString(
                            "olap", "noMeasures");
                throw Error(message);
            }
            
            // loop: create measure members
            var n:int = _measures.length;
            for (var i:int = 0; i < n; ++i)
            {
                var m:OLAPMeasure = _measures.getItemAt(i) as OLAPMeasure;
                m.dimension = measuresDim;
                measuresLevel.addMember(m);
            }
        }
        
        defaultMeasure = _measures.getItemAt(0) as OLAPMeasure;
        
        //TODO a warning message to the user
        if (!dataProvider)
            return;
        
        cubeBuildingTimer = new Timer(cubeBuildingTimeInterval);
        cubeBuildingTimer.addEventListener(TimerEvent.TIMER,  updateDimensions);
        cubeBuildingTimer.start();
    }
    
    /**
     *  @private
     */
    private function dispatchCubeProgress(progress:int, total:int, message:String=null):void
    {
        var ev:CubeEvent = new CubeEvent(CubeEvent.CUBE_PROGRESS);
        ev.progress = progress;
        ev.total = total;
        ev.message = message;
        dispatchEvent(ev);
    }
    
    /**
     *  @private
     */
    private function updateDimensions(event:TimerEvent):void
    {
        if (!prepare)
        {
	        //TODO may have to do it for each dimension if they have individual
    	    // dataProviders (to support star schema?)
            oldSort = dataProvider.sort;
            prepare = true;
            dimIndex = 0;
            dispatchCubeProgress(dimIndex, dimensions.length,
            				ResourceManager.getInstance().getString("olap",
            				"dimensionProcessingMessage", [dimensions.getItemAt(dimIndex).name]));
            return;
        }
        
        if (dimIndex < dimensions.length)
        {
            dispatchCubeProgress(dimIndex, dimensions.length,
            			ResourceManager.getInstance().getString("olap", 
            			"dimensionProcessingMessage", [dimensions.getItemAt(dimIndex).name]));
            dimensions.getItemAt(dimIndex).refresh();
            ++dimIndex;
            return;
        }

        dispatchCubeProgress(dimIndex, dimensions.length);
        
        prepare = false;
        cubeBuildingTimer.stop();
        cubeBuildingTimer.removeEventListener(TimerEvent.TIMER,  updateDimensions);

        dataProvider.sort = oldSort;
        oldSort = null;
        
        dataProvider.refresh();
        
        if (cubeImpl)
        {
            cubeImpl.cube = this;
            cubeImpl.refresh();
            cubeBuildingTimer.addEventListener(TimerEvent.TIMER,  buildCube);
            cubeBuildingTimer.start();
            progress = 0;
            total = dataProvider.length;
        }
    }
        
    /**
    *  @private
    */
    private function buildCube(event:TimerEvent):void
    {
        //once we have processed all rows cube would be doing a final pass
        //which takes a longer time. So we skip a loop to provide
        // a chance for the progress to be shown
        if (progress == (total + 1))
        {
            //TODO use resource bundle
            dispatchCubeProgress(progress - 1, total, 
            			ResourceManager.getInstance().getString("olap", 
            						"finalizingMessage"));
            ++progress;
            return;
        }

        var startTime:int = getTimer();
        var timeTaken:int = 0;  
        var cubeBuilt:Boolean;      

        // if total time taken for a action is less than 10 ms 
        // call the action function again
        while (timeTaken < workDuration)
        {
            cubeBuilt = cubeImpl.buildCubeIteratively();
            if (cubeBuilt)
                break;
            if (progress > total)
                dispatchCubeProgress(total, total, 
                		ResourceManager.getInstance().getString("olap", 
            									"finalizingMessage"));
            else
                dispatchCubeProgress(progress++, total, 
                			ResourceManager.getInstance().getString("olap", 
                			"progressMessage", [progress, total]));
            
            timeTaken = getTimer() - startTime;
        }
        
        if (cubeBuilt)
        {
            dispatchEvent(new CubeEvent(CubeEvent.CUBE_COMPLETE));
            cubeBuildingTimer.stop();      
            cubeBuildingTimer = null;
        }
    }

    /**
     *  Registers an event listener object with an EventDispatcher object so that the listener 
     *  receives notification of an event.
     *
     *  @param type The type of event.
     *
     *  @param listener The listener function that processes the event. 
     *
     *  @param useCapture Determines whether the listener works in the capture phase 
     *  or the target and bubbling phases.
     *
     *  @param priority The priority level of the event listener. 
     *
     *  @param useWeakReference Determines whether the reference to the listener is strong or weak. 
     *  A strong reference (the default) prevents your listener from being garbage-collected. 
     *  A weak reference does not.
     *
     *  @see flash.events.EventDispatcher#addEventListener()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    public function addEventListener(type:String, listener:Function, 
    			useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
    {
        ev.addEventListener(type, listener, useCapture, priority, useWeakReference);    
    }
    
    /**
     *  Removes a listener. 
     *  If there no matching listener is registered, 
     *  a call to this method has no effect.
     *
     *  @param type The type of event.
     *
     *  @param listener The listener object to remove.
     *
     *  @param useCapture Specifies whether the listener was registered for 
     *  the capture phase or the target and bubbling phases. 
     *
     *  @see flash.events.EventDispatcher#removeEventListener()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
    {
        ev.removeEventListener(type, listener, useCapture);     
    }
    
    /**
     *  Checks whether an event listener is registered with this object or any of its ancestors for the specified event type. 
     *  This method returns <code>true</code> if an event listener is triggered during any phase of the event flow 
     *  when an event of the specified type is dispatched to this object or to any of its descendants.
     *
     *  @param type The type of event.
     *
     *  @return A value of <code>true</code> if a listener of the 
     *  specified type is triggered; <code>false</code> otherwise.
     *
     *  @see flash.events.EventDispatcher#willTrigger()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    public function willTrigger(type:String):Boolean 
    {
        return ev.willTrigger(type);    
    }
        
    /**
     *  Dispatches an event into the event flow. 
     *  The event target is the object upon which the <code>dispatchEvent()</code> method is called.
     *
     *  @param event The Event object that is dispatched into the event flow. 
     *
     *  @return A value of <code>true</code> if the event was successfully dispatched. 
     *  A value of <code>false</code> indicates failure or that the 
     *  <code>preventDefault()</code> method was called on the event.
     *
     *  @see flash.events.EventDispatcher#dispatchEvent()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    public function dispatchEvent(event:Event):Boolean
    {
        return ev.dispatchEvent(event);
    }
                
    /**
     *  Checks whether the object has any listeners registered for a specific type of event. 
     *  This lets you determine where an object has altered handling of 
     *  an event type in the event flow hierarchy. 
     *
     *  @param type The type of event.
     *
     *  @return A value of <code>true</code> if a listener of the specified type 
     *  is registered; <code>false</code> otherwise.
     *
     *  @see flash.events.EventDispatcher#hasEventListener()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    public function hasEventListener(type:String):Boolean 
    {
        return ev.hasEventListener(type);   
    }
    
    /**
     *  @private
     */
    mx_internal function get cubeImpl():IOLAPCubeImpl
    {
        return _cubeImpl;
    }
        
    /**
     *  @private
     */
    mx_internal function set cubeImpl(value:IOLAPCubeImpl):void
    {
        _cubeImpl = value;
        _cubeImpl.cube = this;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function execute(query:IOLAPQuery):AsyncToken
    {
    	// attempt is being made by the user to execute 
    	// a query which has been already submitted for execution. 
    	if (_queriesPending.indexOf(query) != -1)
    		return null;
    		
        var token:AsyncToken = new AsyncToken(null);
        
        _queriesPending.push(query);
        _queryToken[query] = { tok:token };
        
        if (!queryTimer)
        {
            queryTimer = new Timer(queryBuildingTimeInterval);
            queryTimer.addEventListener(TimerEvent.TIMER, executeQuery);
            queryTimer.start();
        }
        
        return token;
    }
        
    /**
     * @private
     * 
     * Query validation functions should be moved to a interface/class whcih can be implemented/extended.
     */
    private function getAxisHierarchies(axis:IOLAPQueryAxis):Array
    {
        var axisHierarchies:Array = [];
        var sets:Array = axis.sets;
        var n:int = sets.length;
        for (var i:int = 0; i < n; ++i)
        {
            var tempSet:OLAPSet = sets[i];
            var tuples:Array = tempSet.tuples;
            var m:int = tuples.length;
            for (var j:int = 0; j < m; ++j)
            {
                var tempTuple:OLAPTuple = tuples[j];
                var list:IList = tempTuple.explicitMembers;
                var l:int = list.length;
                for (var k:int = 0; k < l; ++k)
                {
                    var tempHeirarchy:OLAPHierarchy = list.getItemAt(k).hierarchy as OLAPHierarchy;
                    if (tempHeirarchy)
                        axisHierarchies.push(tempHeirarchy);
                }
            }
        }
        
        return axisHierarchies;
    }
    
    /**
     * @private
     * 
     */
    private function findDuplicateHierarchies(axisHierarchies1:Array, axisHierarchies2:Array):OLAPHierarchy
    {
        //TODO is it possible that same hierarchy is represented by different object?
        // then we need to change this find logic
        for each (var h:OLAPHierarchy in axisHierarchies1)
        {
            var foundIndex:int = axisHierarchies2.indexOf(h);
            if (foundIndex > -1)
                return h;
        }
        
        return null;
    }
    
    /**
     * @private
     * 
     */
    private function validateQuery(q:IOLAPQuery):void
    {
        //check usage of same hierarchy on different axis.
        var axes:Array = OLAPQuery(q).axes;

        var n:int = axes.length;
        for (var i:int = 0; i < n; ++i)
        {
            var queryAxis:OLAPQueryAxis = axes[i];
        	
            if (queryAxis.axisOrdinal != OLAPQuery.SLICER_AXIS)
                checkZeroLengthAxis(queryAxis, queryAxis.axisOrdinal);
        	
            var axisHierarchies1:Array = getAxisHierarchies(queryAxis);
            var m:int = axes.length;
            for (var j:int = i + 1; j < m; ++j)
            {
                var axisHierarchies2:Array = getAxisHierarchies(axes[j]);
                var dup:OLAPHierarchy = findDuplicateHierarchies(axisHierarchies1, axisHierarchies2);
                if (dup)
                {
                    var message:String = ResourceManager.getInstance().getString(
                        "olap", "duplicateHierarchyOnAxes", [dup.name, i ,j]);
                    throw new QueryError(message);
                }
            }
        }
    }
    
    /**
     * @private
     * Checks if the axis has no tuples 
     */
    private function checkZeroLengthAxis(queryAxis:IOLAPQueryAxis, index:int):void
    {
    	if (queryAxis.tuples.length == 0)
    	{
                var message:String = ResourceManager.getInstance().getString(
                   "olap", "zeroElementsOnAxis", [index]);
                throw new QueryError(message);
    	}
    }

    /**
     *  @private
     *  The query execution callback function.
     */
    private function executeQuery(event:TimerEvent):void
    {
        var holder:Object = _queryToken[_queriesPending[0]];
        var token:AsyncToken = holder.tok;
        if (token.hasResponder())
        {
            var responder:IResponder;
            var result:OLAPResult;
            var q:IOLAPQuery = _queriesPending[0];
            var deleteEntry:Boolean = true;
            var fault:Fault;
            var faultCode:String;
            var faultEvent:FaultEvent;
            
            try
            {
                if (!holder.hasOwnProperty("result"))
                {
                    validateQuery(q);
                    holder["result"] = result = new resultClass;
                }
                else
                {
                    result = holder.result;
                }
                    
                if (!_cubeImpl.execute(q, result))
                {
                    deleteEntry = false;
                    return;
                }
            }
            catch(qe:QueryError)
            {
                faultCode = ResourceManager.getInstance().getString("olap", "queryError");
                fault = new Fault(faultCode, qe.message);
                faultEvent = FaultEvent.createEvent(fault, token);
                for each (responder in token.responders)
                {
                    responder.fault(faultEvent);  
                }
                result = null;
            }
            catch (e:Error)
            {
                faultCode = ResourceManager.getInstance().getString("olap", "error");
                fault = new Fault(faultCode, e.message);
                faultEvent = FaultEvent.createEvent(fault, token);
                for each (responder in token.responders)
                {
                    responder.fault(faultEvent);  
                }
                result = null;
            }
            finally
            {
                if (deleteEntry)
                {
                    _queriesPending.splice(0, 1);
                    delete _queryToken[q];
                    if (_queriesPending.length == 0)
                    {
                        queryTimer.stop();
                        queryTimer = null;
                    }
               }
            }

            if (result)
            {
                for each (responder in token.responders)
                {
                    responder.result(result);
                }
            }
        }
    }
    
    /**
     *  @private
     *  Returns true if the tuple addresses a valid cell in the cube.
     *  If the members of the tuple form a invalid combination returns false.
     *  
     *  @param tuple the tuple whose validity is to be checked. 
     */
    mx_internal function isTupleValid(tuple:OLAPTuple):Boolean
    {
        return DefaultCubeImpl(cubeImpl).isTupleValid(tuple);
    }
    
    /**
     *  Returns the name of the cube
     *
     *  @return The name of the cube.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function toString():String
    {
        return name;  
    }
}

}
