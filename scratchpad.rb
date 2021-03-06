void printDacBoxStatus(dacBoxStatus_t* db, uint8_t b) {
#define OS1 "      "
#define OS0 "    "
<<<<<<< HEAD

  LOV_INF("--------------------------------------------------\n");
  LOV_INF("dacBoxStatus->\n");
  LOV_INF(OS0"board [%d] ->\n", b);

  LOV_INF(OS1"Mum          ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    LOV_INF("% 8d", i);
  }
  LOV_INF("\n");
  LOV_INF(OS1"channelDacVal   [ ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    LOV_INF("0x%04x, ", (int) db->board[b].channelDacVal[i]);
  }
  LOV_INF("]\n");
  LOV_INF(OS1"channelSpanCode [ ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    LOV_INF("0x%04x, ", (int) db->board[b].channelSpanCode[i]);
  }
  LOV_INF("]\n");
  LOV_INF(OS1"channelIsOn     [ ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    LOV_INF("% 6d, ", (int) db->board[b].channelIsOn[i]);
  }
  LOV_INF("]\n");
  LOV_INF(OS1"monitorMux      0x%04x\n", db->board[b].monitorMux);
  LOV_INF(OS1"toggleSelect    0x%04x\n", db->board[b].toggleSelect);
  LOV_INF(OS1"globalToggle    0x%04x\n", db->board[b].globalToggle);
  LOV_INF(OS1"config          0x%04x\n", db->board[b].config);
  LOV_INF("--------------------------------------------------\n");

}
=======
  char istr[1024] = {0};
  int c = 0;
  LOG_INF("--------------------------------------------------");
  LOG_INF("dacBoxStatus->");
  LOV_INF(OS0"board [%d] ->\n", b);
>>>>>>> 9bafa592444fbdcf9dd46e74453a5fba7474151d

  c += sprintf(istr + c, OS1"Mum          ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    c += sprintf(istr + c, "% 8d", i);
  }
  c = 0;
  LOG_INF(istr);
  c += sprintf(istr + c, OS1"channelDacVal   [ ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    c += sprintf(istr + c, "0x%04x, ", (int) db->board[b].channelDacVal[i]);
  }
  c += sprintf(istr + c, "]");
  c = 0;
  LOG_INF(istr);
  c += sprintf(istr + c, OS1"channelSpanCode [ ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    c += sprintf(istr + c, "0x%04x, ", (int) db->board[b].channelSpanCode[i]);
  }
  c += sprintf(istr + c, "]");
  c = 0;
  LOG_INF(istr);
  c += sprintf(istr + c, OS1"channelIsOn     [ ");
  for (int i = 0; i < BOARD_CHANNEL_COUNT; i++) {
    c += sprintf(istr + c, "% 6d, ", (int) db->board[b].channelIsOn[i]);
  }
  c += sprintf(istr + c, "]");
  c = 0;
  LOG_INF(istr);
  LOV_INF("]");
  LOV_INF(OS1"monitorMux      0x%04x", db->board[b].monitorMux);
  LOV_INF(OS1"toggleSelect    0x%04x", db->board[b].toggleSelect);
  LOV_INF(OS1"globalToggle    0x%04x", db->board[b].globalToggle);
  LOV_INF(OS1"config          0x%04x", db->board[b].config);
  LOV_INF("--------------------------------------------------");
  LOG_INF(istr);
}

Sep 20 13:20:10 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 0: 0x0 
Sep 20 13:20:10 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 1: 0x30
Sep 20 13:20:10 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 2: 0x80
Sep 20 13:20:10 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 3: 0x0 

Sep 20 13:27:28 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 0: 0x78
Sep 20 13:27:28 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 1: 0x56
Sep 20 13:27:28 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 2: 0x34
Sep 20 13:27:28 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 3: 0x12

Sep 20 13:30:00 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 0: 0x00
Sep 20 13:30:00 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 1: 0x30
Sep 20 13:30:00 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 2: 0xbf
Sep 20 13:30:00 dacbox_pi masc_pi_service: (printCmd:104) dacCmd byte 3: 0xff



78
56

12345678

0 


00803000

00
30

0xffbf3000


APB_ADDR_OFFSET = 0x43C00000
PAGE_SIZE = 4096



puts APB_ADDR_OFFSET % PAGE_SIZE
puts  PAGE_SIZE % APB_ADDR_OFFSET
puts APB_ADDR_OFFSET / PAGE_SIZE
puts APB_ADDR_OFFSET / 4
puts APB_ADDR_OFFSET / 8
puts APB_ADDR_OFFSET % 8


// From data sheet  
#define W_CODE_TO_N           0b0000    // Write Code to n
#define UPD_N_PU              0b0001    // Update n (Power Up)
#define W_CODE_TO_N_UPD_ALL   0b0010    // Write Code to n, Update All (Power Up)
#define W_CODE_TO_N_UPD_N     0b0011    // Write Code to n, Update n (Power Up)
#define PWD_N                 0b0100    // Power Down n
#define PWD_IC                0b0101    // Power Down Chip (All DACs, Mux and Reference)
#define W_SPAN_TO_N           0b0110    // Write Span to n
#define CONFIG                0b0111    // Config
#define W_CODE_TO_ALL         0b1000    // Write Code to All
#define UPD_ALL_PU            0b1001    // Update All (Power Up)
#define W_CODE_TO_ALL_UPD_ALL 0b1010    // Write Code to All, Update All (Power Up)
#define MONITOR_MUX           0b1011    // Monitor Mux
#define W_SPAN_TO_ALL         0b1110    // Write Span to All
#define TOGGLE_SEL            0b1100    // Toggle Select
#define GLOBAL_TOGGLE         0b1101    // Global Toggle
#define NOP                   0b1111    // No Operation

enum {
   CHANNELDACVAL,
   CHANNELSPANCODE,
   CHANNELISON,
   MONITORMUX,
   TOGGLESELECT,
   GLOBALTOGGLE,
   CONFIG,
}


#define GENERATE_CASE(NAME) \
                 case NAME##_e: \
                    return sizeof(struct NAME); \
                 break;

case W_CODE_TO_N          :    // Write Code to n

break;  
case W_CODE_TO_ALL        :    // Write Code to All

break;  
case W_SPAN_TO_N          :    // Write Span to n

break;  
case W_SPAN_TO_ALL        :    // Write Span to All

break;  
case UPD_N_PU             :    // Update n (Power Up)

break;  
case UPD_ALL_PU           :    // Update All (Power Up)

break;  
case W_CODE_TO_N_UPD_N    :    // Write Code to n, Update n (Power Up)

break;  
case W_CODE_TO_N_UPD_ALL  :    // Write Code to n, Update All (Power Up)

break;  
case W_CODE_TO_ALL_UPD_ALL:    // Write Code to All, Update All (Power Up)

break;  
case PWD_N                :    // Power Down n

break;  
case PWD_IC               :    // Power Down Chip (All DACs, Mux and Reference)

break;  
case MONITOR_MUX          :    // Monitor Mux

break;  
case TOGGLE_SEL           :    // Toggle Select

break;  
case GLOBAL_TOGGLE        :    // Global Toggle

break;  
case CONFIG               :    // Config

break;  
case NOP                  :    // No Operation

break;  