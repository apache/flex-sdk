////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
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