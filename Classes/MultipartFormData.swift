//
//  MultipartFormData.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation

open class MultipartFormData{
    
    //Data type for multipart data
    class BodyPart{
        let data:Data
        let contentLength:UInt64
        let headers:BodyPartHeaders
        var isFirstPartData:Bool = false
        var isLastPartData:Bool = false
        
        init(_ data:Data,_ contentLength:UInt64,_ headers:BodyPartHeaders) {
            self.data = data
            self.contentLength = contentLength
            self.headers = headers
        }
    }
    
    //Encoding charecter help struct
    struct EncodingData{
        static var seperator:String{
            return "\r\n"
        }
    }
    
    typealias BodyPartHeaders = [String:String]
    
    
    public var contentType:String{
        return "multipart/form-data; boundary=\(boundary)"
    }
    
    private var bodyParts:[BodyPart]
    private let boundary:String
    
    ///Append multipart data to all data
    ///If you can give only name and value or mime type and filename to.
    public func append(value:Data,for name:String,_ mimeType:String? = nil,_ fileName:String? = nil){
        let headers = createHeaders(with: name, mimeType, fileName)
        let contentLength = UInt64(value.count)
        append(value, headers: headers, contentLength)
    }
    
    
    //append publicly appended data to local data array
    private func append(_ data:Data,headers:BodyPartHeaders,_ contentLength:UInt64){
        let bodyPart = BodyPart(data, contentLength, headers)
        bodyParts.append(bodyPart)
    }
    
    //Create header for single data
    private func createHeaders(with name:String,_ mimeType:String? = nil,_ fileName:String? = nil)->BodyPartHeaders{
        
        var headers:BodyPartHeaders = [:]
        
        var contentDisposition = "form-data; name=\"\(name)\""
        if let _fileName = fileName{contentDisposition = contentDisposition + "; filename=\"\(_fileName)\""}
        headers["Content-Disposition:"] = contentDisposition
        
        if let _mimeType = mimeType{headers["Content-Type:"] = _mimeType}
        
        return headers
    }
    
    
    init() {
        bodyParts = []
        boundary = GetBoundary().randomBoundary()
    }
    
    ///Encode multipart data to swift Data type.
    public func encode()->Data{
        var encodedData = Data()
        
        bodyParts.first?.isFirstPartData = true
        bodyParts.last?.isLastPartData = true
        
        for bodyPart in bodyParts{
            let _encodedBodyPart = encode(bodyPart)
            encodedData.append(_encodedBodyPart)
        }
        
        return encodedData
    }
    
    //Encode single body part data file
    private func encode(_ bodyPart:BodyPart)->Data{
        var encoded = Data()
        
        let boundaryData = bodyPart.isFirstPartData ? GetBoundary().generateBoundary(for: .start, boundary) : GetBoundary().generateBoundary(for: .middle, boundary)
        encoded.append(boundaryData)
        
        let headersData = encodeHeaders(bodyPart.headers)
        encoded.append(headersData)
        
        encoded.append(bodyPart.data)
        
        if bodyPart.isLastPartData{
            encoded.append(GetBoundary().generateBoundary(for: .last, boundary))
        }
        
        return encoded
    }
    
    //Encode header to data type of single body part data
    private func encodeHeaders(_ headers:BodyPartHeaders)->Data{
        var encodedHeadersText = ""
        
        for (key,value) in headers{
            encodedHeadersText = encodedHeadersText + "\(key)\(value)\(EncodingData.seperator)"
        }
        
        encodedHeadersText = encodedHeadersText + EncodingData.seperator
        
        return encodedHeadersText.data(using: .utf8, allowLossyConversion: false)!
    }
    
    
    
    //Get boundary for request
    struct GetBoundary{
        //Create random string for boundary
        
        func randomBoundary()->String{
            return String(format: "MNkCloudRequest.boundary.%08x%08x", arc4random(), arc4random())
        }
        
        func generateBoundary(for type:BoundaryType,_ boundary:String)->Data{
            var boundaryText:String = ""
            
            switch type {
            case .start:
                boundaryText = "--\(boundary)\(EncodingData.seperator)"
            case .middle:
                boundaryText = "\(EncodingData.seperator)--\(boundary)\(EncodingData.seperator)"
            case .last:
                boundaryText = "\(EncodingData.seperator)--\(boundary)--\(EncodingData.seperator)"
            }
            
            return boundaryText.data(using: .utf8, allowLossyConversion: false)!
        }
    }
    
    enum BoundaryType {
        case start
        case middle
        case last
    }
}
