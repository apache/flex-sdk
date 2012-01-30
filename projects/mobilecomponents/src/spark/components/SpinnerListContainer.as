package spark.components
{
/**
 *  Container for one or more SpinnerList controls. The SpinnerLists are laid out horizontally.
 *  The SpinnerListContainerSkin displays a frame, shadow gradients and a selection indicator.   
 *       
 * @see spark.components.SpinnerList
 * @see spark.skins.mobile.SpinnerListContainerSkin
 * 
 *  @includeExample examples/SpinnerListExample.mxml -noswf
 *  @includeExample examples/SpinnerListContainerExample.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */ 
    
[Exclude(name="backgroundAlpha", kind="style")]
[Exclude(name="backgroundColor", kind="style")]    
    
public class SpinnerListContainer extends SkinnableContainer
{
    /**
     *  Constructor.
     *        
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */     
    public function SpinnerListContainer()
    {
        super();
    }
}
}