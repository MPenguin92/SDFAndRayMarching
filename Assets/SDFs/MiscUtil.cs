using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class MiscUtil
{
    private static Mesh sFullScreenTriangleMesh;

    public static Mesh FullScreenTriangleMesh
    {
        get
        {
            if (sFullScreenTriangleMesh == null)
            {
                sFullScreenTriangleMesh = new()
                {
                    vertices = GetFullScreenTriangleVertexPosition(),
                    triangles = new int[] { 0, 1, 2 },
                };
            }

            return sFullScreenTriangleMesh;
        }
    }

    /// <summary>
    /// 定义一个覆盖屏幕的大三角形
    /// 顶点是(-1, -1),(3, -1),(-1, 3)
    /// uv是(0,0),(2,0),(0,2)
    /// 那么中间的正方形部分,就是齐次裁剪空间(HCS)下的屏幕
    /// 顶点为(-1,-1)~(1,1)
    ///  uv为(0,0)~(1,1)
    /// 在Common.hlsl中有相同方法
    /// </summary>
    /// <returns></returns>
    public static Vector3[] GetFullScreenTriangleVertexPosition()
    {
        var z = SystemInfo.usesReversedZBuffer ? 1 : -1;
        var r = new Vector3[3];
        for (int i = 0; i < 3; i++)
        {
            var uv = new Vector2((i << 1) & 2, i & 2);
            r[i] = new Vector3(uv.x * 2.0f - 1.0f, uv.y * 2.0f - 1.0f, z);
        }

        return r;
    }
}