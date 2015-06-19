import os
import sys
import fileinput



fileToSearch = "MIPSProcessor.mpf"
text1ToSearch = "C:/Users/Nish Krishnan/Documents/429/MIPS-Processor"
text2ToSearch = "F:/Development/MIPS-Processor"
text3ToSearch = "C:/Development/MIPS-Processor"
textToReplace = "."
for line in fileinput.input(fileToSearch, inplace=True):
	if text1ToSearch in line:
		print(line.replace(text1ToSearch, textToReplace), end='')
	elif text2ToSearch in line:
		print(line.replace(text2ToSearch, textToReplace), end='')
	elif text3ToSearch in line:
		print(line.replace(text3ToSearch, textToReplace), end='')
	else:
		print(line, end='')
	
	