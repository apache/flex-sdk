////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.olapDataGridClasses
{
import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.controls.OLAPDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.Container;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IUIComponent;
import mx.events.FlexEvent;
import mx.olap.IOLAPElement;
import mx.styles.ISimpleStyleClient;

/**
 *  The OLAPDataGridHeaderRenderer is a container which contains
 *  one header for each row of on the column axis. This header describes 
 *  the name of the hierarchy to which a particular member belongs.
 *  
 *  Because of the limitation that a valid column grouping should be in a tree
 *  form, a fake top level column is created to give the required functionality of
 *  column axis headers to OLAPDataGrid
 *
 *  @see mx.controls.OLAPDataGrid
 *  @see mx.controls.olapDataGridClasses.OLAPDataGridHeaderRendererProvider
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */

/**
 *  @private
 */
public class OLAPDataGridHeaderRenderer extends Container
       implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer
{
	include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPDataGridHeaderRenderer()
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
    private var listOwner:OLAPDataGrid;
    
    private var factoriesChanged:Boolean = false;
    
    private var dataProviderChanged:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overriden Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @private
     *  Storage for the data property.
     */
    private var _data:Object;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>data</code> property as 
     *  defined by the IDataRenderer interface.
     *
     *  @see mx.core.IDataRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get data():Object
    {
        return _data;
    }

    /**
     *  @private
     */
    override public function set data(value:Object):void
    {
        _data = value;
        
        invalidateProperties();

        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    
    //----------------------------------
    //  horizontalScrollPolicy
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set horizontalScrollPolicy(value:String):void
    {
        super.horizontalScrollPolicy = "off";
    }
    
    //----------------------------------
    //  verticalScrollPolicy
    //----------------------------------

    /**
     *  @private
     */
    override public function set verticalScrollPolicy(value:String):void
    {
        super.verticalScrollPolicy = "off";
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  listData
    //----------------------------------

    /**
     *  @private
     *  Storage for the listData property.
     */
    private var _listData:AdvancedDataGridListData;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>listData</code> property as 
     *  defined by the IDropInListItemRenderer interface.
     *
     *  @see mx.controls.listClasses.IDropInListItemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get listData():BaseListData
    {
        return _listData;
    }

    /**
     *  @private
     */
    public function set listData(value:BaseListData):void
    {
        _listData = AdvancedDataGridListData(value);
        
        invalidateProperties();
    }


    
    //----------------------------------
    //  factories
    //----------------------------------
    
    private var _factories:Array /* of IFactory */;

    /**
     *  @private
     */
    public function get factories():Array /* of IFactory */
    {
        return _factories;
    }

    /**
     *  @private
     */
    public function set factories(value:Array /* of IFactory */):void
    {
        if(checkIfChanged(_factories, value))
        {
            _factories = value;
            factoriesChanged = true;
            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  dataProvider
    //----------------------------------

    private var _dataProvider:Array /* of IOLAPHierarchy */;

    /**
     *  @private
     */
    public function get dataProvider():Array /* of IOLAPHierarchy */
    {
        return _dataProvider;
    }

    /**
     *  @private
     */
    public function set dataProvider(value:Array /* of IOLAPHierarchy */):void
    {
        if(checkIfChanged(_dataProvider, value))
        {
            _dataProvider = value;
            dataProviderChanged = true;
            invalidateProperties();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overriden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if ((factoriesChanged || dataProviderChanged) && factories && dataProvider)
        {
            factoriesChanged = dataProviderChanged = false;

            //Remove the children if there are any already added 
            while(this.numChildren)
                this.removeChildAt(0);
                
            var n:int = factories.length;
            for (var i:int = 0; i < n; i++)
            {
                var factory:IFactory = factories[i];
                var r:IListItemRenderer = factory.newInstance();
                
                if (r is IDropInListItemRenderer)
                {
                    var c:AdvancedDataGridColumn;
                    if(data is AdvancedDataGridColumn)
                        c = AdvancedDataGridColumn(data);
                    else
                        c = null;
                    
                    IDropInListItemRenderer(r).listData =  makeListData(this.dataProvider[i],  
                                                                        _listData.uid, 
                                                                        _listData.rowIndex,
                                                                        _listData.columnIndex,
                                                                        c);
                }

                r.data = this.data;
                this.addChild(DisplayObject(r));
            }
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function setStyle(styleProp:String, newValue:*):void
    {
        super.setStyle(styleProp, newValue);

        if (styleProp == "axisHeaderStyleName")
        {
            //Need to propagate the style value to all the child headers 
            for ( var i:int = 0; i < this.numChildren; i++)
            {
                var child:DisplayObject = DisplayObject(this.getChildAt(i));

                if(child is ISimpleStyleClient)
                    ISimpleStyleClient(child).styleName = newValue;
            }
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function measure():void
    {
        super.measure();

        var w:Number = 0;
            
        var h:Number = 0;

        for ( var i:int = 0; i < factories.length; i++)
        {
            var child:IUIComponent = IUIComponent(this.getChildAt(i));
            h = Math.max(h, child.getExplicitOrMeasuredHeight());
            w += child.getExplicitOrMeasuredWidth()+5;
        }

        if (!isNaN(explicitWidth))
            w = explicitWidth;

        measuredWidth = w;
        measuredHeight = h;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var startx:Number = 0;
        var g:Graphics = this.graphics;
        g.clear();

        var color:uint = getStyle("verticalGridLineColor");
        g.lineStyle(1, color, 100);
        
        var n:int = factories.length;
        for ( var i:int = 0; i < n; i++)
        {
            var child:IUIComponent = IUIComponent(this.getChildAt(i));
            child.move(startx, 0);

            var w:Number = (child.getExplicitOrMeasuredWidth());
            child.setActualSize(w, child.getExplicitOrMeasuredHeight());

            startx += w;
            
            g.moveTo(startx, -5);
            g.lineTo(startx, unscaledHeight);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Creates a new AdvancedDataGridListData instance and populates the fields based on
     *  the input data provider item (In case of OLAPDataGrid it is an IOLAPHierarhcy). 
     *  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function makeListData(data:Object, uid:String, 
                                             rowNum:int, columnNum:int, column:AdvancedDataGridColumn):BaseListData
    {
        var text:String = "";
        //data here is an IOLAPAttribute
        if (data is IOLAPElement)
            text = data.name
        
        return new AdvancedDataGridListData(text, column ? column.dataField : "", columnNum, 
                                            uid, _listData.owner, rowNum);
    }

    /**
     *  @private
     */
    private function checkIfChanged(a:Array /* of Object */, b:Array /* of Object */):Boolean
    {
        var mismatch:Boolean = false;
        if(!a)
        {
            mismatch = true;
        }
        else if(b && b.length)
        {
            if(b.length != a.length)
            {
                mismatch = true;
            }
            else
            {
                for (var i:int = 0; i < b.length && i < a.length; i++)
                {
                    if(a[i] != b[i])
                        mismatch = true;
                }
            }
        }
        return mismatch;
    }
}

}