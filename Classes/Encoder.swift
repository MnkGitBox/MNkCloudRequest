//
//  Encoder.swift
//  MNkCloudRequest
//
//  Created by Malith Nadeeshan on 6/13/19.
//

import Foundation

/*.......................................................................
 MARK:- Create request for normal parameter process - only added url param
 ........................................................................*/
struct RequestForNormal{
    static func build(for url:URL,_ method:RequestMethod,with params:[RequestParams])throws->URLRequest{
        var urlComponent = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
        let precentageEncQuery = try EncodeQueryString.encode(of: params)
        urlComponent?.percentEncodedQuery =  precentageEncQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        var request = URLRequest(url: urlComponent!.url! )
        request.httpMethod = method.rawValue
        return request
    }
}
/*.......................................................................
 MARK:- Create request for encoding form the data presentation
 ........................................................................*/
struct RequestForFormData{
    static func build(for url:URL,_ method:RequestMethod,with params:[RequestParams])throws->URLRequest{
        var request = URLRequest(url: url )
        request.httpMethod = method.rawValue
        request.httpBody = (try EncodeQueryString.encode(of: params)).data(using: .utf8)
        return request
    }
}
/*.......................................................................
 MARK:- Create request for JSON type encoding
 ........................................................................*/
struct RequestForJsonData{
    //Encode for Json Body type
    static func build(of url:URL,_ method:RequestMethod,with params:Any?)throws->URLRequest{
        do{
            var request = URLRequest(url: url )
            request.httpMethod = method.rawValue
            
            guard let _parameter = params else{
                return request
            }
            
            let encoded = try JSONSerialization.data(withJSONObject: _parameter, options: .prettyPrinted)
            request.httpBody = encoded
            return request
            
        }catch let err{
            throw err
        }
    }
}

/*...................................
 MARK:- Build request for upload step
 .............................................*/
struct RequestForUpload{
    static func build(of url:URL,_ method:RequestMethod,with params:Any?)throws->URLRequest{
        guard let multipartData = params as? MultipartFormData else{
            throw MNKCloudError.parametersEncodingFailed(reason:.dataEncodefail(error: "No Encodable Url in request"))
        }
        var request = URLRequest(url: url )
        request.httpMethod = method.rawValue
        request.httpBody = multipartData.encode()
        return request
    }
}

/*.......................................................................
 MARK:- Parameters encode for identified type ResponseParam,
 This mainly for encode paramters for form data and normal utl type data
 ........................................................................*/
struct EncodedParam{
    static func encode(_ parameters:Any?)->[RequestParams]{
        guard let paramDic = parameters as? [String:Any] else{
            return []
        }
        return append(paramDic)
    }
    
    //Assign parameters to BodyParam Data type and add to [BodyParam].
    private static func append(_ parameters:[String:Any])->[RequestParams]{
        var bodyParams:[RequestParams] = []
        for (key,value) in parameters{
            var bodyParam = RequestParams(key, value)
            if value is [Any]{bodyParam.isNextedValues = true}
            bodyParams.append(bodyParam)
        }
        return bodyParams
    }
}



/*.......................................................................
 MARK:- Encode paramters value for saver identified format of string
 ........................................................................*/
struct EncodeQueryString{
    //Encode body params for form type
    static func encode(of bodyParams:[RequestParams])throws->String{
        var encoded:String = ""
        for bodyParam in bodyParams{
            do{
                let encodeData = bodyParam.isNextedValues ? try self.encode(bodyParam) : try encode(bodyParam.name, bodyParam.value)
                encoded.append(encodeData)
            }catch let err{
                throw err
            }
        }
        return encoded
    }
    
    //Encode Parameters if have nexted parameter values
    private static func encode(_ bodyParam:RequestParams)throws->String{
        
        guard let serializeNextedJson = try? JSONSerialization.data(withJSONObject: bodyParam.value, options: .prettyPrinted)
            else{
                throw MNKCloudError.parametersEncodingFailed(reason:.dataEncodefail(error: "\(bodyParam.value)"))
        }
        return try encode(bodyParam.name, serializeNextedJson)
    }
    
    //Encode normal type parameters without nexted parameters
    private static func encode(_ name:String,
                               _ value:Any)throws->String{
        
        var paramtext = "\(name)\(EncodingChar.equalizer)\(value)"
        paramtext = paramtext + EncodingChar.seperatorAt
        return paramtext
    }
}
