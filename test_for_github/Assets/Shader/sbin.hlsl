struct appdata//结构体可以用typeof，但是这里没必要
            {
                float2 objPos : POSITION;//实际上这里objPos是构成cube的共24个顶点
                half4 color :COLOR;//读取顶点颜色值，默认为白色
            };
[loop]
float Func(float arr[2]){
    float sum = 0;
    for(int i = 0;i < 2;i++){//HLSL的数组没有length
        sum += arr[i];
    }
    return sum;
}