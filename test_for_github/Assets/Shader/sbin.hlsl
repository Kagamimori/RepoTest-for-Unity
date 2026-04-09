
[loop]
float Func(float arr[2]){
    float sum = 0;
    for(int i = 0;i < 2;i++){//HLSL的数组没有length
        sum += arr[i];
    }
    return sum;
}