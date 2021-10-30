using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshUtil {
    static Mesh rect_mesh;
    static Mesh quad_mesh;

    static public Mesh GetRectMesh() {
        if (rect_mesh == null) {
            Mesh mesh = new Mesh();
            mesh.vertices = new Vector3[] {
                                        new Vector3(0, 0, 0),
                                        new Vector3(1, 0, 0),
                                        new Vector3(0, 1, 0),
                                        new Vector3(1, 1, 0)
                                    };
            mesh.uv = new Vector2[] {
                                        new Vector2(0, 1),
                                        new Vector2(1, 1),
                                        new Vector2(0, 0),
                                        new Vector2(1, 0)
                                    };
            mesh.SetIndices(new int[] { 0, 1, 2, 2, 1, 3 }, MeshTopology.Triangles, 0);
            rect_mesh = mesh;
        }
        return rect_mesh;
    }

    static public Mesh GetQuadMesh() {
        if (quad_mesh == null) {
            Mesh mesh = new Mesh();
            mesh.vertices = new Vector3[] {
                                        new Vector3(-1, -1, 0),
                                        new Vector3(1, -1, 0),
                                        new Vector3(-1, 1, 0),
                                        new Vector3(1, 1, 0)
                                    };
            mesh.uv = new Vector2[] {
                                        new Vector2(0, 1),
                                        new Vector2(1, 1),
                                        new Vector2(0, 0),
                                        new Vector2(1, 0)
                                    };
            mesh.SetIndices(new int[] { 0, 1, 2, 2, 1, 3 }, MeshTopology.Triangles, 0);
            quad_mesh = mesh;
        }
        return quad_mesh;
    }

}
