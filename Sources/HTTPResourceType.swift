// HTTPResourceType.swift
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

import HTTP

public protocol HTTPResourceType {
    func index(request: HTTPRequest) throws -> HTTPResponse
    mutating func create(request: HTTPRequest) throws -> HTTPResponse
    func show(request: HTTPRequest, id: String) throws -> HTTPResponse
    mutating func update(request: HTTPRequest, id: String) throws -> HTTPResponse
    mutating func destroy(request: HTTPRequest, id: String) throws -> HTTPResponse
}

extension HTTPResourceType {
    func index(request: HTTPRequest) throws -> HTTPResponse {
        return HTTPResponse(statusCode: 405, reasonPhrase: "Method Not Allowed")
    }

    func create(request: HTTPRequest) throws -> HTTPResponse {
        return HTTPResponse(statusCode: 405, reasonPhrase: "Method Not Allowed")
    }

    func show(request: HTTPRequest, id: String) throws -> HTTPResponse {
        return HTTPResponse(statusCode: 405, reasonPhrase: "Method Not Allowed")
    }

    func update(request: HTTPRequest, id: String) throws -> HTTPResponse {
        return HTTPResponse(statusCode: 405, reasonPhrase: "Method Not Allowed")
    }

    func destroy(request: HTTPRequest, id: String) throws -> HTTPResponse {
        return HTTPResponse(statusCode: 405, reasonPhrase: "Method Not Allowed")
    }
}
