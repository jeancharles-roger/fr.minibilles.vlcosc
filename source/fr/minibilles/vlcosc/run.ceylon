import ceylon.io {
	newSocketConnector,
	SocketAddress,
	Socket
}
import ceylon.io.charset {
	ascii
}

import com.illposed.osc {
	OSCPortIn,
	OSCListener,
	OSCMessage
}

import fr.minibilles.cli {
	parseArguments,
	help,
	option
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

"VlcOsc recieves OSC command and propagates them to VLC throught VLC lua remote."
class Options(
	
	"VLC host"
	option("host", 'h')
	shared String host = "localhost",
	
	"VLC port"
	option ("port", 'p')
	shared Integer port = 9999,
	
	"OSC in port"
	option("oscPort")
	shared Integer oscPort = OSCPortIn.defaultSCOSCPort()
) {
	
}

"
 Vlc object able to receive lua command. This are the possible commands:
 	
     +----[ Remote control commands ]
     |
     | add XYZ    . . . . . . . . . . add XYZ to playlist
     | playlist . . .    show items currently in playlist
     | play . . . . . . . . . . . . . . . . play stream
     | stop . . . . . . . . . . . . . . . . stop stream
     | next . . . . . . . . . . . . next playlist item
     | prev . . . . . . . . . . previous playlist item
     | goto . . . . . . . . . . . . goto item at index
     | clear . . . . . . . . . . . clear the playlist
     | atus . . . . . . . . . current playlist status
     | title [X]  . . . . set/get title in current item
     | title_n  . . . . . .  next title in current item
     | title_p  . . . .  previous title in current item
     | chapter [X]  . . set/get chapter in current item
     | chapter_n  . . . .  next chapter in current item
     | chapter_p  . .  previous chapter in current item
     |
     | seek X . seek in seconds, for instance 'seek 12'
     | pause  . . . . . . . . . . . . . .  toggle pause
     | fastforward  . . . . . .  .  set to maximum rate
     | rewind  . . . . . . . . . .  set to minimum rate
     | faster . . . . . . . .  faster playing of stream
     | slower . . . . . . . .  slower playing of stream
     | normal . . . . . . . .  normal playing of stream
     | f [on|off] . . . . . . . . . . toggle fullscreen
     | info . . .  information about the current stream
     |
     | volume [X] . . . . . . . .  set/get audio volume
     | volup [X]  . . . . .  raise audio volume X steps
     | voldown [X]  . . . .  lower audio volume X steps
     | adev [X] . . . . . . . . .  set/get audio device
     | achan [X]. . . . . . . .  set/get audio channels
     | menu [on|off|up|down|left|right|select] use menu
     |
     | marq-marquee STRING  . . overlay STRING in video
     | marq-x X . . . . . . . . . . . .offset from left
     | marq-y Y . . . . . . . . . . . . offset from top
     | marq-position #. . .  .relative position control
     | marq-color # . . . . . . . . . . font color, RGB
     | marq-opacity # . . . . . . . . . . . . . opacity
     | marq-timeout T. . . . . . . . . . timeout, in ms
     | marq-size # . . . . . . . . font size, in pixels
     |
     | time-format STRING . . . overlay STRING in video
     | time-x X . . . . . . . . . . . .offset from left
     | time-y Y . . . . . . . . . . . . offset from top
     | time-position #. . . . . . . . relative position
     | time-color # . . . . . . . . . . font color, RGB
     | time-opacity # . . . . . . . . . . . . . opacity
     | time-size # . . . . . . . . font size, in pixels
     |
     | logo-file STRING . . . the overlay file path/name
     | logo-x X . . . . . . . . . . . .offset from left
     | logo-y Y . . . . . . . . . . . . offset from top
     | logo-position #. . . . . . . . relative position
     | logo-transparency #. . . . . . . . .transparency
     |
     | mosaic-alpha # . . . . . . . . . . . . . . alpha
     | mosaic-height #. . . . . . . . . . . . . .height
     | mosaic-width # . . . . . . . . . . . . . . width
     | mosaic-xoffset # . . . .top left corner position
     | mosaic-yoffset # . . . .top left corner position
     | mosaic-align 0..2,4..6,8..10. . .mosaic alignment
     | mosaic-vborder # . . . . . . . . vertical border
     | mosaic-hborder # . . . . . . . horizontal border
     | mosaic-position {0=auto,1=fixed} . . . .position
     | mosaic-rows #. . . . . . . . . . .number of rows
     | mosaic-cols #. . . . . . . . . . .number of cols
     | mosaic-keep-aspect-ratio {0,1} . . .aspect ratio
     |
     | help . . . . . . . . . . . . . this help message
     | longhelp . . . . . . . . . a longer help message
     | logout . . . . .  exit (if in socket connection)
     | quit . . . . . . . . . . . . . . . . .  quit vlc
     |
     +----[ end of help ]
 
 "
class Vlc(Socket socket) {
	
	variable Boolean paused = false;
	
	shared void command(String command) {
		socket.writeFully(ascii.encode(command + operatingSystem.newline));
	}
	
	shared void pause() {
		paused = !paused;
		command("pause");
	}
	
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

