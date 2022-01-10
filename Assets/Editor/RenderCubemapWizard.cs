using UnityEngine;
using UnityEditor;

public class RenderCubemapWizard : ScriptableWizard
{
    public Transform RenderFromPosition;
    public Cubemap ExportCubemap;
    
    [MenuItem("Tools/Render Cubemap")]
    public static void Test()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapWizard>(
            "Render Cubemap", "Render");
    }

    private void OnWizardUpdate()
    {
        isValid = (RenderFromPosition != null && ExportCubemap != null);
    }

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("CubemapCamera");
        go.AddComponent<Camera>();
        go.transform.position = RenderFromPosition.position;
        go.GetComponent<Camera>().RenderToCubemap(ExportCubemap);
        DestroyImmediate(go);
    }
}
