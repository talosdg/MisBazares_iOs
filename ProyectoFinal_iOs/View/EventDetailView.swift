//
//  DetailViewEvent.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 13/06/25.
//


import UIKit
class EventDetailView: UIView {
    
    
    let icono = UIImageView(image: UIImage(systemName: "storefront"))
    
    let txtNombre = UITextField()
    let txtEstatus = UITextField()
    let txtLugar = UITextField()
    let txtPlazas = UITextField()
    
    let btnCrear = UIButton(type: .custom)
    let btnCrearPublicar = UIButton(type: .custom)
    let btnPublicar = UIButton(type: .custom)
    let btnDespublicar = UIButton(type: .custom)
    let btnCancelar = UIButton(type: .custom)
    let btnEliminar = UIButton(type: .custom)
    let btnGuardarCambios = UIButton(type: .custom)
    let btnInscripcion = UIButton(type: .custom)


    var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {

        // Inicializa el stackView
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        icono.contentMode = .scaleAspectFit
        icono.tintColor = .darkrose
        icono.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(icono)

        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            icono.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            icono.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        // Configura campos
        setupTextField(txtNombre, placeholder: "Nombre")
        setupTextField(txtEstatus, placeholder: "Estatus")
        setupTextField(txtLugar, placeholder: "Lugar")
        setupTextField(txtPlazas, placeholder: "Plazas")
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        stackView.addArrangedSubview(textField)
    }
    
    func agregarBotones(estatus: String) {
        // Limpiar botones previamente agregados
        for view in [btnPublicar, btnCrearPublicar, btnDespublicar, btnCancelar, btnEliminar, btnGuardarCambios] {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        switch estatus {
            
        case "pendiente":
            configurarBoton(btnPublicar, titulo: "Publicar evento", color: .midgreen)
            configurarBoton(btnCancelar, titulo: "Cancelar evento", color: .amber)
            configurarBoton(btnGuardarCambios, titulo: "Guardar cambios", color: .opaqueturqoise)
            stackView.addArrangedSubview(btnPublicar)
            stackView.addArrangedSubview(btnCancelar)
            stackView.addArrangedSubview(btnGuardarCambios)
            inhabilitado(es: false)
        case "publicado":
            if SessionManager.esAdmin{
                configurarBoton(btnDespublicar, titulo: "Despublicar", color: .amber)
                configurarBoton(btnGuardarCambios, titulo: "Guardar cambios", color: .opaqueturqoise)
                stackView.addArrangedSubview(btnDespublicar)
                stackView.addArrangedSubview(btnGuardarCambios)
                inhabilitado(es: false)
            }else{
                //NO DEBE PINTARSE DE INICIO configurarBoton(btnInscripcion, titulo: "Inscribirme", color: .orange)
                stackView.addArrangedSubview(btnInscripcion)
                inhabilitado(es: true)
            }
        case "cancelado", "terminado":
            configurarBoton(btnEliminar, titulo: "Eliminar", color: .red)
            stackView.addArrangedSubview(btnEliminar)
            inhabilitado(es: true)
        default:
       
            break
        }
    }
    func inhabilitado(es: Bool){
        let campos = [txtNombre, txtEstatus, txtLugar, txtPlazas]

        for campo in campos {
            campo.isEnabled = !es
            campo.backgroundColor = es ? .rosewood : UIColor.white
            campo.textColor = UIColor.label // mantiene buena visibilidad
        }

    }
    
    func configurarBoton(_ boton: UIButton, titulo: String, color: UIColor) {
        boton.setTitle(titulo, for: .normal)
        boton.setTitleColor(.white, for: .normal)
        boton.backgroundColor = color
    }
}

