import ceylon.io {
	newSocketConnector,
	SocketAddress,
	Socket
}
import ceylon.io.charset {
	utf8,
	ascii
}

import com.illposed.osc {
	OSCPortIn,
	OSCListener,
	OSCMessage
}

import fr.minibilles.cli {
	parseArguments,
	help
}

import java.lang {
	Thread
}
import java.nio.charset {
	StandardCharsets
}
import java.util {
	Date
}
import ceylon.io.buffer {
	newByteBuffer
}


/*
 +----[ CLI commands ]
 | playlist . . . . . . . . . . . . .  show items currently in playlist
 | search [string]  . .  search for items in playlist (or reset search)
 | delete [X] . . . . . . . . . . . . . . . . delete item X in playlist
 | move [X][Y]  . . . . . . . . . . . . move item X in playlist after Y
 | sort key . . . . . . . . . . . . . . . . . . . . . sort the playlist
 | sd [sd]  . . . . . . . . . . . . . show services discovery or toggle
 | play . . . . . . . . . . . . . . . . . . . . . . . . . . play stream
 | stop . . . . . . . . . . . . . . . . . . . . . . . . . . stop stream
 | next . . . . . . . . . . . . . . . . . . . . . .  next playlist item
 | prev . . . . . . . . . . . . . . . . . . . .  previous playlist item
 | goto, gotoitem . . . . . . . . . . . . . . . . .  goto item at index
 | repeat [on|off]  . . . . . . . . . . . . . .  toggle playlist repeat
 | loop [on|off]  . . . . . . . . . . . . . . . .  toggle playlist loop
 | random [on|off]  . . . . . . . . . . . . . .  toggle playlist random
 | clear  . . . . . . . . . . . . . . . . . . . . .  clear the playlist
 | status . . . . . . . . . . . . . . . . . . . current playlist status
 | title [X]  . . . . . . . . . . . . . . set/get title in current item
 | title_n  . . . . . . . . . . . . . . . .  next title in current item
 | title_p  . . . . . . . . . . . . . .  previous title in current item
 | chapter [X]  . . . . . . . . . . . . set/get chapter in current item
 | chapter_n  . . . . . . . . . . . . . .  next chapter in current item
 | chapter_p  . . . . . . . . . . . .  previous chapter in current item
 | 
 | seek X . . . . . . . . . . . seek in seconds, for instance `seek 12'
 | pause  . . . . . . . . . . . . . . . . . . . . . . . .  toggle pause
 | fastforward  . . . . . . . . . . . . . . . . . . set to maximum rate
 | rewind . . . . . . . . . . . . . . . . . . . . . set to minimum rate
 | faster . . . . . . . . . . . . . . . . . .  faster playing of stream
 | slower . . . . . . . . . . . . . . . . . .  slower playing of stream
 | normal . . . . . . . . . . . . . . . . . .  normal playing of stream
 | rate [playback rate] . . . . . . . . . .  set playback rate to value
 | frame  . . . . . . . . . . . . . . . . . . . . . play frame by frame
 | fullscreen, f, F [on|off]  . . . . . . . . . . . . toggle fullscreen
 | info . . . . . . . . . . . . .  information about the current stream
 | stats  . . . . . . . . . . . . . . . .  show statistical information
 | get_time . . . . . . . . .  seconds elapsed since stream's beginning
 | is_playing . . . . . . . . . . . .  1 if a stream plays, 0 otherwise
 | get_title  . . . . . . . . . . . . . the title of the current stream
 | get_length . . . . . . . . . . . .  the length of the current stream
 | 
 | volume [X] . . . . . . . . . . . . . . . . . .  set/get audio volume
 | volup [X]  . . . . . . . . . . . . . . .  raise audio volume X steps
 | voldown [X]  . . . . . . . . . . . . . .  lower audio volume X steps
 | achan [X]  . . . . . . . . . . . .  set/get stereo audio output mode
 | atrack [X] . . . . . . . . . . . . . . . . . . . set/get audio track
 | vtrack [X] . . . . . . . . . . . . . . . . . . . set/get video track
 | vratio [X] . . . . . . . . . . . . . . .  set/get video aspect ratio
 | vcrop, crop [X]  . . . . . . . . . . . . . . . .  set/get video crop
 | vzoom, zoom [X]  . . . . . . . . . . . . . . . .  set/get video zoom
 | vdeinterlace [X] . . . . . . . . . . . . . set/get video deinterlace
 | vdeinterlace_mode [X]  . . . . . . .  set/get video deinterlace mode
 | snapshot . . . . . . . . . . . . . . . . . . . . take video snapshot
 | strack [X] . . . . . . . . . . . . . . . . .  set/get subtitle track
 | 
 +----[ end of help ]

 */

class Vlc(Socket socket) {
	
	variable Boolean paused = false;
	
	shared void command(String command) {
		socket.writeFully(ascii.encode(command + operatingSystem.newline));
	}
	
	shared void pause() {
		paused = !paused;
		command("pause");
	}
	
	"add XYZ to playlist"
	shared void add(String file) => command("add ``file``");
	
	"queue XYZ to playlist"
	shared void enqueue(String file) => command("enqueue ``file``");





	"load the VLM"
	shared void vlm() => command("vlm");

	"describe this module"
	shared void description() => command("description");

	"a help message"
	shared void help(String pattern) => command("help ``pattern``");

	"a longer help message"
	shared void longhelp(String pattern) => command("longhelp ``pattern``");

	"lock the telnet prompt"
	shared void lock() => command("lock");

	"exit (if in a socket connection)"
	shared void logout() => command("logout");

	"quit VLC (or logout if in a socket connection)"
	shared void quit() => command("quit");

	"shutdown VLC"
	shared void shutdown() => command("shutdown");
	

	shared void close() {
		socket.close();
	}
}

Vlc connectVlc(String host, Integer port) {
	value connector = newSocketConnector(SocketAddress(host, port));
	value socket = connector.connect();
	print("Connected on VLC on ``host``:``port``");
	return Vlc(socket);
}

void startOscServer(Integer port, Vlc vlc) {
	
	value server = OSCPortIn(port, StandardCharsets.\iUTF_8);
	value listener = object satisfies OSCListener {
		shared actual void acceptMessage(Date date, OSCMessage message) {
			print("Received message on ``message.address``: ``message.arguments``.");	
			value last = message.address.lastOccurrence('/');
			if (exists last) {
				value command = message.address.spanFrom(last+1);
				if (exists argument = message.arguments.get(0)) {
					vlc.command("``command`` ``argument``");
				} else {
					vlc.command(command);
				}
			}
		}  
	};
	server.addListener("", listener);
	server.startListening();	
	
	print("Listening OSC on ``port``.");
}


"Run the module `fr.minibilles.vlcosc`."
shared void run() {

	value [options, errors] = parseArguments<Options>(process.arguments);
	if (nonempty errors) {
		errors.each(print);
		print(help<Options> ("VlcOsc"));
		process.exit(1);
	}
	value vlc = connectVlc(options.host, options.port);	
	startOscServer(options.oscPort, vlc);
	
	while (true) {
		Thread.sleep(50);
	}

}

