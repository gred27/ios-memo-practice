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
    var imageList: [UIImage]? = []
    
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoToolbar: UIToolbar!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    // 메모 수정 뷰 저장 없이 닫기
    @IBAction func close (_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // 메모 저장 후 닫기
    @IBAction func save (_ sender: Any) {
        
        // 메모 입력을 하지 않았으면
        guard let memo = memoTextView.text, memo.count > 0 else {
            alert(message: "메모를 입력하세요")
            return
        }
        
        // 메모 수정 모드인지 새 메모 생성 모드인지 구분
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
    
    
    // 앨범, 카메라에서 이미지 추가
    var picker = UIImagePickerController()
    
    @IBAction func addImage (_ sender: Any?) {
        print("click image")
        
        // 모드를 고를 alert 생성
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "사진 찍기", style: .default) {
            [weak self] (action) in
            self?.picker.sourceType = .camera
            self?.present(self!.picker, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "사진 보관함", style: .default) {
            [weak self] (action) in
            self?.picker.sourceType = .photoLibrary
            self?.present(self!.picker, animated: true, completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editDoneHideKeyboard(_ sender: Any){
        view.endEditing(true)
    }
    
    
    
    
    // 키보드 상태 확인할 토큰, 옵저버 생성
    var willShowToken: NSObjectProtocol?
    var willHiddenToken: NSObjectProtocol?
    
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        
        if let token = willHiddenToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 수정, 생성 모드 구분
        if let memo = editTarget {
            navigationItem.title = "edit"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        } else {
            navigationItem.title = "new Memo"
            memoTextView.text = ""
        }
        
        // 툴바를 키보드 위에 붙임
        memoTextView.inputAccessoryView = memoToolbar
        
        memoTextView.delegate = self
        
        // 키보드 보일 때
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else {
                return
            }
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let height = frame.cgRectValue.height
                var inset = strongSelf.memoTextView.contentInset
                inset.bottom = height
                strongSelf.memoTextView.contentInset = inset
                
                inset = strongSelf.memoTextView.scrollIndicatorInsets
                inset.bottom = height
                strongSelf.memoTextView.scrollIndicatorInsets = inset
            }
        })
        
        // 키보드 없어질 때
        willHiddenToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noit) in
            guard let strongSelf = self else {
                return
            }
            
            var inset = strongSelf.memoTextView.contentInset
            inset.bottom = 0
            strongSelf.memoTextView.contentInset = inset
            
            inset = strongSelf.memoTextView.scrollIndicatorInsets
            inset.bottom = 0
            strongSelf.memoTextView.scrollIndicatorInsets = inset
        })
        
        picker.delegate = self
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(CustomCollectionCell.self, forCellWithReuseIdentifier: "imageCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoTextView.becomeFirstResponder()
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        memoTextView.resignFirstResponder()
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

extension NewMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("imagepick")
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageList?.append(image)
        }
        
        self.imageCollectionView?.reloadData()
        dismiss(animated: true, completion: nil)
    }
    

}

extension NewMemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CustomCollectionCell
        
        if self.imageList?.count ?? 0 > 0 {
            let image = imageList?[indexPath.row]
            cell.imageView?.image = image
        }
        
        return cell
    }
    
    
}

extension NewMemoViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:40,height:40)
        
    }
}

class CustomCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
}
