#include "cmark.h"
#include <stdio.h>
 
#include <stdio.h>
#include <stdint.h>
#include <windows.h>
 
void print_error(const char * context)
{
CMARK(1);   DWORD error_code = GetLastError();
CMARK(2);   char buffer[256];
  DWORD size = FormatMessageA(
    FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_MAX_WIDTH_MASK,
    NULL, error_code, MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
CMARK(3);     buffer, sizeof(buffer), NULL);
CMARK(4);   if (size == 0) { buffer[0] = 0; }
CMARK(5);   fprintf(stderr, "%s: %s\n", context, buffer);
}
 
HANDLE open_serial_port(const char * device, uint32_t baud_rate)
{
  HANDLE port = CreateFileA(device, GENERIC_READ | GENERIC_WRITE, 0, NULL,
CMARK(6);     OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (port == INVALID_HANDLE_VALUE)
  {
CMARK(7);     print_error(device);
CMARK(8);     return INVALID_HANDLE_VALUE;
  }
 
CMARK(9);   BOOL success = FlushFileBuffers(port);
  if (!success)
  {
CMARK(10);     print_error("Failed to flush serial port");
CMARK(11);     CloseHandle(port);
CMARK(12);     return INVALID_HANDLE_VALUE;
  }
 
CMARK(13);   COMMTIMEOUTS timeouts = { 0 };
CMARK(14);   timeouts.ReadIntervalTimeout = 0;
CMARK(15);   timeouts.ReadTotalTimeoutConstant = 100;
CMARK(16);   timeouts.ReadTotalTimeoutMultiplier = 0;
CMARK(17);   timeouts.WriteTotalTimeoutConstant = 100;
CMARK(18);   timeouts.WriteTotalTimeoutMultiplier = 0;
 
CMARK(19);   success = SetCommTimeouts(port, &timeouts);
  if (!success)
  {
CMARK(20);     print_error("Failed to set serial timeouts");
CMARK(21);     CloseHandle(port);
CMARK(22);     return INVALID_HANDLE_VALUE;
  }
 
CMARK(23);   DCB state;
CMARK(24);   state.DCBlength = sizeof(DCB);
CMARK(25);   success = GetCommState(port, &state);
  if (!success)
  {
CMARK(26);     print_error("Failed to get serial settings");
CMARK(27);     CloseHandle(port);
CMARK(28);     return INVALID_HANDLE_VALUE;
  }
 
CMARK(29);   state.BaudRate = baud_rate;
 
CMARK(30);   success = SetCommState(port, &state);
  if (!success)
  {
CMARK(31);     print_error("Failed to set serial settings");
CMARK(32);     CloseHandle(port);
CMARK(33);     return INVALID_HANDLE_VALUE;
  }
 
CMARK(34);   return port;
}
 
int write_port(HANDLE port, uint8_t * buffer, size_t size)
{
CMARK(35);   DWORD written;
CMARK(36);   BOOL success = WriteFile(port, buffer, size, &written, NULL);
  if (!success)
  {
CMARK(37);     print_error("Failed to write to port");
CMARK(38);     return -1;
  }
  if (written != size)
  {
CMARK(39);     print_error("Failed to write all bytes to port");
CMARK(40);     return -1;
  }
CMARK(41);   return 0;
}
 
SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)
{
CMARK(42);   DWORD received;
CMARK(43);   BOOL success = ReadFile(port, buffer, size, &received, NULL);
  if (!success)
  {
CMARK(44);     print_error("Failed to read from port");
CMARK(45);     return -1;
  }
CMARK(46);   return received;
}
 
int jrk_set_target(HANDLE port, uint16_t target)
{
CMARK(47);   if (target > 4095) { target = 4095; }
CMARK(48);   uint8_t command[2];
CMARK(49);   command[0] = 0xC0 + (target & 0x1F);
CMARK(50);   command[1] = (target >> 5) & 0x7F;
CMARK(51);   return write_port(port, command, sizeof(command));
}
 
int jrk_get_variable(HANDLE port, uint8_t offset, uint8_t * buffer,
  uint8_t length)
{
CMARK(52);   uint8_t command[] = { 0xE5, offset, length };
CMARK(53);   int result = write_port(port, command, sizeof(command));
CMARK(54);   if (result) { return -1; }
CMARK(55);   SSIZE_T received = read_port(port, buffer, length);
CMARK(56);   if (received < 0) { return -1; }
  if (received != length)
  {
    fprintf(stderr, "read timeout: expected %u bytes, got %ld\n",
CMARK(57);       length, received);
CMARK(58);     return -1;
  }
CMARK(59);   return 0;
}
 
int jrk_get_target(HANDLE port)
{
CMARK(60);   uint8_t buffer[2];
CMARK(61);   int result = jrk_get_variable(port, 0x02, buffer, sizeof(buffer));
CMARK(62);   if (result) { return -1; }
CMARK(63);   return buffer[0] + 256 * buffer[1];
}
 
int jrk_get_feedback(HANDLE port)
{
CMARK(64);   uint8_t buffer[2];
CMARK(65);   int result = jrk_get_variable(port, 0x04, buffer, sizeof(buffer));
CMARK(66);   if (result) { return -1; }
CMARK(67);   return buffer[0] + 256 * buffer[1];
}
 
int main()
{
CMARK(68);   const char * device = "\\\\.\\COM7";
 
CMARK(69);   uint32_t baud_rate = 9600;
 
CMARK(70);   HANDLE port = open_serial_port(device, baud_rate);
CMARK(71);   if (port == INVALID_HANDLE_VALUE) { return 1; }
 
CMARK(72);   int target = jrk_get_target(port);
CMARK(73);   if (target < 0) { return 1; }
 
CMARK(74);   int new_target = (target < 2048) ? 2248 : 1848;
CMARK(75);   int result = jrk_set_target(port, new_target);
CMARK(76);   if (result) { return 1; }

CMARK(77);   int feedback = jrk_get_feedback(port);
CMARK(78);   if (feedback < 0) { return 1; }
 
CMARK(79);   if (feedback > 0) { return 1; }
CMARK(80);    printf("Under Pressure!");
CMARK(81);    return 1;
  }

CMARK(82);   CloseHandle(port);
CMARK(83);   return 0;
}
