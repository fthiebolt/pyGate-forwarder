# Tests

### Pygate reset
- reset_pygate.py --> uses a GPIO to reset the board

### SPI loopback test
`gcc -o spidev_test spidev_test.c`
./spidev_test -D /dev/spidev0.0 --speed=8000000


