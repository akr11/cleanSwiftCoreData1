import Foundation

//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)


// MARK: - Welcome
struct CartoonСharacters: Codable {
    let info: Info
    let results: [CharResult]
}

// MARK: - Info
struct Info: Codable {
    let count, pages: Int
    let next, prev: String
}

// MARK: - Result
struct CharResult: Codable {
    let id: Int
    let name: String
    let status: Status
    let species, type: String
    let gender: Gender
    let origin, location: Location
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
    case unknown = "unknown"
}

// MARK: - Location
struct Location: Codable {
    let name: String
    let url: String
}

enum Status: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}
