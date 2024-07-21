import Math;

function returnRandom()
{
    return Math.floor(Math.random() * 100);
}

var s:Int = returnRandom();
trace(s);