import os


def returndirectory(directory):
    directory = os.fsencode(directory)
    directorylist = []

    for file in os.listdir(directory):
        filename = os.fsdecode(file)
        #print(filename)
        directorylist.append(filename)
    return directorylist


def printresult(bytesFile, resultsFile, memoryFile, ):
    print("Running " + bytesFile + " test:")

def hasexpected(bytesfile, resultslist):
    name = bytesfile.split('.')[0]
    for file in resultslist:
        #print(file.split('.')[0])
        if name == file.split('.')[0]:
            return file

    return 0

def printStandardStart():
    print("initial")
    print("begin")
    print("""\t$display("Beginning CPU tests!"); """)
    print("\tnumSuccess = 0;\n")

def forLoopForInstructions(numInstructions):
    print("for( int i = 0 ; i < " + str(numInstructions) + " ; i++)")
    print("\tbegin")
    print("\taddressForInstruction = i;")
    print("\t#5;")
    print("\tend\n")

if __name__ =="__main__":
    byteslist = returndirectory("bytecode")
    memlist = returndirectory("final_memory")
    resultslist = returndirectory("results")

    printStandardStart()

    for file in byteslist:
        print("\tfile_name = \"" + file.split('.')[0] + "\" ;")
        print("\tinstruct_read = 1;")

        result = hasexpected(file, memlist)
        if(result != 0):
            print("\t$display(\" Memory should be initialized from " + result + "\");")
            print("\tdata_read = 1;")
        else:
            #does not need to get mem file uploaded
            print("\tdata_read = 0;")
        
        print("\treset = 1;")
        print("\t#15")
        print("\treset = 0;\n")

        numInstructions = len(open("bytecode/" + file).readlines())

        print("\t#{}".format(numInstructions*10))

        result = hasexpected(file, resultslist)
        if(result != 0):
            print("\t$readmemh(\"" + result + "\" ," + "resultFromFile);")
            print("\tif(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin")
            print("\t\tsuccessful_tests[numSuccess ++] = \"" + file + "\";")
            print("\t\t$display(\"Success on Test: %s\", file_name);")
            print("\tend else begin")
            print("\t\t$display(\"Failed on Test: %s\", file_name);")
            print("\t\t$display(\"Expected result : %h \", resultFromFile[0] );")
            print("\t\t$display(\"Found result : %h \", CPU.rFile.gprs[0] );")
            print("\tend")


        print("\tinstruct_read = 0;")
        print("\tdata_read = 0;")
        print("\tresultFromFile[0] = 0;")
        print("\t#5;")
        print()


    print("end")

