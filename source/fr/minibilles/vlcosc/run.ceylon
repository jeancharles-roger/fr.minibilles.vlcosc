import ceylon.io {
	newSocketConnector,
	SocketAddress,
	Socket
}
import ceylon.io.charset {
	utf8
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


class Vlc(Socket socket) {
	
	variable Boolean paused = false;
	
	void command(String command) {
		socket.writeFully(utf8.encode(command + operatingSystem.newline));
	}
	
	shared void pause() {
		paused = !paused;
		command("pause");
	}
	
	shared void add(String file) => command("add ``file``");
	
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
			print("Message on ``message.address``: ``message.arguments``.");			
			vlc.pause();
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
	
	value file = "/Volumes/diskE/Users/j5r/Documents/Personnel/musique/Space Oddity (2009) David Bowie/01 Space Oddity (Mono Single Edit) (2009 Digital Remaster).mp3";
	
	value vlc = connectVlc(options.host, options.port);
	vlc.add(file);
	
	startOscServer(options.oscPort, vlc);
	
	while (true) {
		Thread.sleep(50);
	}

}

