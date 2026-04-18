using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MVP_Transform : MonoBehaviour
{
    private float dis = -1;
    private float a = 0.2f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //也可以用自定义的矩阵去影响物体顶点，当然，C#没有对索引的自动转换，还是得0-3
        Matrix4x4 p = Camera.main.projectionMatrix;
    
    // 🔑 关键：将投影矩阵适配到当前图形 API
        p = GL.GetGPUProjectionMatrix(p, false);
        Matrix4x4 mvp = p * Camera.main.worldToCameraMatrix * transform.localToWorldMatrix;
        //Matrix4x4 mvp = transform.localToWorldMatrix *  Camera.main.worldToCameraMatrix *  p ;
               
        //注意矩阵乘法的顺序细节,C#是行主序
        GetComponent<Renderer> ().material.SetMatrix("mvp",mvp.transpose);


        dis += Time.deltaTime * 0.9f;
        GetComponent<Renderer>().material.SetFloat("dis",dis);
        GetComponent<Renderer>().material.SetFloat("a",a);

    }
}
// 特性	C# Matrix4x4 * Matrix4x4	HLSL mul(Matrix, Vector)
// 逻辑运算	行主序 (Row-Major) 逻辑	列主序 (Column-Major) 逻辑
// 向量位置	通常向量在左：Vector4 * Matrix	通常向量在右：mul(Matrix, Vector)
// 变换顺序	先写的先应用：M * V * P	先写的先应用：mul(P, mul(V, mul(M, v)))
// 内存存储	列主序存储（但运算符逻辑是行主序）	列主序存储（运算符逻辑也是列主序）
// C#主打一个名不副实