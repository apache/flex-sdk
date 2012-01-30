
package
{

internal class MobileComponentsClasses
{

/**
 *  @private
 *  This class is used to link additional classes into mobilecomponents.swc
 *  beyond those that are found by dependecy analysis starting
 *  from the classes specified in manifest.xml.
 *  For example, Button does not have a reference to ButtonSkin,
 *  but ButtonSkin needs to be in framework.swc along with Button.
 */
    import spark.preloaders.SplashScreen; SplashScreen;
    import spark.components.supportClasses.StyleableStageText; StyleableStageText;
    import spark.components.supportClasses.StyleableTextField; StyleableTextField;
    import spark.components.ActionBarDefaultButtonAppearance; ActionBarDefaultButtonAppearance;
    import spark.components.ContentBackgroundAppearance; ContentBackgroundAppearance;
}
}
