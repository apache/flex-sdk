package spark.components.supportClasses
{
import flashx.textLayout.operations.FlowOperation;


/**
 *  The TextInputOperation class represents a text input operation.
 *  This class is only used by StyleableTextField when sending the
 *  CHANGING event. 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class TextInputOperation extends FlowOperation
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TextInputOperation():void
    {
        super(null);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The text that was inputted. If the CHANGING event is not cancelled,
     *  this text will be added to the TextFeld. If the event is cancelled,
     *  the text will not be added.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var text:String;
}
}