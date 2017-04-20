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

let totient = lib?.makeFunction(name: "euler_totient")
let reduce = lib?.makeFunction(name: "parsum")
let eulerState = try? device?.makeComputePipelineState(function: totient!)
let reduceState = try? device?.makeComputePipelineState(function: reduce!)
encoder?.setComputePipelineState(eulerState!!)

let bytes = data.count * MemoryLayout<UInt32>.size
var inBuf = device?.makeBuffer(bytes: data, length: bytes)
encoder?.setBuffer(inBuf, offset: 0, at: 0)

let outBuf = device?.makeBuffer(length: bytes, options: [])
encoder?.setBuffer(outBuf, offset: 0, at: 1)

var partialSums = device?.makeBuffer(length: 256 * MemoryLayout<UInt32>.size, options: [])
encoder?.setBuffer(partialSums, offset: 0, at: 2)


let threadsPerGroup = MTLSize(width: 256, height: 1, depth: 1)
let numThreadGroups = MTLSize(width: 256, height:1, depth:1)

encoder?.setThreadgroupMemoryLength(MemoryLayout<UInt32>.size * 256, at: 0)
encoder?.dispatchThreadgroups(numThreadGroups, threadsPerThreadgroup:threadsPerGroup )

encoder?.setComputePipelineState(reduceState!!)
encoder?.dispatchThreadgroups(numThreadGroups, threadsPerThreadgroup: threadsPerGroup)
encoder?.endEncoding()

let kstart = DispatchTime.now()
commandBuffer?.commit()
commandBuffer?.waitUntilCompleted()

let kend = DispatchTime.now()
let buf = UnsafeBufferPointer(start:partialSums?.contents().assumingMemoryBound(to: UInt32.self), count:256)

let out = Array(buf) 
var sum: UInt32 = 0
for i in out {
    sum += i
}

let now = DispatchTime.now()

print(sum)

print("GPU time: \((kend.uptimeNanoseconds - kstart.uptimeNanoseconds) / 1000000) milliseconds")
print("time: \((now.uptimeNanoseconds - then.uptimeNanoseconds) / 1000000) milliseconds")

//print(out)
