import numpy
import random 

def swap16(x):
	a = numpy.array(x,dtype = numpy.uint16)
	returnValue = a.byteswap(True)
	return returnValue

def swap32(x):
	a = numpy.array(x,dtype = numpy.uint32)
	returnValue = a.byteswap(True)
	return returnValue
def swap64(x):
	a = numpy.array(x,dtype = numpy.uint64)
	returnValue = a.byteswap(True)
	return returnValue

if __name__ == "__main__":

	input_32 = list()
	input_64 = list()

	output_32_16 = list()
	output_32_32 = list()
	output_64_16 = list()
	output_64_32 = list()
	output_64_64 = list()

	numSamples = 500

	for i in range(numSamples): 
		rand_32 = random.getrandbits(32)
		input_32.append(rand_32)
		output_32_16.append(0x00000000|swap16(rand_32&0x0000ffff))
		output_32_32.append(swap32(rand_32))

		rand_64 = random.getrandbits(64)
		input_64.append(rand_64)
		output_64_16.append(0x0000000000000000|swap16(rand_64&0x000000000000ffff))
		output_64_32.append(0x0000000000000000|swap32(rand_64&0x00000000ffffffff))
		output_64_64.append(swap64(rand_64))


	inputFile_32 = 'GV_Input32_ByteSwap.txt'
	inputFile_64 = 'GV_Input64_ByteSwap.txt'

	outputFile_32_16 = 'GV_Output32_16_ByteSwap.txt'
	outputFile_32_32 = 'GV_Output32_32_ByteSwap.txt'

	outputFile_64_16 = 'GV_Output64_16_ByteSwap.txt'
	outputFile_64_32 = 'GV_Output64_32_ByteSwap.txt'
	outputFile_64_64 = 'GV_Output64_64_ByteSwap.txt'

	with open(inputFile_32, 'w') as FID: 
		for input in input_32: 
			FID.write("%d\n" % input)

	with open(inputFile_64, 'w') as FID: 
		for input in input_64: 
			FID.write("%d\n" % input)


	with open(outputFile_32_16, 'w') as FID:
		for output in output_32_16: 
			FID.write("%d\n" % output)

	with open(outputFile_32_32, 'w') as FID:
		for output in output_32_32: 
			FID.write("%d\n" % output)

	with open(outputFile_64_16, 'w') as FID: 
		for output in output_64_16: 
			FID.write("%d\n" % output)

	with open(outputFile_64_32, 'w') as FID: 
		for output in output_64_32: 
			FID.write("%d\n" % output)

	with open(outputFile_64_64, 'w') as FID: 
		for output in output_64_64: 
			FID.write("%d\n" % output)

