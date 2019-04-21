//
//  MNkCloudRequest.swift
//  MNkCloudRequest
//
//  Created by Malith Nadeeshan on 6/20/18.
//  Copyright © 2018 Malith Nadeeshan. All rights reserved.

import Foundation

public struct MNkCloudRequest{
    
    public static var contentType:ContentType = .formData
    
    //MARK:- REQUEST WITH NORMAL DATA RESULT..
    public static func request(_ urlConvertable:String,
                               _ method:RequestMethod = .get,
                               _ parameters:[String:Any] = [:],
                               _ headers:[String:String] = [:],
                               completed:@escaping (Data?,HTTPURLResponse?,String?)->Void){
        
        guard Reacherbility.isInternetAccessible else {
            DispatchQueue.main.async {
                completed(nil,nil,"no internet connection.")
            }
            return
        }
        
        do{
            
            let bodyParamData = try BodyParameters(parameters, contentType).encode()
            
            let request = MNKRequest(to: urlConvertable,
                                     bodyParamData,
                                     contentType.rawValue,
                                     method,
                                     headers)
            request.perform(completed: completed)
        }catch{
            completed(nil,nil,error.localizedDescription)
        }
    }
    
    
    //MARK:- REQUEST WITH DECORDABLE MODEL RESULT..
    public static func request<T:Decodable>(_ urlConvertable:String,
                                            _ method:RequestMethod = .get,
                                            _ parameters:[String:Any] = [:],
                                            _ headers:[String:String] = [:],
                                            completed:@escaping (T?,HTTPURLResponse?,String?)->Void){
        
        request(urlConvertable,
                method,
                parameters,
                headers) { (data, response, err) in
                    
                    guard err == nil,
                        let _data = data
                        else{
                            DispatchQueue.main.async {
                                completed(nil,response,err)
                            }
                            return
                    }
                    
                    do{
                        let obj = try JSONDecoder().decode(T.self, from: _data)
                        DispatchQueue.main.async {
                            completed(obj,response,err)
                        }
                        
                    }catch let error{
                        completed(nil,nil,"Type Decoding error: \(error.localizedDescription)")
                    }
                    
        }
    }
    
    
    ///Upload data to server with normal result
    public static func upload(multipartData:@escaping(MultipartFormData)->Void,
                              to url:UrlConvertable,
                              _ method:RequestMethod = .post ,
                              _ headers:[String:String] = [:],
                              completed:@escaping (Data?,HTTPURLResponse?,String?)->Void){
        let formData = MultipartFormData()
        multipartData(formData)
        
        let request = MNKRequest(to: url,
                                 formData.encode(),
                                 formData.contentType,
                                 method,
                                 headers)
        request.perform(completed: completed)
    }
    
    ///Upload data with multipart way. Result object will be decoded to given type
    public static func upload<T:Decodable>(multipartData:@escaping(MultipartFormData)->Void,
                                           to url:UrlConvertable,
                                           _ method:RequestMethod = .post ,
                                           _ headers:[String:String] = [:],
                                           completed:@escaping (T?,HTTPURLResponse?,String?)->Void){
        
        self.upload(multipartData: multipartData, to: url, method,headers) { (data, response, error) in
            guard let _data = data else{completed(nil,nil,"empty result");return}
            do{
                let decodedTypeData = try JSONDecoder().decode(T.self, from: _data)
                completed(decodedTypeData,response,error)
            }catch let err{completed(nil,response,err.localizedDescription)}
        }
    }
    
}
