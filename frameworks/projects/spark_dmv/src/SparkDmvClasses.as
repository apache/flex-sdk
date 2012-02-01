
package
{

internal class SparkDmvClasses
{

/**
 *  @private
 *  This class is used to link additional classes into spark.swc
 *  beyond those that are found by dependecy analysis starting
 *  from the classes specified in manifest.xml.
 *  For example, Button does not have a reference to ButtonSkin,
 *  but ButtonSkin needs to be in framework.swc along with Button.
 */
import mx.controls.advancedDataGridClasses.FTEAdvancedDataGridItemRenderer; FTEAdvancedDataGridItemRenderer;
import mx.controls.advancedDataGridClasses.MXAdvancedDataGridItemRenderer; MXAdvancedDataGridItemRenderer;
}

}
