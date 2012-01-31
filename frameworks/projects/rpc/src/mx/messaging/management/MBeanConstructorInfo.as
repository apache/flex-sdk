
package mx.messaging.management
{
    
import mx.utils.ObjectUtil;

[RemoteClass(alias='flex.management.jmx.MBeanConstructorInfo')]    
    
/**
 * Client representation of metadata for a MBean constructor.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public class MBeanConstructorInfo extends MBeanFeatureInfo 
{
    /**
     *  Creates a new instance of an empty MBeanConstructorInfo.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function MBeanConstructorInfo()
	{
		super();
	}
	
	/**
	 * The parameter data types that make up the constructor signature.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var signature:Array;
    
}

}