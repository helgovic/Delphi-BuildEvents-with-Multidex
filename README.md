# Delphi-BuildEvents-with-Multidex

This Delphi addon adds a more flexible Build events functionality to the delphi IDE, and adds support for Multidex in android development.

Installation.

   You need to have JEDI JCL installed.

   Run Targets.exe in the Targets\bin directory as administrator.
   Load the addon in Delphi. Build and install.

USE:

You now have a new item in the projct menu, BuildEvents.

To add/delete/edit a prebuild or postbuild event right click the grid controls.

Pre/Postbuild events runs depending on the Run Pre/Post -buildevents checkboxes, whether the compile was successfull or not, and whether an optional parameter is set or not.

MULTIDEX:

To turn on MultiDex for the current project, check the MultiDex parameter.

RunDex: Normally Delphi runs the Dex step on every compile. In non-MultiDex it doesn't take long, because pre-dexed libraries are used, but in multidex, you can't, and dexing takes longer. You only need to run the dex step, when you have added/removed/updated your libs. Check this item to run dex step. RunDex is reset to false on successfull compile.
If you intend to support Android before version 5.0 (minSDK < 21), you need to do the following.

To run the dex job check the RunDex parameter.

Add the MultiDex.jar in the MultidexJarPas directory to your project libs. Add the AndroidApi.JNI.MultiDex.pas in the MultidexJarPas directory to your mainform uses list. Add the following statements at the start of your main forms FormCreate procedure.

if TJBuild_VERSION.JavaClass.SDK_INT < 21
then
   TJMultiDex.javaclass.install(TAndroidHelper.Context);
