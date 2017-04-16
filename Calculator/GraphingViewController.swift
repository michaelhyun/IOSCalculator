//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Michael Hyun on 4/11/17.
//  Copyright © 2017 Michael Hyun. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {

    
    private let brain = CalculatorBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationvc = segue.destination
        if let graphingvc = destinationvc as? GraphingViewController{
            if let identifier = segue.identifier{
                //what to do here
            }
        }
    }


}
