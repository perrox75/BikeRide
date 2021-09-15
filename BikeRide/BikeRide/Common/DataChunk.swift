//
//  DataChunk.swift
//  BikeRide
//
//  Created by perrox75 on 30/08/2021.
//

import Foundation

struct DataChunk: ClassName {

    // Parse chunks into data
    func chunksIntoData(chunks: [Data]) -> Data {
        var data = Data()
        for chunk in chunks {
            data.append(chunk)
        }
        return data
    }

    // Splits data into chunks
    func dataIntoChunks(data: Data, chunkSize: Int) -> [Data] {
        var chunks = [Data]()
        let length = data.count
        var offset = 0

        while offset < length {
            let size = length - offset > chunkSize ? chunkSize : length - offset
            let range: Range = offset..<(offset + size)
            let chunk = data.subdata(in: range)
            chunks.append(chunk)
            offset += size
        }
        return chunks
    }

    // test func to generate arbitrary length data
    private func dataWithLength(length: Int) -> Data {
      var bytes: [UInt8] = []
      for _ in 0..<length {
        bytes.append(UInt8(arc4random_uniform(9)+1))
      }
      return Data(bytes: bytes, count: bytes.count * MemoryLayout<UInt8>.size)
    }

    // TODO Move to unit testing sooner or later
    func test() {
        // work with data
        let data1 = dataWithLength(length: 184)
        let chunks = dataIntoChunks(data: data1, chunkSize: 10)
        let data2 = chunksIntoData(chunks: chunks)

        // checks
        print(data1.count == data2.count)
        print(data1 == data2)
    }
}
