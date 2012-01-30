package
{
import flash.system.Capabilities;

import mx.core.DPIClassification;
import mx.core.RuntimeDPIProvider;

public class RuntimeDPIProviderExample extends RuntimeDPIProvider
{
    public function RuntimeDPIProviderExample()
    {
    }
    
    override public function get runtimeDPI():Number
    {
        // A tablet reporting an incorrect DPI of 240.
        if (Capabilities.screenDPI == 240 &&
            Capabilities.screenResolutionX == 600 &&
            Capabilities.screenResolutionY == 1024)
        {
            return DPIClassification.DPI_160;
        }
        
        return super.runtimeDPI;
    }
}
}