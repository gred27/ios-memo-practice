//
//  DetailViewController.swift
//  GredMemo
//
//  Created by 박지홍 on 2020/02/16.
//  Copyright © 2020 gred. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var memoTableView: UITableView!
    
    
    var memo: Memo?
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "KO_kr")
        return f
    }()

    override func prepare(for segue: UIStoryboardSegue,  sender: Any?) {
        if let vc = segue.destination.children.first as? NewMemoViewController {
            vc.editTarget = memo
        }
    }
    
    var token: NSObjectProtocol?
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = NotificationCenter.default.addObserver(forName: NewMemoViewController.memoDidChange, object: nil, queue: OperationQueue.main, using: {
            [weak self] (noti) in
            self?.memoTableView.reloadData()
        })
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let memoCell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)
            memoCell.textLabel?.text = memo?.content
            return memoCell
            
        case 1:
            let dateCell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
            dateCell.textLabel?.text = formatter.string(for: memo?.insertDate)
            return dateCell
            
        default:
            fatalError()
        }
    }
    
    
}
