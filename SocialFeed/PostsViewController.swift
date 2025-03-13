import UIKit

class PostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var posts: [Post] = []
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "SocialFeed"
        
        
        setupGradientBackground()
        setupTableView()
        fetchData()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center
        let textAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

    // Настройка таблицы
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }

    // Загрузка данных
    func fetchData() {
        loadingIndicator.startAnimating()
        
        self.posts = CoreDataManager.shared.fetchSavedPosts()
        self.tableView.reloadData()
        
        NetworkService.shared.fetchPosts { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let posts):
                    self.posts = posts
                    CoreDataManager.shared.context.perform {
                        for post in posts {
                            CoreDataManager.shared.savePost(post)
                        }
                    }
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.showErrorAlert(message: "Ошибка загрузки данных: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func refreshData() {
        NetworkService.shared.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.tableView.refreshControl?.endRefreshing()

                switch result {
                case .success(let posts):
                    self.posts = posts
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.showErrorAlert(message: "Ошибка обновления: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    func setupGradientBackground() {
        let gradientView = UIView(frame: view.bounds)
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.systemBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = gradientView.bounds
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configure(with: post)
        cell.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut, animations: {
            cell.alpha = 1
        })
        return cell
    }
}
