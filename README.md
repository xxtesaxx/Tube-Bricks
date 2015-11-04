# Tube-Bricks
Tube Bricks is a simple to use text generator for YouTube. Add text bricks, separators and start mixing them to create the desciption for your next YouTube video.

## Bricks
Bricks are one of the main components of this App. Every Brick has a title and the text itself. Titels are used to organise and find your bricks. The list on the left side is searchable so you can find and edit a specific brick quicker. The text of the brick is used to generate the description in the Generator tab.
![alt tag](https://github.com/xxtesaxx/Tube-Bricks/blob/master/Screenshots/BricksTab.png)

## Separators
Separators are the other main component of this App. Every Separator also has a title and a text. Titels are again used to organise them and the list of separators are searchable as well. The purpose of separators is, that in the generator each brick is simply concatenated to the generated description. A separator separates each brick from each other. You can for example create a separator to get a line break, a double line break or anything you can imagine to separate your bricks.
![alt tag](https://github.com/xxtesaxx/Tube-Bricks/blob/master/Screenshots/SeparatorsTab.png)

## Generator
Here your bricks and separators come to life. Add your bricks, chose a separator for each brick and generate your description. There are also two textfields for freetext, the header and the footer. Each separator is inserted right after the brick or the header. Only the separator for the footer is inserted between the last brick and the text for the footer. Once you click generate, the generated text is copied to your pastebord.
![alt tag](https://github.com/xxtesaxx/Tube-Bricks/blob/master/Screenshots/GeneratorTab.png)

Here's how the finished text for the sample above looks:
```
Have fun watching my new video. :)
——————
Music used in this Video:
-Some Artist - Some Song (youtube.com/someartist)
——————
-https://www.facebook.com/JanLeMann
-https://twitter.com/JanLeMann


Thank you for watching. Please rate and comment.
```

## Future Improvements
This App is a first draft of what I find useful for myself, developed quick and dirty in a couple of ours. It's also my first Mac App as well as my first App written in swift. Therefore it might contain some bugs and doesn't follow best practices. I gave my best since I use the App everyday to generate descriptions of my daily video diary. Nevertheless I can imagine some improvements and additional features. Heres a short list of what I might or might not implement in the near future. Feel free to implement it yourself and send me a pull request:
* Adding keyboard shortcut support (create and save bricks, separators, switch tabs, add/remove/move bricks in the generator and so on)
* Drag and Drop bricks in the generator (to add/remove/reorder them)
* Add profiles so you can save and load a configuration in the generator

## Additional Thanks
Additional thanks goes to the developers of Realm (http://www.realm.io). Realm is used as the underlaying database to store and retrieve bricks and separators. It has a very small footprint and it's even easier to use than Apples Core Data.
