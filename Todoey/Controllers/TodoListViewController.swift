//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Андрей Фроленков on 21.03.23.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    var itemArray = ["Find Mike", "Buy Eggos", "Destory Demogorgon"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsNavigationBar()
        settingsTableView()
        
        guard let array = defaults.array(forKey: "TodoListArray") as? [String] else { return }
        itemArray = array
    }
    
    
}

// MARK: - TableView Datasource Methods
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = itemArray[indexPath.row]
        cell.contentConfiguration = config
        
        return cell
    }
    
}

// MARK: - TableView Delegate Methods
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}


// MARK: - Settings TableView
extension TodoListViewController {
    
    private func settingsTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}


// MARK: - Settings NavigationBar
extension TodoListViewController {
    
    private func settingsNavigationBar() {
        
        title = "Todoey"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.5568627451, blue: 0.568627451, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItems))
        
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func addNewItems() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTF in
            alertTF.placeholder = "Create new item"
            textField = alertTF
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] action in
            guard let text = textField.text, text != "" else { return }
            self?.itemArray.append(text)
            self?.defaults.set(self?.itemArray, forKey: "TodoListArray")
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

// MARK: - Create UINavigationController
extension TodoListViewController {
    
    func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        return navigationController
    }
}

// MARK: - SwiftUI
import SwiftUI

struct TodoVCProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let navigationController = UINavigationController(rootViewController: TodoListViewController())
        
        func makeUIViewController(context: Context) -> some UINavigationController {
            return navigationController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
    
}




