#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace NoveCeus.Editor
{
    [InitializeOnLoad]
    public static class NoveCeusProjectSetup
    {
        const string ScenePath = "Assets/Scenes/Main.unity";
        const string SetupKey = "NoveCeus.ProjectSetup.v1";

        static NoveCeusProjectSetup()
        {
            EditorApplication.delayCall += EnsureProject;
        }

        static void EnsureProject()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode) return;

            bool sceneMissing = !File.Exists(ScenePath);
            if (sceneMissing)
            {
                Directory.CreateDirectory("Assets/Scenes");
                Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
                var marker = new GameObject("Nove Ceus - runtime scene is generated procedurally");
                EditorSceneManager.MarkSceneDirty(scene);
                EditorSceneManager.SaveScene(scene, ScenePath);
                Object.DestroyImmediate(marker);
            }

            EditorBuildSettings.scenes = new[]
            {
                new EditorBuildSettingsScene(ScenePath, true)
            };

            PlayerSettings.companyName = "Nove Ceus";
            PlayerSettings.productName = "Nove Céus: Arquiteto do Cosmos";
            PlayerSettings.defaultInterfaceOrientation = UIOrientation.Portrait;
            PlayerSettings.runInBackground = true;
            PlayerSettings.colorSpace = ColorSpace.Linear;
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.noveceus.arquiteto");
            PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel26;
            PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64;
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);

            QualitySettings.vSyncCount = 0;
            Application.targetFrameRate = 60;

            if (!EditorPrefs.GetBool(SetupKey, false))
            {
                EditorPrefs.SetBool(SetupKey, true);
                Debug.Log("Nove Céus: projeto configurado. Abra Assets/Scenes/Main.unity e pressione Play.");
            }

            AssetDatabase.SaveAssets();
        }
    }
}
#endif
