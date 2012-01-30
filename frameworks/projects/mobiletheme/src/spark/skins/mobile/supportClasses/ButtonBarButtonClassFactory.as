////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile.supportClasses
{
import mx.core.ClassFactory;
import mx.core.IFactory;

import spark.components.ButtonBarButton;
import spark.components.supportClasses.SkinnableComponent;

/**
 *  Adds skinClass style support to ClassFactory.
 * 
 *  @see spark.skins.mobile.ButtonBarSkin
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class ButtonBarButtonClassFactory extends ClassFactory
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function ButtonBarButtonClassFactory(generator:Class)
    {
        super(generator);
    }
    
    private var _skinClass:Class;
    
    /**
     * The skin class that should be applied to button bar buttons created
     * by this factory.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function get skinClass():Class
    {
        return _skinClass;
    }
    
    public function set skinClass(skinClass:Class):void
    {
        _skinClass = skinClass;
    }
    
    override public function newInstance():*
    {
        var instance:Object = new generator();
        
        if (properties != null)
        {
            for (var p:String in properties)
            {
                instance[p] = properties[p];
            }
        }
        
        if (instance is SkinnableComponent && _skinClass)
        {
            SkinnableComponent(instance).setStyle("skinClass", _skinClass);
            SkinnableComponent(instance).setStyle("focusSkin", null);
        }
        
        return instance;
    }
}
}