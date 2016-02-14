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
	return Vlc(socket);
}


"Run the module `fr.minibilles.vlcosc`."
shared void run() {

	value vlcAddress = "localhost";
	value vlcPort = 9999;
	value file = "/Volumes/diskE/Users/j5r/Documents/Personnel/musique/Space Oddity (2009) David Bowie/01 Space Oddity (Mono Single Edit) (2009 Digital Remaster).mp3";
	//value file = "/Volumes/video/Films Vus/alfie.avi";
	
	value vlc = connectVlc(vlcAddress, vlcPort);
	vlc.add(file);
	
	print("Connected on VLC on ``vlcAddress``:``vlcPort``");

	value port = OSCPortIn.defaultSCOSCPort();
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

	while (true) {
		Thread.sleep(50);
	}

}

