#include "caluMD5_utilities.h"
#include "moastdif.h"

// for md 5 hashing
#ifndef _H_MD5Checksum	  
	#include "MD5Checksum.h"
	#include "MD5ChecksumDefines.h"
#endif

int md5Error = 0;

void setFileHashingError(int error){
	md5Error = error;
}

int getFileHashingError(){
	return md5Error;
}
