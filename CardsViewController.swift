//
//  CardsViewController.swift
//  DatesRUs
//
//  Created by Miguel Rivera on 10/30/15.
//  Copyright (c) 2015 Miguel Rivera. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, SwipeViewDelegate {
    
    struct Card {
        let cardView: CardView
        let swipeView: SwipeView
        let user:User
    }
    
    let frontCardTopMargin: CGFloat = 0
    let backCardTopMargin: CGFloat = 10

    @IBOutlet weak var cardStackView: UIView!
    
    var backCard: Card?
    var frontCard: Card?
    
    var users: [User]?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        cardStackView.backgroundColor = UIColor.clearColor()
        
        // Do any additional setup after loading the view.
        
        fetchUnviewedUsers ({
            users in
            self.users = users
            
            if let card = self.popCard() {
                self.frontCard = card
                self.cardStackView.addSubview(self.frontCard!.swipeView)
            }
            
            if let card = self.popCard() {
                self.backCard = card
                self.backCard!.swipeView.frame = self.createCardFrame(self.backCardTopMargin)
                self.cardStackView.insertSubview(self.backCard!.swipeView, aboveSubview: self.frontCard!.swipeView)
            }
            
            
            println(self.users)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "nav-header"))
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back-button"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToProfile:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createCardFrame(topMargin: CGFloat) -> CGRect
    {
        
        return CGRect(x: 0, y: topMargin, width: cardStackView.frame.width, height: cardStackView.frame.height)
    }
    
    private func createCard(user: User) -> Card {
        let cardView = CardView()
        cardView.name = user.name
        
        user.getPhoto ({
            image in
            cardView.image = image
        })
        
        
        let swipeView = SwipeView(frame: createCardFrame(0))
        swipeView.delegate = self
        swipeView.innerView = cardView
        
        return Card(cardView: cardView, swipeView: swipeView, user: user)
    }
    
    private func popCard() -> Card? {
        if users != nil && users?.count > 0 {
            return createCard(users!.removeLast())
        }
        return nil
    }
    
    private func switchCards() {
        if let card = backCard {
            frontCard = card
            UIView.animateWithDuration(0.2, animations: {
                self.frontCard!.swipeView.frame = self.createCardFrame(self.frontCardTopMargin)
            })
        }
        
        if let card = self.popCard() {
            self.backCard = card
            self.backCard!.swipeView.frame = self.createCardFrame(self.backCardTopMargin)
            self.cardStackView.insertSubview(self.backCard!.swipeView, aboveSubview: self.frontCard!.swipeView)
        }
    }//end switchCards
    
    func goToProfile(button: UIBarButtonItem) {
        pageController.goToPreviousVC()
    }

    
    //MARK: SwipeViewDelegate
    func swipedLeft() {
        println("Swiped Left")
        if let frontCard = frontCard {
            frontCard.swipeView.removeFromSuperview()
            switchCards()
        }
    }
    
    func swipedRight() {
        println("Swiped Right")
        if let frontCard = frontCard {
            frontCard.swipeView.removeFromSuperview()
            switchCards()
        }
    }
}
