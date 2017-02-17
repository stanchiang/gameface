//
//  APIManager.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation
import ObjectMapper

class APIManager {
    
    fileprivate let session: URLSession
    
    fileprivate static var sharedInstance: APIManager = APIManager()
    
    fileprivate init(){
        session = URLSession.shared
    }
        

    class func getAuth(_ email: String, userId: String, redirectURL: String, orgId: Int, clientId: String, completion: @escaping (Result<Auth>) -> ()) {
        
        let params: [String : Any] = [
            
            "email": email ,
            "org_id": orgId,
            "user_id": userId,
            "grant_type": "sdk",
            "redirect_uri":redirectURL,
            "client_id": clientId
        ]
        
        makeRequest(Request(url: URLStore.tokenURL).setMethod(.POST).setData(.form(json: params))) { (result) in
            completion(mapResponse(result))
        }
    }
    
    
    
    class func getLayerAccessToken(_ nonce: String, userId: String, completion: @escaping (Result<String>) -> ()){
        
        makeRequest(Request(url: URLStore.layerTokenURL).setMethod(.POST).setData(.json(json: ["nonce": nonce, "userId": userId]))) { (result) in
            
            switch result {
            case .success(let response):
                if let json = response as? [String: Any], let token = json["identityToken"] as? String {
                    completion(.success(token))
                    return
                }
                fallthrough
            default:
                completion(.failure(DriftError.apiFailure))
            }
        }
    }
    
    class func getEmbeds(_ embedId: String, refreshRate: Int?, completion: @escaping (Result<Embed>) -> ()){
        
        guard let url = URLStore.embedURL(embedId, refresh: refreshRate) else {
            LoggerManager.log("Failure in Embed URL creation")
            return
        }
        
        makeRequest(Request(url: url).setMethod(.GET)) { (result) -> () in
            let response: Result<Embed> = mapResponse(result)
            completion(response)
        }
    }
    
    
    class func getUser(_ userId: Int, orgId: Int, authToken:String, completion: @escaping (Result<[CampaignOrganizer]>) -> ()) {
        
        guard let url = URLStore.campaignUserURL(orgId, authToken: DriftDataStore.sharedInstance.auth!.accessToken) else {
            LoggerManager.log("Failure in Campaign Organizer URL creation")
            return
        }
        
        let params: [String: Any] =
        [   "avatar_w": 102,
            "avatar_h": 102,
            "avatar_fit": "1",
            "access_token": authToken,
            "userId": userId
        ]
        
        makeRequest(Request(url: url).setMethod(.GET).setData(.url(params: params))) { (result) -> () in
            completion(mapResponse(result))
        }
        
    }
    
    class func getEndUser(_ endUserId: Int, authToken:String, completion: @escaping (Result<User>) -> ()){
        
        guard let url = URLStore.usersURL(endUserId, authToken: authToken) else {
            LoggerManager.log("Failure in User URL creation")
            return
        }
        
        makeRequest(Request(url: url).setMethod(.GET)) { (result) in
            completion(mapResponse(result))
        }
    }
    
    class func postIdentify(_ orgId: Int, userId: String, email: String, attributes: [String: Any]?, completion: @escaping (Result<User>) -> ()) {
        
        var params: [String: Any] = [
            "orgId": orgId,
            "userId": userId,
            "attributes": ["email": email]
        ]
        
        if var attributes = attributes {
            attributes["email"] = email
            params["attributes"] = attributes
        }
        
        makeRequest(Request(url: URLStore.identifyURL).setMethod(.POST).setData(.json(json: params))) { (result) -> () in
            completion(mapResponse(result))
        }
    }
    
    
    class func recordAnnouncement(_ conversationId: Int, authToken: String, response: AnnouncementResponse) {
        
        
        guard let url = URLStore.messagesURL(conversationId, authToken: authToken) else {
            LoggerManager.log("Failed in Messages URL Creation")
            return
        }
        
        let json: [String: Any] = [
            "type": "CONVERSATION_EVENT",
            "conversationEvent": ["type": response.rawValue]
        ]
    
        let request = Request(url: url).setData(.json(json: json)).setMethod(.POST)
        
        makeRequest(request) { (result) -> () in
            
            switch result {
            case .success(let json):
                LoggerManager.log("Record Annouincment Success: \(json)")
            case .failure(let error):
                LoggerManager.log("Record Announcement Failure: \(error)")
            }
        }
    }
    
    
    class func recordNPS(_ conversationId: Int, authToken: String, response: NPSResponse){
        
        
        guard let url = URLStore.messagesURL(conversationId, authToken: authToken) else {
            LoggerManager.log("Failed in Messages URL Creation")
            return
        }
        
        
        var attributes: [String: Any] = [:]
        
        
        switch response{
        case .dismissed:
            attributes = ["dismissed":true]
        case .numeric(let numeric):
            attributes = ["numericResponse":numeric]
        case .textAndNumeric(let numeric, let text):
            attributes = ["numericResponse":numeric, "textResponse": text]
        }
        
        let json: [String: Any] = [
            "type": "NPS_RESPONSE",
            "attributes": attributes
        ]
        
        let request = Request(url: url).setData(.json(json: json)).setMethod(.POST)
        
        makeRequest(request) { (result) -> () in
            
            switch result {
            case .success(let json):
                LoggerManager.log("Record NPS Success: \(json)")
            case .failure(let error):
                LoggerManager.log("Record NPS Failure: \(error)")
            }
        }
    }
    
    
    class func getConversations(_ endUserId: Int, authToken: String, completion: @escaping (_ result: Result<[Conversation]>) -> ()){
        
        
        guard let url = URLStore.conversationsURL(endUserId, authToken: authToken) else {
            LoggerManager.log("Failed in Conversations URL Creation")
            return
        }
        
        let request = Request(url: url).setMethod(.GET)
        
        makeRequest(request) { (result) -> () in
            
            switch result {
            case .success:
                let conversations: Result<[Conversation]> = mapResponse(result)
                completion(conversations)
            case .failure(let error):
                completion(.failure(DriftError.apiFailure))
                LoggerManager.log("Unable to get conversations for user: \(error)")
            }
        }
    }
    
   
    class func getMessages(_ conversationId: Int, authToken: String, completion: @escaping (_ result: Result<[Message]>) -> ()){
        
        
        guard let url = URLStore.messagesURL(conversationId, authToken: authToken) else {
            LoggerManager.log("Failed in Messages URL Creation")
            return
        }
        
        let request = Request(url: url).setMethod(.GET)
        
        makeRequest(request) { (result) -> () in
            
            switch result {
            case .success:
                let messages: Result<[Message]> = mapResponse(result)
                completion(messages)
            case .failure(let error):
                completion(.failure(DriftError.apiFailure))
                LoggerManager.log("Unable to get messages for conversation: \(error)")
            }
        }
    }
    
    
    class func postMessage(_ conversationId: Int, message: Message, authToken: String, completion: @escaping (_ result: Result<Message>) -> ()){
        
        
        guard let url = URLStore.messagesURL(conversationId, authToken: authToken) else {
            LoggerManager.log("Failed in Messages URL Creation")
            return
        }
        
        let json = message.toJSON()
        
        let request = Request(url: url).setData(.json(json: json)).setMethod(.POST)
        
        makeRequest(request) { (result) -> () in
            
            switch result {
            case .success:
                let messages: Result<Message> = mapResponse(result)
                completion(messages)
            case .failure(let error):
                completion(.failure(DriftError.apiFailure))
                LoggerManager.log("Unable to get messages for conversation: \(error)")
            }
        }

    }
    
    class func createConversation(_ body: String, authorId:Int?, authToken: String, completion: @escaping (_ result: Result<Message>) -> ()){
        
        
        guard let url = URLStore.createConversationURL(authToken) else {
            LoggerManager.log("Failed in Create Conversation URL Creation")
            return
        }
        
        let json: [String : Any] = ["body":body]
        
        let request = Request(url: url).setData(.json(json: json)).setMethod(.POST)
        
        makeRequest(request) { (result) -> () in
            
            switch result {
            case .success:
                let messages: Result<Message> = mapResponse(result)
                completion(messages)
            case .failure(let error):
                completion(.failure(DriftError.apiFailure))
                LoggerManager.log("Unable to get messages for conversation: \(error)")
            }
        }
        
    }
    
    class func downloadAttachmentFile(_ attachment: Attachment, authToken: String, completion: @escaping (_ result: Result<URL>) -> ()){
        guard let url = URLStore.downloadAttachmentURL(attachment.id, authToken: authToken) else {
            LoggerManager.log("Failed in Download Attachment URL Creation")
            return
        }
        
        sharedInstance.session.dataTask(with: url, completionHandler: { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                LoggerManager.log("API Complete: \(response.statusCode) \(response.url?.path ?? "")")
            }
            
            if let data = data, let directoryURL = DriftManager.sharedInstance.directoryURL {
                let fileURL = directoryURL.appendingPathComponent("\(attachment.id)_\(attachment.fileName)")
                do {
                    try data.write(to: fileURL, options: .atomicWrite)
                    completion(.success(fileURL))
                } catch {
                    completion(.failure(DriftError.dataCreationFailure))
                }
            }else{
                completion(.failure(DriftError.apiFailure))
            }
        }) .resume()
    }
    
    class func getAttachmentsMetaData(_ attachmentIds: [Int], authToken: String, completion: @escaping (_ result: Result<[Attachment]>) -> ()){
        
        guard let url = URLStore.getAttachmentsURL(attachmentIds, authToken: authToken) else {
            LoggerManager.log("Failed in Get Attachment Metadata URL Creation")
            return
        }
        
        let request = Request(url: url).setMethod(.GET)
        
        makeRequest(request) { (result) -> () in
            
            switch result {
            case .success:
                let attachments: Result<[Attachment]> = mapResponse(result)
                completion(attachments)
            case .failure(let error):
                completion(.failure(DriftError.apiFailure))
                LoggerManager.log("Unable to get attachments metadata: \(error)")
            }
        }
    }
    
    class func postAttachment(_ attachment: Attachment, authToken: String, completion: @escaping (_ result: Result<Attachment>) ->()){

        let boundary = "Boundary-\(UUID().uuidString)"
        let requestURL = URLStore.postAttachmentURL(authToken)
        
        let request = NSMutableURLRequest.init(url: requestURL!)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let multipartBody = NSMutableData()
        multipartBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        multipartBody.append("Content-Disposition: form-data; name=\"conversationId\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        multipartBody.append("\(attachment.conversationId)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        multipartBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        multipartBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        multipartBody.append("Content-Type: \(attachment.mimeType)\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        multipartBody.append(attachment.data as Data)
        multipartBody.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        multipartBody.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        request.httpBody = multipartBody as Data
        sharedInstance.session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                LoggerManager.log("API Complete: \(response.statusCode) \(response.url?.path ?? "")")
            }
            
            let accepted = [200, 201]
            
            if let response = response as? HTTPURLResponse, let data = data , accepted.contains(response.statusCode){
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] {
                        if let attachment: Attachment = Mapper<Attachment>().map(JSON: json){
                            DispatchQueue.main.async(execute: {
                                completion(.success(attachment))
                            })
                            return
                        }
                    }
                } catch {
                    print(request.httpBody)
                    print(response.statusCode)
                    DispatchQueue.main.async(execute: {
                        completion(.failure(DriftError.apiFailure))
                    })
                }
            }else if let error = error {
                DispatchQueue.main.async(execute: {
                    completion(.failure(error))
                })
            }else{
                DispatchQueue.main.async(execute: {
                    completion(.failure(DriftError.apiFailure))
                })
            }
            
        }) .resume()
    }
    
    /**
     Responsible for calling a request and parsing its response
     
     - parameter request: The request object to make the call
     - parameter completion: Completion Block called with result Object - AnyObject or nil
    */
    fileprivate class func makeRequest(_ request: Request, completion: @escaping (Result<Any>) -> ()) {
        
        sharedInstance.session.dataTask(with: request.getRequest(), completionHandler: { (data, response, error) -> Void in
            if let response = response as? HTTPURLResponse {
                LoggerManager.log("API Complete: \(response.statusCode) \(response.url?.path ?? "")")
            }

            let accepted = [200, 201]
            
            if let response = response as? HTTPURLResponse, let data = data , accepted.contains(response.statusCode){
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    DispatchQueue.main.async(execute: { 
                        completion(.success(json))
                    })
                } catch {
                    DispatchQueue.main.async(execute: {
                        completion(.failure(DriftError.apiFailure))
                    })
                }
            }else if let error = error {
                DispatchQueue.main.async(execute: {
                    completion(.failure(error))
                })
            }else{
                DispatchQueue.main.async(execute: {
                    completion(.failure(DriftError.apiFailure))
                })
            }
            
            }) .resume()
    }
    
    //Maps response to result T using ObjectMapper JSON parsing
    fileprivate class func mapResponse<T: Mappable>(_ result: Result<Any>) -> Result<T> {
        
        switch result {
        case .success(let res):
            if let json = res as? [String : Any] {
                let response = Mapper<T>().map(JSON: json)     ///If initialisation is done in if let this can result in getting an object back when nil is returned - This is a bug in swift
                if let response = response {
                    return .success(response)
                }
            }
            fallthrough
        default:
            return .failure(DriftError.apiFailure)
        }
    }
    
    //Maps response to result [T] using ObjectMapper JSON parsing
    fileprivate class func mapResponse<T: Mappable>(_ result: Result<Any>) -> Result<[T]> {
        
        switch result {
        case .success(let res):
            if let json = res as? [[String: Any]] {
                if let response: [T] = Mapper<T>().mapArray(JSONArray: json){
                    return .success(response)
                }
            }
            fallthrough
        default:
            return .failure(DriftError.apiFailure)
        }
    }
}

class URLStore{
    
    static let identifyURL = URL(string: "https://event.api.drift.com/identify")!
    static let layerTokenURL = URL(string: "https://customer.api.drift.com/layer/token")!
    static let tokenURL = URL(string: "https://customer.api.drift.com/oauth/token")!
    class func embedURL(_ embedId: String, refresh: Int?) -> URL? {

        let refreshString = Int(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double((refresh ?? 30000))))
        
        return URL(string: "https://js.drift.com/embeds/\(refreshString)/\(embedId).json")
    }
    
    class func campaignUserURL(_ orgId: Int, authToken: String) -> URL? {
        return URL(string: "https://customer.api.drift.com/organizations/\(orgId)/users?access_token=\(authToken)")
    }
        
    class func conversationsURL(_ endUserId: Int, authToken: String) -> URL? {
        return URL(string: "https://conversation.api.drift.com/conversations/end_users/\(endUserId)?access_token=\(authToken)")
    }
    
    class func messagesURL(_ conversationId: Int, authToken: String) -> URL? {
        return URL(string: "https://conversation.api.drift.com/conversations/\(conversationId)/messages?access_token=\(authToken)")
    }
    
    class func createConversationURL(_ authToken: String) -> URL? {
        return URL(string: "https://conversation.api.drift.com/messages?access_token=\(authToken)")
    }

    class func postAttachmentURL(_ authToken: String) -> URL? {
        return URL(string: "https://conversation.api.drift.com/attachments?access_token=\(authToken)")
    }
    
    class func downloadAttachmentURL(_ attachmentId: Int, authToken: String) -> URL? {
        return URL(string: "https://conversation.api.drift.com/attachments/\(attachmentId)/data?access_token=\(authToken)")
    }
    
    class func getAttachmentsURL(_ attachmentIds: [Int], authToken: String) -> URL? {
        var params = ""
        for id in attachmentIds{
            params += "&id=\(id)"
        }
        params += "&img_auto=compress"

        return URL(string: "https://conversation.api.drift.com/attachments?access_token=\(authToken)\(params)")
    }
    
    class func usersURL(_ userId: Int, authToken: String) -> URL? {
        return URL(string: "https://customer.api.drift.com/end_users/\(userId)?access_token=\(authToken)")
    }
}

///Result object for either Success with sucessfully parsed T
enum Result<T> {
    case success(T)
    case failure(Error)
}


private enum HeaderField: String {
    case Accept = "Accept"
    case ContentType = "Content-Type"
}

private enum HeaderValue: String {
    case ApplicationJson = "application/json"
    case FormURLEncoded = "application/x-www-form-urlencoded"
}

///Request Object to encompase API Requests
class Request {
    
    enum Method: String {
        case POST = "POST"
        case GET = "GET"
        case OPTIONS = "OPTIONS"
    }
    
    enum DataType {
        case url(params: [String: Any])
        case json(json: [String: Any])
        case form(json: [String: Any])

        
        func appendToRequest(_ request:NSMutableURLRequest) -> NSMutableURLRequest {
            
            switch self {
                
            case .url(let params):
                
                var url = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
                
                let queries = params.queryItems()
                
                url?.queryItems = queries
                
                request.url = url?.url
                
            case .json(let json):
                
                request.addValue(HeaderValue.ApplicationJson.rawValue, forHTTPHeaderField: HeaderField.Accept.rawValue)
                request.addValue(HeaderValue.ApplicationJson.rawValue, forHTTPHeaderField: HeaderField.ContentType.rawValue)
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
                    request.httpBody = jsonData
                } catch let error as NSError {
                    LoggerManager.log(error.localizedDescription)
                }
                
            case .form(let params):
                
                request.addValue(HeaderValue.FormURLEncoded.rawValue, forHTTPHeaderField: HeaderField.ContentType.rawValue)

                func query(_ parameters: [String: Any]) -> String {
                    var components: [(String, String)] = []
                    
                    for key in parameters.keys.sorted(by: <) {
                        let value = parameters[key]!
                        components += queryComponents(key, value)
                    }
                    
                    return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
                }

                if var URLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                    let percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(params)
                    URLComponents.percentEncodedQuery = percentEncodedQuery
                    request.url = URLComponents.url
                }
            }
            
            return request
        }
    }
    
    var dataType:DataType?
    var method: Method = .GET
    var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func setMethod(_ method: Method) -> Request {
        self.method = method
        return self
    }
    
    func setData(_ dataType: DataType) -> Request {
        self.dataType = dataType
        return self
    }
    
    func getRequest() -> URLRequest {
        
        var request = NSMutableURLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        if let dataType = dataType {
            request = dataType.appendToRequest(request)
        }
        
        return request as URLRequest
    }
}

/**
 Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
 
 - parameter key:   The key of the query component.
 - parameter value: The value of the query component.
 
 - returns: The percent-escaped, URL encoded query string components.
 */
func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
    var components: [(String, String)] = []
    
    if let dictionary = value as? [String: Any] {
        for (nestedKey, value) in dictionary {
            components += queryComponents("\(key)[\(nestedKey)]", value)
        }
    } else if let array = value as? [Any] {
        for value in array {
            components += queryComponents("\(key)[]", value)
        }
    } else {
        components.append((escape(key), escape("\(value)")))
    }
    
    return components
}

func escape(_ string: String) -> String {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    
    var allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! CharacterSet
    allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
    
    var escaped = ""
    
    if #available(iOS 8.3, OSX 10.10, *) {
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
    } else {
        let batchSize = 50
        var index = string.startIndex
        
        while index != string.endIndex {
            let startIndex = index
            if let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) { //(index, offsetBy: batchSize, limitedBy: string.endIndex)
                let range = startIndex..<endIndex
                
                let substring = string.substring(with: range)
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
    }
    
    return escaped
}

extension Dictionary {
    
    func queryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        for (key, value) in self {
            queryItems.append(URLQueryItem(name: String(describing: key), value: String(describing: value)))
        }
        return queryItems
    }
}
