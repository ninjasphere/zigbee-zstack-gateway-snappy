// A command line tool for writing a ZNP request frame to the UART and reading and printing the response frame.
// The printed frame includes all the bytes between, but not including, the frame length and frame check sequence
// bytes.
//
// The UART is addressed by the tty option. If the tty option is not specified, /dev/tty.zigbee is assumed.
//
// If --stdout is specified, the UART is not used and instead the full frame is written to stdout.
package main

// #include <termios.h>
// #include <poll.h>
// typedef struct pollfd pollfd;
import "C"

import (
	serial "github.com/huin/goserial"

	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"time"
)

var (
	tty = "/dev/tty.zigbee"
)

// Open a device and set various control parameters, such as baud rate.
func open(tty string) io.ReadWriteCloser {
	c := &serial.Config{Name: tty, Baud: 115200}
	// out, err = os.OpenFile(tty, os.O_RDWR, 0x666) // ,
	out, err := serial.OpenPort(c)
	if err != nil {
		log.Fatalf("Unable to open %s: %v", tty, err)
	}
	return out
}

// Read the specified number of bytes from the input stream or die trying.
func mustRead(in io.ReadCloser, bytes []byte) int {
	var offset = 0
	pollfd := &C.pollfd{
		fd:      C.int(in.(*os.File).Fd()),
		events:  C.POLLIN,
		revents: 0,
	}

	for offset < len(bytes) {
		rc := C.poll(pollfd, 1, -1)
		switch rc {
		case 0, 1:
			break
		default:
			log.Fatalf("Poll failed with rc = %d", rc)
		}
		n, err := in.Read(bytes[offset:])
		offset += n
		if err != nil {
			log.Fatalf("Unexpected error while reading %d bytes from input: %v", len(bytes), err)
		}
	}
	return len(bytes)
}

// build a frame from the specified hex values
func buildFrame(args []string) []byte {

	var xor byte

	length := len(args) - 2
	frame := make([]uint8, length+5)
	frame[0] = 0xfe
	frame[1] = (uint8)(length)
	xor = frame[1]

	for i, x := range args {
		n, err := fmt.Sscanf(x, "%x", &frame[i+2])
		if n != 1 || err != nil {
			log.Fatalf("Could not parse hex value from '%s'.", x)
		}
		xor = xor ^ frame[i+2]
	}

	frame[length+4] = xor

	return frame
}

// read a resonse frame from the UART
func processResponse(io io.ReadWriteCloser) byte {
	sof := make([]byte, 1)
	mustRead(io, sof)
	if sof[0] != 0xfe {
		log.Fatalf("Unexpected byte (%02x) found in place of SOF", sof[0])
	}

	header := make([]byte, 3)
	mustRead(io, header)
	xor := (byte)(header[0] ^ header[1] ^ header[2])

	packet := make([]byte, header[0])
	mustRead(io, packet)
	for _, b := range packet {
		xor = xor ^ (byte)(b)
	}

	fcs := make([]byte, 1)
	mustRead(io, fcs)

	if uint8(xor) == fcs[0] {
		fmt.Printf("%02x %02x", header[1], header[2])
		for _, b := range packet {
			fmt.Printf(" %02x", b)
		}
		fmt.Printf("\n")
	} else {
		log.Fatalf("FCS byte contained incorrect XOR value. Expected %02x, but found %02x", xor, fcs[0])
	}
	return header[1]
}

func main() {
	var stdout bool
	var reopen bool
	var delay int

	flag.BoolVar(&stdout, "stdout", false, "Write the specified frame to stdout instead of to a tty.")
	flag.StringVar(&tty, "tty", "/dev/tty.zigbee", "The tty device to use.")
	flag.IntVar(&delay, "delay", 0, "The number of seconds to delay before re-opening the tty after a reset command.")
	flag.Parse()

	args := flag.Args()

	length := len(args) - 2

	if length < 0 || length > 255 {
		fmt.Printf("usage: cc2530-frame {options} [subSysId] [cmdId] [hex...]\n")
		flag.PrintDefaults()
		os.Exit(1)
	}

	frame := buildFrame(args)

	if frame[2] == 0x41 && frame[3] == 0x00 && !stdout {
		reopen = true
	}

	var io io.ReadWriteCloser

	if stdout {
		io = os.Stdout
	} else {
		io = open(tty)
	}

	io.Write(frame)

	if reopen {
		io.Close()

		time.Sleep(time.Second * time.Duration(delay))

		io = open(tty)
		io.Write([]byte{0xef})
		io.Close()

		io = open(tty)
	}

	if !stdout {
		for {
			responseSubsysId := processResponse(io)
			if responseSubsysId == (frame[2]|0x20) || responseSubsysId == frame[2] {
				// we received a response that wasn't for the command we
				// sent
				break
			}
		}
	}
}
