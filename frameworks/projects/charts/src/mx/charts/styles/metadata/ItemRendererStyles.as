
[Style(name="itemRenderer", type="mx.core.IFactory", inherit="no")]

/**
 *  The class that the series uses to render the series's marker in any associated legends. If this style is <code>null</code>, most series default to
 *	using their itemRenderer as a legend marker skin instead. Classes used as legend markers should implement the IFlexDisplayObject interface, and optionally the ISimpleStyleClient and IDataRenderer interfaces.
 *	If the class used as a legend marker implements the IDataRenderer interface, the data property is assigned a LegendData instance.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="legendMarkerRenderer", type="mx.core.IFactory", inherit="no")]

