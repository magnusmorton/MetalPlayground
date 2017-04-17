//
//  kernel.metal
//  MetalPlayground
//
//  Created by John Morton on 12/04/2017.
//  Copyright © 2017 Magnus. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;
uint gcd(uint, uint);
uint phi(uint);

uint gcd(uint n, uint k){
    uint x;
    while (k) {
        x = n;
        n = k;
        k = x % k;
    }
    return abs(n);
}

uint phi(uint n)
{
    uint acc = 0;
    for (uint i=0; i< n; i++) {
        if (gcd(n, i) == 1)
            acc ++;
    }
    return acc;
}

kernel void euler_totient(constant uint* in [[buffer(0)]], device uint* out [[buffer(1)]], uint gid [[thread_position_in_grid]]) {
    out[gid] = phi(in[gid]);
}

kernel void reduction(constant uint* in [[buffer(0)]], device uint* out [[buffer(1)]], uint gid [[thread_position_in_grid]], uint lid ) {
    
}
