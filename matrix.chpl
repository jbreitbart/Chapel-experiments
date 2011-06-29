/*
 * Basic generic matrix class 
 */

use Random;
use CyclicDist;
use Time;

config const tileSize = 64;
config const matrixSize = 4;
config param debug = true;


class tileMatrix {
	/********** GENERICS *************/
	type itemType;
	
	/********** VARIABLES ************/
	const space : domain (2) dmapped Cyclic(startIdx=(0,0));
	const tileSpace : domain(1) = [0..tileSize-1];
	var tiles : [space] tile;

	/********** SUBCLASS ************/
	class tile { // use record breaks in current release
		var flag$ : single int;
		var data : [tileSpace] itemType;
		
		// generic function to set tile
		proc set(a) {
			data = a;
			flag$ = 1;
		}
		
		proc get() {
			return data;
		}
		
		proc data var {
			// make sure data is only read after the flag is checked
			if (!setter && flag$!=1) then halt ("Error that should not happen 23b");
			
			return data;
		}
	}

	
	/******* CONSTRUCTORS **********/
	proc tileMatrix(type itemType, xTiles : int, yTiles : int) {
		space = [0..xTiles-1, 0..yTiles-1]; 
		coforall  i in tiles {
			on (i) {
				writeln (i.locale.id);
				i = new tile();
			}
		}
	}
	
	/******* DATA ACCESS FUNCTIONS ************/
	proc this ((x,y) : 2*int) var : tile {		
		return tiles(x,y);
	}
	
	iter these() var {
		for i in tiles {
			yield i;
		}
	}
}

proc compute (matrix, id, all) : tileMatrix(int) {
	var returnee = new tileMatrix(int, matrixSize, matrixSize);
	forall (x,y) in [0..matrixSize-1, 0..matrixSize-1] {
		//writeln ("e: ", (x,y));
		on (returnee((x,y))) {
			var t = matrix((x,y));
			var r = returnee((x,y));
			if (x==0) {
				var a = t.get();
				r.set(a);
			} else {
				var t0 = matrix((x-1,y));
				r.set(t0.get() + t.get());
			}
		}
	}
	
	return returnee;
}

if (debug) {
	for loc in Locales {
		on loc {
			writeln ("Hello from node ", loc.id, " of " , numLocales);
		}
	}
}

var matrix = new tileMatrix(int, matrixSize, matrixSize);

// for all is not compiling
// -> requires leader/follow iterator
for/*all*/ i in matrix {
	on (i) {
		i.set(i.locale.id);
	}
}

var t: Timer;

t.start();
var m = compute(matrix, 0, matrixSize);
t.stop();

if debug then writeln(m);

writeln ("TIME: ", t.elapsed());
