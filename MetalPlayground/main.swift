//
//  main.swift
//  MetalPlayground
//
//  Created by John Morton on 12/04/2017.
//  Copyright © 2017 Magnus. All rights reserved.
//

import Foundation
import Metal


print("Hello, World!")
let range : UInt32 = 65536
let data : [UInt32] = Array(4000...(4000 + range))

let then  = DispatchTime.now()

var device = MTLCreateSystemDefaultDevice()
var lib = device?.newDefaultLibrary()
var queue  = device?.makeCommandQueue()
var commandBuffer = queue?.makeCommandBuffer()
var encoder = commandBuffer?.makeComputeCommandEncoder()

var totient = lib?.makeFunction(name: "euler_totient")
var compState = try? device?.makeComputePipelineState(function: totient!)
encoder?.setComputePipelineState(compState!!)

let bytes = data.count * MemoryLayout<UInt32>.size

var inBuf = device?.makeBuffer(bytes: data, length: bytes)

encoder?.setBuffer(inBuf, offset: 0, at: 0)
var result = Array(repeating:0, count: data.count )
var outBuf = device?.makeBuffer(bytes: result, length: bytes)
encoder?.setBuffer(outBuf, offset: 0, at: 1)

//let w = compState!!.threadExecutionWidth
//let threadsPerThreadGroup = compState!!.maxTotalThreadsPerThreadgroup
let threadsPerGroup = MTLSize(width: 32, height: 1, depth: 1)
let numThreadGroups = MTLSize(width: (data.count + 31)/32, height:1, depth:1)

//encoder?.dispatchThreadgroups(MTLSize(width:w, height:1, depth:1), threadsPerThreadgroup: MTLSize(width:threadsPerThreadGroup, height:1, depth:1))
encoder?.dispatchThreadgroups(numThreadGroups, threadsPerThreadgroup:threadsPerGroup )
encoder?.endEncoding()
commandBuffer?.commit()
commandBuffer?.waitUntilCompleted()

let buf = UnsafeBufferPointer(start:outBuf?.contents().assumingMemoryBound(to: UInt32.self), count:data.count)

let out = Array(buf) 
var sum: UInt32 = 0
for i in out {
    sum += i
}

let now = DispatchTime.now()

print(sum)

print("time: \((now.uptimeNanoseconds - then.uptimeNanoseconds) / 1000000) milliseconds")

//print(out)
