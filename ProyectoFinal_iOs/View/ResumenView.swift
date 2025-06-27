//
//  ResumenView.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 18/06/25.
//

import UIKit

class ResumenView: UIView {
    let tv = UITextView()
    
    override func draw(_ rect: CGRect) {
        self.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.widthAnchor.constraint(equalToConstant:250).isActive = true
        tv.heightAnchor.constraint(equalToConstant:250).isActive = true
        tv.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        tv.topAnchor.constraint(equalTo:self.topAnchor, constant: 15).isActive = true
        tv.backgroundColor = .darkrose
        tv.isEditable = false
        tv.font = UIFont.systemFont(ofSize: 22)
    }

}
