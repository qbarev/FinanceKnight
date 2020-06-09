//
//  ColorPickerController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate: class  {
    func controller(_ controller: ColorPickerController, didSelectColor color: UIColor)
}

class ColorPickerController: UITableViewController {
    
    var delegate: ColorPickerDelegate?
    
    private let colors = [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2515868906, green: 0.2586473288, blue: 1, alpha: 1), #colorLiteral(red: 0.1552311628, green: 1, blue: 0.9902720035, alpha: 1), #colorLiteral(red: 1, green: 0.1974754793, blue: 0.1859553409, alpha: 1), #colorLiteral(red: 0.9413609154, green: 0.3448878096, blue: 1, alpha: 1), #colorLiteral(red: 0.4367238866, green: 1, blue: 0.441926928, alpha: 1)]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        tableView.register(UINib(nibName: DetailCell.reuseID, bundle: .main), forCellReuseIdentifier: DetailCell.reuseID)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.reuseID, for: indexPath) as! DetailCell
        
        cell.titleLabel.isHidden = true
        cell.detailLabel.isHidden = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let customCell = cell as? DetailCell else { return }
        
        customCell.contentContainer?.backgroundColor = colors[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.controller(self, didSelectColor: colors[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}
