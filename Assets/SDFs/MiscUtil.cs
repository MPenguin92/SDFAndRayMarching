using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class MiscUtil
{
      private static Mesh sFullScreenTriangleMesh;
  
      public static Mesh FullScreenTriangleMesh {
          get {
              if (sFullScreenTriangleMesh == null) {
                  sFullScreenTriangleMesh = new() {
                      vertices = GetFullScreenTriangleVertexPosition(),
                      triangles = new int[] { 0, 1, 2 },
                  };
              }
              return sFullScreenTriangleMesh;
          }
      }
  
      public static Vector3[] GetFullScreenTriangleVertexPosition() {
          var z = SystemInfo.usesReversedZBuffer ? 1 : -1;
          var r = new Vector3[3];
          for (int i = 0; i < 3; i++) {
              var uv = new Vector2((i << 1) & 2, i & 2);
              r[i] = new Vector3(uv.x * 2.0f - 1.0f, uv.y * 2.0f - 1.0f, z);
          }
          return r;
      }
}
