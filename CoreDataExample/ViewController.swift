//
//  ViewController.swift
//  CoreDataExample
//
//  Created by KaiD on 26/11/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var models: [ToDoListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        getAllItems()
    }
    
    private func setupNavigationBar() {
        title = "CoreDataExample To Do List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAddButton))
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func didTapAddButton() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let self, let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }
    
    private func handleEdit(item: ToDoListItem) {
        let alert = UIAlertController(title: "Edit Item", message: "Edit your item name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?.first?.text = item.name
        alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
            guard let self, let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                return
            }
            
            self.updateItem(item: item, newName: newName)
        }))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = models[indexPath.row]
        cell.textLabel?.text = data.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Edit Item", message: "What do you want to do?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.handleEdit(item: item)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            self.deleteItem(item: item)
        }))
        
        present(sheet, animated: true)
    }
}

// MARK: - Core Data functions
extension ViewController {
    func getAllItems() {
        do {
            self.models = try context.fetch(ToDoListItem.fetchRequest())
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Failed to get items with error: \(error)")
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch let error as NSError {
            print("Failed to save item with error: \(error)")
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        getAllItems()
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch let error as NSError {
            print("Failed to update item with error: \(error)")
        }
    }
}

