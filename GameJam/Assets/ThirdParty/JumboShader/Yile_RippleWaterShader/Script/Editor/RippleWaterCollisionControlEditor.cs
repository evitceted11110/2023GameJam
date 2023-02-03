using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(RippleWaterCollisionControl))]
public class RippleWaterCollisionControlEditor : Editor
{
    private RippleWaterCollisionControl script;
    private void OnEnable()
    {
        script = (RippleWaterCollisionControl)target;
    }

    public override void OnInspectorGUI()
    {
        script.reverseWave = EditorGUILayout.Toggle("擴散反轉", script.reverseWave);
        if (script.reverseWave)
        {
            script.reverseWaveMaxDistance = EditorGUILayout.FloatField("擴散最遠距離", script.reverseWaveMaxDistance);
        }
        script.speedWaveSpread = EditorGUILayout.FloatField("水波擴散速度", script.speedWaveSpread);
        script.minMagnitude = EditorGUILayout.FloatField("最小振幅", script.minMagnitude);
        script.MaxMagnitude = EditorGUILayout.FloatField("最大振幅", script.MaxMagnitude);
        script.waveAmplitudeDecreaseRate = EditorGUILayout.FloatField("水波減弱幅度", script.waveAmplitudeDecreaseRate);

        script.cam = (Camera)EditorGUILayout.ObjectField("攝影機 (未指定則取用Camera.Main)", script.cam, typeof(Camera), true);

        script.useClick = EditorGUILayout.Toggle("是否啟用點擊", script.useClick);
        if (script.useClick)
        {
            script.useCollider = EditorGUILayout.Toggle("是否使用碰撞器", script.useCollider);
            if (script.useCollider)
            {
                //啟用碰撞器
                script.colliderObject = (GameObject)EditorGUILayout.ObjectField("碰撞器物件", script.colliderObject, typeof(GameObject), true);
            }
            else
            {
                script.scaleRange = EditorGUILayout.Vector2Field("點擊範圍", script.scaleRange);
            }
            
        }
        
    }
}

