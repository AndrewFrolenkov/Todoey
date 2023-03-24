//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Андрей Фроленков on 23.03.23.
//

import Foundation
import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
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
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)
        
        if let categories = categories {
            let category = categories[indexPath.row]
            var config = cell.defaultContentConfiguration()
            config.text = category.name
            cell.contentConfiguration = config
            
            let n1 = numberFormatter(text: category.color[0].hue)
            let n2 = numberFormatter(text: category.color[0].saturation)
            let n3 = numberFormatter(text: category.color[0].brightness)
            
            cell.backgroundColor = UIColor(hue: n1 , saturation: n2 , brightness: n3 , alpha: 1)
            //        cell.accessoryType = item.done ? .checkmark : .none
        }
        return cell
    }
    
    private func numberFormatter(text: String) -> CGFloat {
        let str = text
        if let n = NumberFormatter().number(from: str) {
            let f = CGFloat(truncating: n)
            return f
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

// MARK: - TableView Delegate Methods
extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let controller = TodoListViewController()
        controller.categories = categories?[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let categories = categories else { return UISwipeActionsConfiguration()}
        
        let action = UIContextualAction(style: .destructive,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            do {
                try self?.realm.write {
                    self?.realm.delete(categories[indexPath.row])
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
    
    //    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //
    //    }
    
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
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
            
            let category = Category()
            category.name = text
            let _ = UIColor.generateRandomColor()
            let colorRealm = Color()
            colorRealm.hue = UIColor.hue.description
            colorRealm.saturation = UIColor.saturation.description
            colorRealm.brightness = UIColor.brightness.description
            category.color.append(colorRealm)
            
            self?.saveCategories(category: category)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func saveCategories(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func loadCategories() {
        let categories = realm.objects(Category.self)
        self.categories = categories
        
    }
}

// MARK: - Settings TableView
extension CategoryTableViewController {
    
    private func settingsTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "category")
        tableView.separatorStyle = .none
    }
}

