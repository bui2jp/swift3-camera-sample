//
//  CameraSettingViewController.swift
//  camera_sample
//
//  Created by Takuya on 2017/06/13.
//  Copyright © 2017 Takuya. All rights reserved.
//

import UIKit

class CameraSettingViewController: UIViewController {

    var myApp: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //解像度
    @IBOutlet weak var resolutionText: UITextField!
    
    //location mode on/off
    @IBOutlet weak var locationInfo: UISwitch!
    
    @IBAction func resolutionExit(_ sender: Any) {
    }

    @IBAction func resolutionChanged2(_ sender: Any) {
        myApp.cam_resolution = resolutionText.text!
    }
    
    @IBAction func loc_changed(_ sender: Any) {
        myApp.cam_geoInfo = locationInfo.isOn
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //myApp.cam_resolution
        resolutionText.text = myApp.cam_resolution
        //myApp.cam_geoInfo
        locationInfo.isOn = myApp.cam_geoInfo
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
