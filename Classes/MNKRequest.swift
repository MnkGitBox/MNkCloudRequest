//
//  MNKRequest.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation

class MNKRequest {
    
    private let data:Data
    private let contentType:String
    private let method:RequestMethod
    private let url:UrlConvertable
    private var headers:[String:String] = [:]
    
    init(to url:UrlConvertable,_ data:Data,_ contentType:String,_ method:RequestMethod) {
        self.url = url
        self.data = data
        self.contentType = contentType
        self.method = method
        
        self.headers[ "Content-Type"] = contentType
        self.headers["Accept"] = contentType
    }
    
    func perform(completed:@escaping (Data?,HTTPURLResponse?,String?)->Void){
        
        guard let _url = try? url.getURL() else{
            completed(nil,nil,MNKCloudError.invalidURl(url: url).localizedDescription)
            return
        }
        
        var request = URLRequest(url: _url)
        request.httpMethod = method.rawValue
        request.httpBody = data
        
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
