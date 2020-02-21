//
//  MNKRequest.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation
import RxSwift
import RxCocoa

class MNKRequest {
    private let contentType:String
    private let method:RequestMethod
    private let url:UrlConvertable
    private var headers:[String:String] = [:]
    
    private var bodyParams:[RequestParams] = []
    
    private var request:URLRequest!

    var task:URLSessionDataTask?
    
    init(to url:UrlConvertable,_ contentType:String,_ method:RequestMethod,_ headers:[String:String] = [:],_ parameters:Any? = nil,_ encoding:EnocodingType)throws{
        self.url = url
        self.contentType = contentType
        self.method = method
        self.headers = headers
        self.headers[ "Content-Type"] = contentType
        self.headers["Accept"] = contentType
        
        bodyParams = EncodedParam.encode(parameters)
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
    
    
    
    func perform(completed:@escaping (Data?,HTTPURLResponse?,Error?)->Void){
        
        let session = URLSession.shared
        
        for header in headers{
            request.addValue(header.value, forHTTPHeaderField: header.key )
        }

        task = session.dataTask(with: request) { (data, response, err) in
            DispatchQueue.main.async {
                completed(data,response as? HTTPURLResponse,err)
            }
            }
        task?.resume()
    }
    
    func performRx()->Observable<Data>{
        let session = URLSession.shared
        
        for header in headers{
            request.addValue(header.value, forHTTPHeaderField: header.key )
        }
        
        return session.rx.data(request: request)
    }
    
//    func perform()->Observable<Data?>{
//        
//        return Observable<Data?>.create{observer in
//            for header in self.headers{
//                self.request.addValue(header.value, forHTTPHeaderField: header.key )
//            }
//            
//            let task = URLSession.shared.dataTask(with: self.request) { data, response, err in
//                observer.onNext(data)
//                observer.onCompleted()
//            }
//            
//            task.resume()
//            
//            return Disposables.create{
//                task.cancel()
//            }
//        }
//    }
}








