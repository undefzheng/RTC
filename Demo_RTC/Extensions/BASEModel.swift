//
//  BASEModel.swift
//  rtc_demo
//
//  Created by apple on 2021/12/3.
//

import Foundation

struct BASEModel {
    
    //单独的字典（json）转模型
    static public func jsonToModel<T>(type:T.Type, json:Any) -> T? where T:Codable {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return nil
        }
        guard let model = try? JSONDecoder.init().decode(type, from: jsonData) else {
            return nil
        }
        return model
    }
    
    //json数组转模型数组
    static public func jsonToModel<T>(type:T.Type, array:[[String:Any]]) -> [T]? where T:Codable {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted) else {
            return nil
        }
        guard let result = try? JSONDecoder.init().decode([T].self, from: jsonData) else {
            return nil
        }
        return result
    }
    
    //单个模型转json字符串
    public static func modelToJson<T>(toString model:T) -> String? where T:Encodable {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(model)else{
            return nil
        }
        guard let jsonStr = String(data: data, encoding: .utf8)else{
            return nil
        }
        return jsonStr
    }
    
    //单个模型转json字典
    public static func modelToJson<T>(toDictionary model:T) -> [String:Any]? where T:Encodable{

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(model) else {
            return nil
        }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)as? [String:Any] else {
            return nil
        }
        return dict
    }

}
