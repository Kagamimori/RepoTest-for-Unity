using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UV_Transform : MonoBehaviour
{
    public int height;
    public int width;
    public int fps;
    private int index ;
   
    IEnumerator Start()
    {
        float x2 = 1.0f / width;
        float y2 = 1.0f / height;

        Material m = GetComponent<Renderer>().material;

        while(true)
        {
            float x1 = index % width * x2;
            float y1 = index / height * y2 ;
            m.SetTextureScale("_MainTex",new Vector2(x2,y2));
            m.SetTextureOffset("_MainTex",new Vector2(x1,y1));

            yield return new WaitForSeconds(1.0f / fps); // 秒数加帧率

            index = (++index) % (width * height);
        }
    }
}
