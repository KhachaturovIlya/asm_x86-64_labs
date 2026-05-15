TARGET = main

CC = gcc

MY_CFLAGS = -g -Wall -Wextra -fsanitize=address
LDFLAGS = -fsanitize=address

override CFLAGS += $(MY_CFLAGS)

SRCS = main.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

re: clean all

.PHONY: clean all re
