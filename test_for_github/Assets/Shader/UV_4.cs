using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UV_4 : MonoBehaviour
{
    public float x1;
    public float y1;
    public float x2;
    public float y2;
    void Start()
    {
        GetComponent<Renderer>().material.SetFloat("x1",x1);
        GetComponent<Renderer>().material.SetFloat("y1",y1);
        GetComponent<Renderer>().material.SetFloat("x2",x2);
        GetComponent<Renderer>().material.SetFloat("y2",y2);
    }
}
