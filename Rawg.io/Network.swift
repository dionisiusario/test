//
//  Networking.swift
//  Rawg.io
//
//  Created by MNC Insurance 1 on 22/05/24
//

import Foundation
import Alamofire

enum GameError:Error{
  case NoData
  case DataCannotBeReached
}
struct Network{
  static let sharedInstance = Network()
  let session = URLSession.shared
  let key = "401e898599c74ee69e7b821f48226647"
  let baseURL = "https://api.rawg.io/api/games"
  
  func getListGame(page: Int, completion: @escaping(Result<Game,GameError>)->Void) {
    let listURL = "\(baseURL)?key=\(key)"
    let listGameURL = URL(string: "\(listURL)&page=\(page)")!
    
    AF.request(listGameURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil)
      .response{ resp in
        switch resp.result{
        case .success(let data):
          
          guard let data = data else{
            completion(.failure(.NoData))
            return
          }
          do{
            let jsonData = try JSONDecoder().decode(Game.self, from: data)
            print(jsonData)
            completion(.success(jsonData))
          } catch {
            print(error.localizedDescription)
            
          }
        case .failure(let error):
          print(error.localizedDescription)
          completion(.failure(.DataCannotBeReached))
        }
      }
  }
  
  
  
  func getDetailGame(id: Int, completion: @escaping(Result<Details,GameError>)->Void) {
    let listURL = "\(baseURL)/\(id)?key=\(key)"
    let detailGameURL = URL(string: "\(listURL)")!
    AF.request(detailGameURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil)
      .response{ resp in
        switch resp.result{
        case .success(let data):
          
          guard let data = data else{
            completion(.failure(.NoData))
            return
          }
          
          do{
            let jsonData = try JSONDecoder().decode(Details.self, from: data)
            completion(.success(jsonData))
          } catch {
            print(error.localizedDescription)
            
          }
        case .failure(let error):
          print(error.localizedDescription)
          completion(.failure(.DataCannotBeReached))
        }
      }
  }
  
  func getGameFromQR(url: String, completion: @escaping(Result<Details,GameError>)->Void) {
    let detailGameURL = URL(string: "\(url)")!
    AF.request(detailGameURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil)
      .response{ resp in
        switch resp.result{
        case .success(let data):
          
          guard let data = data else{
            completion(.failure(.NoData))
            return
          }
          
          do{
            let jsonData = try JSONDecoder().decode(Details.self, from: data)
            print(jsonData)
            completion(.success(jsonData))
          } catch {
            print(error.localizedDescription)
            
          }
        case .failure(let error):
          print(error.localizedDescription)
          completion(.failure(.DataCannotBeReached))
        }
      }
  }
  
  
}

