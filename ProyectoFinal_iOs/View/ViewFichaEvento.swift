//
//  ViewFichaEvento.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//

import UIKit

class ViewFichaEvento: UIView {
    
    let scrollView = UIScrollView()
    let contentStack = UIStackView()

    let tituloLabel = UILabel()
    let nombreLabel = UILabel()
    let recintoLabel = UILabel()
    let plazasLabel = UILabel()
    let fechaLabel = UILabel()
    let horarioLabel = UILabel()
    let ubicacionLabel = UILabel()
    let mapaImageView = UIImageView()
    let observacionesLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .white

        // Scroll
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // Stack
        scrollView.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // Elementos
        addSection(title: "EVENTO DISPONIBLE", label: tituloLabel, color: .systemGreen, fontSize: 22, bold: true)
        addSection(title: "Nombre", label: nombreLabel)
        addSection(title: "Recinto", label: recintoLabel)
        addSection(title: "Número de plazas disponibles", label: plazasLabel)
        addSection(title: "Fecha", label: fechaLabel)
        addSection(title: "Horario abierto al público", label: horarioLabel)
        addSection(title: "Ubicación", label: ubicacionLabel)

        // Mapa
        mapaImageView.contentMode = .scaleAspectFit
        mapaImageView.backgroundColor = .lightGray
        mapaImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        contentStack.addArrangedSubview(mapaImageView)

        // Observaciones
        addSection(title: "Observaciones", label: observacionesLabel)
    }

    private func addSection(title: String, label: UILabel, color: UIColor = .systemPurple, fontSize: CGFloat = 17, bold: Bool = false) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = color.withAlphaComponent(0.7)

        label.font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = 0
        label.textColor = .label

        let stack = UIStackView(arrangedSubviews: [titleLabel, label])
        stack.axis = .vertical
        stack.spacing = 4
        contentStack.addArrangedSubview(stack)
    }
}
