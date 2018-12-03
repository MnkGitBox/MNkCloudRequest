//
//  BodyParameters.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation

class BodyParameters{
    
    struct BodyParam{
        var name:String
        var value:Any
        var isNextedValues:Bool = false
        
        init(_ name:String,_ value:Any) {
            self.name = name
            self.value = value
        }
    }
    
    private var bodyParams:[BodyParam]
    
    private var contentType:ContentType
    
    struct EncodingChar{
        static let seperatorAt:String = "&"
        static let seperatorComma = ","
        static let equalizer = "="
        static let signColon = ":"
    }
    
    init(_ parameters:[String:Any],_ contentType:ContentType) {
        bodyParams = []
        self.contentType = contentType
        append(parameters)
    }
    
    //Assign parameters to BodyParam Data type and add to [BodyParam].
    private func append(_ parameters:[String:Any]){
        for (key,value) in parameters{
            var bodyParam = BodyParam(key, value)
            if value is [Any]{bodyParam.isNextedValues = true}
            bodyParams.append(bodyParam)
        }
    }
    
    ///Encode parameters to data.
    func encode()throws->Data{
        
        guard !bodyParams.isEmpty else{return Data()}
        
        guard contentType == .formData else{
            return try encodeForJsonBody()
        }
        
        return try encodeForFormData()
    }
    
    //Encode normal type parameters without nexted parameters
    private func encode(_ name:String,
                        _ value:Any)throws->Data{
        
        var paramtext = "\(name)\(EncodingChar.equalizer)\(value)"
        paramtext = paramtext + EncodingChar.seperatorAt
        guard let paramData = paramtext.data(using: .utf8, allowLossyConversion: false)
            else{
                throw MNKCloudError.parametersEncodingFailed(reason:.dataEncodefail(error:paramtext))
        }
        return paramData
    }
    
    //Encode Parameters if have nexted parameter values
    private func encode(_ bodyParam:BodyParam)throws->Data{
        
        guard let serializeNextedVal = try? JSONSerialization.data(withJSONObject: bodyParam.value, options: .prettyPrinted)
            else{
                throw MNKCloudError.parametersEncodingFailed(reason:.dataEncodefail(error: "\(bodyParam.value)"))
        }
        guard let serializeNextedValText = String(data: serializeNextedVal, encoding: .utf8) else{throw MNKCloudError.jsonDecodingFailed(reason:.parameterDecodinFail(error: "\(bodyParam.value)"))}
        
        return try encode(bodyParam.name, serializeNextedValText)
    }
    
    //Encode body params for form type
    private func encodeForFormData()throws->Data{
        var encoded = Data()
        for bodyParam in bodyParams{
            do{
                let encodeData = bodyParam.isNextedValues ? try encode(bodyParam) : try encode(bodyParam.name, bodyParam.value)
                encoded.append(encodeData)
            }catch let err{
                throw err
            }
        }
        return encoded
    }
    
    //Encode for Json Body type
    private func encodeForJsonBody()throws->Data{
        var encoded = Data()
        let paramDic = Dictionary(uniqueKeysWithValues: bodyParams.map{($0.name,$0.value)})
        do{
            encoded = try JSONSerialization.data(withJSONObject: paramDic, options: .prettyPrinted)
        }catch let err{
            throw err
        }
        return encoded
    }
    
}
