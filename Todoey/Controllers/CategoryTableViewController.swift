//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Андрей Фроленков on 23.03.23.
//

import Foundation
import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsNavigationBar()
        settingsTableView()
        
        loadCategories()
    
    }
    
}

// MARK: - TableView Datasource Methods
extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)
        
        let category = categories[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = category.name
        cell.contentConfiguration = config
        
//        cell.accessoryType = item.done ? .checkmark : .none
        
        
        return cell
    }
    
}

// MARK: - TableView Delegate Methods
extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let controller = TodoListViewController()
        controller.categories = categories[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
        saveCategories()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

// MARK: - Settings NavigationBar
extension CategoryTableViewController {
    
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
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCategory))
        
        
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func addNewCategory() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTF in
            alertTF.placeholder = "Create new Category"
            textField = alertTF
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { [weak self] action in
            guard let text = textField.text, text != "" else { return }
            
            if let context = self?.context {
                let category = Category(context: context)
                category.name = text
                self?.categories.append(category)
                
                self?.saveCategories()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }

        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func saveCategories() {
        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            let category = try context.fetch(request)
            self.categories = category
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Settings TableView
extension CategoryTableViewController {
    
    private func settingsTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "category")
    }
}

