//
//  Utilities.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation

//SOME SUPPORT UTILITIES FOR MNKCLOUD
extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
    
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
    ]
    
    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
    
    var type:FileTypes{
        let indexOfShalsh = mimeType.index(after: (mimeType.index(of: "/")!))
        let _type = FileTypes(rawValue: String(mimeType[indexOfShalsh...])) ?? FileTypes.plain
        return _type
    }
}


enum FileTypes:String{
    case jpeg = "jpeg"
    case png = "png"
    case gif = "gif"
    case tiff = "tiff"
    case pdf = "pdf"
    case vnd = "vnd"
    case plain = "plain"
}



public protocol UrlConvertable{
    func getURL() throws -> URL
}

extension String:UrlConvertable{
    public func getURL() throws -> URL {
        guard let _url = URL(string: self) else{throw MNKCloudError.invalidURl(url: self)}
        return _url
    }
}

extension URL:UrlConvertable{
    public func getURL() throws -> URL {
        return self
    }
    
}


//MARK:-  NETWORK REQUEST METHODS
public enum RequestMethod:String{
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
}

public enum ContentType:String{
    case json = "application/json"
    case formData = "application/x-www-form-urlencoded"
}

public enum EnocodingType{
    case json
    case formData
    case upload
    case none
}

struct RequestParams{
    var name:String
    var value:Any
    var isNextedValues:Bool = false
    
    init(_ name:String,_ value:Any) {
        self.name = name
        self.value = value
    }
}

struct EncodingChar{
    static let seperatorAt:String = "&"
    static let seperatorComma = ","
    static let equalizer = "="
    static let signColon = ":"
}
