//
//  MNkCloudRequest.swift
//  MNkCloudRequest
//
//  Created by Malith Nadeeshan on 6/20/18.
//  Copyright © 2018 Malith Nadeeshan. All rights reserved.

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

public typealias MultipartFormData = [(value:Data,key:String)]


enum FileTypes:String{
    case jpeg = "jpeg"
    case png = "png"
    case gif = "gif"
    case tiff = "tiff"
    case pdf = "pdf"
    case vnd = "vnd"
    case plain = "plain"
}


 public struct MNkCloudRequest{
    
//    public static var contentType = "application/x-www-form-urlencoded"
    public static var contentType = "application/json"
    
    //MARK:- REQUEST WITH NORMAL DATA RESULT..
    public static func request(_ urlConvertable:String,_ method:RequestMethod = .get,_ parameters:[String:Any] = [:],_ headers:[String:Any] = [:],completed:@escaping (Data,HTTPURLResponse?,String?)->Void){
        
        guard Reacherbility.isInternetAccessible else {
            DispatchQueue.main.async {
                completed(Data(),nil,"no internet connection.")
            }
            return
        }
        
        guard let url = URL(string: urlConvertable) else{completed(Data(),nil,"use valid url string");return}
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let stringOFParam = parameters.map { (key,value) -> String in
            return "\(key)=\(value)"
            }.joined(separator: "&")
        
        if parameters.count > 0 {
            request.httpBody = stringOFParam.data(using: .utf8)
        }
        
        var _headers = headers
        _headers[ "Content-Type"] = contentType
        _headers["Accept"] = contentType
    
        
        if _headers.count > 0 {
            for header in _headers{
                request.addValue(header.value as! String, forHTTPHeaderField: header.key )
            }
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, Error in
            DispatchQueue.main.async {
                completed(data ?? Data(),response as? HTTPURLResponse,Error?.localizedDescription)
            }
            
            }.resume()
    }
    
    
    //MARK:- REQUEST WITH DECORDABLE MODEL RESULT..
    public static func request<T:Decodable>(_ urlConvertable:String,_ method:RequestMethod = .get,_ parameters:[String:Any] = [:],_ headers:[String:Any] = [:],completed:@escaping (T?,HTTPURLResponse?,String?)->Void){
        request(urlConvertable, method, parameters, headers) { (data, response, err) in
           
            guard err == nil else{
                
                DispatchQueue.main.async {
                   completed(nil,response,err)
                }
                return
            }
            
            do{
                let obj = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completed(obj,response,err)
                }
                
            }catch let error{
               completed(nil,nil,error.localizedDescription)
            }
            
        }
    }
    
    
    
    //MARK:- UPLOAD DATA REQUEST WITH MAULTIPART DATA..
    
    public static func upload(multipartData:@escaping()->MultipartFormData,to urlConvertable:String,_ method:RequestMethod ,completed:@escaping (Data?,HTTPURLResponse?,String?)->Void){
        
        guard Reacherbility.isInternetAccessible else {
            DispatchQueue.main.async {
                completed(nil,nil,"no internet connection.")
            }
            return
        }
        
        let _multipartData = multipartData()
        
        guard _multipartData.count > 0,
            let url = URL(string: urlConvertable)
            else{
                DispatchQueue.main.async {
                    completed(nil,nil,"some thing went wrong")
                }
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBody(using: _multipartData, in: boundary)
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, err) in
            DispatchQueue.main.async {
                completed(data,response as? HTTPURLResponse,err?.localizedDescription)
            }
            }.resume()
        
    }
    
    public static func upload<T:Decodable>(multipartData:@escaping()->MultipartFormData,to urlConvertable:String,_ method:RequestMethod = .post,completed:@escaping (T?,HTTPURLResponse?,String?)->Void){
        
        self.upload(multipartData: { () -> MultipartFormData in
            return multipartData()
            
        }, to: urlConvertable, method) { data, httpResponse, err in
            
            guard let _data = data, err == nil else{completed(nil,nil,err ?? "some thing went wrong.");return}
            do{
                let objc = try JSONDecoder().decode(T.self, from: _data)
                completed(objc,httpResponse,err)
            }catch{
                completed(nil,nil,error.localizedDescription)
            }
            
            
        }
        
    }
    
    
    //SOME SUPPORT FUNCTIONS FOR MUTIPART DATA ---- CHECK AND NEED TO DEPRECATE FUTURE
    private static func createBody(using multipartData:MultipartFormData,in boundary:String) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (index,data) in multipartData.enumerated(){
            guard data.value.count > 0 else{continue}
            
            //            print("value: \(data.value), key: \(data.key)")
            
            switch data.value.type{
            case .plain:
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(data.key)\"\r\n\r\n")
                body.append(data.value)
                body.appendString("\r\n")
            case .gif,.jpeg,.pdf,.png,.tiff,.vnd:
                let fileName = "file\(index).\(data.value.type)"
                //                print("file name: ",fileName)
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(data.key)\"; filename=\"\(fileName)\"\r\n")
                body.appendString("Content-Type: \(data.value.mimeType)\r\n\r\n")
                body.append(data.value)
                body.appendString("\r\n")
            }
            
        }
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    //MARK:-  NETWORK REQUEST METHODS
    public enum RequestMethod:String{
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
        case put = "PUT"
    }
    
}
