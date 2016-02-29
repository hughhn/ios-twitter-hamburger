# Project 4 - Hugo Twitter (cont.)

Time spent: 15 hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] Hamburger menu
- [X] Dragging anywhere in the view should reveal the menu.
- [X] The menu should include links to your profile, the home timeline, and the mentions view.
- [X] The menu can look similar to the example or feel free to take liberty with the UI.
- [X] Profile page
- [X] Contains the user header view
- [X] Contains a section with the users basic stats: # tweets, # following, # followers
- [X] Home Timeline
- [X] Tapping on a user image should bring up that user's profile page

The following **optional** features are implemented:

- [X] Implement the paging view for the user description.
- [X] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
- [X] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
- [ ] Long press on tab bar to bring up Account view with animation
- [ ] Tap account to switch to
- [ ] Include a plus button to Add an Account
- [ ] Swipe to delete an account


The following **additional** features are implemented:

- [X] Create container view in Profile page to include both Tweets stream and Likes stream (UISegmentedControl switch)
- [X] Core Animation transforms on: profile image, label text, background image, z index. exactly like the official app
- [X] Prettify large numbers (e.g.: 1300 = 1.3K following; 2,100,000 = 2.1M followers)
- [X] Turns out that setting border width and color does not completely remove the outline of the image from the edges. Had to create a UIBezierPath sub-layer to the profile image to fix this.

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. How to enable scroll on the header view and send it to the UITableView underneath? I tried using a pan gesture on the header and have the UITableView setContentOffset() using the translation on the header but this approach a) overrides the hamburger swipe gesture and 2) strangely it does not handle pull to refresh (even though I thought setContentOffset() will do it but it won't)
2. How to handle dynamic sized content in UITableView? the tweets images' heights are not known in advance. I have a height constraint on the UIImageView that is set programmatically in the callback of setImageWithURL(). The problem with that is it seems to break the other cell constraints and some cells look messed up. I can get around it by downloading the images synchronously and set the height constraint immediately. But then the UI is really slow- and downloading images synchronously is a bad practice anyway. What's a good solution for this?


## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Video Walkthrough](hamburger.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

Copyright [2016] [Hugo Nguyen]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
