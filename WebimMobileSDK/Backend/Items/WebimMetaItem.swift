//
//  WebimMeta.swift
//  webim-client-sdk-ios
//
//  Created by Anna Frolova on 15.09.2025.
//

final class WebimMetaItem {
    
    private var accountConfig: WebimEndpointItem?
    private var historyMobile: WebimEndpointItem?
    private var auth: WebimEndpointItem?
    private var info: WebimEndpointItem?
    
    enum JSONField: String {
        case historyMobile = "history_mobile"
        case accountConfig = "configs"
        case auth
        case info
        case endpoints
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let endpointsDictionary = jsonDictionary[JSONField.endpoints.rawValue] as? [String: Any?] {
            
            if let history = endpointsDictionary[JSONField.historyMobile.rawValue] as? [String: Any?] {
                self.historyMobile = WebimEndpointItem(jsonDictionary: history)
            }
            
            if let auth = endpointsDictionary[JSONField.auth.rawValue] as? [String: Any?] {
                self.auth = WebimEndpointItem(jsonDictionary: auth)
            }
            
            if let info = endpointsDictionary[JSONField.info.rawValue] as? [String: Any?] {
                self.info = WebimEndpointItem(jsonDictionary: info)
            }
            
            if let accountConfig = endpointsDictionary[JSONField.accountConfig.rawValue] as? [String: Any?] {
                self.accountConfig = WebimEndpointItem(jsonDictionary: accountConfig)
            }
        }
    }
    
    
    func getAccountConfigEndpoint() -> WebimEndpointItem? {
        return accountConfig
    }
    
    func getHistoryMobileEndpoint() -> WebimEndpointItem? {
        return historyMobile
    }
    
    func getAuthEndpoint() -> WebimEndpointItem? {
        return auth
    }
    
    func getInfoEndpoint() -> WebimEndpointItem? {
        return info
    }
}

final class WebimEndpointItem {
    private var url: String?
    private var metod: String?
    private var params: [String]?
    
    enum JSONField: String {
        case url
        case metod
        case params
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let url = jsonDictionary[JSONField.url.rawValue] as? String {
            self.url = url
        }
            
        if let params = jsonDictionary[JSONField.params.rawValue] as? [String] {
            self.params = params
        }
            
        if let metod = jsonDictionary[JSONField.metod.rawValue] as? String {
            self.metod = metod
        }
    }
    
    
    func getUrl() -> String? {
        return url
    }
    
    func getParams() -> [String]? {
        return params
    }
    
    func getMetod() -> String? {
        return metod
    }
}
