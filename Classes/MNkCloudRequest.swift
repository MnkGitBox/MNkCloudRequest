//
//  MNkCloudRequest.swift
//  MNkCloudRequest
//
//  Created by Malith Nadeeshan on 6/20/18.
//  Copyright © 2018 Malith Nadeeshan. All rights reserved.

import Foundation
import RxSwift
import RxCocoa

public struct MNkCloudRequest{
    
    public static var contentType:ContentType = .formData
    
    //    //MARK:- REQUEST WITH NORMAL DATA RESULT..
    public static func request(_ urlConvertable:String,
                               _ method:RequestMethod = .get,
                               _ parameters:Any? = nil,
                               _ headers:[String:String] = [:],
                               _ encoding:EnocodingType = .json,
                               completed:@escaping (Data?,HTTPURLResponse?,Error?)->Void){
        
        guard Reacherbility.isInternetAccessible else {
            DispatchQueue.main.async {
                completed(nil,nil,MNKCloudError.noInternet(error: "No Active Internet Connection"))
            }
            return
        }
        
        do{
            
            let request = try MNKRequest(to: urlConvertable,
                                         contentType.rawValue,
                                         method,
                                         headers,
                                         parameters,
                                         encoding)
            
            request.perform(completed: completed)
            
        }catch{
            completed(nil,nil,error)
        }
    }
    
    
    
    //MARK:- REQUEST WITH DECORDABLE MODEL RESULT..
    public static func request<T:Decodable>(_ urlConvertable:String,
                                            _ method:RequestMethod = .get,
                                            _ parameters:Any? = nil,
                                            _ headers:[String:String] = [:],
                                            _ encoding:EnocodingType = .json,
                                            completed:@escaping (T?,HTTPURLResponse?,Error?)->Void){
        
        request(urlConvertable,
                method,
                parameters,
                headers,
                encoding) { (data, response, err) in
                    
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
                        completed(nil,nil,error)
                    }
                    
        }
    }
    
    
    ///Upload data to server with normal result
    public static func upload(multipartData:@escaping(MultipartFormData)->Void,
                              to url:UrlConvertable,
                              _ method:RequestMethod = .post ,
                              _ headers:[String:String] = [:],
                              completed:@escaping (Data?,HTTPURLResponse?,Error?)->Void){
        let formData = MultipartFormData()
        multipartData(formData)
        
        let request = try?  MNKRequest.init(to: url,
                                            formData.contentType,
                                            method,
                                            headers,
                                            formData,
                                            .upload)
        
        request?.perform(completed: completed)
    }
    
    ///Upload data with multipart way. Result object will be decoded to given type
    public static func upload<T:Decodable>(multipartData:@escaping(MultipartFormData)->Void,
                                           to url:UrlConvertable,
                                           _ method:RequestMethod = .post ,
                                           _ headers:[String:String] = [:],
                                           completed:@escaping (T?,HTTPURLResponse?,Error?)->Void){
        
        self.upload(multipartData: multipartData, to: url, method,headers) { (data, response, error) in
            guard let _data = data else{completed(nil,nil,MNKCloudError.uploadErro(error: "Empty Data for Upload"));return}
            do{
                let decodedTypeData = try JSONDecoder().decode(T.self, from: _data)
                completed(decodedTypeData,response,error)
            }catch let err{completed(nil,response,err)}
        }
    }
    
    
    public static func rxRequestDecodable<T:Decodable>(_ urlConvertable:String,
                                              _ method:RequestMethod = .get,
                                              _ parameters:Any? = nil,
                                              _ headers:[String:String] = [:],
                                              _ encoding:EnocodingType = .json)->Observable<T>{
        
        return Observable<T>.create{ observer in
            
            var request:MNKRequest?
            
            do{
                
                request = try MNKRequest(to: urlConvertable,
                                         contentType.rawValue,
                                         method,
                                         headers,
                                         parameters,
                                         encoding)
                
                request?.perform{ (data, response, err) in
                    
                    guard let _data = data else{
                        observer.onError(err!)
                        return
                    }
                    
                    do{
                        let result = try JSONDecoder().decode(T.self, from: _data)
                        observer.onNext(result)
                        
                    }catch let error{
                        observer.onError(error)
                    }
                    
                    observer.onCompleted()
                }
                
            }catch let reqError{
                observer.onError(reqError)
                observer.onCompleted()
            }
            
            return Disposables.create {
                request?.task?.cancel()
            }
            
        }
    }
    
    public static func rxRequestData(_ urlConvertable:String,
                                              _ method:RequestMethod = .get,
                                              _ parameters:Any? = nil,
                                              _ headers:[String:String] = [:],
                                              _ encoding:EnocodingType = .json)->Observable<Data>{
        
        return Observable<Data>.create{ observer in

            var request:MNKRequest?

            do{

                request = try MNKRequest(to: urlConvertable,
                                         contentType.rawValue,
                                         method,
                                         headers,
                                         parameters,
                                         encoding)

                request?.perform{ (data, response, err) in

                    guard let _data = data else{
                        observer.onError(err!)
                        return
                    }
                    
                    observer.onNext(_data)
                    observer.onCompleted()
                }

            }catch let reqError{
                observer.onError(reqError)
                observer.onCompleted()
            }

            return Disposables.create {
                request?.task?.cancel()
            }

        }
    }
    
//    public static func rxRequest<T:Decodable>(_ urlConvertable:String,
//                                              _ method:RequestMethod = .get,
//                                              _ parameters:Any? = nil,
//                                              _ headers:[String:String] = [:],
//                                              _ encoding:EnocodingType = .json)->Observable<T>{
//
//        let request =  try? MNKRequest(to: urlConvertable,
//                                                 contentType.rawValue,
//                                                 method,
//                                                 headers,
//                                                 parameters,
//                                                 encoding)
//        return request!.performRx()
//            .map{data in
//                return try JSONDecoder().decode(T.self, from: data)
//        }.asObservable()
//    }
    
}

