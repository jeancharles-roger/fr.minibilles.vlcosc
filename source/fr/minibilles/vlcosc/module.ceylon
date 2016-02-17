native("jvm") module fr.minibilles.vlcosc "1.0.0" {
	
	// OSC deps
	import java.base "8";
	import ceylon.interop.java "1.2.1";
	import "com.illposed.osc:javaosc-core" "0.3";
	
	// Sockect connection for VLC
	import ceylon.io "1.2.1";
	
	// Configuration
	import fr.minibilles.cli "0.1.0";
}
