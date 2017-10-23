//
//  StartViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 01.00.2017.
//  Copyright © 2017 Webim. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    // MARK: - Properties
    
    let gradient: CAGradientLayer = CAGradientLayer()
    
    // MARK: Outlets    
    @IBOutlet weak var startChatButton: UIButton!
    
    
    // MARK: - Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Setting an image to NavigationItem TitleView.
        let navigationItemImageView = UIImageView(image: #imageLiteral(resourceName: "LogoWebimNavigationBar"))
        navigationItemImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationItemImageView
        
        // Setting a gradient over the Start Chat Button.
        gradient.opacity = 0.3
        gradient.frame = startChatButton.bounds
        let colors: [UIColor] = [.clear,
                                 .lightGray]
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = [0.6,
                              1.0]
        startChatButton.layer.insertSublayer(gradient,
                                             at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Re-drawing gradient over the Start Chat Button on device rotations.
        gradient.frame = startChatButton.bounds
    }
    
}
