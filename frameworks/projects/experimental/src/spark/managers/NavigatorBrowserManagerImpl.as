////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package spark.managers
{
	import flash.display.DisplayObjectContainer;
	
	import mx.core.IVisualElement;
	import mx.events.BrowserChangeEvent;
	import mx.events.FlexEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	import spark.components.DataGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.events.IndexChangeEvent;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.utils.LabelUtil;
	
	import spark.layouts.supportClasses.INavigatorLayout;

	[ExcludeClass]
	/**
	 *  @private
	 *  The NavigatorBrowserManager is a Singleton manager that acts as
	 *  a proxy between the BrowserManager and INavigatorLayout instances
	 *  added to it.
	 * 
	 *  <p>It updates the <code>fragment</code> property of the IBrowserManager
	 *  when a registered INavigatorLayout changes its <code>selectedindex</code>,
	 *  and also sets the <code>selectedIndex</code> of registered INavigatorLayout instances
	 *  when the <code>fragment</code> property of the IBrowserManager changes.
	 *
	 *  @see mx.managers.IBrowserManager
	 *  @see spark.layouts.supportClasses.INavigatorLayout
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class NavigatorBrowserManagerImpl implements INavigatorBrowserManager
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Class Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static var _instance:NavigatorBrowserManagerImpl;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Class Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		public static function getInstance():NavigatorBrowserManagerImpl
		{
			if( !_instance ) _instance = new NavigatorBrowserManagerImpl();
			return _instance;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor. 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function NavigatorBrowserManagerImpl()
		{
			super();
			
			_browserManager = BrowserManager.getInstance();
			_browserManager.addEventListener( BrowserChangeEvent.BROWSER_URL_CHANGE, onBrowserManagerBrowserURLChange, false, 0, true ); 
			_browserManager.init("", "");
			
			parseFrament();
			updateFragment();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Instance of the browser manager to be used.
		 */
		private var _browserManager:IBrowserManager;
		
		/**
		 *  @private
		 *  The list of layouts being managed.
		 */
		private var _layouts:Vector.<INavigatorLayout> = new Vector.<INavigatorLayout>();
		
		/**
		 *  @private
		 *  The list of layouts that can still be parsed after a URL change.
		 */
		private var _layoutsToParse:Vector.<INavigatorLayout> = new Vector.<INavigatorLayout>();
		
		/**
		 *  @private
		 *  The list of layouts to ignore their <code>FlexEvent.VALUE_COMMIT</code> events.
		 *  When the index of a layout is changed, we want to ignore the value commit, if
		 *  the layouts <code>selectedIndex</code> is the same as the index set.
		 */
		private var _layoutsToIgnore:Vector.<LayoutToIgnore> = new Vector.<LayoutToIgnore>();
		
		/**
		 *  @private
		 *  A list of fragment parts that still need to be parsed.
		 */
		private var _fragmentsToParse:Array;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  fragmentField
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for fragmentField.
		 */
		private var _fragmentField:String;
		
		/**
		 *  The portion of current URL after the '#' as it appears 
		 *  in the browser address bar, or the default fragment
		 *  used in setup() if there is nothing after the '#'.  
		 *  Use setFragment to change this value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get fragmentField():String
		{
			return _fragmentField;
		}
		/**
		 *  @private
		 */
		public function set fragmentField( value:String ):void
		{
			if( _fragmentField == value ) return;
			
			_fragmentField = value;
			updateFragment();
		}
		
		
		//----------------------------------
		//  fragmentFunction
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for fragmentFunction.
		 */
		private var _fragmentFunction:Function;
		
		/**
		 *  The portion of current URL after the '#' as it appears 
		 *  in the browser address bar, or the default fragment
		 *  used in setup() if there is nothing after the '#'.  
		 *  Use setFragment to change this value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get fragmentFunction():Function
		{
			return _fragmentFunction;
		}
		/**
		 *  @private
		 */
		public function set fragmentFunction( value:Function ):void
		{
			if( _fragmentFunction == value ) return;
			
			_fragmentFunction = value;
			updateFragment();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function registerLayout( value:INavigatorLayout ):void
		{
			if( _layouts.indexOf( value ) == -1 )
			{
				value.addEventListener( FlexEvent.VALUE_COMMIT, onLayoutIndexChange, false, 0, true );
				_layouts.push( value );
				_layouts.sort( nestLevelCompareFunction );
				
				_layoutsToParse.push( value );
				_layoutsToParse.sort( nestLevelCompareFunction );
			}
			
			if( _fragmentsToParse && _fragmentsToParse.length )
			{
				parseFrament();
			}
			else
			{
				updateFragment();
			}
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function unRegisterLayout( value:INavigatorLayout ):void
		{
			const index:int = _layouts.indexOf( value )
			if( index != -1 )
			{
				const l:INavigatorLayout = _layouts.splice( index, 1 )[ 0 ];
				l.removeEventListener( IndexChangeEvent.CHANGE, onLayoutIndexChange, false );
			}
			
			updateFragment();
		}
		
		
		/**
		 *  @private
		 *  Sorts the layouts into order depending on th nestLevel (how deep they are in the displayList).
		 */
		private function nestLevelCompareFunction( a:INavigatorLayout, b:INavigatorLayout ):int
		{
			const at:GroupBase = LayoutBase( a ).target;
			const bt:GroupBase = LayoutBase( b ).target;
			
			if( !at && !bt )
			{
				return 0;
			}
			else if( !at )
			{
				return 1;
			}
			else if( !bt )
			{
				return -1;
			}
			else
			{
				return Math.min( 1, Math.max( -1, at.nestLevel - bt.nestLevel ) );
			}
		}
		
		
		/**
		 *  @private
		 *  Parses the fragments by looking for the correct layouts to select the index on.
		 */
		private function parseFrament( override:Boolean = true ):void
		{
			if( !_fragmentsToParse || !_fragmentsToParse.length ) return;
			
			var target:GroupBase;
			var part:String;
			var layout:INavigatorLayout;
			var elements:Array;
				
			const numLayouts:int = _layoutsToParse.length;
			for( var i:int = 0; i < numLayouts; i++ )
			{
				part = _fragmentsToParse[ 0 ];
				layout = _layoutsToParse[ 0 ];
				target = LayoutBase( layout ).target;
				
				if( target )
				{
					elements = getElements( target );
					var numElements:int = elements.length;
					for( var e:int = 0; e < numElements; e++ )
					{
						if( LabelUtil.itemToLabel( elements[ e ], fragmentField, fragmentFunction ) == part )
						{
							// Remove both from their lists
							_fragmentsToParse.splice( 0, 1 );
							_layoutsToParse.splice( 0, 1 );
							
							// Make sure we ignore this layouts valueCommit.
							_layoutsToIgnore.push( new LayoutToIgnore( layout, e ) );
							
							layout.selectedIndex = e;
							
							if( _fragmentsToParse.length )
							{
								break;
							}
							else
							{
								return;
							}
						}
					}
				}
			}
		}
		
		
		
		/**
		 *  @private
		 *  Util method to get a list of the items being rendrered.
		 *  These could be visual items or data items.
		 */
		private function updateFragment():void
		{
			_layouts.sort( nestLevelCompareFunction );
			
			var target:GroupBase;
			var fragment:String = "";
			
			var selectedElement:IVisualElement;
			for each( var layout:INavigatorLayout in _layouts )
			{
				target = LayoutBase( layout ).target;
				
				if( target )
				{
					if( !selectedElement )
					{
						selectedElement = layout.selectedElement;
						fragment += getFragment( layout, target );
					}
					// Make sure that this layouts target is a child of the
					// previously selectedElement.
					else if( selectedElement is DisplayObjectContainer && 
							 DisplayObjectContainer( selectedElement ).contains( target ) )
					{
						fragment += getFragment( layout, target );
						selectedElement = layout.selectedElement;
					}
				}
			}
			
			if( _browserManager.fragment != fragment ) _browserManager.setFragment( fragment );
		}
		
		/**
		 *  @private
		 *  Util method to get a list of the items being rendrered.
		 *  These could be visual items or data items.
		 */
		protected function getElements( target:GroupBase ):Array
		{
			if( target is DataGroup )
			{
				return DataGroup( target ).dataProvider.toArray();
			}
			else
			{
				try
				{
					return target[ "getMXMLContent" ]();
				}
				catch( e:Error )
				{
					return target[ "toArray" ]();
				}
				catch( e:Error )
				{
					throw new Error( "NavigatorLayoutBase cannot be used as a layout for this kind of container" );
					return new Array();
				}
			}
			
			return new Array();
		}
		
		/**
		 *  @private
		 *  Util method get a framenet string for the selectedIndex.
		 */
		private function getFragment( l:INavigatorLayout, target:GroupBase ):String
		{
			const elements:Array = getElements( target );
			return LabelUtil.itemToLabel( elements[ l.selectedIndex ], fragmentField, fragmentFunction ) + "/";
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Listeners
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Invoked by the the URL is changed in the browser.
		 */
		private function onBrowserManagerBrowserURLChange( event:BrowserChangeEvent ):void
		{
			_layoutsToParse = _layouts.concat();
			
			_fragmentsToParse = _browserManager.fragment.split( "/" );
			_fragmentsToParse.splice( _fragmentsToParse.length - 1, 1 );
			parseFrament();
		}
		
		/**
		 *  @private
		 *  Invoked when the selectedIndex changes in a layout.
		 */
		private function onLayoutIndexChange( event:FlexEvent ):void
		{
			const l:INavigatorLayout = INavigatorLayout( event.currentTarget );
			const numLayouts:int = _layoutsToIgnore.length;
			
			for( var i:int = 0; i < numLayouts; i++ )
			{
				if( _layoutsToIgnore[ i ].layout == l && _layoutsToIgnore[ i ].selectedIndex == l.selectedIndex )
				{
					_layoutsToIgnore.splice( i, 1 );
					return;
				}
			}
			updateFragment();
		}
	}
}



import spark.layouts.supportClasses.INavigatorLayout;

/**
 *  @private
 *  Util class used to store layouts whos valueCommit property
 *  we want to ignore due to use setting their selectedIndex.
 */
internal class LayoutToIgnore
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
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function LayoutToIgnore( layout:INavigatorLayout, selectedIndex:int )
	{
		_layout = layout;
	  	_selectedIndex = selectedIndex;
	}
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  index
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage property for selectedIndex.
	 */
	private var _selectedIndex:int;
	
	/**
	 *  The selectedIndex that the NavigatorBrowserManager set on the layout. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get selectedIndex():int
	{
		return _selectedIndex;
	}
	
	
	//----------------------------------
	//  layout
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage property for layout.
	 */
	private var _layout:INavigatorLayout;
	
	/**
	 *  The layout that the NavigatorBroswerManager updated. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get layout():INavigatorLayout
	{
		return _layout;
	}
}