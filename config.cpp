class CfgPatches {
    class uo_briefingkit {
        units[]={};
        weapons[]={};
        requiredVersion=1.62;
        requiredAddons[]= {"cba_main"};
    };
};

class Extended_PostInit_EventHandlers {
    class uo_briefingkit {
        clientinit="call compile preprocessFileLineNumbers '\z\uo\Addons\briefingkit\xeh_postInit.sqf'";
    };
};
