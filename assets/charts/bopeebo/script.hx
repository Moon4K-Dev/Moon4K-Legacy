function onCreate(){
    trace("90% sure onCreate shit don't work sooo...");
}

function createPost(){        
    PlayState.instance.circleMode = true;
}

function update(elapsed){
}

function updatePost(elapsed){
}

function noteMiss(direction:Int = 0){
    trace("MISSED!");
}

function goodNoteHit(note:Int = 0){
    trace("Nice job! (Note Hit!)");
}