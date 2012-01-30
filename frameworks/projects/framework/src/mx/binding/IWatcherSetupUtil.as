
package mx.binding
{

[ExcludeClass]

/**
 *  @private
 */
public interface IWatcherSetupUtil
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
				   bindings:Array, watchers:Array):void;
}

}
