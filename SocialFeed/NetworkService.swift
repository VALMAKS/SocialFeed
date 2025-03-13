import Alamofire

class NetworkService {
    static let shared = NetworkService()
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        let url = "https://jsonplaceholder.typicode.com/posts"
        
        AF.request(url).responseDecodable(of: [Post].self) { response in
            switch response.result {
            case .success(let posts):
                completion(.success(posts))
            case .failure(let error):
                print("❌ Ошибка загрузки: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
