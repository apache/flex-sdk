package spark.automation.delegates.components.gridClasses
{
    import flash.display.DisplayObject;
    
    import mx.automation.Automation;
    
    import spark.automation.delegates.components.SparkGroupAutomationImpl;
    import spark.components.gridClasses.GridItemRenderer;
    
    
    /**
     *  Defines methods and properties required to perform instrumentation for the 
     *  GridItemRenderer component.
     * 
     *  @see spark.components.gridClasses.GridItemRenderer 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public class SparkGridItemRendererAutomationImpl extends SparkGroupAutomationImpl
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
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(GridItemRenderer, SparkGridItemRendererAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj GridItemRenderer object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkGridItemRendererAutomationImpl(obj:GridItemRenderer)
        {
            super(obj);
        }
    }
}