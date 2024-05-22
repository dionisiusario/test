

import Foundation

struct Game: Codable {
    let count: Int
    let next, previous: String?
    var results: [Results]
  
  enum CodingKeys: String, CodingKey {
    case count, next, previous, results
  }
}

struct Results: Codable {
    let id: Int?
    let slug, name, released : String?
    let tba: Bool?
    let rating, rating_top: Double?
    let backgroundImage: String?

    enum CodingKeys: String, CodingKey {
        case id, slug, name, released, tba, rating, rating_top
        case backgroundImage = "background_image"
    }
}

struct Details: Codable {
    let id: Int?
    let name, description: String?
    let released: String?
    let backgroundImage, website: String?
    let rating, rating_top: Double?

    enum CodingKeys: String, CodingKey {
        case id, name
        case description
        case released = "released_at"
        case backgroundImage = "background_image"
        case website, rating, rating_top
    }
}
