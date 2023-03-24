//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Андрей Фроленков on 21.03.23.
//

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var categories : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsNavigationBar()
        settingsTableView()

        
    }
}

// MARK: - TableView Datasource Methods
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let n1 = numberFormatter(text: categories?.color[0].hue ?? "")
        let n2 = numberFormatter(text: categories?.color[0].saturation ?? "")
        let n3 = numberFormatter(text: categories?.color[0].brightness ?? "")
        
        if let item = todoItems?[indexPath.row] {
            let alpha = CGFloat(indexPath.row) / CGFloat(todoItems!.count)
            let color = UIColor(hue: n1 , saturation: n2 , brightness: n3 , alpha: alpha)
            var config = cell.defaultContentConfiguration()
            config.text = item.title
            config.textProperties.color = .black
            cell.contentConfiguration = config
            
            
           
            cell.backgroundColor = color
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            var config = cell.defaultContentConfiguration()
            config.text = "No items added"
            cell.contentConfiguration = config
        }
        
//        cell.backgroundColor = UIColor(hue: n1 , saturation: n2 , brightness: n3 , alpha: 1)
        
        
        
        
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func numberFormatter(text: String) -> CGFloat {
        let str = text
        if let n = NumberFormatter().number(from: str) {
            let f = CGFloat(truncating: n)
            return f
        }
        return 0
    }
    
}

// MARK: - TableView Delegate Methods
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print(error.localizedDescription)
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let categories = categories else { return UISwipeActionsConfiguration()}
        
        let action = UIContextualAction(style: .destructive,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            do {
                try self?.realm.write {
                    self?.realm.delete(categories.items[indexPath.row])
                }
            } catch {
                print(error.localizedDescription)
            }
            tableView.reloadData()
            
            completionHandler(true)
        }
        action.image = UIImage(systemName: "basket")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}


// MARK: - Settings TableView
extension TodoListViewController {
    
    private func settingsTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

// MARK: - Settings UISearchController
extension TodoListViewController {
    
    func createSearchController() -> UISearchController {
        
        let n1 = numberFormatter(text: categories?.color[0].hue ?? "")
        let n2 = numberFormatter(text: categories?.color[0].saturation ?? "")
        let n3 = numberFormatter(text: categories?.color[0].brightness ?? "")
        let color = UIColor(hue: n1 , saturation: n2 , brightness: n3 , alpha: 1)
        
        let searchController = UISearchController(searchResultsController: nil)
//                searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.backgroundColor = color
        
        return searchController
    }
}

// MARK: - SearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: true)
            
            tableView.reloadData()
        }
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            print("WOW")
            self.loadItems()
            
            tableView.reloadData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}

// MARK: - Settings NavigationBar
extension TodoListViewController {
    
    private func settingsNavigationBar() {
        
        title = "Items"
        
        let n1 = numberFormatter(text: categories?.color[0].hue ?? "")
        let n2 = numberFormatter(text: categories?.color[0].saturation ?? "")
        let n3 = numberFormatter(text: categories?.color[0].brightness ?? "")
        let color = UIColor(hue: n1 , saturation: n2 , brightness: n3 , alpha: 1)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItems))
        
        
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = barButtonItem
        navigationItem.searchController = createSearchController()
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
            
            let newItem = Item()
            newItem.title = text
            newItem.dateCreated = Date()
            
            
            self?.saveItems(item: newItem)
            
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func saveItems(item: Item) {
       
        do {
            try realm.write({
                categories?.items.append(item)     
            })
        } catch {
            print(error.localizedDescription)
        }
        
        self.tableView.reloadData()
    }
    
    private func loadItems() {
        
        todoItems = categories?.items.sorted(byKeyPath: "title", ascending: true)
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




