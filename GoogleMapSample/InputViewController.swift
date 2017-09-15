//
//  InputViewController.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

class InputViewController: UIViewController, UITextFieldDelegate {
    
    var selectedIndex: Int!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var inputTextField: BorderTextField!
    
    @IBOutlet var explainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self
        
        switch selectedIndex {
        case 3:
            self.navigationItem.title = "最寄り出口"
            titleLabel.text = "最寄り出口を入力して下さい。"
            explainTextView.text = "(例1) 東南口\n(例2) B13出口"
        case 4:
            self.navigationItem.title = "電車の方面"
            titleLabel.text = "電車の方面を入力して下さい。"
            explainTextView.text = "(例1) 内回り 品川方面\n(例2) 外回り 鶴橋・天王寺方面"
        case 5:
            self.navigationItem.title = "最寄り出口に近い車両"
            titleLabel.text = "最寄り出口に近い車両番号を入力して下さい。"
            explainTextView.text = "(例1) 4号車\n(例2) うしろから2番目の車両"
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if inputTextField.canBecomeFirstResponder == true {
            inputTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if inputTextField.canResignFirstResponder == true {
            inputTextField.resignFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch selectedIndex {
        case 3:
            Place.shared.exit = inputTextField.text
        case 4:
            Place.shared.direction = inputTextField.text
        case 5:
            Place.shared.trainNumber = inputTextField.text
        default:
            break
        }
        
        textField.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
        
        return true
    }
    
}
