# Delphi-BuildEvents-with-Multidex

This Delphi addon adds a more flexible Build events functionality to the delphi IDE, and adds support for Multidex in android development.

Installation.

   You need to have JEDI JCL installed.

   Run Targets.exe in the Targets\bin directory as administrator.
   Load the addon in Delphi. Build and install.

MULTIDEX:

If you intend to support Android before version 5.0 (minSDK < 21), you need to do the following.

Add the MultiDex.jar in the MultidexJarPas directory to your project libs. Add the AndroidApi.JNI.MultiDex.pas in the MultidexJarPas directory to your mainform uses list. Add the following statements at the start of your main forms FormCreate procedure.

if TJBuild_VERSION.JavaClass.SDK_INT < 21
then
   TJMultiDex.javaclass.install(TAndroidHelper.Context);
