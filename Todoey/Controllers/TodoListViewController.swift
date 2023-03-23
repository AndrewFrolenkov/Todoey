//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Андрей Фроленков on 21.03.23.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()
    
    var categories : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
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
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        
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

// MARK: - Settings UISearchController
extension TodoListViewController {
    
    func createSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        //        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.5568627451, blue: 0.568627451, alpha: 1)
        
        return searchController
    }
}

// MARK: - SearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        if let text = searchBar.text {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
            
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            self.loadItems()
            
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
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.5568627451, blue: 0.568627451, alpha: 1)
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
            
            if let context = self?.context {
                let item = Item(context: context)
                item.title = text
                item.done = false
                item.parentCategory = self?.categories
                self?.itemArray.append(item)
                
                self?.saveItems()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
            
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func saveItems() {
        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predictate: NSPredicate? = nil) {
        
        if let categories = categories?.name, let predictate = predictate {
            let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", categories)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predictate])
            request.predicate = compoundPredicate
        } else {
            if let categories = categories?.name {
                request.predicate = NSPredicate(format: "parentCategory.name MATCHES %@", categories)
            } else {
                print("Error")
            }
        }
        
        do {
            let item = try context.fetch(request)
            self.itemArray = item
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
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




