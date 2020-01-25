//
//  MNKCloudError.swift
//  MNkCloudRequest
//
//  Created by MNk_Dev on 1/11/18.
//

import Foundation

public enum MNKCloudError:Error{
    
    public enum ParameterEncodingFail{
        case jsonEncodingfail(error:String)
        case dataEncodefail(error:String)
        case keyValueEncodingFaile(error:String)
    }
    
    public enum JsonDecodingReasons{
        case parameterDecodinFail(error:String)
    }
    
    case invalidURl(url: UrlConvertable)
    case parametersEncodingFailed(reason:ParameterEncodingFail)
    case jsonDecodingFailed(reason:JsonDecodingReasons)
    case noInternet(error:String)
    case uploadErro(error:String)
}

extension MNKCloudError{
    public var UrlConvertable:UrlConvertable?{
        switch self{
        case .invalidURl(let url):
            return url
        default:return nil
        }
    }
}

extension MNKCloudError:LocalizedError{
    public var errorDescription:String?{
        switch self{
        case .invalidURl(let url):
            return "Invalid string to conver url : \(url)"
        case .jsonDecodingFailed(let reason):
            return reason.localizedDescription
        case .parametersEncodingFailed(let reason):
            return reason.localizedDescription
        case .noInternet(let err):
            return err
        case .uploadErro(let err):
            return err
        }
    }
}

extension MNKCloudError.ParameterEncodingFail{
    public var localizedDescription:String{
        switch self{
        case .dataEncodefail(let aditionalReason):
            return "Failed to encode data : \(aditionalReason)"
        case .jsonEncodingfail(let aditionalData):
            return "Failed to encode json :\(aditionalData)"
        case .keyValueEncodingFaile(let aditionalData):
            return "Couldn't find Key:Value fair from given parameters -> \(aditionalData)"
        }
    }
}

extension MNKCloudError.JsonDecodingReasons{
    public var localizedDescription:String{
        switch self{
        case .parameterDecodinFail(let parametertext):
            return "Failed to decode json to text of :\(parametertext)"
        }
    }
}
