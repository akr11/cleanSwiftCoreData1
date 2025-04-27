import Foundation
import UIKit

typealias Completion = ((Result<CartoonСharacters, Error>) -> Void)

protocol UserNetworkWorkerProtocol {
    func fetchUsers(completion: @escaping Completion)
}

struct Network {
    private let url = URL(string: "https://rickandmortyapi.com/api/character?page=3")

    func fatchCharacters(completion:  @escaping Completion) {
        let urlRequest = URLRequest(url: url ?? URL(fileURLWithPath: ""))
        let task = URLSession.shared.dataTask(
            with: urlRequest,
            completionHandler: { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                guard response.statusCode == 200 else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                guard let data = data else {
                    completion(.failure(URLError(.cannotDecodeContentData)))
                    return
                }

                do {
                    let characters = try? JSONDecoder().decode(CartoonСharacters.self, from: data)
                    guard let result = characters else {
                        return
                    }
                    completion(.success(result))
                }
            }
        )
        task.resume()
    }

    func loadImage(for url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(
            with: urlRequest,
            completionHandler: { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                guard response.statusCode == 200 else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    completion(.failure(URLError(.cannotDecodeContentData)))
                    return
                }

                completion(.success(image))
            }
        )
        task.resume()
    }
}
