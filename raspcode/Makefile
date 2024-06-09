CC = gcc
CFLAGS = -Wall -Wextra

SRC = main.c

EXECUTABLE = rpiserv

# Libraries
LIBS = `pkg-config --cflags --libs bluez` -lbluetooth -lwiringPi -lpthread

# Header files directory (if needed)
INCLUDES = -I.

# Help message
HMSG = !!! USE SUDO ./$(EXECUTABLE) !!!

# Targets
all: $(EXECUTABLE)
	@echo $(HMSG)

$(EXECUTABLE): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(EXECUTABLE) $(LIBS) $(INCLUDES)

clean:
	rm -f $(EXECUTABLE)
