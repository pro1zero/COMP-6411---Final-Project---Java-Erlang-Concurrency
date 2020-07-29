
import java.util.*;
import java.io.*;

public class exchange {
	static List<String> senders = new ArrayList<>();
	static HashMap<Integer, List<String>> responses = new HashMap<>();
	static class MasterPrinter extends Thread{
		static List<String> printStatements = new ArrayList<>();
		public MasterPrinter() {
			start();
			while(printStatements.size() != 0) {
				try {
					Thread.sleep(50);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				String response = printStatements.get(0);
				String identifier = "";
				for(int i = 0; i < response.length(); i++) {
					if(Character.isDigit(response.charAt(i)))
						identifier += response.charAt(i);
						
				}
				int ID = Integer.parseInt(identifier);
				List<String> temp = responses.get(ID);
				response = temp.get(0) + " received a reply message from " + temp.get(1) + " ["+  ID + "]";
				System.out.println(response);
				printStatements.remove(0);
			}
		}
		
		public void run() {
			try {
				Thread.sleep(5500);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			System.out.println();
			for(int i = 0; i < senders.size(); i++) {
				System.out.println("Process " + senders.get(i) + " has received no calls for 5 seconds, ending...");
				System.out.println();
			}
			try {
				Thread.sleep(5000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			System.out.println("Master has received no requests for 10 seconds, ending...");
		}
		
		
	}
	
	static class Users extends Thread{
		String user;
		List<String> receivers;
		public Users(String user, List<String> list) {
			this.user = user;
			this.receivers = list;
			Random r = new Random();
			int sleepTime = 50 + r.nextInt(50);
			try {
				Thread.sleep(sleepTime);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
		public void run() {
			Random r = new Random();
			
			for(int i = 0; i < receivers.size(); i++) {
				int ID = 500000 + r.nextInt(500000);
				String message = receivers.get(i) + " received an intro message from " + user + "["+ ID + "]";
				MasterPrinter.printStatements.add(message);
				List<String> temp = List.of(user, receivers.get(i));
				responses.put(ID, temp);
				try {
					Thread.sleep(50);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				System.out.println(message);
			}
		}
		
	}
	
	static HashMap<String, List<String>> data;
	static List<String> records = new ArrayList<>();
	public static void fetchData(){
		
		File file = new File("calls.txt");
	      Scanner scan = null;
		try {
			scan = new Scanner(file);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	      
	      while (scan.hasNextLine()) {
	        records.add(scan.nextLine());
	      }
	      scan.close();
	 }
	
	
	public static void main(String[] args) {
		fetchData();
		HashMap<String, List<String>> map = new HashMap<>();
		for(int i = 0; i < records.size(); i++) {
			String temp = records.get(i);
			temp = temp.replace("[", "");
			temp = temp.replace("]", "");
			temp = temp.replace("{", "");
			temp = temp.replace("}", "");
			temp = temp.replace(".", "");
			temp = temp.replace(" ", "");
			
			String[] words = temp.split(",");
			List<String> r = new ArrayList<>();
			for(int j = 1; j < words.length; j++) {
				r.add(words[j]);
			}
			map.put(words[0], r);
		}
		
		System.out.println("** Calls to be made**");
		System.out.println();
		for(String user: map.keySet()) {
			System.out.println(user + ": " + map.get(user));
		}
		System.out.println();
		for(String user: map.keySet()) {
			try {
				senders.add(user);
				new Users(user, map.get(user)).start();
			}
			catch(Exception e) {
				System.out.println(e);
			}
		}
		
		@SuppressWarnings("unused")
		//This is for the constructor to initiate the run method.
		MasterPrinter object = new MasterPrinter();
	}
}
