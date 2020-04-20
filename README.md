# CreditCardRewards
 #### PennKey: jxiao23
 CIS 195 Final Project
 

 
 CreditCardRewards is an app that allows users to determine which of their cards are best suited/will earn them the most cash back in a given situation.  For example, some cards give more cash back when spent on dining, while others are specific towards purchases on Amazon or at Whole Foods.
 
 When the app is run for the first time, the user will be presented with a login/sign up screen.  After providing the valid credentials, they will be moved to the Home Screen.  The app should be relatively straightforward from there.  Below are a few of the relevant features of the app.
 
 ## Home
 
 This is where the bulk of determining which card is best will happen.  The top half of the screen has selectors (segment controls and picker views).  The user can filter the cards based on their purchase and watch the cards sort themselves at the bottom.  If this is their first time using the app, there won't be any cards on the home screen yet!  To add cards, go to the "Cards" tab by selecting the corresponding cell in the menu.
 
 ## Cards
 
 This is where users can pick and add cards to their collection.  The top view will show the user's added cards, while the bottom will show the unadded cards.  To add cards, click on any of them to show a detailed view (below) and click the "add/remove card" button at the bottom.
 
 ## Detail View
 
 At any given point, clicking on a card will give a more detailed view of the card and its benefits in all scenarios listed.  Additionally, this is the pane where users can add/remove a specific card.  If the user wants to add cash on a specific card, they can start the process by clicking the + button on the top right side of the navigation bar.
 
 ## Add Cash
 
 Given a certain card, select and fill in the relevant fields to calculate how much cash was saved for a given purchase.
 
 ## Analytics

The first of two analytics views, here is where you can see the total amount of cash saved over all of your added cards.  You can also see how much cash you saved on each card.  To see more detailed analytics based on filters, click on the first cell in the analytics page ($___ cash made back).

## Cash Breakdown

The second of the two analytics views, this page allows users to see their card breakdown based off the same filters on the home page.

## Profile

A short profile page, showing the number of cards added and date joined in the app.  Here is also where a user can log out of the app.  Note that this app uses UserDefaults to autologin, so unless the user explicitly logs out, the app will return to the user's home page upon activation.


## Future Directions

Right now, the app only contains a small subset of cards (since I had to draft up the json files myself).  The goal is to add many more cards to the database, as well as implement a better searching/cash back algorithm (currently, I combined cash back, points, and miles into one group).
