//
//  AlertManager.swift
//  TakeCare
//
//  Created by Carson Gross on 10/1/23.
//

import SwiftUI

@Observable final class AlertManager {
    static let shared = AlertManager()
    
    var showingAlert = false {
        didSet {
            if !showingAlert {
                title = ""
                
                primaryButtonText = nil
                primaryButtonAction = nil
                primaryButtonRole = nil
                
                secondaryButtonText = nil
                secondaryButtonAction = nil
                secondaryButtonRole = nil
            }
        }
    }
    
    public private(set) var title = ""
    
    public private(set) var primaryButtonText: String? = nil
    public private(set) var primaryButtonAction: (() -> Void)? = nil
    public private(set) var primaryButtonRole: ButtonRole? = nil
    
    public private(set) var secondaryButtonText: String? = nil
    public private(set) var secondaryButtonAction: (() -> Void)? = nil
    public private(set) var secondaryButtonRole: ButtonRole? = nil
    
    func showAlert(
        title: String,
        primaryButtonText: String? = nil,
        primaryButtonAction: (() -> Void)? = nil,
        primaryButtonRole: ButtonRole? = nil,
        secondaryButtonText: String? = nil,
        secondaryButtonAction: (() -> Void)? = nil,
        secondaryButtonRole: ButtonRole? = nil
    ) {
        self.title = title
        
        self.primaryButtonText = primaryButtonText
        self.primaryButtonAction = primaryButtonAction
        self.primaryButtonRole = primaryButtonRole
        
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonAction = secondaryButtonAction
        self.secondaryButtonRole = secondaryButtonRole
        
        showingAlert = true
    }
}
