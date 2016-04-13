// IP.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import CLibvenice
@_exported import Venice

public enum IPMode {
    case ipV4
    case ipV6
    case ipV4Prefered
    case ipV6Prefered

    var code: Int32 {
        switch self {
        case .ipV4: return 1
        case .ipV6: return 2
        case .ipV4Prefered: return 3
        case .ipV6Prefered: return 4
        }
    }
}

public struct IP {
    public let address: ipaddr

    public init(address: ipaddr) throws {
        self.address = address
        try IPError.assertNoError()
    }

    public init(localAddress: String? = nil, port: Int = 0, mode: IPMode = .ipV4Prefered) throws {
        try IP.assertValid(port)
        if let localAddress = localAddress {
            try self.init(address: iplocal(localAddress, Int32(port), mode.code))
        } else {
            try self.init(address: iplocal(nil, Int32(port), mode.code))
        }
    }

    public init(networkInterface: String, port: Int = 0, mode: IPMode = .ipV4Prefered) throws {
        try IP.assertValid(port)
        try self.init(address: iplocal(networkInterface, Int32(port), mode.code))
    }

    public init(remoteAddress: String, port: Int, mode: IPMode = .ipV4Prefered, deadline: Double = .never) throws {
        try IP.assertValid(port)
        try self.init(address: ipremote(remoteAddress, Int32(port), mode.code, deadline.int64milliseconds))
    }

    private static func assertValid(_ port: Int) throws {
        if port < 0 || port > 0xffff {
            throw IPError.invalidPort(description: "Port number should be between 0 and 0xffff")
        }
    }
}

extension IP: CustomStringConvertible {
    public var description: String {
        var buffer = [Int8](repeating: 0, count: 46)
        ipaddrstr(address, &buffer)
        return String(cString: buffer)
    }
}