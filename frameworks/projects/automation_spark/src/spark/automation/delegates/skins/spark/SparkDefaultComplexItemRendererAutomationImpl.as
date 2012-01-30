package spark.automation.delegates.skins.spark
{
    import flash.display.DisplayObject;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.SparkSkinnableContainerAutomationImpl;
    import spark.automation.delegates.components.supportClasses.SparkItemRendererAutomationImpl;
    import spark.components.Scroller;
    import spark.components.supportClasses.GroupBase;
    import spark.core.IViewport;
    import spark.skins.spark.DefaultComplexItemRenderer;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  ItemRenderer class for spark.
     * 
     *  @see spark.skins.spark.DefaultItemRenderer
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    
    public class SparkDefaultComplexItemRendererAutomationImpl extends SparkItemRendererAutomationImpl
    {
        
        include "../../../../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Registers the delegate class for a component class with automation manager.
         *  
         *  @param root The SystemManger of the application.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.skins.spark.DefaultComplexItemRenderer, SparkDefaultComplexItemRendererAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj DefaultItemRenderer object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        
        public function SparkDefaultComplexItemRendererAutomationImpl(obj:spark.skins.spark.DefaultComplexItemRenderer)
        {
            super(obj);
            recordClick = false;
        }
        
        /**
         *  @private
         */
        private function get renderer():spark.skins.spark.DefaultComplexItemRenderer
        {
            return uiComponent as spark.skins.spark.DefaultComplexItemRenderer;
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPart(child:IAutomationObject):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPart(uiAutomationObject, child);
        }
        
        /**
         *  @private
         */
        override public function resolveAutomationIDPart(part:Object):Array
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpResolveIDPart(uiAutomationObject, part);
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties);
            
        }
        
        /**
         *  @private
         */
        
        override public function get numAutomationChildren():int
        { 
            
            var objArray:Array = getAutomationChildren();
            return (objArray?objArray.length:0);
        }
        
        /**
         *  @private
         */
        
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            var numChildren:int = renderer.contentGroup.numChildren;
            if(index < numChildren )
                return   renderer.contentGroup.getChildAt(index) as IAutomationObject;
            else
            {
                index = index - numChildren;
                var scrollBars:Array = getScrollBars(renderer,renderer.contentGroup);
                if(scrollBars && index < scrollBars.length)
                    return scrollBars[index];
            }   
            
            
            return null;
        }
        
        
        override public function getAutomationChildren():Array
        {
            
            var chilArray:Array = new Array();
            var n:int = renderer.contentGroup.numChildren;
            
            for (var i:int = 0; i<n ; i++)
            {
                var obj:Object = renderer.contentGroup.getChildAt(i);
                // here if are getting scrollers, we need to add the viewport's children as the actual children
                // instead of the scroller
                if(obj is spark.components.Scroller)
                {
                    var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
                    var viewPort:IViewport =  scroller.viewport;
                    if(viewPort is IAutomationObject)
                        chilArray.push(viewPort);
                    if(scroller.horizontalScrollBar)
                        chilArray.push(scroller.horizontalScrollBar);
                    if(scroller.verticalScrollBar)
                        chilArray.push(scroller.verticalScrollBar);
                }
                else
                    chilArray.push(obj);
            }
            var scrollBars:Array = getScrollBars(null,renderer.contentGroup);
            n = scrollBars? scrollBars.length : 0;
            
            for ( i=0; i<n ; i++)
            {
                chilArray.push(scrollBars[i]);
            }
            
            
            return chilArray;
        }
        
        /**
         * private
         */ 
        protected function getScrollBars(passedObj:Object, stopWithContetGroup:GroupBase):Array
        {
            var scroller:spark.components.Scroller = null;
            if(passedObj)
                scroller = getScroller(passedObj,stopWithContetGroup);
            else
                scroller = getScroller(renderer,stopWithContetGroup);
            
            if(scroller)
            {
                var tempArray:Array = new Array();
                if(scroller.horizontalScrollBar && scroller.horizontalScrollBar.visible)
                    tempArray.push(scroller.horizontalScrollBar);
                if(scroller.verticalScrollBar && scroller.verticalScrollBar.visible)
                    tempArray.push(scroller.verticalScrollBar);
                
            }
            return tempArray;
            
        }
        
        /**
         * private
         */ 
        protected function getScroller(passedObj:Object, stopWithContentGroup:GroupBase):spark.components.Scroller
        {
            
            if(passedObj)
            {
                if( !(passedObj.hasOwnProperty("numChildren") && 
                    passedObj.hasOwnProperty("getChildAt")))
                    return null;
            }
            
            var requiredObject:Object = null;
            if(passedObj)
                requiredObject = passedObj;
            else
                // just to ensure that if no object is passed, we will consider it on the
                // current object.
                requiredObject = renderer;
            
            var n:int = requiredObject.numChildren;
            
            var obj:Object;
            for (var i:int = 0; i<n ; i++)
            {
                obj  =  requiredObject.getChildAt(i);
                
                if(obj is spark.components.Scroller)
                    return obj as spark.components.Scroller;
                
                // check whether we need to proceed with the element to dig further
                // if it is a skin we need to proceed.
                // if the object corresponds to our contentGroup, we need not proceed further
                if(stopWithContentGroup &&(obj == stopWithContentGroup))
                    continue;
                do
                {
                    obj = getScroller(obj,stopWithContentGroup);
                }while(obj && !(obj is spark.components.Scroller))
                
                if(obj is spark.components.Scroller)
                    return obj as spark.components.Scroller;
            }
            return null;
        }
        
    }
}