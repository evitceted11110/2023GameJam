using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(SpriteUVRemapHandler))]
public class SpriteUVRemapHandlerEditor : Editor
{
    private SpriteUVRemapHandler handler;

    void OnSceneGUI()
    {

        Vector2 tempLB = PointtoUV(Draw(UVtoPoint(handler.leftButtom)));
        Vector2 tempLT = PointtoUV(Draw(UVtoPoint(handler.leftTop)));
        Vector2 tempRT = PointtoUV(Draw(UVtoPoint(handler.rightTop)));
        Vector2 tempRB = PointtoUV(Draw(UVtoPoint(handler.rightButtom)));

        if (handler.leftButtom != tempLB)
        {
            Undo.RecordObject(handler, "Move Point");
            handler.leftButtom = tempLB;
            handler.UpdateMaterial();
        }
        if (handler.leftTop != tempLT)
        {
            Undo.RecordObject(handler, "Move Point");
            handler.leftTop = tempLT;
            handler.UpdateMaterial();
        }
        if (handler.rightTop != tempRT)
        {
            Undo.RecordObject(handler, "Move Point");
            handler.rightTop = tempRT;
            handler.UpdateMaterial();
        }
        if (handler.rightButtom != tempRB)
        {
            Undo.RecordObject(handler, "Move Point");
            handler.rightButtom = tempRB;
            handler.UpdateMaterial();
        }

    }

    Vector2 Draw(Vector2 point)
    {
        Handles.color = Color.red;
        Vector2 newPos = Handles.FreeMoveHandle(point, Quaternion.identity, 0.3f, Vector2.zero, Handles.CylinderHandleCap);
        return newPos;
    }

    private void OnEnable()
    {
        handler = (SpriteUVRemapHandler)target;
    }

    Vector2 PointtoUV(Vector2 point)
    {
        float UVx = (point.x - handler.MinX) / (handler.MaxX - handler.MinX);
        float UVy = (point.y - handler.MinY) / (handler.MaxY - handler.MinY);
        return new Vector2(UVx, UVy);
    }

    Vector2 UVtoPoint(Vector2 uv)
    {
        float pointX = handler.MinX + ((handler.MaxX - handler.MinX) * uv.x);
        float pointY = handler.MinY + ((handler.MaxY - handler.MinY) * uv.y);
        return new Vector2(pointX, pointY);
    }
}
