//
//  RegisterViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 07/06/25.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btGoHome(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
               let window = sceneDelegate.window {
                
                window?.rootViewController = tabBarVC
                window?.makeKeyAndVisible()
            }
        }
        
    }
    @IBAction func btCancel(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "LoginView") as? ViewController {
 
            self.present(mainVC, animated: true, completion: nil)
 
        }
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
