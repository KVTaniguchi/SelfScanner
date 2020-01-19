# ShelfScanner

Should be "Shelf Scanner".

I hate having to scan shelves of products looking for that one thing I've been asked to buy.
My phone has a camera, I should be able to point it at a store rack and it should tell me where the thing is.

Right now this tries to find rectangles then tries to read inside those rectangles for the search string.

- Some things I've learned about vision.
1.  Its really short range and dependent on the actual image res of the text you are trying to read.
2.  Its fast when you're at the right distance.
3.  You're still in UIKit land for the most part, so its a little better to stick to UIKit and use Combine than trying to go full SwiftUI with this kind of work.
