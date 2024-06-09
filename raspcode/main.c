#include "raspserv.h"

#define WIFI_PORT 12345 // Port for the WiFi socket

int wifi_server_socket, wifi_client_socket;
int bluetooth_server_socket, bluetooth_client_socket;

void	setupWifiSocket(void)
{
	struct sockaddr_in	server_addr;

	// Initialize the WiFi server socket
	wifi_server_socket = socket(AF_INET, SOCK_STREAM, 0);
	memset(&server_addr, 0, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_addr.s_addr = INADDR_ANY;
	server_addr.sin_port = htons(WIFI_PORT);
	bind(wifi_server_socket, (struct sockaddr *)&server_addr,
		sizeof(server_addr));
	listen(wifi_server_socket, 1);
	printf("WiFi server listening on port %d...\n", WIFI_PORT);
}

void	openBluetoothSocket(void)
{
	// Initialize the Bluetooth socket
	// (Add your Bluetooth setup code here)
	// Example:
	// server_socket = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
	// (Set up the Bluetooth socket and start listening)
	printf("Bluetooth server listening...\n");
}

void	closeSockets(void)
{
	// Close WiFi socket
	close(wifi_client_socket);
	close(wifi_server_socket);
	// Close Bluetooth socket
	close(bluetooth_client_socket);
	close(bluetooth_server_socket);
}

void handleWifiCommand(const char* command) {
    // Add code to handle WiFi commands here
    if (strcmp(command, "OPEN_BLUETOOTH") == 0) {
        // Open the Bluetooth socket
        // (Add your Bluetooth logic here)
        printf("Opening Bluetooth...\n");
    } else if (strcmp(command, "OTHER_COMMAND") == 0) {
        // Handle other commands as needed
    }
}

int main(void) {
    setupWifiSocket();
    openBluetoothSocket();

    struct sockaddr_in wifi_client_addr;
    socklen_t wifi_client_addr_len = sizeof(wifi_client_addr);

    while (1) {
        wifi_client_socket = accept(wifi_server_socket, (struct sockaddr*)&wifi_client_addr, &wifi_client_addr_len);
        if (wifi_client_socket == -1) {
            perror("Error accepting WiFi connection");
            continue;
        }
        printf("WiFi client connected.\n");

        char buffer[1024];
        int bytes_received = recv(wifi_client_socket, buffer, sizeof(buffer), 0);
        if (bytes_received <= 0) {
            perror("Error receiving data");
        } else {
            buffer[bytes_received] = '\0';
            printf("Received command from WiFi client: %s\n", buffer);
            handleWifiCommand(buffer);
        }

        close(wifi_client_socket);
        printf("WiFi client disconnected.\n");
    }

    closeSockets();
    return 0;
}