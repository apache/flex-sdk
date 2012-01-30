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

package spark.components.supportClasses
{    
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import flash.utils.IExternalizable;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    import spark.components.supportClasses.ViewHistoryData;
    
    import mx.core.mx_internal;
    use namespace mx_internal;
    
    /**
     *  <code>ViewNavigatorSection</code> is a data structure that represents a stack 
     *  of Screens used by navigators.  This object consists of a vector
     *  of <code>ScreenData</code> objects that contain initialization properties
     *  for a screen.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class ViewNavigatorSection implements IExternalizable
    {
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function ViewNavigatorSection()
        {
            super();
            
            _source = new Vector.<ViewHistoryData>();
        }
        
        //--------------------------------------------------------------------------
        //
        // Variables
        // 
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        private var _source:Vector.<ViewHistoryData>;
        
        //--------------------------------------------------------------------------
        //
        // Properties
        // 
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  icon
        //----------------------------------
        /**
         *  @private
         */
        private var _icon:Class;
        
        /**
         *  Returns the icon that should be used when this stack is represented
         *  by a visual component.
         */
        public function get icon():Class
        {
            return _icon;    
        }
        /**
         *  @private
         */
        public function set icon(value:Class):void
        {
            _icon = value;
        }
        
        //----------------------------------
        //  firstViewData
        //----------------------------------
        /**
         * @private
         */
        private var _firstViewData:Object;
        
        /**
         * This is the initialization data to pass to the
         * root screen when it is created.
         */
        public function get firstViewData():Object
        {
            return _firstViewData;
        }
        
        /**
         * @private
         */
        public function set firstViewData(value:Object):void
        {
            _firstViewData = value;
        }
        
        //----------------------------------
        //  label
        //----------------------------------
        /**
         *  @private
         */
        private var _label:String;
        
        /**
         *  The label to be used when this stack is represented by
         *  a visual component.
         */
        public function get label():String
        {
            return _label;
        }
        
        /**
         *  @private
         */
        public function set label(value:String):void
        {    
            _label = value;
        }
        
        //----------------------------------
        //  length
        //----------------------------------
        
        /**
         *  Returns the length of the stack
         */        
        public function get length():int
        {
            return _source.length;
        }
        
        //----------------------------------
        //  firstView
        //----------------------------------
        /**
         *  @private
         *  The backing variable for the firstView property.
         */
        private var _firstView:Class;
        
        /**
         *  This property is the object to use to initialize the root screen
         *  of the stack.  This can be a Class, instance or Factory that creates
         *  an object that extends <code>Screen</code>.
         */
        public function get firstView():Class
        {
            return _firstView;
        }
        
        /**
         * @private
         */
        public function set firstView(value:Class):void
        {
            _firstView = value;
        }
        
        //----------------------------------
        //  top
        //----------------------------------
        
        /**
         *  Returns the object at the top of the stack.  If the
         *  stack is empty, this propety is null.
         */
        mx_internal function get topView():ViewHistoryData
        {
            return _source.length == 0 ? null : _source[_source.length - 1];
        }
        
        //--------------------------------------------------------------------------
        //
        // Methods
        // 
        //--------------------------------------------------------------------------
        
        /**
         *  Clears the entire stack.
         */
        public function clear():void
        {
            _source.length = 0;    
        }
        
        /**
         *  Pushes a data on the top of the stack.
         */
        public function push(factory:Class, data:Object):void
        {
            _source.push(new ViewHistoryData(factory, data));
        }
        
        /**
         *  Removes the top item off the stack.
         */
        public function pop():void
        {
            _source.pop();
        }
        
        /**
         *  Removes all but the root object from the screen stack.
         */
        public function popToFirstView():void
        {
            if (_source.length > 1)
                _source.length = 1;
        }
        
        //--------------------------------------------------------------------------
        //
        // Methods: IExternalizable
        // 
        //--------------------------------------------------------------------------
        
        public function writeExternal(output:IDataOutput):void
        {
            output.writeObject(firstViewData);
            output.writeObject(label);
            output.writeObject(_source);
            output.writeObject(getQualifiedClassName(icon));
            output.writeObject(getQualifiedClassName(firstView));
        }
        
        public function readExternal(input:IDataInput):void 
        {
            firstViewData = input.readObject();
            label = input.readObject();
            _source = input.readObject() as Vector.<ViewHistoryData>;
            
            var className:String = input.readObject();
            icon = (className == "null") ? null : getDefinitionByName(className) as Class;
            
            className = input.readObject();
            firstView = (className == "null") ? null : getDefinitionByName(className) as Class;
        }
    }
}