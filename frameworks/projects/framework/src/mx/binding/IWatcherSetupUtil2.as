
package mx.binding
{

[ExcludeClass]

/**
 *  @private
 *  This interface is used internally by Flex 4 to enable data binding
 *  to static private variables and properties.
 *  Flex 3 used the IWatcherSetupUtil interface.
 */
public interface IWatcherSetupUtil2
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	function setup(target:Object, propertyGetter:Function,
                   staticPropertyGetter:Function,
				   bindings:Array, watchers:Array):void;
}

}
