
package mx.managers
{

import mx.managers.IHistoryManagerClient;

[ExcludeClass]

/**
 *  @private
 */
public interface IHistoryManager
{
	function register(obj:IHistoryManagerClient):void;
	function unregister(obj:IHistoryManagerClient):void;
	function save():void;
}

}

