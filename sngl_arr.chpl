/*
 * Single array tests 
 */

const space : domain(1) = [0..127];

var arr : [space] single int;

var counter : int = 0;

for a in arr {
	a = counter;
	counter = counter +1;
}

writeln(arr);

arr(0) = 23; // <- halt

writeln(arr);
