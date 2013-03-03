import java.io.IOException;


class HaskellProcessBuilder {
	
	private ProcessBuilder pb;
	
	HaskellProcessBuilder(){
        String osName = System.getProperty("os.name").toLowerCase();
        String shellAdress = "";
   		String shellArguments = "";
   		String shellProg = "";
   		if (osName.startsWith("windows")){
        	shellAdress = "cmd.exe";
        	shellArguments = "/C";
        	shellProg = "chords.exe";
   		}
   		else if (osName.startsWith("linux")){
        	shellAdress = "/bin/sh";
        	shellArguments = "-c";
        	shellProg = "./chords";
        }
        pb = new ProcessBuilder(shellAdress, shellArguments, shellProg);
        pb.redirectErrorStream(true);
	}
	
	Process start() throws IOException {
		return pb.start();
	}
}