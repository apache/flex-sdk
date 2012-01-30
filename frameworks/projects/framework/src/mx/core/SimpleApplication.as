
package mx.core
{

import flash.display.MovieClip;

[Frame(factoryClass="mx.core.FlexApplicationBootstrap")]

[ExcludeClass]

/**
 *  @private
 *  SimpleApplication is nothing other than a base class to use when
 *  you need a trivial application bootstrapped by FlexApplicationBootstrap.
 */
public class SimpleApplication extends MovieClip
{
	include "../core/Version.as";
}

}
