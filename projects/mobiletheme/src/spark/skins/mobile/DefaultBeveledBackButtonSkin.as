
package spark.skins.mobile
{
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  Emphasized button uses accentColor instead of chromeColor. Replaces the
 *  BeveledBackButtonSkin.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class DefaultBeveledBackButtonSkin extends BeveledBackButtonSkin
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
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function DefaultBeveledBackButtonSkin()
    {
        super();
        
        fillColorStyleName = "accentColor";
    }
}
}