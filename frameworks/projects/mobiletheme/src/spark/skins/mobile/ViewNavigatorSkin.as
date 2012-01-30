package spark.skins.mobile
{
import mx.effects.IEffect;
import mx.states.State;
import mx.states.Transition;

import spark.components.ActionBar;
import spark.components.ButtonBar;
import spark.components.Group;
import spark.components.ViewNavigator;
import spark.effects.IViewTransition;
import spark.effects.Move;
import spark.effects.SlideViewTransition;

public class ViewNavigatorSkin extends SliderSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ViewNavigatorSkin()
    {
        super();
        
        states = [
            new State({name:"portrait"}),
            new State({name:"portraitAndOverlay"}),
            new State({name:"landscape"}),
            new State({name:"landscapeAndOverlay"})
            ];
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    public var hostComponent:ViewNavigator;
    
    // Groups and UI Controls
    public var contentGroup:Group;
    public var actionBar:ActionBar;
    public var tabBar:ButtonBar;
    
    // Transitions
    public var defaultPushTransition:IViewTransition;
    public var defaultPopTransition:IViewTransition;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createChildren():void
    {
        contentGroup = new Group();
        contentGroup.minHeight = 0;
    	
        tabBar = new ButtonBar();
        tabBar.requireSelection = true;
        tabBar.height = 40;
        
        actionBar = new ActionBar();
        
        addChild(contentGroup);
        addChild(actionBar);
        addChild(tabBar);
        
        defaultPushTransition = new SlideViewTransition(300, SlideViewTransition.SLIDE_LEFT);
        defaultPopTransition = new SlideViewTransition(300, SlideViewTransition.SLIDE_RIGHT);
    }
    
    /**
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function set currentState(value:String):void
    {
        if (super.currentState != value)
        {
            super.currentState = value;
            
            // Force a layout pass on the components
            invalidateDisplayList();
        }
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var top:Number = 0;
        var bottom:Number = unscaledHeight;
        var componentHeight:Number;
        
        if (tabBar.includeInLayout)
        {
            tabBar.alpha = .5;
            componentHeight = tabBar.getPreferredBoundsHeight();
            tabBar.setLayoutBoundsSize(unscaledWidth, componentHeight);
            tabBar.setLayoutBoundsPosition(0, top);
            
            top += componentHeight;
        }
        
        if (actionBar.includeInLayout)
        {
            actionBar.alpha = .5;
            componentHeight = actionBar.getPreferredBoundsHeight();
            
            actionBar.setLayoutBoundsSize(unscaledWidth, componentHeight);
            actionBar.setLayoutBoundsPosition(0, top);
            
            top += componentHeight;
        }
        
        if (hostComponent.overlayControls)
        {
            tabBar.alpha = .5;
            actionBar.alpha = .5;
            
            if (contentGroup.includeInLayout)
            {
                contentGroup.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
                contentGroup.setLayoutBoundsPosition(0, 0);
            }
        }
        else
        {
            tabBar.alpha = 1.0;
            actionBar.alpha = 1.0;
            
    		if (contentGroup.includeInLayout)
    		{
    			var contentGroupHeight:Number = bottom - top;
    			
    			if (contentGroupHeight < contentGroup.minHeight)
    				contentGroupHeight = contentGroup.minHeight;
                
                contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
                contentGroup.setLayoutBoundsPosition(0, top);
    		}
        }
    }
}
}