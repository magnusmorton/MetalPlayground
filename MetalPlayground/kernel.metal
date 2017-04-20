//
//  kernel.metal
//  MetalPlayground
//
//  Created by John Morton on 12/04/2017.
//  Copyright © 2017 Magnus. All rights reserved.
//

#include <metal_stdlib>
#include <metal_compute>

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

kernel void parsum(constant uint* in [[buffer(1)]], device uint* partialSums [[buffer(2)]],
                      threadgroup uint* localSums [[ threadgroup(0) ]],
                      uint tid [[thread_position_in_grid]],
                      uint lid [[thread_index_in_threadgroup]],
                      uint size [[threads_per_threadgroup]],
                      uint gid [[threadgroup_position_in_grid]]) {
    
    localSums[lid] = in[tid];
    for (uint offset = 1; offset < size; offset <<=1) {
        int mask = (offset << 1) - 1;
        threadgroup_barrier(mem_flags::mem_threadgroup);
        if ((lid & mask) == 0)
            localSums[lid] += localSums[lid + offset];
    }
    
    if (lid == 0)
        partialSums[gid] = localSums[0];
    
    
}
