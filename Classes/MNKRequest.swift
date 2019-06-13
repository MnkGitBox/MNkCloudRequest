//
//  MNKRequest.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation

class MNKRequest {
    private let contentType:String
    private let method:RequestMethod
    private let url:UrlConvertable
    private var headers:[String:String] = [:]
    
    private var bodyParams:[RequestParams] = []
    
    private var request:URLRequest!
    
    init(to url:UrlConvertable,_ contentType:String,_ method:RequestMethod,_ headers:[String:String] = [:],_ parameters:Any? = nil,_ encoding:EnocodingType)throws{
        self.url = url
        self.contentType = contentType
        self.method = method
        self.headers = headers
        self.headers[ "Content-Type"] = contentType
        self.headers["Accept"] = contentType
        
        bodyParams = try EncodedParam.encode(parameters)
        self.request = try initRequestData(for: encoding, with: parameters)
    }
    
    
    private func initRequestData(for encoding:EnocodingType, with param:Any?)throws->URLRequest{
        guard let _url = try? url.getURL() else{
            throw MNKCloudError.parametersEncodingFailed(reason:.dataEncodefail(error: "No Encodable Url in request"))
        }
        
        switch encoding{
        case .formData:
            return try RequestForFormData.build(for: _url, method, with: bodyParams)
        case .json:
            return try RequestForJsonData.build(of: _url, method, with: param)
        case .none:
            return try RequestForNormal.build(for: _url, method, with: bodyParams)
        case .upload:
            return try RequestForUpload.build(of: _url, method, with: param)
        }
    }
    
    
    
    func perform(completed:@escaping (Data?,HTTPURLResponse?,String?)->Void){
        
        for header in headers{
            request.addValue(header.value, forHTTPHeaderField: header.key )
        }
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, err) in
            DispatchQueue.main.async {
                completed(data,response as? HTTPURLResponse,err?.localizedDescription)
            }
            }.resume()
    }
    
}








