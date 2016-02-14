import com.illposed.osc {
	OSCPortIn,
	OSCListener,
	OSCMessage
}
import java.nio.charset {
	StandardCharsets
}
import java.util {
	Date
}
import java.lang {
	Runnable,
	Thread,
	ProcessBuilder,
	Process
}
import java.io {
	PrintWriter,
	BufferedReader,
	InputStreamReader
}

[Process, PrintWriter] createVlcProcess(String vlcPath) {
	value builder = ProcessBuilder(vlcPath, "-I", "cli");
	value vlc = builder.start();
	value writer = PrintWriter(vlc.outputStream);
	
	// uses a Thread to read the output buffer.
	// Windows problem:
	// The output buffer has a limited size, it must be read or the process will be blocked.
	// See http://support.microsoft.com/kb/326709/fr
	value outReader = BufferedReader(InputStreamReader(vlc.inputStream));
	Thread(object satisfies Runnable {
		shared actual void run() {
			variable String? line = outReader.readLine();
			while (exists currentLine = line) {
				process.writeLine(currentLine);
				line = outReader.readLine();
			}
		}
	}).start();	
	
	value errReader = BufferedReader(InputStreamReader(vlc.errorStream));
	Thread(object satisfies Runnable {
		shared actual void run() {
			variable String? line = errReader.readLine();
			while (exists currentLine = line) {
				process.writeErrorLine(currentLine);
				line = errReader.readLine();
			}
		}
	}).start();	
	
	return [vlc, writer];
}

class VlcStatus(String file, PrintWriter consoleWriter) {
	
	variable Boolean paused = false;
	
	void command(String command) {
		consoleWriter.println(command);
		consoleWriter.flush();
	}
	
	shared void pause() {
		paused = !paused;
		command("pause");
	}
	
	shared void add(String file) => command("add ``file``");
	
	add(file);
	pause();
}


"Run the module `fr.minibilles.vlcosc`."
shared void run() {

	value vlcExe = "/Applications/VLC.app/Contents/MacOS/VLC";
	value file = "/Volumes/diskE/Users/j5r/Documents/Personnel/musique/Space Oddity (2009) David Bowie/01 Space Oddity (Mono Single Edit) (2009 Digital Remaster).mp3";
	//value file = "/Volumes/video/Films Vus/alfie.avi";
	
	value [process, writer] = createVlcProcess(vlcExe);

	value vlc = VlcStatus(file, writer);

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

	print("Listening on ``port``.");

	process.waitFor();

}

