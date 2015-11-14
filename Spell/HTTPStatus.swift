// HTTPStatus.swift
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

public enum HTTPStatus : Equatable {
    case OK
    case NotFound
    case Unknown(statusCode: Int)

    var statusCode: Int {
        switch self {
        case OK:             return 200
        case NotFound:       return 404
        case Unknown(let s): return s
        }
    }

    var reasonPhrase: String {
        switch self {
        case OK:       return "OK"
        case NotFound: return "Not Found"
        case Unknown:  return "Unknown"
        }
    }

    init(statusCode: Int) {
        switch statusCode {
        case 200: self = OK
        case 404: self = NotFound
        default:  self = Unknown(statusCode: statusCode)
        }
    }
}

public func ==(lhs: HTTPStatus, rhs: HTTPStatus) -> Bool {
    return lhs.statusCode == rhs.statusCode
}