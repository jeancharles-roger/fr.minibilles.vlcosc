import com.illposed.osc {
	OSCPortIn
}

import fr.minibilles.cli {
	option
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