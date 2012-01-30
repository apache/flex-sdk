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

package spark.components
{
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.StageOrientationEvent;
import flash.net.registerClassAlias;

import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewDescriptor;
import spark.components.supportClasses.ViewNavigatorApplicationBase;
import spark.components.supportClasses.ViewNavigatorBase;

use namespace mx_internal;

[DefaultProperty("navigators")]

/**
 *  The TabbedViewNavigatorApplication container defines an application 
 *  with multiple sections. 
 *  The TabbedViewNavigatorApplication container automatically creates 
 *  a TabbedMobileNavigator container. 
 *  The TabbedViewNavigator container creates the TabBar control to 
 *  support navigation among the sections of the application.
 *
 *  <p>The only allowable child of the TabbedViewNavigatorApplication 
 *  container is ViewNavigator. 
 *  Define one ViewNavigator for each section of the application.</p> 
 *
 *  <p>The TabbedViewNavigatorApplication container has the following 
 *  default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>100% high and 100% wide to take up all available screen space.</td>
 *        </tr>
 *        <tr>
 *           <td>Child layout</td>
 *           <td>Defined by the individual View containers 
 *               that make up the views of the application.</td>
 *        </tr>
 *        <tr>
 *           <td>Scroll bars</td>
 *           <td>None. If you do add scroll bars, users can scroll the entire application. 
 *              That includes the ActionBar and TabBar area of the application. 
 *              Because you typically do not want those areas of the view to scroll, 
 *              add scroll bars to the individual View containers of the application, 
 *              rather than to the application container itself. </td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.mobile.TabbedViewNavigatorApplicationSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:TabbedViewNavigatorApplication&gt;</code> tag inherits all of the tag
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:TabbedViewNavigatorApplication
 *    <strong>Properties</strong>
 *    navigators="null"
 * 
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.TabbedViewNavigator
 *  @see spark.components.TabBar
 *  @see spark.skins.mobile.TabbedViewNavigatorApplicationSkin
 *
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigatorApplication extends ViewNavigatorApplicationBase
{
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    /**
     *  The main tabbedNavigator for the application.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var tabbedNavigator:TabbedViewNavigator;
    
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
    public function TabbedViewNavigatorApplication()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */
    private var navigatorProperties:Object = {};
    
    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  @private
     */ 
    override mx_internal function get activeView():View
    {
        if (tabbedNavigator)
            return tabbedNavigator.activeView;
        
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  exitApplicationOnBackKey
    //----------------------------------
    /**
     *  @private
     */ 
    override mx_internal function get exitApplicationOnBackKey():Boolean
    {
        if (tabbedNavigator)
            return tabbedNavigator.exitApplicationOnBackKey;
        
        return super.exitApplicationOnBackKey;
    }
    
    //----------------------------------
    //  navigators
    //----------------------------------
    /**
     *  @copy TabbedViewNavigator#navigators
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigators():Vector.<ViewNavigatorBase>
    {
        if (tabbedNavigator)
            return tabbedNavigator.navigators;
        else
            return navigatorProperties.navigators;
    }
    /**
     *  @private
     */
    public function set navigators(value:Vector.<ViewNavigatorBase>):void
    {
        if (tabbedNavigator)
            tabbedNavigator.navigators = value;
        else
            navigatorProperties.navigators = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: ViewNavigatorApplicationBase
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function invokeHandler(event:InvokeEvent):void
    {
        super.invokeHandler(event);
        
        // If the navigator and view are created, this means that the application
        // is restoring its state after being suspended by the operating system.
        // In this case, the activeView is currently deactivated and it orientation 
        // state could potentially be wrong.  Wait for the next stage resize event
        // so that the runtime has a chance to discover its orientation and then 
        // properly update and activate the view
        if (tabbedNavigator)
        {
            if (tabbedNavigator.activeView)
                systemManager.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
        }
        
        // Set the stage focus to the navigator's active view
        if (systemManager.stage.focus == null && tabbedNavigator)
        {
            if (tabbedNavigator.activeView)
                systemManager.stage.focus = tabbedNavigator.activeView;
            else
                systemManager.stage.focus = tabbedNavigator;
        }
    }
    
    /**
     *  @private
     *  This method is called on the first resize event after an application
     *  has been invoked after being suspended in the background.
     */
    private function stage_resizeHandler(event:Event):void
    {
        systemManager.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
        
        // The active view was deactivated when the application was suspended.  We
        // need to reactivate it here.
        var view:View = tabbedNavigator.activeView;;
        if (!view.isActive)
            view.setActive(true);
    }
    
    /**
     *  @private
     */ 
    override protected function deactivateHandler(event:Event):void
    {
        if (tabbedNavigator && tabbedNavigator.activeView)
            tabbedNavigator.activeView.setActive(false);
        
        // super is called after so that the active view can get the
        // viewDeactive event before the persistence process begins.
        super.deactivateHandler(event);
    }
    
    /**
     *  @private
     */ 
    override protected function backKeyUpHandler(event:KeyboardEvent):void
    {
        super.backKeyUpHandler(event);
        
        if (viewMenuOpen)
            viewMenuOpen = false;
        else if (tabbedNavigator)
            tabbedNavigator.backKeyUpHandler();
    }
    
    /**
     *  @private
     */
    override protected function saveNavigatorState():void
    {
        super.saveNavigatorState();
        
        if (navigators.length > 0)
            persistenceManager.setProperty("navigatorState", tabbedNavigator.saveViewData());
    }

    /**
     *  @private
     */
    override protected function loadNavigatorState():void
    {
        super.loadNavigatorState();
        
        var savedState:Object = persistenceManager.getProperty("navigatorState");
        
        if (savedState)
            tabbedNavigator.loadViewData(savedState);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == tabbedNavigator)
        {
            if (navigatorProperties.navigators !== undefined)
            {
                tabbedNavigator.navigators = navigatorProperties.navigators;
            }
            
            // Set the stage focus to the navigator
            systemManager.stage.focus = tabbedNavigator;
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
    }
}
}