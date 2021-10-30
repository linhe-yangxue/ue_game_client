using UnityEngine;

public class UISpellGizmos : MonoBehaviour {
    public Color color_ = Color.green; // 线框颜色
    private float radius_; // 圆环的半径
    private float theta_ = 0.01f; // 值越低圆环越平滑

    void OnDrawGizmosSelected()
    {
        if (theta_ < 0.0001f) theta_ = 0.0001f;
        Quaternion quat = Quaternion.Euler(transform.eulerAngles + new Vector3(90, 0, 0));
        Gizmos.matrix = Matrix4x4.TRS(transform.position, quat, transform.lossyScale);
        Gizmos.color = color_;
        radius_ = GetComponent<RectTransform>().rect.width / 2;

        Vector3 begin_point = Vector3.zero;
        Vector3 first_point = Vector3.zero;
        for (float theta = 0; theta < 2 * Mathf.PI; theta += theta_)
        {
            float x = radius_ * Mathf.Cos(theta);
            float z = radius_ * Mathf.Sin(theta);
            Vector3 end_point = new Vector3(x, 0, z);
            if (theta == 0)
            {
                first_point = end_point;
            }
            else
            {
                Gizmos.DrawLine(begin_point, end_point);
            }
            begin_point = end_point;
        }
        Gizmos.DrawLine(first_point, begin_point);
    }
}
