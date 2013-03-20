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
package spark.containers
{
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	
	import mx.core.ContainerCreationPolicy;
	import mx.core.IDeferredContentOwner;
	import mx.core.IDeferredInstance;
	import mx.core.IFlexModule;
	import mx.core.IFlexModuleFactory;
	import mx.core.IFontContextComponent;
	import mx.core.IInvalidating;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.graphics.shaderClasses.ColorBurnShader;
	import mx.graphics.shaderClasses.ColorDodgeShader;
	import mx.graphics.shaderClasses.ColorShader;
	import mx.graphics.shaderClasses.ExclusionShader;
	import mx.graphics.shaderClasses.HueShader;
	import mx.graphics.shaderClasses.LuminosityShader;
	import mx.graphics.shaderClasses.SaturationShader;
	import mx.graphics.shaderClasses.SoftLightShader;
	import mx.resources.ResourceManager;
	
	import spark.components.supportClasses.GroupBase;
	import spark.core.IGraphicElement;
	import spark.events.ElementExistenceEvent;
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;
	
	import spark.containers.supportClazzes.DeferredCreationPolicy;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when the deferred content of this component is created.
	 *
	 *  @eventType mx.events.FlexEvent.CONTENT_CREATION_COMPLETE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="contentCreationComplete", type="mx.events.FlexEvent")]
	
	[DefaultProperty("mxmlContentFactory")]
	
	/**
	 *  The DeferredGroup class enables deferred instatiation of child elements
	 *  via is <code>creationPolicy</code> property.
	 * 
	 *  <p>You cannot use GraphicElement objects with the DeferredGroup due to Adobe
	 *  data typing the paramater passed to <code>GraphicElement.parentChanged()</code>
	 *  as a <code>Group</code>.
	 *  See <a href="https://bugs.adobe.com/jira/browse/SDK-25601">Don't not hard code GraphicElement to Group</a>
	 *  and <a href="https://bugs.adobe.com/jira/browse/SDK-25333">Make it easier to extend Group</a>.</p>
	 *
	 * <p>The Group container has the following default characteristics:</p>
	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>Default size</td><td>Large enough to display its children</td></tr>
	 *     <tr><td>Minimum size</td><td>0 pixels</td></tr>
	 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
	 *  </table>
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;s:DeferredGroup&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;s:GroupBase
	 *    <strong>Properties</strong>
	 *    blendMode="auto"
	 *    creationPolicy="visible"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @see spark.containers.supportClasses.DeferredCreationPolicy
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class DeferredGroup extends GroupBase implements IDeferredContentOwner
	{
		
		private static const ITEM_ORDERED_LAYERING:uint = 0;
		private static const SPARSE_LAYERING:uint = 1; 
		
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
		public function DeferredGroup()
		{
			super();
			
			creationPolicy = DeferredCreationPolicy.VISIBLE;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Storage property for whether <code>createChildren</code>
		 *  has been invoked.
		 */
		private var _childrenCreated	: Boolean;
		
		private var needsDisplayObjectAssignment:Boolean = false;
		private var layeringMode:uint = ITEM_ORDERED_LAYERING;
		
		 
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  useVirtualLayout
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for useVirtualLayout.
		 */
		private var _useVirtualLayout:Boolean = true;
		
		/**
		 *  Returns whether a virtual layout is being used which is dependant
		 *  on the <code>creationPolicy</code>.
		 * 
		 *	<p>The value of this property overrides <code>useVirtualLayout</code>
		 * 	set directly on the layout property.</p>
		 *
		 *  @see #creationPolicy
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get useVirtualLayout():Boolean
		{
			return ( layout ) ? layout.useVirtualLayout : _useVirtualLayout;
		}
		
		
		//----------------------------------
		//  creationPolicy
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for creationPolicy.
		 */
		private var _creationPolicy		: String;
		
		[Inspectable(enumeration="visible,construct,all,none", defaultValue="visible")]
		/**
		 *  Content creation policy for this component.
		 *
		 *  <p>Possible values are:</p>
		 *    <ul>
		 *      <li><code>none</code> - Content must be created manually by calling the <code>createDeferredContent()</code> method.</li>
		 *      <li><code>visible</code> - Only construct the immediate descendants and initialize those that are visible.</li>
		 *      <li><code>construct</code> - Construct all decendants immediately but only inialize those that are visible.</li>
		 *      <li><code>all</code> - Create the content as soon as the parent component is created. This
		 *          option should only be used as a last resort because it increases startup time and memory usage.</li>
		 *    </ul>
		 *  
		 *  
		 *  <p>If no <code>creationPolicy</code> is specified for a container, that container inherits the value of 
		 *  its parent's <code>creationPolicy</code> property.</p>
		 *
		 *  <p>The <code>creationPolicy</code> affects <code>useVirtualLayout</code> in he following way:</p>
		 *     <table class="innertable">
		 *        <tr>
		 *           <th>creationPolicy</th>
		 *           <th>useVirtualLayout</th>
		 *        </tr>
		 *        <tr>
		 *           <td>none</td>
		 *           <td>false</td>
		 *        </tr>
		 *        <tr>
		 *           <td>visible</td>
		 *           <td>true</td>
		 *        </tr>
		 *        <tr>
		 *           <td>construct</td>
		 *           <td>true</td>
		 *        </tr>
		 *        <tr>
		 *           <td>all</td>
		 *           <td>false</td>
		 *        </tr>
		 *     </table>
		 * 
		 *  @default visible
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get creationPolicy():String
		{
			return _creationPolicy;
		}
		/**
		 *  @private
		 */
		public function set creationPolicy(value:String):void
		{
			if( _creationPolicy == value ) return;
			
			_creationPolicy = value;
			_useVirtualLayout = _creationPolicy != DeferredCreationPolicy.ALL;
			
			if( layout )
			{
				if( layout is BasicLayout )
				{
					if( _useVirtualLayout ) throw new Error( ResourceManager.getInstance().getString("layout", "basicLayoutNotVirtualized"));
				}
				else
				{
					layout.useVirtualLayout = _useVirtualLayout;
				}
			}
			
			createContentIfNeeded();
		}
		
		
		//----------------------------------
		//  mxmlContentFactory
		//----------------------------------
		
		/** 
		 *  @private
		 *  Backing variable for the contentFactory property.
		 */
		private var _mxmlContentFactory:IDeferredInstance;
		
		/**
		 *  @private
		 *  Flag that indicates whether or not the content has been created.
		 */
		private var _mxmlContentCreated:Boolean = false;
		
		[InstanceType("Array")]
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  A factory object that creates the initial value for the
		 *  <code>content</code> property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set mxmlContentFactory(value:IDeferredInstance):void
		{
			if( value == _mxmlContentFactory ) return;
			
			_mxmlContentFactory = value;
			_mxmlContentCreated = false;
			
			createContentIfNeeded();
		}
		
		
		//----------------------------------
		//  mxmlContent
		//----------------------------------
		
		protected var _mxmlContent:Array;
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  @copy spark.components.Group#mxmlContent
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set mxmlContent(value:Array):void
		{
			_mxmlContent = value;
			
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  deferredContentCreated
		//----------------------------------
		
		private var _deferredContentCreated:Boolean;
		/**
		 *  A flag that indicates whether the deferred content has been created.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get deferredContentCreated():Boolean
		{
			return _deferredContentCreated;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Properties 
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  layout
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function set layout( value:LayoutBase ):void
		{
			if( _useVirtualLayout )
			{
				if( value is BasicLayout )
				{
					throw new Error( "BasicLayout does not support virtualLayout and therefore cannot be using with the creationPolicy: " + creationPolicy );	
				}
				else
				{
					value.useVirtualLayout = _useVirtualLayout;
				}
			}
			else
			{
				value.useVirtualLayout = _useVirtualLayout;
			}
			
			super.layout = value;
		}
		
		
		//----------------------------------
		//  moduleFactory
		//----------------------------------
		/**
		 *  @private
		 */
		override public function set moduleFactory( moduleFactory:IFlexModuleFactory ):void
		{
			super.moduleFactory = moduleFactory;
			
			// Register the _creationPolicy style as inheriting. See the creationPolicy
			// getter for details on usage of this style.
			styleManager.registerInheritingStyle("_creationPolicy");
		}
		
		/**
		 *  @private
		 *  Override to ensure we set redrawRequested when appropriate.
		 */
		override public function set mouseEnabledWhereTransparent(value:Boolean):void
		{
			if (value == mouseEnabledWhereTransparent)
				return;
			
			super.mouseEnabledWhereTransparent = value;
			redrawRequested = true;
		}

		//----------------------------------
		//  numElements
		//----------------------------------
		
		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function get numElements():int
		{
			if( _mxmlContent == null ) return 0;
			
			return _mxmlContent.length;
		}
		
		
		//----------------------------------
		//  alpha
		//----------------------------------
		
		[Inspectable(defaultValue="1.0", category="General", verbose="1")]
		
		/**
		 *  @private
		 */
		override public function set alpha(value:Number):void
		{
			if (super.alpha == value)
				return;
			
			if (_blendMode == "auto")
			{
				// If alpha changes from an opaque/transparent (1/0) and translucent
				// (0 < value < 1), then trigger a blendMode change
				if ((value > 0 && value < 1 && (super.alpha == 0 || super.alpha == 1)) ||
					((value == 0 || value == 1) && (super.alpha > 0 && super.alpha < 1)))
				{
					blendModeChanged = true;
					invalidateDisplayObjectOrdering();
					invalidateProperties();
				}
			}
			
			super.alpha = value;
		}
		
		
		//----------------------------------
		//  blendMode
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the blendMode property.
		 */
		private var _blendMode:String = "auto";  
		private var blendModeChanged:Boolean;
		private var blendShaderChanged:Boolean;
		
		[Inspectable(category="General", enumeration="auto,add,alpha,darken,difference,erase,hardlight,invert,layer,lighten,multiply,normal,subtract,screen,overlay,colordodge,colorburn,exclusion,softlight,hue,saturation,color,luminosity", defaultValue="auto")]
		
		/**
		 *  @inheritDoc
		 */
		override public function get blendMode():String
		{
			return _blendMode; 
		}
		
		/**
		 *  @private
		 */
		override public function set blendMode(value:String):void
		{
			if (value == _blendMode)
				return;
			
			invalidateProperties();
			blendModeChanged = true;
			
			//The default blendMode in FXG is 'auto'. There are only
			//certain cases where this results in a rendering difference,
			//one being when the alpha of the Group is > 0 and < 1. In that
			//case we set the blendMode to layer to avoid the performance
			//overhead that comes with a non-normal blendMode. 
			
			if (value == "auto")
			{
				_blendMode = value;
				if (((alpha > 0 && alpha < 1) && super.blendMode != BlendMode.LAYER) ||
					((alpha == 1 || alpha == 0) && super.blendMode != BlendMode.NORMAL) )
				{
					invalidateDisplayObjectOrdering();
				}
			}
			else 
			{
				var oldValue:String = _blendMode;
				_blendMode = value;
				
				// If one of the non-native Flash blendModes is set, 
				// record the new value and set the appropriate 
				// blendShader on the display object. 
				if (isAIMBlendMode(value))
				{
					blendShaderChanged = true;
				}
				
				// Only need to re-do display object assignment if blendmode was normal
				// and is changing to something else, or the blend mode was something else 
				// and is going back to normal.  This is because display object sharing
				// only happens when blendMode is normal.
				if ((oldValue == BlendMode.NORMAL || value == BlendMode.NORMAL) && 
					!(oldValue == BlendMode.NORMAL && value == BlendMode.NORMAL))
				{
					invalidateDisplayObjectOrdering();
				}
				
			}
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
		public function addElement(element:IVisualElement):IVisualElement
		{
			var index:int = numElements;
			
			// This handles the case where we call addElement on something
			// that already is in the list.  Let's just handle it silently
			// and not throw up any errors.
			if (element.parent == this)
				index = numElements-1;
			
			return addElementAt(element, index);
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addElementAt(element:IVisualElement, index:int):IVisualElement
		{
			if (element == this)
				throw new ArgumentError(resourceManager.getString("components", "cannotAddYourselfAsYourChild"));
			
			// check for RangeError:
			checkForRangeError(index, true);
			
			var host:DisplayObject = element.parent; 
			
			// This handles the case where we call addElement on something
			// that already is in the list.  Let's just handle it silently
			// and not throw up any errors.
			if (host == this)
			{
				setElementIndex(element, index);
				return element;
			}
			else if (host is IVisualElementContainer)
			{
				// Remove the item from the group if that group isn't this group
				IVisualElementContainer(host).removeElement(element);
			}
			
			// If we don't have any content yet, initialize it to an empty array
			if (_mxmlContent == null) _mxmlContent = [];
			
			_mxmlContent.splice( index, 0, element );
			if( layout ) layout.elementAdded(index);
			
			invalidateDisplayList();
			
			return element;
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeAllElements():void
		{
			for (var i:int = numElements - 1; i >= 0; i--)
			{
				removeElementAt(i);
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
		public function removeElementAt( index:int ):IVisualElement
		{
			// check RangeError
			checkForRangeError( index );
			
			var element:IVisualElement = _mxmlContent[index];
			
			// Need to call elementRemoved before removing the item so anyone listening
			// for the event can access the item.
			if( element.parent ) elementRemoved( element, index );
			
			_mxmlContent.splice(index, 1);
			if( layout ) layout.elementRemoved( index );
			
			return element;
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function swapElementsAt( index1:int, index2:int ):void
		{
			checkForRangeError( index1 );
			checkForRangeError( index2 );
			
			if( index1 == index2 ) return;
			
			// Make sure that index1 is the smaller index so that addElementAt 
			// doesn't RTE
			if( index1 > index2)
			{
				var temp:int = index2;
				index2 = index1;
				index1 = temp; 
			}
			
			var element1:IVisualElement = _mxmlContent[ index1 ];
			var element2:IVisualElement = _mxmlContent[ index2 ];
			
			var index1Added:Boolean;
			var index2Added:Boolean;
			
			// Make sure we do the proper invalidations, but don't dispatch events
			if( element1.parent )
			{
				elementRemoved( element1, index1, false /*notifyListeners*/);
				index1Added = true;
			}
			if( element2.parent )
			{
				elementRemoved( element2, index2, false /*notifyListeners*/);
				index2Added = true;
			}
			
			// Step 1: remove
			// Make sure we remove the bigger index first
			_mxmlContent.splice( index2, 1 );
			_mxmlContent.splice( index1, 1 );
			
			// Step 2: swap
			// Add them in reverse order 
			_mxmlContent.splice( index1, 0, element2 );
			_mxmlContent.splice( index2, 0, element1 );
			
			// Make sure we do the proper invalidations, but don't dispatch events
			if( index1Added ) elementAdded( element2, index1, false /*notifyListeners*/);
			if( index2Added ) elementAdded(element1, index2, false /*notifyListeners*/);
		}
		
		/**
		 *  Create the content for this component. If creationPolicy is "auto" or "all", this
		 *  function will be called by the flex framework. If creationPolicy is "none", this 
		 *  function must be called to create the content for the component.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function createDeferredContent():void
		{
			if( !_mxmlContentCreated )
			{
				_mxmlContentCreated = true;
				if (_mxmlContentFactory)
				{
					var deferredContent:Object = _mxmlContentFactory.getInstance();
					mxmlContent = deferredContent as Array;
					_deferredContentCreated = true;
					
					switch( _creationPolicy )
					{
						
						case DeferredCreationPolicy.CONSTRUCT :
						case DeferredCreationPolicy.ALL :
						{
							createDeferredChildren();
							break;
						}
						case DeferredCreationPolicy.NONE :
						case DeferredCreationPolicy.VISIBLE :
						{
							// Do nothing
							break;
						}
					}
					
					dispatchEvent( new FlexEvent( FlexEvent.CONTENT_CREATION_COMPLETE ) );
				}
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
		public function setElementIndex(element:IVisualElement, index:int):void
		{
			// check for RangeError...this is done in addItemAt
			// but we want to do it before removing the element
			checkForRangeError(index);
			
			removeElement(element);
			addElementAt(element, index);
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeElement(element:IVisualElement):IVisualElement
		{
			return removeElementAt(getElementIndex(element));
		}
		
		/**
		 *  @private
		 */
		mx_internal function getMXMLContent():Array
		{
			return ( _mxmlContent ) ? _mxmlContent.concat() : null;
		}
		
		/**
		 *  @private
		 */
		private function createContentIfNeeded():void
		{
			if( !_mxmlContentCreated && 
				_childrenCreated &&
				creationPolicy != ContainerCreationPolicy.NONE )
				createDeferredContent();
		}
		
		/**
		 *  @private
		 */
		private function createDeferredChildren():void
		{
			var content:Array = getMXMLContent();
			var element:IVisualElement;
			
			var numItems:int = content.length;
			for( var i:int = 0; i < numItems; i++ )
			{
				element = IVisualElement( content[ i ] );
				if( element is IDeferredContentOwner ) IDeferredContentOwner( element ).createDeferredContent();
			}
		}
		
		/**
		 *  @private 
		 *  Checks the range of index to make sure it's valid
		 */ 
		private function checkForRangeError(index:int, addingElement:Boolean = false):void
		{
			// figure out the maximum allowable index
			var maxIndex:int = (_mxmlContent == null ? -1 : _mxmlContent.length - 1);
			
			// if adding an element, we allow an extra index at the end
			if (addingElement)
				maxIndex++;
			
			if (index < 0 || index > maxIndex)
				throw new RangeError(resourceManager.getString("components", "indexOutOfRange", [index]));
		}
		
		/**
		 *  @private
		 *
		 *  If the displayObject is not a child of this Group, then insert it at the
		 *  specified index (or at the end of the list, when index is -1).
		 *  Else, if the displayObject is already a child of the Group, then simply
		 *  adjust its child index.  
		 */ 
		private function addDisplayObjectToDisplayList(child:DisplayObject, index:int = -1):void
		{
			var overlayCount:int = _overlay ? _overlay.numDisplayObjects : 0;
			if (child.parent == this)
				super.setChildIndex(child, index != -1 ? index : super.numChildren - 1 - overlayCount);
			else
				super.addChildAt(child, index != -1 ? index : super.numChildren - overlayCount);
		}
		
		/**
		 *  @private
		 *  
		 *  Invalidates the display object ordering and will run assignDisplayObjects()
		 *  if necessary.
		 * 
		 *  @return true if the display object ordering needed to be invalidated; 
		 *          false otherwise.
		 */
		//FIXME tink cannot be IGraphicElement
		private function invalidateDisplayObjectOrdering():Boolean
		{
			if( layeringMode == SPARSE_LAYERING )
			{
				needsDisplayObjectAssignment = true;
				invalidateProperties();
				return true;
			}
			
			return false;
		}
		
		/**
		 * @private
		 */
		private function isAIMBlendMode(value:String):Boolean
		{
			if (value == "colordodge" || 
				value =="colorburn" || value =="exclusion" || 
				value =="softlight" || value =="hue" || 
				value =="saturation" || value =="color" ||
				value =="luminosity")
				return true; 
			else return false; 
		}
		
		/**
		 *  Adds an item to this Group.
		 *  Flex calls this method automatically; you do not call it directly.
		 *
		 *  @param item The item that was added.
		 *
		 *  @param index The index where the item was added.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		mx_internal function elementAdded(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
		{
			if (layout)
				layout.elementAdded(index);        
			
			if (element.depth != 0)
				invalidateLayering();
			
			// Set the moduleFactory to the child, but don't overwrite an existing moduleFactory.
			// Propagate moduleFactory to the child, but don't overwrite an existing moduleFactory.
			if (element is IFlexModule && IFlexModule(element).moduleFactory == null)
			{
				if (moduleFactory != null)
					IFlexModule(element).moduleFactory = moduleFactory;
					
				else if (document is IFlexModule && document.moduleFactory != null)
					IFlexModule(element).moduleFactory = document.moduleFactory;
					
				else if (parent is IFlexModule && IFlexModule(element).moduleFactory != null)
					IFlexModule(element).moduleFactory = IFlexModule(parent).moduleFactory;
			}
			
			// Set the font context in non-UIComponent children.
			// UIComponent children use moduleFactory.
			if (element is IFontContextComponent && !(element is UIComponent) &&
				IFontContextComponent(element).fontContext == null)
			{  
				IFontContextComponent(element).fontContext = moduleFactory;
			}
			
			if (element is IGraphicElement) 
			{
				// FIXME tink cannot be IGraphicElement due to Adobe typing the paramater
				// passed to <code>GraphicElement.parentChanged()</code> as a <code>Group</code>.
				// see https://bugs.adobe.com/jira/browse/SDK-25601
				// https://bugs.adobe.com/jira/browse/SDK-25333
				throw new Error( "You cannot use an IGraphicElement in a DeferredGroup, all elements must extend UIComponent" );
				numGraphicElements++;
				addingGraphicElementChild(element as IGraphicElement);
				invalidateDisplayObjectOrdering();
			}   
			else
			{
				// item must be a DisplayObject
				
				// if the display object ordering is invalidated (because we have graphic elements 
				// that aren't actually in the display list), then lets just add our item to the end.  
				// If the ordering isn't invalidated, then let's just try to add it to the proper index.
				if (invalidateDisplayObjectOrdering())
				{
					// This always adds the child to the end of the display list. Any 
					// ordering discrepancies will be fixed up in assignDisplayObjects().
					addDisplayObjectToDisplayList(DisplayObject(element));
				}
				else
				{
					// TODO Tink keep and eye on this
					//					addDisplayObjectToDisplayList(DisplayObject(element), index);
					// We don't pass the index here either and therefore the child will always 
					// be added to the end of the display list. This is to ensure that items don't
					// need to be shown in order.
					addDisplayObjectToDisplayList(DisplayObject(element));
				}
			}
			
			if (notifyListeners)
			{
				if (hasEventListener(ElementExistenceEvent.ELEMENT_ADD))
					dispatchEvent(new ElementExistenceEvent(
						ElementExistenceEvent.ELEMENT_ADD, false, false, element, index));
				
				
				if (element is IUIComponent && element.hasEventListener(FlexEvent.ADD))
					element.dispatchEvent(new FlexEvent(FlexEvent.ADD));
			}
			
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 *  Removes an item from this Group.
		 *  Flex calls this method automatically; you do not call it directly.
		 *
		 *  @param index The index of the item that is being removed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		mx_internal function elementRemoved(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
		{
			var childDO:DisplayObject = element as DisplayObject;   
			
			if (notifyListeners)
			{        
				if (hasEventListener(ElementExistenceEvent.ELEMENT_REMOVE))
					dispatchEvent(new ElementExistenceEvent(
						ElementExistenceEvent.ELEMENT_REMOVE, false, false, element, index));
				
				if (element is IUIComponent && element.hasEventListener(FlexEvent.REMOVE))
					element.dispatchEvent(new FlexEvent(FlexEvent.REMOVE));
			}
			
			if (element && (element is IGraphicElement))
			{
				//FIXME tink cannot be IGraphicElement
				throw new Error( "You cannot use an IGraphicElement in a DeferredGroup, all elements must extend UIComponent" );
				//				numGraphicElements--;
				//				removingGraphicElementChild(element as IGraphicElement);
			}
			else if (childDO && childDO.parent == this)
			{
				super.removeChild(childDO);
			}
			
			invalidateDisplayObjectOrdering();
			invalidateSize();
			invalidateDisplayList();
			
			if (layout)
				layout.elementRemoved(index);     
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods 
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
		override public function getElementIndex( element:IVisualElement ):int
		{
			var index:int = _mxmlContent ? _mxmlContent.indexOf( element ) : -1;
			
			if( index == -1 )
				throw ArgumentError(resourceManager.getString("components", "elementNotFoundInGroup", [element]));
			else
				return index;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function getVirtualElementAt(index:int, eltWidth:Number=NaN, eltHeight:Number=NaN):IVisualElement
		{
			// check for RangeError:
			checkForRangeError(index);
		
			var elt:IVisualElement = IVisualElement( _mxmlContent[index] );
			
			if( !elt.parent )
			{
				elementAdded(elt, numChildren);
				if( elt is IInvalidating ) IInvalidating( elt ).validateNow();
				if( !isNaN( eltWidth ) || !isNaN( eltHeight ) ) elt.setLayoutBoundsSize(eltWidth, eltHeight);
			}
			else
			{
				if( elt.parent != this ) throw new Error(resourceManager.getString("components", "mxmlElementNoMultipleParents", [elt]));
			}

			return elt;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function getElementAt(index:int):IVisualElement
		{
			// check for RangeError:
			checkForRangeError(index);
			
			var elt:IVisualElement = IVisualElement( _mxmlContent[index] );
			
			if( elt.parent )
			{
				if( elt.parent != this ) throw new Error(resourceManager.getString("components", "mxmlElementNoMultipleParents", [elt]));
			}
			else
			{
				elementAdded(elt, index);
			}
			
			return elt;
		}
		
		/**
		 *  @private
		 */
		override public function addChild(child:DisplayObject):DisplayObject
		{
			throw(new Error(resourceManager.getString("components", "addChildError")));
		}
		
		/**
		 *  @private
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			throw(new Error(resourceManager.getString("components", "addChildAtError")));
		}
		
		/**
		 *  @private
		 */
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			throw(new Error(resourceManager.getString("components", "removeChildError")));
		}
		
		/**
		 *  @private
		 */
		override public function removeChildAt(index:int):DisplayObject
		{
			throw(new Error(resourceManager.getString("components", "removeChildAtError")));
		}
		
		/**
		 *  @private
		 */
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			throw(new Error(resourceManager.getString("components", "setChildIndexError")));
		}
		
		/**
		 *  @private
		 */
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			throw(new Error(resourceManager.getString("components", "swapChildrenError")));
		}
		
		/**
		 *  @private
		 */
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			throw(new Error(resourceManager.getString("components", "swapChildrenAtError")));
		}
		
		/**
		 *  @private
		 */
		override public function invalidateLayering():void
		{
			if( layeringMode == ITEM_ORDERED_LAYERING ) layeringMode = SPARSE_LAYERING;
			invalidateDisplayObjectOrdering();
		}
		
		/**
		 *  Create content children, if the <code>creationPolicy</code> property 
		 *  is not equal to <code>none</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			_childrenCreated = true;
			
			createContentIfNeeded();
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{       
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Quick hack to help TimeMchineLayout
			// When items are added to the displayList they are added
			// at the front, and the validation of the depth
			// being changed, doesn't happen until the next frame due
			// to it being in commitProperties().
			if (needsDisplayObjectAssignment)
			{
				needsDisplayObjectAssignment = false;
				assignDisplayObjects();
			}
			
			// If the DisplayObject assignment is still not completed, then postpone validation
			// of the GraphicElements
			if( needsDisplayObjectAssignment && invalidatePropertiesFlag ) return;
			//			if (scaleGridChanged)
			//			{
			//				scaleGridChanged = false;
			//				
			//				if (isValidScaleGrid())
			//				{
			//					// Check for DisplayObjects other than overlays
			//					var overlayCount:int = _overlay ? _overlay.numDisplayObjects : 0;
			//					if (numChildren - overlayCount > 0)
			//						throw new Error(resourceManager.getString("components", "scaleGridGroupError"));
			//					
			//					super.scale9Grid = new Rectangle(scaleGridLeft, 
			//						scaleGridTop,    
			//						scaleGridRight - scaleGridLeft, 
			//						scaleGridBottom - scaleGridTop);
			//				} 
			//				else
			//				{
			//					super.scale9Grid = null;
			//				}                              
			//			}
		}
		
		/**
		 *  @private
		 */ 
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (blendModeChanged)
			{
				blendModeChanged = false;
				
				// Figure out the correct blendMode value
				// to set. 
				if (_blendMode == "auto")
				{
					if (alpha == 0 || alpha == 1) 
						super.blendMode = BlendMode.NORMAL;
					else
						super.blendMode = BlendMode.LAYER;
				}
				else if (!isAIMBlendMode(_blendMode))
				{
					super.blendMode = _blendMode;
				}
				
				if (blendShaderChanged) 
				{
					// The graphic element's blendMode was set to a non-Flash 
					// blendMode. We mimic the look by instantiating the 
					// appropriate shader class and setting the blendShader
					// property on the displayObject. 
					blendShaderChanged = false; 
					switch(_blendMode)
					{
						case "color": 
						{
							super.blendShader = new ColorShader();
							break; 
						}
						case "colordodge":
						{
							super.blendShader = new ColorDodgeShader();
							break; 
						}
						case "colorburn":
						{
							super.blendShader = new ColorBurnShader();
							break; 
						}
						case "exclusion":
						{
							super.blendShader = new ExclusionShader();
							break; 
						}
						case "hue":
						{
							super.blendShader = new HueShader();
							break; 
						}
						case "luminosity":
						{
							super.blendShader = new LuminosityShader();
							break; 
						}
						case "saturation": 
						{
							super.blendShader = new SaturationShader();
							break; 
						}
						case "softlight":
						{
							super.blendShader = new SoftLightShader();
							break; 
						}
					}
				}
			}
			
			if (needsDisplayObjectAssignment)
			{
				needsDisplayObjectAssignment = false;
				assignDisplayObjects();
			}
			
			//FIXME tink address scaleGrid
			//			if (scaleGridChanged)
			//			{
			//				// Don't reset scaleGridChanged since we also check it in updateDisplayList
			//				if( isValidScaleGrid() ) resizeMode = ResizeMode.SCALE; // Force the resizeMode to scale 
			//			}
			
			//FIXME tink no support for IGraphicElement
			// Validate element properties
			//			if (numGraphicElements > 0)
			//			{
			//				var length:int = numElements;
			//				for (var i:int = 0; i < length; i++)
			//				{
			//					var element:IGraphicElement = getElementAt(i) as IGraphicElement;
			//					if (element)
			//						element.validateProperties();
			//				}
			//			}
		}
		

		
		
		//--------------------------------------------------------------------------
		//
		//  ISharedDisplayObject
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _redrawRequested:Boolean = false;
		
		/**
		 *  @private
		 *  Contains <code>true</code> when any of the <code>IGraphicElement</code> objects that share
		 *  this <code>DisplayObject</code> object needs to redraw.  
		 *  This is used internally
		 *  by the <code>Group</code> class and developers don't typically use this. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get redrawRequested():Boolean
		{
			return _redrawRequested;
		}
		/**
		 *  @private
		 */
		public function set redrawRequested(value:Boolean):void
		{
			_redrawRequested = value;
		}
		
		
		/**
		 *  @private
		 *  Called to assign display objects to graphic elements
		 */
		private function assignDisplayObjects():void
		{
			var topLayerItems:Vector.<IVisualElement>;
			var bottomLayerItems:Vector.<IVisualElement>;        
			var keepLayeringEnabled:Boolean = false;
			var insertIndex:int = 0;
			
			// Keep track of the previous IVisualElement.  This is used when
			// assigning DisplayObjects to the IGraphicElements.
			// If the Group can share its DisplayObject with the IGraphicElements
			// then initialize the prevItem with this Group object.
			var prevItem:IVisualElement;
//			if (canShareDisplayObject)
//				prevItem = this;
			
			// Iterate through all of the items
			var len:int = numElements; 
			for (var i:int = 0; i < len; i++)
			{  
				var item:IVisualElement = _mxmlContent[ i ];
				
				if( super.contains( DisplayObject( item ) ) )
				{
					if (layeringMode != ITEM_ORDERED_LAYERING)
					{
						var layer:Number = item.depth;
						if (layer != 0)
						{               
							if (layer > 0)
							{
								if (topLayerItems == null) topLayerItems = new Vector.<IVisualElement>();
								topLayerItems.push(item);
								continue;                   
							}
							else
							{
								if (bottomLayerItems == null) bottomLayerItems = new Vector.<IVisualElement>();
								bottomLayerItems.push(item);
								continue;                   
							}
						}
					}
				
					// this should only get called if layer == 0, or we don't care
					// about layering (layeringMode == ITEM_ORDERED_LAYERING)
					insertIndex = assignDisplayObjectTo(item, prevItem, insertIndex);
					prevItem = item;
				}
			}
			
			// we've done all layer == 0 items. 
			// now let's put the higher z-index ones on next
			// then we'll handle the ones on bottom, but we'll
			// insert them in the very beginning (index = 0)
			
			if (topLayerItems != null)
			{
				keepLayeringEnabled = true;
				//topLayerItems.sortOn("layer",Array.NUMERIC);
				GroupBase.sortOnLayer(topLayerItems);
				len = topLayerItems.length;
				for (i=0;i<len;i++)
				{
					// For layer != 0, we never share display objects
					insertIndex = assignDisplayObjectTo(topLayerItems[i], null /*prevElement*/, insertIndex);
				}
			}
			
			if (bottomLayerItems != null)
			{
				keepLayeringEnabled = true;
				insertIndex = 0;
				
				//bottomLayerItems.sortOn("layer",Array.NUMERIC);
				GroupBase.sortOnLayer(bottomLayerItems);
				len = bottomLayerItems.length;
				
				for (i=0;i<len;i++)
				{
					// For layer != 0, we never share dsiplay objects
					insertIndex = assignDisplayObjectTo(bottomLayerItems[i], null /*prevElement*/, insertIndex);
				}
			}
			
			// If we tried to layer these visual elements and found that we 
			// don't actually need to because layer=0 for all of them, 
			// then lets optimize this next time and just skip the layering step.
			// If an element gets added that has layer set to something non-zero, then 
			// layeringMode will get set to SPARSE_LAYERING.
			// If the layer property changes on a current element, invalidateLayering()
			// will be called and layeringMode will get set to SPARSE_LAYERING.
			if (keepLayeringEnabled == false)
				layeringMode = ITEM_ORDERED_LAYERING;
			
			// Make sure we do a pass through the graphic elements and redraw
			// the invalid ones.  We should only redraw, no need to redo the layout.
			super.$invalidateDisplayList();
		}
		
		
		/**
		 *  @private
		 *  Assigns a DisplayObject to the curElement and ensures the DisplayObject
		 *  is at insertIndex in the display object list.
		 * 
		 *  If <code>curElement</code> implements IGraphicElement, then both its
		 *  DisplayObject and displayObjectSharingMode will be updated.
		 * 
		 *  @curElement The current element to assign DisplayObject to
		 *  @prevEelement The previous element in the list of elements or null.
		 *  @return Returns the display list index after the current element's
		 *  DisplayObject.
		 */
		private function assignDisplayObjectTo(curElement:IVisualElement,
											   prevElement:IVisualElement,
											   insertIndex:int):int
		{
			if( curElement is DisplayObject )
			{
				if( curElement.parent ) super.setChildIndex(curElement as DisplayObject, insertIndex++);
			}
			//FIXME tink no support for IGraphicElement
//			else if (curElement is IGraphicElement)
//			{
//				var current:IGraphicElement = IGraphicElement(curElement);
//				var previous:IGraphicElement = prevElement as IGraphicElement;
//				
//				var oldDisplayObject:DisplayObject = current.displayObject;
//				var oldSharingMode:String = current.displayObjectSharingMode;
//				
//				if (previous && previous.canShareWithNext(current) && current.canShareWithPrevious(previous) &&
//					current.setSharedDisplayObject(previous.displayObject))
//				{
//					// If we are the second element in the shared sequence,
//					// make sure that the first element has the correct displayObjectSharingMode
//					if (previous.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
//						previous.displayObjectSharingMode = DisplayObjectSharingMode.OWNS_SHARED_OBJECT;
//					
//					current.displayObjectSharingMode = DisplayObjectSharingMode.USES_SHARED_OBJECT;
//				}
//				else if (prevElement == this && current.setSharedDisplayObject(this))
//				{
//					current.displayObjectSharingMode = DisplayObjectSharingMode.USES_SHARED_OBJECT;
//				}
//				else
//				{
//					// We don't want to create new DisplayObjects for elements that
//					// already have created their own their display objects.
//					var ownsDisplayObject:Boolean = oldSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT;
//					
//					// If the element doesn't have a DisplayObject or it doesn't own
//					// the DisplayObject it currently has, then create a new one
//					var displayObject:DisplayObject = oldDisplayObject;
//					if (!ownsDisplayObject || !displayObject)
//						displayObject = current.createDisplayObject();
//					
//					// Make sure the DisplayObject is at the correct position.
//					// Check displayObject for null, some graphic elements
//					// may choose not to create a DisplayObject during this pass.
//					if (displayObject)
//						addDisplayObjectToDisplayList(displayObject, insertIndex++);
//					
//					current.displayObjectSharingMode = DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT;
//				}
//				invalidateAfterAssignment(current, oldSharingMode, oldDisplayObject);
//			}
			return insertIndex;
		}
		
		
		
		
	}
}