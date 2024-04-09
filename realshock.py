"""
File:                       shock.py (adapted from a_out_scan.py)

Library Call Demonstrated:  mcculw.ul.a_out_scan()

Purpose:                    Writes to a range of D/A Output Channels.

Demonstration:              Sends a digital output to the D/A channels

Other Library Calls:        mcculw.ul.win_buf_alloc()
                            mcculw.ul.win_buf_free()
                            mcculw.ul.get_status()
                            mcculw.ul.release_daq_device()

Special Requirements:       Device must have D/A converter(s).
                            This function is designed for boards that
                            support timed analog output.  It can be used
                            for polled output boards but only for values
                            of NumPoints up to the number of channels
                            that the board supports (i.e., NumPoints =
                            6 maximum for the six channel CIO-DDA06).
"""
from __future__ import absolute_import, division, print_function
from builtins import *  # @UnusedWildImport

from ctypes import cast, POINTER, c_ushort
from math import pi, sin
from scipy import signal
from time import sleep

from mcculw import ul
from mcculw.enums import ScanOptions, FunctionType, Status
from mcculw.device_info import DaqDeviceInfo

try:
    from console_examples_util import config_first_detected_device
except ImportError:
    from .console_examples_util import config_first_detected_device

import sys

def shock(lvl):
    verbose = True
    if verbose:
        print(f"Shock with multiplier: {lvl}")
    if lvl > 1.0:
        raise ValueError("Shock multiplier is too large (> 1.0)")
    # By default, the example detects and displays all available devices and
    # selects the first device listed. Use the dev_id_list variable to filter
    # detected devices by device ID (see UL documentation for device IDs).
    # If use_device_detection is set to False, the board_num variable needs to
    # match the desired board number configured with Instacal.
    use_device_detection = True
    dev_id_list = []
    board_num = 0
    memhandle = None

    try:
        if use_device_detection:
            config_first_detected_device(board_num, dev_id_list)

        daq_dev_info = DaqDeviceInfo(board_num)
        if not daq_dev_info.supports_analog_output:
            raise Exception('Error: The DAQ device does not support '
                            'analog output')

        print('\nActive DAQ device: ', daq_dev_info.product_name, ' (',
              daq_dev_info.unique_id, ')\n', sep='')

        ao_info = daq_dev_info.get_ao_info()

        low_chan = 1
        high_chan = 1
        num_chans = high_chan - low_chan + 1

        rate = 1000 # per ms
        points_per_channel = 4 # in ms
        total_count = points_per_channel * num_chans

        ao_range = ao_info.supported_ranges[0]
        print(f"ao_range: {ao_range}") if verbose else None
        print(f"ScanOptions BG: {ScanOptions.BACKGROUND}") if verbose else None  

        # Allocate a buffer for the scan
        memhandle = ul.win_buf_alloc(total_count)
        # Convert the memhandle to a ctypes array
        # Note: the ctypes array will no longer be valid after win_buf_free
        # is called.
        # A copy of the buffer can be created using win_buf_to_array
        # before the memory is freed. The copy can be used at any time.
        ctypes_array = cast(memhandle, POINTER(c_ushort))

        # Check if the buffer was successfully allocated
        if not memhandle:
            raise Exception('Error: Failed to allocate memory')

        frequencies = add_data(board_num, ctypes_array, ao_range,
                                       num_chans, rate, points_per_channel, verbose, multi=1.0)

        for ch_num in range(low_chan, high_chan + 1):
            print('Channel', ch_num, 'Output Signal Frequency:',
                  frequencies[ch_num - low_chan])

        # Start the scan
        ul.a_out_scan(board_num, low_chan, high_chan, total_count, rate,
                      ao_range, memhandle, ScanOptions.BACKGROUND)

        # Wait for the scan to complete
        print('Waiting for output scan to complete...', end='')
        status = Status.RUNNING
        while status != Status.IDLE:
            print('.', end='')

            # Slow down the status check so as not to flood the CPU
            sleep(0.5)

            status, _, _ = ul.get_status(board_num, FunctionType.AOFUNCTION)
        print('')

        print('Scan completed successfully')


    except Exception as e:
        print('\n', e)
    finally:
        if memhandle:
            # Free the buffer in a finally block to prevent a memory leak.
            ul.win_buf_free(memhandle)
        if use_device_detection:
            ul.release_daq_device(board_num)


def add_data(board_num, data_array, ao_range, num_chans, rate,
                     points_per_channel, verbose, multi):
    # Calculate frequencies that will work well with the size of the array
    frequencies = []
    for channel_num in range(num_chans):
        frequencies.append(
            (channel_num + 1) / (points_per_channel / rate))

    # print(points_per_channel / rate)

    frequencies = [250]

    # print(frequencies)

    # Calculate an amplitude and y-offset for the signal
    # to fill the analog output range
    amplitude = (ao_range.range_max - ao_range.range_min) / 2 * multi
    y_offset = (amplitude + ao_range.range_min) / 2

    if amplitude > 5:
        raise ValueError("Amplitude for shock D/A converter is too large (> 5)")

    print(f"amp: {amplitude}; y_offset: {y_offset}") if verbose else None
    val_array = []

    # Fill the array with sine wave data at the calculated frequencies.
    # Note that since we are using the SCALEDATA option, the values
    # added to data_array are the actual voltage values that the device
    # will output
    # J: For this application the data is mostly stagnant as a single sine pulse 
    data_index = 0
    for point_num in range(points_per_channel):
        # print(f"point_num")
        for channel_num in range(num_chans):
            freq = frequencies[channel_num]
            value = amplitude * signal.square(2 * pi * freq * point_num / rate) + y_offset
            val_array.append(value)
            raw_value = ul.from_eng_units(board_num, ao_range, value)
            data_array[data_index] = raw_value
            data_index += 1

    print(f"max: {max(val_array)}; min: {min(val_array)}") if verbose else None
    return frequencies


if __name__ == '__main__':
    level = sys.argv[1]
    if isinstance(level, str)
        level = float(level)
    shock(level)
