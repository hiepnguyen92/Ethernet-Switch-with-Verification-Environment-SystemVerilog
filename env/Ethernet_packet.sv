//*************************************************************
//Ethernet Packet Class
//This class defines all the properties of an ethernet packet
//This class is part of Testbench for Ethernet DUT
//*************************************************************

class Ethernet_packet;

	rand bit [47:0] source_address;
	rand bit [47:0] destination_address;
	rand byte packet_data[$];                 //queue of packet data (payload) without Source add, dest add and crc
	bit [15:0] frame_type;			 //Ethernet type such as: IPv4, ARP, IPv6, etc.
	bit [1:0] packet_type;			 //type of Ethernet Frame payload (input signal: framegen_patmode)
	bit [31:0] packet_CRC;
	int packet_size;                         //Total size of the packet
	byte full_packet[$];                     //Queue of full ethernet Packet with source and destination address and CRC

	function new();
	endfunction
		
	function void build_packet(); 	                   //function to create build entire packet
		int packet_size;
//		packet_size = $urandom_range(46,1500);           //minimum size of the packet should be 46 Bytes and max should be 1500 Bytes
//		packet_size = (packet_size>>2)<<2;
		int packet_size = $urandom_range(46, 1500) inside {[46:1500]};
		bit [1:0] packet_type = $urandom_range(0, 2);
		
		if (packet_type == 0) begin
      			for (int i = 0; i < packet_size; i += 4) begin
         			packet_data.push_back(i % 256); // Bytewise incremental
         			packet_data.push_back((i + 1) % 256);
         			packet_data.push_back((i + 2) % 256);
         			packet_data.push_back((i + 3) % 256);
      			end
   		end
		else if (packet_type == 1) begin
      			byte [7:0] pattern[4] = '{8'hFF, 8'h00, 8'h55, 8'hCC}; // Constant repeating
     			for (int i = 0; i < packet_size; i += 4) begin
         			packet_data.push_back(pattern[i % 4]);
         			packet_data.push_back(pattern[(i + 1) % 4]);
         			packet_data.push_back(pattern[(i + 2) % 4]);
         			packet_data.push_back(pattern[(i + 3) % 4]);
      			end
   		end
   		else begin
      			foreach (packet_data[i]) begin
         			packet_data[i] = $urandom(); // Random
      			end
   		end
		
	endfunction
	function void build_frame_type();
		bit [15:0] frame_type_values[3] = '{16'h0800, 16'h0806, 16'h86DD}; //IPv4, ARP, IPv6
   		frame_type = frame_type_values[$urandom_range(0, 2)];
	endfunction
	function void build_crc();
		packet_CRC = 32'hABCDDEAD;
	endfunction
	
	function void build_address();
		int random_num;
		random_num = $urandom_range(0,3);
		case(random_num)
		 0:
			begin
				source_address = 48'hAABB_CCDD_EEFF;
				destination_address = 48'hBEEF_BEEF_BEEF;
			end
		1:
			begin
				source_address = 48'h1111_2222_3333;
				destination_address = 48'hBEEF_BEEF_BEEF;
			end
		2:
			begin
				source_address = 48'hAABB_CCDD_EEFF;
				destination_address = 48'hBEEF_BEEF_BEEF;
			end
		3:
			begin
				source_address = 48'hAABB_CCDD_EEFF;
				destination_address = 48'hBEEF_BEEF_BEEF;
			end
		endcase
	endfunction
	
	function void post_randomize();
		packet_size = packet_data.size() +6 +6 +2 +4; //size of data + source add + dest add + ethertype + CRC all in bytes
		build_address(); //temporary using fixed address
		build_frame_type();
		build_packet(); 
		build_crc();
		for( int i = 0; i <6 ; i++)
			begin
				full_packet.push_back(destination_address >> i*8);     //adding destination address in the Ethernet packet
			end
		for( int i = 0; i <6 ; i++)
			begin
				full_packet.push_back(source_address >> i*8);         //adding source address to the Ethernet packet queue
			end
		for( int i = 0; i <= packet_data.size(); i++)
			begin
				full_packet.push_back(packet_data[i]);                //adding source address to the Data packet queue
			end
		for( int i = 0; i <4 ; i++)
			begin
				full_packet.push_back(packet_CRC >> i*8);            //adding source CRC to the Ethernet packet queue
			end
	endfunction
	
			
	function bit packet_compare(Ethernet_packet pkt);
		if(this.full_packet == full_packet)
			begin
				return 1;
			end
		else
		
			begin
				return 0;
			end
	endfunction
	
	function string packet_details();
		string details;
		details = $psprintf("sa = %x da = %x crc = %x", source_address, destination_address, packet_CRC);
		return details;
	endfunction
	
	
endclass : Ethernet_packet
	
		


