# HScript!!

* You can call or do legit ANYTHING with HScript
* This shouldn't need much introduction since well it's basically just regular haxe lol
* Template Script Below (or you can look in the bopeebo chart folder):

```haxe
function onCreate(){
    trace("90% sure onCreate shit don't work sooo...");
}

function createPost(){        
    trace("Script Initialized.");
}

function update(elapsed){
    trace("update lol!");
}

function updatePost(elapsed){
    trace("update post lol!");
}

function noteMiss(direction:Int = 0){
    trace("MISSED!");
}

function goodNoteHit(note:Int = 0){
    trace("Nice job! (Note Hit!)");
}
```

Extra Key Template:

```haxe
function onCreate(){
    trace("90% sure onCreate shit don't work sooo...");
}

function createPost(){        
    trace("Script Initialized.");
}

function update(elapsed){
    PlayState.instance.keyCount = 6; // 1-9 key, also extra keys is buggy as fuck so use at your own risk
}

function updatePost(elapsed){
}

function noteMiss(direction:Int = 0){
}

function goodNoteHit(note:Int = 0){
}
```