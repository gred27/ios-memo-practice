//
//  NewMemoViewController.swift
//  GredMemo
//
//  Created by 박지홍 on 2020/02/16.
//  Copyright © 2020 gred. All rights reserved.
//

import UIKit

class NewMemoViewController: UIViewController {
    
    var editTarget: Memo?
    var originalMemoContent: String?
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func close (_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save (_ sender: Any) {
        guard let memo = memoTextView.text, memo.count > 0 else {
            alert(message: "메모를 입력하세요")
            return
        }
        
        if let target = editTarget {
            target.content = memo
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: NewMemoViewController.memoDidChange, object: nil)
        } else {
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: NewMemoViewController.newMemoDidInsert, object: nil)
        }
        

        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let memo = editTarget {
            navigationItem.title = "edit"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        } else {
            navigationItem.title = "new Memo"
            memoTextView.text = ""
        }
        memoTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.presentationController?.delegate = nil
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

extension NewMemoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let origin = originalMemoContent, let edited = textView.text {
            if #available(iOS 13.0, *) {
                isModalInPresentation = origin != edited
                print("delegate")
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

extension NewMemoViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "저장하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) {
                [weak self] (action) in
                    self?.save(action)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .default) {
            [weak self] (action) in self?.close(action)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension NewMemoViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
