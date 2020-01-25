//
//  Json.swift
//  MNkCloudRequest
//
//  Created by Malith Nadeeshan on 6/2/18.
//  Copyright © 2018 Malith Nadeeshan. All rights reserved.
//

import Foundation

protocol MNkJsonDecodable{}

public struct Json{
    
    public var description:Any
    
    private var dic:[String:Any]{
        return description as? [String:Any] ?? [:]
    }

    public init(_ data:Data?) {
        guard let _data = data else{self.description = [:];return}
        do{
            self.description = try JSONSerialization.jsonObject(with: _data, options: .mutableContainers)
        }catch let err{
            self.description = [:]
            print("json encoding error: \(err.localizedDescription)")
        }
    }
    
    private init(_ data:Any) {
        self.description = data
    }
    
    
    
    public func data(in key:String)->Data{
        
        let _dict = dic.dictionaryValue(for: key)
        let decodeData:Data!
        do{
            
            decodeData = try JSONSerialization.data(withJSONObject: _dict, options: [])
            
        }catch let err{
            fatalError(err.localizedDescription)
        }
        return decodeData
    }
    
    public func stringVal(for key:String)->String{
        return dic[key] as? String ?? ""
    }
    public func intVal(for key:String)->Int{
        return dic[key] as? Int ?? 0
    }
    public func dictionaryValue(for key:String)->[String:Any]{
        return dic[key] as? [String:Any] ?? [:]
    }
    public func boolVal(for key:String)->Bool{
        return dic[key] as? Bool ?? false
    }
    public func nsArray(for key:String)->NSArray{
        return dic[key] as? NSArray ?? []
    }
    public func arraValue(for key:String)->[Json]{
        let array = dic[key] as? NSArray ?? []
        var jsonArray:[Json] = []
        for ob in array{
            jsonArray.append(Json(ob))
        }
        return jsonArray
    }
    
    public func arrayValues()->[Json]{
        let array = description as? NSArray ?? []
        var jsonAarray:[Json] = []
        for ob in array{
            jsonAarray.append(Json(ob))
        }
        return jsonAarray
    }
    
    public func doubleValue(for key:String)->Double{
        return dic[key] as? Double ?? 0.0
    }
    
}

public extension Dictionary where Key == String{
    func stringVal(for key:String)->String{
        return self[key] as? String ?? ""
    }
    func intVal(for key:String)->Int{
        return self[key] as? Int ?? 0
    }
    func dictionaryValue(for key:String)->[String:Any]{
        return self[key] as? [String:Any] ?? [:]
    }
    func boolVal(for key:String)->Bool{
        return self[key] as? Bool ?? false
    }
    func doubleValue(for key:String)->Double{
        return self[key] as? Double ?? 0.0
    }
    func nsArray(for key:String)->NSArray{
        return self[key] as? NSArray ?? []
    }
    func arrayValue(for key:String)->Array<Dictionary>{
        return self[key] as? [Dictionary] ?? []
    }
}
