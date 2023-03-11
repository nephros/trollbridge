.pragma library

function test() {
    console.log("test successful");
}

WorkerScript.onMessage = function(mess){
    console.log("message:",mess);
    WorkerScript.sendMessage({"response": { "foo": "bar" }})
}

// vim: ft=javascript expandtab ts=4 st=2 sw=2
