//
//  Cloud.swift
//  BS Bingo
//
//  Created by Per Friis on 19/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class Cloud: NSObject {
    /// completion block for async calls to cloud
    /// - Parameters:
    ///     - success: Flag to indicate the success of the call
    ///     - obj: an object relevant to the call
    ///     - error: If the result have an error it is here
    typealias CloudCompleteBlock = (_ success:Bool, _ obj:Any?, _ error:Error? ) -> (Void)
    
    let authorization = "Authorization"
    static let shared = Cloud()
    
    /// current authentication for user
    var authentication: String?
    var tokenExpire: Date = Date()
    
    /// current authentication for API
    var apiAuthentication: String?
    var apiTokenExpire: Date = Date()
    
    /// persisted user name
    var username:String? {
        get {
            return UserDefaults.standard.string(forKey: "username")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "username")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// persisted user password
    var password:String? {
        get {
            return UserDefaults.standard.string(forKey: "password")
        }
        set {
            UserDefaults.standard.set(newValue, forKey:"password")
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate let apiUrl = URL(string: "https://bsbingo.azurewebsites.net")!
    
    /// Get all the words in the database
    /// - Parameters:
    ///     - language: the language to fetch words from, default "en"
    ///     - persistentContainer: The persistenContainer to get the datacontext
    ///     - completion: Completion block, _obj:_ is not used in this call
    func getWords(language:String = "en", persistentContainer: NSPersistentContainer, completion:@escaping CloudCompleteBlock) {
        print(#function)
        systemLogin { (success) -> (Void) in
            guard success else {
                completion(false,nil,nil)
                return
            }
            
            
            
            guard var urlComponents = URLComponents(url: self.apiUrl.appendingPathComponent("words"), resolvingAgainstBaseURL: false) else {
                completion(false,nil,nil)
                return
            }
            
            urlComponents.queryItems = [URLQueryItem(name: "search", value: "language eq \(language)")]
            
            var urlRequest = URLRequest(url: urlComponents.url!)
            urlRequest.addValue(self.apiAuthentication!, forHTTPHeaderField: self.authorization)
            
            let urlsession = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else {
                    completion(false, nil, error)
                    return
                }
                
                guard [200].contains((response as! HTTPURLResponse).statusCode) else {
                    completion(false, response as! HTTPURLResponse, nil)
                    return
                }
                
                guard let data = data else {
                    completion(false, nil, nil)
                    return
                }
                
                
                let decoder = JSONDecoder()
                do {
                    let bsWordsDTO = try decoder.decode(BSWordsDTO.self, from: data)
                    
                    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                    
                    persistentContainer.performBackgroundTask({ (context) in
                        for bsWordDTO in bsWordsDTO.value {
                            let bsword = BSWord.find(link: bsWordDTO.href, context: context) ?? BSWord(context: context)
                            
                            bsword.dto = bsWordDTO
                        }
                        
                        do {
                            try context.save()
                            completion(true,nil,nil)
                        } catch {
                            print(error)
                            completion(false,nil,error)
                            return
                        }
                    })
                } catch {
                    completion(false,nil, error)
                    print(error.localizedDescription)
                }
            }
            urlsession.resume()
        }
    }
    
    
    /// Get all categories and save to database
    /// - Parameters:
    ///     - language: the language to fetch words from, default "en"
    ///     - persistentContainer: The persistenContainer to get the datacontext
    ///     - completion: Completion block, _obj:_ is not used in this call
    func getCategories(language:String = "en", persistentContainer: NSPersistentContainer, completion:@escaping CloudCompleteBlock) {
        print(#function)
        systemLogin { (suscess) -> (Void) in
            guard suscess else {
                completion(false,nil,nil)
                return
            }
            
            
            guard var urlComponents = URLComponents(url: self.apiUrl.appendingPathComponent("words").appendingPathComponent("categories"), resolvingAgainstBaseURL: false) else {
                completion(false,nil,nil)
                return
            }
            
            urlComponents.queryItems = [URLQueryItem(name: "search", value: "language eq \(language)")]
            
            var urlRequest = URLRequest(url: urlComponents.url!)
            urlRequest.addValue(self.apiAuthentication!, forHTTPHeaderField: self.authorization)
            
            let urlsession = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else {
                    completion(false, nil, error)
                    return
                }
                
                guard [200].contains((response as! HTTPURLResponse).statusCode) else {
                    completion(false, response as! HTTPURLResponse, nil)
                    return
                }
                
                guard let data = data else {
                    completion(false, nil, nil)
                    return
                }
                
                
                let decoder = JSONDecoder()
                do {
                    let categoriesDTO = try decoder.decode(CategoriesDTO.self, from: data)
                    
                    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                    
                    for category in categoriesDTO.value {
                        print(category)
                    }
                    
                    persistentContainer.performBackgroundTask({ (context) in
                        for name in categoriesDTO.value {
                            guard Category.find(name: name, context: context) == nil  else {
                                continue
                            }
                            
                            let category = Category(context: context)
                            category.name = name
                            
                        }
                        do {
                            try context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                } catch {
                    completion(false,nil, error)
                    print(error.localizedDescription)
                }
            }
            urlsession.resume()
        }
    }
}



// MARK: -
// MARK: User handling
/// User handling
extension Cloud {
    /// registre a new user to the backend
    /// - Parameters:
    ///     - userDTO: the user information to registre
    ///     - completion: Completion block, _obj:_ is not used in this call
    func registreUser(userDTO:RegistreUserDTO, complete: @escaping CloudCompleteBlock) {
        print(#function)
        
            var request = URLRequest(url: self.apiUrl.appendingPathComponent("users"))
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(self.apiAuthentication!, forHTTPHeaderField: self.authorization)
            
            request.httpMethod = "POST"
            
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(userDTO)
                
            } catch {
                complete(false,nil,error)
                return
            }
            
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    complete(false,nil,error)
                    return
                }
                
                guard [201].contains((response as! HTTPURLResponse).statusCode) else {
                    complete(false,(response as! HTTPURLResponse),nil)
                    return
                }
                
                self.username = userDTO.email
                self.password = userDTO.password
                
                complete(true,(response as! HTTPURLResponse).allHeaderFields["Location"],nil);
            }
            
            dataTask.resume()
    }
    
    
    /// Login to the backend, if the user is the same user as previously and the token is valid
    /// the function returns a success with no object and no error
    /// - Parameters:
    ///     - username: user to login
    ///     - password: and the password
    ///     - completion: Completion block, _obj:_ can contain the returned data if any
    func login(username:String, password:String, complete: @escaping CloudCompleteBlock) {
        // check if the user is already logged in
        if authentication != nil,
            tokenExpire.timeIntervalSinceNow > 0,
            username == self.username,
            password == self.password {
            
            complete(true, nil, nil)
        }
        
        
        let url = apiUrl.appendingPathComponent("token")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        request.encodeParameters(parameters: ["grant_type":"password","username": username, "password": password])
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error
            ) in
            guard error == nil else {
                complete(false,data, error)
                return
            }
            
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                complete(false,(response as! HTTPURLResponse), nil)
                
                self.username = nil
                self.password = nil
                
                return
            }
            
            guard let data = data else {
                complete(false, "no data in response",nil)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let authToken = try jsonDecoder.decode(AuthTokenDTO.self, from: data)
                self.authentication = "\(authToken.tokenType) \(authToken.accessToken)"
                self.tokenExpire = Date.init(timeIntervalSinceNow: authToken.expiresIn)
                
                self.username = username
                self.password = password
                
                
            } catch {
                complete(false, data, error)
            }
            
            
            complete(true,data,nil)
        }
        
       task.resume()
    }
    
    /// Get all the words in the database
    /// - Parameters:
    ///     - language: the language to fetch words from, default "en"
    ///     - persistentContainer: The persistenContainer to get the datacontext
    ///     - completion: Completion block, _obj:_ is not used in this call
    func getUserInfo( complete: @escaping CloudCompleteBlock) {
        guard let username = self.username, let password = self.password else {
            complete(false,nil,nil)
            return
        }
        
        login(username: username, password: password) { (success, obj, error) -> (Void) in
            guard success else { return }
            
            let url = self.apiUrl.appendingPathComponent("userinfo")
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.authentication!, forHTTPHeaderField: self.authorization)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error
                ) in
                guard error == nil else {
                    complete(false,data, error)
                    return
                }
                
                guard (response as! HTTPURLResponse).statusCode == 200 else {
                    complete(false,(response as! HTTPURLResponse), nil)
                    return
                }
                
                guard let data = data else {
                    complete(false, "no data in response",nil)
                    return
                }
                
                do {
                    let jsonDecoder = JSONDecoder()
                    let userinfoDTO = try jsonDecoder.decode(UserInfoDTO.self, from: data)
                    complete(true,userinfoDTO,nil)
                } catch {
                    complete(false, data, error)
                }
                complete(true,data,nil)
            }
            task.resume()
        }
    }
    
    
    
    
    /// Get a API token to the backend for system validation
    /// the function returns a success with no object and no error
    /// - Parameter complete: Completion block, _obj:_ is not used in this call
    func systemLogin(complete: @escaping (_ success:Bool) -> (Void)) {
        print("systemLogin")
        // check if the user is already logged in
        if apiAuthentication != nil,
            apiTokenExpire.timeIntervalSinceNow > 0 {
            complete(true)
        }
        
        
        let url = apiUrl.appendingPathComponent("token")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        request.encodeParameters(parameters: ["grant_type":"password","username": "api@friismobility.com", "password": "Ub?r)um2%NPZMazakG9cwf8G"])
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error
            ) in
            guard error == nil else {
                complete(false)
                return
            }
            
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                complete(false)
                
                return
            }
            
            guard let data = data else {
                complete(false)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let authToken = try jsonDecoder.decode(AuthTokenDTO.self, from: data)
                self.apiAuthentication = "\(authToken.tokenType) \(authToken.accessToken)"
                self.apiTokenExpire = Date.init(timeIntervalSinceNow: authToken.expiresIn)
                 complete(true)
                
            } catch {
                complete(false)
            }
        }
        
        task.resume()
    }
    
    
}

extension URLRequest {
    private func percentEscapeString(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }
    
    mutating func encodeParameters(parameters: [String : String]) {
        httpMethod = "POST"
        
        let parameterArray = parameters.map { (arg) -> String in
            let (key, value) = arg
            return "\(key)=\(self.percentEscapeString(value))"
        }
        httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
    
    
}






