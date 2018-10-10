void printDacBoxStatus(dacBoxStatus_t* db, uint8_t b) {
#define OS1 "      "
#define OS0 "    "
  char istr[1024] = {0};
  int c = 0;
  LOG_INF("--------------------------------------------------");
  LOG_INF("dacBoxStatus->");
  LOV_INF(OS0"board [%d] ->\n", b);

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


