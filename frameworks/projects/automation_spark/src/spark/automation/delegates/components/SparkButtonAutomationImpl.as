
package spark.automation.delegates.components
{
    import flash.display.DisplayObject;
    
    import mx.automation.Automation;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.supportClasses.SparkButtonBaseAutomationImpl;
    import spark.components.Button;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  Button control.
     * 
     *  @see spark.components.Button
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkButtonAutomationImpl extends SparkButtonBaseAutomationImpl 
    {
        
        include "../../../core/Version.as";
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
            Automation.registerDelegateClass(spark.components.Button, SparkButtonAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj Button object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkButtonAutomationImpl(obj:spark.components.Button)
        {
            super(obj);
            
        }
        
        
    }
    
}