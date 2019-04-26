//
//  BodyParameters.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation

class BodyParameters{
    
    //Paramaeter Model
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
    
    private var parameters:Any?
    
    private var contentType:ContentType
    
    struct EncodingChar{
        static let seperatorAt:String = "&"
        static let seperatorComma = ","
        static let equalizer = "="
        static let signColon = ":"
    }
    
    init(_ parameters:Any?,_ contentType:ContentType) {
        bodyParams = []
        self.contentType = contentType
        self.parameters = parameters
    }
    
    //initalize body parameters array for help mutipart data
    private func initBodyParam(){
        guard let paramDic = parameters as? [String:Any] else{return}
        append(paramDic)
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
    func encode()throws->Data?{
        
        guard contentType == .formData else{
            return try encodeForJsonBody()
        }
        
        //Do body paramaeters encoding func for multipart form data
        initBodyParam()
        guard !bodyParams.isEmpty else{return nil}
        
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
    private func encodeForJsonBody()throws->Data?{
        var encoded:Data?
        do{
            guard let _parameter = parameters else{return encoded}
            encoded = try JSONSerialization.data(withJSONObject: _parameter, options: .prettyPrinted)
            return encoded
        }catch let err{
            throw err
        }
    }
    
}
