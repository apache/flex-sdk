
package mx.messaging.management
{

import mx.utils.ObjectUtil;

[RemoteClass(alias='flex.management.jmx.MBeanParameterInfo')]

/**
 * Client representation of metadata for a MBean operation parameter.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public class MBeanParameterInfo extends MBeanFeatureInfo 
{
    /**
     *  Creates a new instance of an empty MBeanParameterInfo.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
	public function MBeanParameterInfo()
	{
		super();
	}
	
	/**
	 * The data type of the operation parameter.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion BlazeDS 4
	 *  @productversion LCDS 3 
	 */
	public var type:String;

}

}