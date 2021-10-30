using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class BezierNode {
    public Vector3 pos = Vector3.zero;
    public Vector3 in_pos = new Vector3(-1, 0, 0);
    public Vector3 out_pos = new Vector3(1, 0, 0);
    public float length;
    public float[] length_map;
}

[System.Serializable]
public class BezierCurve {
    public List<BezierNode> nodes_ = new List<BezierNode>();
    public float length_;

    const int calc_count = 10000;
    const int length_count = 20;

    public BezierCurve() {
        AddNode(0);
        AddNode(1);
    }
    public Vector3 GetPos(float percent) {
        int node_index;
        float node_process;
        return GetInfo(percent, out node_index, out node_process);
    }
    public Vector3 GetInfo(float percent, out int node_index, out float node_process) {
        if (length_ == 0 || percent <= 0) {
            node_index = 0;
            node_process = 0;
            return nodes_[0].pos;
        }
        if (percent >= 1) {
            node_index = nodes_.Count - 2;
            node_process = 1;
            return nodes_[nodes_.Count - 1].pos;
        }
        float length = percent * length_;
        for (node_index = 0; node_index < nodes_.Count - 1; ++node_index) {
            if (length <= nodes_[node_index].length) {
                break;
            } else {
                length -= nodes_[node_index].length;
            }
        }
        node_process = length / nodes_[node_index].length;
        float sub_process = node_process * length_count;
        int sub_index = Mathf.FloorToInt(sub_process);
        sub_process = sub_process - sub_index;
        float real_process = Mathf.Lerp(nodes_[node_index].length_map[sub_index],
                                        nodes_[node_index].length_map[sub_index + 1],
                                        sub_process);
        return CalculateBezier(real_process, nodes_[node_index], nodes_[node_index + 1]);
    }

    public Vector3 CalculateBezier(float t, BezierNode a, BezierNode b) {
        return CalculateBezier(t, a.pos, a.out_pos, b.in_pos, b.pos);
    }
    public Vector3 CalculateBezier(float t, Vector3 p, Vector3 a, Vector3 b, Vector3 q) {
        float t2 = t * t;
        float t3 = t2 * t;
        float u = 1.0f - t;
        float u2 = u * u;
        float u3 = u2 * u;
        Vector3 output = u3 * p + 3 * u2 * t * a + 3 * u * t2 * b + t3 * q;
        return output;
    }
    public void OnNodeChange(int i) {
        if (i > 0) GenNodeLength(nodes_[i - 1], nodes_[i]);
        if (i < nodes_.Count - 1) GenNodeLength(nodes_[i], nodes_[i + 1]);
        GenTotalLength();
    }
    public void GenNodeLength(BezierNode a, BezierNode b) {
        float length = 0;
        float[] process_to_length = new float[calc_count];
        Vector3 last_pos = a.pos;
        for (int i = 1; i < calc_count; ++i) {
            Vector3 pos = CalculateBezier((float)i / calc_count, a, b);
            length += Vector3.Distance(pos, last_pos);
            process_to_length[i] = length;
            last_pos = pos;
        }
        float[] length_to_process = new float[length_count + 1];
        if (length > 0) {
            length_to_process[0] = 0;
            length_to_process[length_count] = 1;
            int index = 0;
            for (int i = 1; i < calc_count; ++i) {
                if (process_to_length[i] / length * length_count > index) {
                    length_to_process[index] = (float)i / calc_count;
                    ++index;
                }
            }
        } else {
            for (int i = 0; i <= length_count; ++i) {
                length_to_process[i] = 0;
            }
        }
        a.length = length;
        a.length_map = length_to_process;
    }
    public void GenTotalLength() {
        float total_length = 0;
        for (int i = 0; i < nodes_.Count - 1; ++i) {
            total_length += nodes_[i].length;
        }
        length_ = total_length;
    }
    public void AddNode(int i) {
        i = Mathf.Clamp(i + 1, 0, nodes_.Count);
        BezierNode node = new BezierNode();
        nodes_.Insert(i, node);
        if (nodes_.Count == 1) {
        } else if (i == 0) {
            Vector3 pos = nodes_[i + 1].pos;
            Vector3 pos_in = nodes_[i + 1].in_pos;
            node.pos = pos_in + (pos_in - pos);
        } else if (i == nodes_.Count - 1) {
            Vector3 pos = nodes_[i - 1].pos;
            Vector3 pos_out = nodes_[i - 1].out_pos;
            node.pos = pos_out + (pos_out - pos);
        } else {
            node.pos = (nodes_[i - 1].pos + nodes_[i + 1].pos) / 2;
        }
        RelaxNode(i);
    }
    public void RemoveNode(int i) {
        if (i < 0 || i >= nodes_.Count) return;
        if (nodes_.Count <= 2) return;
        nodes_.RemoveAt(i);
        if (i > 0 && i < nodes_.Count) GenNodeLength(nodes_[i - 1], nodes_[i]);
        GenTotalLength();
    }
    public void RelaxNode(int i) {
        if (i < 0 || i >= nodes_.Count) return;
        BezierNode node = nodes_[i];
        Vector3 tangent = Vector3.forward;
        if (nodes_.Count == 1) {
            tangent = Vector3.forward * 10;
        } else if (i == 0) {
            tangent = nodes_[i + 1].pos - node.pos;
        } else if (i == nodes_.Count - 1) {
            tangent = -(nodes_[i - 1].pos - node.pos);
        } else {
            Vector3 tangent_in = -(nodes_[i - 1].pos - node.pos);
            Vector3 tangent_out = nodes_[i + 1].pos - node.pos;
            float weight = tangent_in.magnitude / (tangent_in.magnitude + tangent_out.magnitude);
            tangent = Vector3.Lerp(tangent_in, tangent_out, weight);
        }
        node.in_pos = node.pos - Vector3.Normalize(tangent) * tangent.magnitude / 3;
        node.out_pos = node.pos + Vector3.Normalize(tangent) * tangent.magnitude / 3;
        OnNodeChange(i);
    }
}

