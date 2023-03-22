//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Андрей Фроленков on 21.03.23.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(component: "Items.plist")
    
    var itemArray = [ItemModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsNavigationBar()
        settingsTableView()
       
        loadItems()
        
        
    }
    
    
}

// MARK: - TableView Datasource Methods
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        cell.contentConfiguration = config
        
        cell.accessoryType = item.done ? .checkmark : .none
       
        
        return cell
    }
    
}

// MARK: - TableView Delegate Methods
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.reloadData()
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
            let item = ItemModel(title: text)
            self?.itemArray.append(item)
            
            self?.saveItems()
                        
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            if let dataFilePath = dataFilePath {
                try data.write(to: dataFilePath)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadItems() {
        do {
            if let dataFilePath = dataFilePath {
                let data = try Data(contentsOf: dataFilePath)
                let decoder = PropertyListDecoder()
                let itemArray = try decoder.decode([ItemModel].self, from: data)
                self.itemArray = itemArray
            }
        } catch {
            print(error.localizedDescription)
        }
        
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




